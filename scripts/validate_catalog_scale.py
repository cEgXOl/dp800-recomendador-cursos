"""Inspect catalog size and run the seven recommendation cases after expansion."""

from __future__ import annotations

import pyodbc
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from app import connection_string, get_categories, recommend

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def main() -> None:
    with pyodbc.connect(connection_string(), timeout=10) as connection:
        counts = connection.cursor().execute(
            """
            SELECT
                COUNT_BIG(*) AS TotalCourses,
                SUM(CASE WHEN JSON_VALUE(AdditionalAttributes, '$.source') = 'synthetic_scale_test' THEN 1 ELSE 0 END) AS SyntheticCourses,
                SUM(CASE WHEN DescriptionEmbedding IS NULL THEN 1 ELSE 0 END) AS PendingEmbeddings
            FROM dbo.Courses;
            """
        ).fetchone()
    print(
        f"Catálogo: {counts.TotalCourses} cursos; "
        f"{counts.SyntheticCourses} sintéticos; "
        f"{counts.PendingEmbeddings} embeddings pendientes."
    )

    sql_category = next(
        category["id"] for category in get_categories() if category["name"] == "SQL"
    )
    cases = [
        ("1. Búsqueda semántica", {"query": "Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos"}),
        ("2. Nivel principiante", {"query": "Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos", "level": "Beginner"}),
        ("3. Nivel avanzado", {"query": "Quiero aprender a analizar ventas con SQL y tengo conocimientos básicos", "level": "Advanced"}),
        ("4. Duración máxima", {"query": "Quiero aprender a crear informes y paneles de datos", "maxDuration": 120}),
        ("5. Temática SQL", {"query": "Quiero consultar y transformar datos relacionales", "categoryId": sql_category}),
        ("6. Consulta sin afinidad", {"query": "Quiero aprender diseño de moda"}),
        ("7. Filtros combinados", {"query": "Quiero aprender a automatizar el análisis de datos", "level": "Beginner", "maxDuration": 180}),
    ]

    for label, payload in cases:
        results = recommend(payload)
        print(f"\n{label}: {len(results)} resultados")
        for result in results[:3]:
            print(
                f"  - {result['title']} | {result['level']} | "
                f"{result['durationMinutes']} min | distancia {result['cosineDistance']}"
            )
        if payload.get("level") and any(result["level"] != payload["level"] for result in results):
            print("  AVISO: se encontró un nivel que no coincide con el filtro.")
        max_duration = payload.get("maxDuration")
        if max_duration and any(result["durationMinutes"] > max_duration for result in results):
            print("  AVISO: se encontró una duración superior al máximo.")
        if label.startswith("6.") and results:
            print("  AVISO: la consulta sin afinidad ha devuelto cursos.")


if __name__ == "__main__":
    main()
