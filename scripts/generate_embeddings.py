"""Generate missing course embeddings locally with Ollama and save them to SQL Server."""

from __future__ import annotations

import json
import math
import os
import sys
import urllib.error
import urllib.request
from typing import Any


MODEL = os.getenv("OLLAMA_EMBED_MODEL", "embeddinggemma")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
EXPECTED_DIMENSIONS = 768
BATCH_SIZE = 8


def get_connection_string() -> str:
    connection_string = os.getenv("COURSE_RECOMMENDER_SQL_CONNECTION_STRING")
    if not connection_string:
        raise RuntimeError(
            "Define COURSE_RECOMMENDER_SQL_CONNECTION_STRING con la conexión a la base de datos."
        )
    return connection_string


def course_text(title: str, description: str, attributes_json: str | None) -> str:
    """Build readable text from the course fields that describe its meaning."""
    parts = [description]
    if attributes_json:
        try:
            attributes: dict[str, Any] = json.loads(attributes_json)
        except (TypeError, json.JSONDecodeError):
            attributes = {}

        skills = attributes.get("skills", [])
        prerequisites = attributes.get("prerequisites", [])
        if skills:
            parts.append("Competencias: " + ", ".join(map(str, skills)))
        if prerequisites:
            parts.append("Prerrequisitos: " + ", ".join(map(str, prerequisites)))
    return f"title: {title} | text: " + "\n".join(parts)


def embed(texts: list[str]) -> list[list[float]]:
    payload = json.dumps({"model": MODEL, "input": texts}).encode("utf-8")
    request = urllib.request.Request(
        f"{OLLAMA_HOST}/api/embed",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            result = json.load(response)
    except urllib.error.URLError as exc:
        raise RuntimeError(
            f"No se pudo conectar con Ollama en {OLLAMA_HOST}. "
            "Comprueba que Ollama esté iniciado y que el modelo esté descargado."
        ) from exc

    vectors = result.get("embeddings")
    if not isinstance(vectors, list) or len(vectors) != len(texts):
        raise RuntimeError("Ollama devolvió una cantidad inesperada de embeddings.")
    for index, vector in enumerate(vectors, start=1):
        if len(vector) != EXPECTED_DIMENSIONS:
            raise RuntimeError(
                f"El vector {index} tiene {len(vector)} dimensiones; "
                f"se esperaban {EXPECTED_DIMENSIONS}."
            )
        if not all(math.isfinite(value) for value in vector):
            raise RuntimeError(f"El vector {index} contiene valores no finitos.")
    return vectors


def main() -> int:
    try:
        import pyodbc
    except ImportError:
        print("Falta pyodbc. Instálalo con: python -m pip install -r requirements.txt", file=sys.stderr)
        return 1

    connection = None
    try:
        connection = pyodbc.connect(get_connection_string())
        cursor = connection.cursor()
        courses = cursor.execute(
            """
            SELECT CourseId, Title, Description, AdditionalAttributes
            FROM dbo.Courses
            WHERE DescriptionEmbedding IS NULL
            ORDER BY CourseId;
            """
        ).fetchall()
        connection.commit()  # Release the read transaction before local inference.

        if not courses:
            print("No hay cursos pendientes: todos tienen embedding.")
            return 0

        total = len(courses)
        for start in range(0, total, BATCH_SIZE):
            batch = courses[start : start + BATCH_SIZE]
            texts = [course_text(row.Title, row.Description, row.AdditionalAttributes) for row in batch]
            vectors = embed(texts)

            for row, vector in zip(batch, vectors, strict=True):
                vector_json = json.dumps(vector, separators=(",", ":"), allow_nan=False)
                cursor.execute(
                    """
                    UPDATE dbo.Courses
                    SET DescriptionEmbedding = CAST(CAST(? AS nvarchar(max)) AS VECTOR(768)),
                        EmbeddingModel = ?,
                        EmbeddingGeneratedAt = SYSUTCDATETIME()
                    WHERE CourseId = ?;
                    """,
                    vector_json,
                    MODEL,
                    row.CourseId,
                )
            print(f"Generados {min(start + len(batch), total)} de {total} embeddings.")

        connection.commit()
        print(f"Listo: {total} embeddings generados con Ollama ({MODEL}, {EXPECTED_DIMENSIONS} dimensiones).")
        return 0
    except Exception as exc:  # Keep the SQL work atomic if any model/API/database step fails.
        if connection is not None:
            connection.rollback()
        print(f"Error al generar embeddings: {exc}", file=sys.stderr)
        return 1
    finally:
        if connection is not None:
            connection.close()


if __name__ == "__main__":
    raise SystemExit(main())
