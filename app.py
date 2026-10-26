"""Small local web UI for semantic course recommendations."""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from contextlib import contextmanager

import pyodbc


ROOT = Path(__file__).resolve().parent
WEB_DIR = ROOT / "web"
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
MODEL = os.getenv("OLLAMA_EMBED_MODEL", "embeddinggemma")
PORT = int(os.getenv("COURSE_RECOMMENDER_PORT", "8000"))
VECTOR_DIMENSIONS = 768
# Umbral inicial calibrado con el catálogo de prueba (menor distancia = mayor afinidad).
MAX_COSINE_DISTANCE = 0.70
MAX_REQUEST_BYTES = 16_384


def connection_string() -> str:
    value = os.getenv("COURSE_RECOMMENDER_SQL_CONNECTION_STRING")
    if not value:
        raise RuntimeError("Falta COURSE_RECOMMENDER_SQL_CONNECTION_STRING.")
    return value


@contextmanager
def database_connection():
    """Use the demonstrator reader identity, reverting before returning to the pool."""
    connection = pyodbc.connect(connection_string(), timeout=10)
    impersonated = False
    try:
        connection.execute("EXECUTE AS USER = 'CourseReaderDemo';")
        impersonated = True
        yield connection
    finally:
        try:
            if impersonated:
                connection.execute('REVERT;')
        finally:
            connection.close()


def embed_query(query: str) -> list[float]:
    payload = json.dumps({
        "model": MODEL,
        "input": f"task: search result | query: {query.strip()}",
    }).encode("utf-8")
    request = urllib.request.Request(
        f"{OLLAMA_HOST}/api/embed",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.URLError as exc:
        raise RuntimeError("No se pudo conectar con Ollama en localhost:11434.") from exc

    embeddings = result.get("embeddings")
    if not embeddings or len(embeddings[0]) != VECTOR_DIMENSIONS:
        raise RuntimeError(f"Ollama no devolvió un vector de {VECTOR_DIMENSIONS} dimensiones.")
    return embeddings[0]


def get_categories() -> list[dict[str, Any]]:
    with database_connection() as connection:
        rows = connection.cursor().execute(
            "SELECT CategoryId, CategoryName FROM dbo.vCategories ORDER BY CategoryName;"
        ).fetchall()
    return [{"id": row.CategoryId, "name": row.CategoryName} for row in rows]


def recommend(payload: dict[str, Any]) -> list[dict[str, Any]]:
    query = str(payload.get("query", "")).strip()
    if not query:
        raise ValueError("Escribe qué quieres aprender para buscar cursos.")
    if len(query) > 2000:
        raise ValueError("La búsqueda no puede superar los 2000 caracteres.")

    level = payload.get("level") or None
    if level not in (None, "Beginner", "Intermediate", "Advanced"):
        raise ValueError("El nivel seleccionado no es válido.")

    max_duration = payload.get("maxDuration")
    if max_duration in (None, ""):
        max_duration = None
    else:
        try:
            max_duration = int(max_duration)
        except (TypeError, ValueError) as exc:
            raise ValueError("La duración máxima debe ser un número de minutos.") from exc
        if max_duration < 1 or max_duration > 100_000:
            raise ValueError("La duración máxima debe estar entre 1 y 100000 minutos.")

    category_id = payload.get("categoryId") or None
    if category_id not in (None, ""):
        try:
            category_id = int(category_id)
        except (TypeError, ValueError) as exc:
            raise ValueError("La temática seleccionada no es válida.") from exc
        if category_id < 1:
            raise ValueError("La temática seleccionada no es válida.")
    else:
        category_id = None

    vector_json = json.dumps(embed_query(query), separators=(",", ":"), allow_nan=False)
    sql = 'EXEC dbo.usp_RecommendCourses @QueryEmbeddingJson=?, @EmbeddingModel=?, @Level=?, @MaxDuration=?, @CategoryId=?, @TopK=?, @MaxDistance=?;'
    params = (
        vector_json,
        MODEL,
        level, max_duration, category_id, 10, MAX_COSINE_DISTANCE,
    )
    with database_connection() as connection:
        rows = connection.cursor().execute(sql, params).fetchall()

    return [
        {
            "id": row.CourseId,
            "title": row.Title,
            "description": row.Description,
            "level": row.Level,
            "durationMinutes": row.DurationMinutes,
            "categories": row.CategoryNames or "Sin temática",
            "categoryIds": [int(value) for value in (row.CategoryIds or '').split(',') if value],
            "cosineDistance": round(float(row.CosineDistance), 4),
        }
        for row in rows
    ]


class RequestHandler(BaseHTTPRequestHandler):
    def _send(self, status: int, content_type: str, body: bytes) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(body)

    def _send_json(self, status: int, value: Any) -> None:
        self._send(status, "application/json; charset=utf-8", json.dumps(value, ensure_ascii=False).encode("utf-8"))

    def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
        if self.path == "/":
            try:
                page = (WEB_DIR / "index.html").read_bytes()
            except OSError:
                self._send_json(500, {"error": "No se encontró web/index.html."})
                return
            self._send(200, "text/html; charset=utf-8", page)
        elif self.path == "/api/categories":
            try:
                self._send_json(200, {"categories": get_categories()})
            except Exception as exc:
                self._send_json(500, {"error": str(exc)})
        else:
            self._send_json(404, {"error": "Ruta no encontrada."})

    def do_POST(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
        if self.path not in ("/api/recommend", "/api/rag"):
            self._send_json(404, {"error": "Ruta no encontrada."})
            return
        try:
            size = int(self.headers.get("Content-Length", "0"))
            if size < 1 or size > MAX_REQUEST_BYTES:
                raise ValueError("La solicitud está vacía o es demasiado grande.")
            payload = json.loads(self.rfile.read(size))
            if not isinstance(payload, dict):
                raise ValueError("Formato de solicitud no válido.")
            results = recommend(payload)
            if self.path == '/api/rag':
                from rag import generate_answer
                response = generate_answer(str(payload['query']).strip(), results)
                response['results'] = results
                self._send_json(200, response)
            else:
                self._send_json(200, {"results": results})
        except ValueError as exc:
            self._send_json(400, {"error": str(exc)})
        except Exception as exc:
            self._send_json(500, {"error": str(exc)})

    def log_message(self, format: str, *args: object) -> None:
        print(f"[{self.log_date_time_string()}] {format % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer(("127.0.0.1", PORT), RequestHandler)
    print(f"Recomendador de cursos disponible en http://127.0.0.1:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor detenido.")
    finally:
        server.server_close()
