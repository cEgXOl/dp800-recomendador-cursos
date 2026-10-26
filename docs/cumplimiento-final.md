# Matriz final de cumplimiento

26 de octubre de 2026. Nivel elegido: **3 avanzado**, con RAG y dos modelos locales.

| Condición | Evidencia entregada |
|---|---|
| Objetivo y caso de negocio | README e informe: recomendación y orientación sobre un catálogo ficticio de cursos. |
| Ejecución local | SQL Server 2025 y Ollama. No hay Azure ni servicios de inferencia de pago. |
| Entorno mínimo | Windows, SQL Server 2025, SSMS 22 y Git comprobados en la auditoría; editor VS Code usado durante el desarrollo. GitHub privado configurado. |
| Bloque A | Tres tablas, PK/FK/CHECK/UNIQUE e índices de restricciones; vistas y procedimientos. CTE, JSON, ROW_NUMBER, consultas correlacionadas y agregación de categorías. Scripts sql/00, 01, 02, 03, 06 y 07. |
| Bloque B | docs/asistencia-ia.md recoge prompts reales, respuestas/código aceptado, errores corregidos y pruebas. |
| Bloque C | sql/08_security.sql: usuarios/roles y permisos GRANT/DENY. sql/09_security_tests.sql demuestra vista permitida, acceso y escritura denegados al lector y modificación permitida al editor con borrado denegado. |
| Bloque D | sql/10_benchmark_baseline.sql y scripts/benchmark.py: treinta pares sobre los mismos datos con igualdad completa de resultados. docs/optimizacion-controlada.md explica planes, costes, lecturas y límites. |
| Bloque E | embeddinggemma 768D; Title + Description + skills/prerequisites; VECTOR(768), modelo y fecha. Generación local en Python. |
| Bloque F | Ranking de distancia coseno, filtros SQL, umbral empírico, caso de paráfrasis y caso sin afinidad. Justificación de la métrica en README. |
| Bloque G | rag.py: pregunta, fuentes SQL, contexto y motivos generados con qwen2.5:1.5b. La interfaz muestra las cuatro etapas. Citas y datos estructurados se validan/componen fuera del modelo. |
| Arquitectura | Diagrama Mermaid en README; diagrama en informe PDF y objetos editables en diapositiva 3. |
| GitHub y secretos | https://github.com/cEgXOl/dp800-course-recommender, privado. Autenticación integrada/variables de entorno y .gitignore; sin contraseñas ni claves en código. |
| README | Problema, nivel, arquitectura, tecnologías, instalación, modelo, funcionalidades, ejemplos, resultados y conclusiones. |
| Scripts desde cero | scripts/setup_database.py crea la base si falta, ejecuta las cargas y los objetos sin borrar datos. sql/00_create_database.sql para creación manual. |
| PDF | output/pdf/informe-dp800.pdf, ocho páginas con modelo, arquitectura, código explicado, seguridad, IA, capturas y resultados. |
| Presentación | presentation/dp800-project.pptx, ocho diapositivas editables; docs/guion-presentacion.md para 5–8 minutos. |
| Reproducción | Base separada CourseRecommender_Repro: 131 embeddings, seguridad y ocho consultas verificadas. evidence/reproduction-validation.json y setup-CourseRecommender_Repro.json. |
| Ejecución visible | docs/evidence/search.png, rag-screen.png, rag-answer.png y rag-context.png; validación HTTP real sin errores JavaScript. |

## Resultados verificados

- Cuatro pruebas unitarias: entrada inválida, abstención sin fuentes, ausencia de precios y salida con citas/datos inválidos.
- Ocho escenarios de recuperación: ranking, nivel básico/avanzado, duración, categoría, combinación, negativo y paráfrasis.
- RAG positivo con fuentes reales; abstención por falta de información de precio y por ausencia de cursos pertinentes.
- Permisos diferenciados comprobados y cambio de identidad revertido en conexiones de la aplicación.
- Benchmark con lecturas lógicas 1.145 -> 331; duración SQL media 1,475 -> 1,164 ms. La mediana ODBC varió muy poco y no se presenta como gran mejora de respuesta.

Las evidencias de búsqueda, permisos y RAG están en `evidence/validation.json`; la comparación y los planes en `evidence/optimization.json`; el ensayo descartado en `evidence/optimization-materialized-trial.json`; la interfaz en `evidence/http-validation.json` y `evidence/ui-rag.json`.

## Entrega por parte del estudiante

El repositorio es privado por elección del usuario. Hay que invitar al profesor o facilitarle un acceso permitido antes de entregar la URL. La exposición y la demostración en directo corresponden al estudiante; los archivos y el guion están preparados. El cumplimiento técnico no implica una calificación anticipada ni ausencia universal de errores del LLM.
