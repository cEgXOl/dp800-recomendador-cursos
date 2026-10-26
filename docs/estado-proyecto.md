# Estado final del miniproyecto

> Actualizado el 26 de octubre de 2026: solución de nivel 3 con RAG local, seguridad, optimización controlada, reproducción y entregables. Consulta [la matriz final de cumplimiento](cumplimiento-final.md). La auditoría inicial se conserva como historial.

## Objetivo

Recomendar hasta diez cursos del catálogo a partir de una petición en lenguaje natural, ordenados por afinidad semántica y limitados opcionalmente por nivel, duración y temática.

## Fases

| Fase | Estado | Resultado |
|---|---|---|
| 1. Diseño del modelo | Completa | Tablas `Courses`, `Categories` y `CourseCategories`, con PK, FK, restricciones y atributos adicionales JSON. |
| 2. Catálogo de prueba | Completa | 31 cursos iniciales y 100 cursos sintéticos de escala, en 10 categorías; carga repetible y enlaces de categoría. |
| 3. Embeddings | Completa | 131 embeddings generados localmente con Ollama `embeddinggemma`, 768 dimensiones, guardados como `VECTOR(768)`. Sin llamadas de pago a Azure OpenAI. |
| 4. Motor e interfaz | Completa | Procedimiento SQL con ranking y filtros, vistas de lectura y RAG local con fuentes/contexto visibles. |
| 5. Pruebas y rendimiento | Completa | Cuatro pruebas unitarias, ocho escenarios de recuperación, RAG, permisos diferenciados y reproducción en otra base. Benchmark de treinta pares con igualdad de resultados y métricas por object_id. |
| 6. Documentación | Completa | README reproducible, asistencia de IA, arquitectura, evidencias, informe PDF de ocho páginas y PowerPoint de ocho diapositivas. Repositorio GitHub privado. |

## Decisiones y límites

- La generación de embeddings es local con Ollama para evitar costes de API y consumo de tokens facturables.
- Se usa el mismo modelo para los cursos y las consultas: `embeddinggemma` con 768 dimensiones.
- La búsqueda compara los vectores almacenados en SQL Server y devuelve hasta diez cursos; los que superan distancia 0,70 se descartan.
- El umbral 0,70 es empírico y debe volver a evaluarse si cambia el catálogo o el modelo.
- La medición de Query Store cubre SQL Server. No incluye la generación del embedding en Ollama ni el tiempo total percibido en el navegador.
- El catálogo de 131 cursos permite una prueba de escala moderada, pero no permite afirmar cómo escalará el sistema a miles de cursos.

## Ejecución de la demostración

1. Inicia Ollama y SQL Server.
2. En PowerShell, desde la carpeta del proyecto, define `COURSE_RECOMMENDER_SQL_CONNECTION_STRING` si no está definida en la sesión.
3. Inicia la interfaz con `.\.venv\Scripts\python.exe app.py`.
4. Abre `http://127.0.0.1:8000` y prueba una consulta en español con los filtros.
5. Para detener el servidor, pulsa `Ctrl+C` en PowerShell.

La ampliación y repetición de las siete pruebas ya están realizadas. No se añadieron índices: con 131 cursos, el recorrido completo del catálogo sigue siendo razonable.

La optimización final se realizó sobre la consulta: TOP K antes de agregar categorías mediante CTE. Redujo las lecturas de 1.145 a 331 por llamada en la medición controlada. Las métricas antiguas por intervalos de la línea base histórica no se utilizan para atribuir esta mejora.
