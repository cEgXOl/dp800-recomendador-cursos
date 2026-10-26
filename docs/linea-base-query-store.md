# Línea base de rendimiento: Query Store

> Historial de las mediciones del 25 de octubre. La comparación controlada final del 26 de octubre se documenta en [optimizacion-controlada.md](optimizacion-controlada.md), con deltas de Query Store por procedimiento. Las conclusiones de ausencia de optimización de este registro corresponden al prototipo inicial.

Medición tomada el 25 de octubre de 2026 en la base local `CourseRecommender`. La primera captura se hizo con el catálogo inicial de 31 cursos.

| Métrica | Valor |
|---|---:|
| Estado de Query Store | `READ_WRITE` |
| Intervalo de agregación | 60 minutos |
| Query ID / Plan ID | 65 / 5 |
| Planes capturados | 1 |
| Ejecuciones | 19 |
| Duración media ponderada | 17,613 ms |
| CPU media ponderada | 16,105 ms |
| Lecturas lógicas medias | 174,47 páginas de 8 KB (aprox. 1,36 MiB) |
| Primera / última ejecución registrada | 12:36 / 13:16 UTC |

## Interpretación

- La consulta SQL tarda alrededor de 18 ms de media en este entorno y con este catálogo; es una referencia inicial, no una garantía de rendimiento con más cursos.
- Query Store agrupa la consulta parametrizada en un único plan aunque cambien los valores de búsqueda y filtros.
- Las métricas cubren la ejecución dentro de SQL Server. No incluyen el tiempo que Ollama tarda en generar el embedding de la petición ni el tiempo total percibido en el navegador.
- Con 31 cursos no hay evidencia para añadir índices u optimizar el plan todavía. Conviene conservar esta línea base, ampliar el catálogo y repetir la medición antes de comparar cambios.

Consulta capturada: búsqueda semántica parametrizada sobre `dbo.Courses`, `VECTOR_DISTANCE('cosine', ...)`, asociación de categorías y filtros opcionales de nivel, duración y temática. La consulta de diagnóstico está en `sql/04_query_store_baseline.sql`.

## Lectura del plan capturado

El plan 5 tiene estos operadores relevantes:

- `Clustered Index Scan` sobre `dbo.Courses` (nodo 5), con unas 8,94 filas estimadas. Para calcular la afinidad semántica se evalúan los cursos candidatos del catálogo; recorrer 31 filas es razonable en esta escala.
- `TopN Sort` (nodo 0), que mantiene los diez resultados con menor distancia coseno.
- `Clustered Index Seek` sobre `dbo.CourseCategories` y `dbo.Categories` (nodos 13 y 14), que recupera los nombres de las temáticas usando las claves existentes.
- `Compute Scalar`, agregación y `Nested Loops` soportan el cálculo/proyección de la distancia y la agregación de categorías.

Las filas estimadas y el coste del plan son estimaciones del optimizador, no mediciones reales por operador. Con el tamaño actual no se justifica cambiar índices ni el plan. El script de inspección está en `sql/05_query_store_plan.sql`.

## Ampliación de escala

Se añadieron 100 cursos sintéticos marcados con `source=synthetic_scale_test` y se generaron sus embeddings en local. La base quedó con 131 cursos y cero embeddings pendientes. El script `scripts/validate_catalog_scale.py` volvió a ejecutar los siete casos: los filtros se respetaron y la consulta sin afinidad no devolvió resultados.

En Query Store la consulta de la aplicación siguió asociada al Query ID 65 y al Plan ID 5. En el intervalo UTC 13:00–14:00 se observaron 11 ejecuciones, 20,829 ms de duración media, 19,742 ms de CPU y 287,18 lecturas lógicas medias. Ese intervalo contiene actividad anterior y posterior a la ampliación, por lo que no permite atribuir la diferencia solo al crecimiento del catálogo. Es una observación de escala, no una comparación controlada. El plan sigue usando un recorrido de `Courses`, razonable para 131 filas.
