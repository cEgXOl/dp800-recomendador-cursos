# Desarrollo asistido por IA: trazabilidad

Este registro usa peticiones reales de la conversación y fragmentos del código generado. Las respuestas se resumen cuando eran extensas; no son transcripciones completas. Las evidencias de ejecución se conservan en `docs/evidence/`.

| Prompt real del usuario | Respuesta o código generado | Aceptado | Corregido y verificado |
|---|---|---|---|
| «Yo lo que no quiero es gastar dinero, consumir tokens, etc...» | Sustituir embeddings de Azure por Ollama embeddinggemma local con VECTOR(768). | Inferencia local y mismo modelo para consultas/documentos. | ODBC enviaba ntext; se añadió conversión a nvarchar(max) antes de VECTOR. La generación y la recuperación se ejecutaron sobre los 131 cursos. Los LLM locales sí procesan tokens, pero no hay facturación por API. |
| «quiero que el proyecto tenga una pequeña interfaz visual, nada complejo» | Servidor Python y página con petición y filtros. | Interfaz local con HTML y consultas parametrizadas. | PowerShell bloqueó el lanzador ps1; se documentó el arranque directo con Python. Se guardan capturas y pruebas HTTP de la interfaz final. |
| «Dime varias pruebas a realizar» | Siete casos: semántica, nivel, duración, categoría, negativo y combinación. | Casos manuales y repetición con el catálogo ampliado. | La negativa devolvía cursos; se incorporó distancia máxima 0,70. La validación automatizada actual exige filtros, orden, resultados positivos y abstención. |
| «Pues vamos con el siguiente paso» (medición con Query Store) | SQL para métricas ponderadas y operadores de planes. | Duración, CPU, lecturas y plan como evidencias. | El alias plan era reservado. El filtro de texto podía contar sus propios diagnósticos. Se cambió a object_id del procedimiento y se verificaron deltas por objeto. |
| «Comprueba que el proyecto cumple todas estas condiciones» | Auditoría de los 18 apartados. | Identificar carencias en seguridad, objetos SQL y entregables. | Se corrigió la declaración prematura de entrega completa y se conservó la auditoría inicial. |
| «Añade Rag, y vamos a hacer todo» | Vistas, procedimientos, roles, RAG local y salida estructurada. | LLM qwen2.5:1.5b con contexto de cursos recuperados y validación de IDs. | La primera respuesta tenía citas inconsistentes; la aplicación inserta referencias desde IDs validados. El modelo evitaba responder a ausencia de precios; se añadió abstención explícita porque ese campo no existe en el esquema. Pruebas unitarias y casos reales documentan el comportamiento. |

## Ejemplo de código aceptado y explicación

El procedimiento calcula distancias con `VECTOR_DISTANCE('cosine', c.DescriptionEmbedding, @Vector)`, limita los resultados en una CTE `Selected` y después agrega sus categorías. El modelo relacional aplica los filtros antes de devolver el ranking. La aplicación valida la petición y ejecuta el procedimiento bajo un usuario lector; el LLM no construye ni ejecuta SQL.

## Propuesta de optimización revisada

La primera propuesta materializaba TOP K en una tabla temporal. La medición mostró menos lecturas pero mayor tiempo de SQL y ODBC. Se sustituyó por una CTE con TOP K antes de la agregación. Se compararon treinta llamadas de cada variante con el mismo vector, filtros y 131 cursos, comprobando igualdad de resultados. Las dos mediciones se guardan para mostrar qué se aceptó y qué se descartó.

## Error factual detectado en la generación

Una prueba real del LLM pequeño atribuyó 180 minutos a dos cursos, aunque uno tenía 90. Se rechazó esa forma de redactar datos estructurados: el modelo ahora devuelve solo courseId y un motivo cualitativo, y la aplicación compone título, nivel, duración y citas desde SQL. La validación rechaza identificadores desconocidos y cifras/referencias dentro del motivo libre. Sigue siendo necesaria revisión humana del sentido de la explicación; esta medida no demuestra ausencia de toda alucinación.

## Cómo se verificó

Se aplicaron los scripts repetidamente en la base principal y se creó una base separada para reproducción. Las pruebas comprueban permisos permitidos/denegados, modelo y vectores existentes, filtros, orden, categoría, abstención, citas fuera de contexto y un caso de paráfrasis. El benchmark guarda las métricas reales y el XML de los planes. El informe y la presentación se basan en esos archivos, sin inventar resultados.
