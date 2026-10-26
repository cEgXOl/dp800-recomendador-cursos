# Auditoría de requisitos de entrega

Fecha: 26 de octubre de 2026.

> Auditoría inicial conservada como historial. Los pendientes se abordaron tras la petición de añadir RAG y completar la entrega. El estado actualizado y sus evidencias están en [cumplimiento-final.md](cumplimiento-final.md).

## Dictamen y alcance

El recomendador funciona y cubre el núcleo de embeddings y búsqueda vectorial local, pero todavía no cumple todas las condiciones de entrega del documento «Desarrollo de una solución inteligente con SQL Server 2025». El cierre de las seis fases anteriores describe el prototipo funcional; no acredita por sí mismo el cumplimiento de esta rúbrica completa.

Se revisaron los archivos del proyecto, los scripts, el estado de Git y los programas registrados en Windows. Para los resultados de SQL Server se utilizaron las evidencias y mediciones del 25 de octubre que ya constan en la documentación. Esta auditoría no vuelve a comprobar el contenido de la base en ejecución ni modifica su configuración.

El enunciado permite seleccionar bloques: no exige implementar todas las variantes de IA. RAG es una ampliación avanzada y no hace falta añadirlo para presentar una solución con embeddings y búsqueda semántica. Los requisitos generales de arquitectura, repositorio, README, PDF, presentación y evidencias siguen pendientes aunque se cumpla un bloque técnico.

## Contraste con las condiciones

| Apartado | Estado | Evidencia y trabajo pendiente |
|---|---|---|
| 1. Objetivo | Cubierto técnicamente | Solución local de catálogo inteligente con SQL Server y modelo local. La entrega documental y la presentación aún están incompletas. |
| 2. Escenario | Cumple | Recomendación de cursos por similitud semántica, uno de los escenarios admitidos. |
| 3. Entorno local | Cubierto en lo principal | SQL Server 2025 y SSMS 22.10.2 constan instalados; Git 2.55 está disponible. Windows registra versión 25H2 y build 26200. El desarrollo y las pruebas se realizaron con VS Code. Falta GitHub configurado para este repositorio. |
| 3. Secretos | Cumple en los archivos revisados | Conexión con autenticación integrada y variable de entorno; no se encontraron claves o contraseñas incrustadas. `.gitignore` excluye entornos, cachés y archivos de configuración local. |
| 4. Bloque A: modelo | Cumple | Tres tablas relacionadas, PK, FK, UNIQUE, CHECK, tipos adecuados y catálogo ampliado a 131 cursos. Las restricciones PK/UNIQUE ya generan índices: la ausencia de índices adicionales no implica incumplir ese punto. |
| 4. Bloque A: programación SQL | Pendiente | No hay scripts CREATE VIEW, PROCEDURE, FUNCTION ni TRIGGER. La consulta de recomendación está incluida en Python. Hace falta incorporar objetos de programación adecuados; los ejemplos del enunciado no implican que deban usarse los cuatro tipos. |
| 4. Bloque A: T-SQL avanzado | Cumple | CTE y subconsultas correlacionadas en `app.py`; JSON y ROW_NUMBER en los scripts del catálogo. |
| 4. Bloque B: asistencia de IA | Parcial | Se utilizó IA durante el desarrollo, pero el repositorio no incluye una trazabilidad con prompt, respuesta, partes aceptadas, correcciones y verificación. La conversación por sí sola no queda disponible al descargar el repositorio. |
| 5. Bloque C: seguridad SQL Server | No implementado como bloque | Faltan scripts de usuarios/roles y mecanismos de seguridad con permisos diferenciados y pruebas de acceso. La autenticación integrada, las consultas parametrizadas y el servidor web local no sustituyen la demostración requerida dentro de SQL Server. |
| 6. Bloque D: optimización | Parcial | Hay métricas de Query Store y lectura de operadores. Falta aplicar una mejora y comparar antes/después con el mismo catálogo y condiciones. Aumentar de 31 a 131 cursos es una prueba de escala, no una optimización. Una mejora sin ganancia también puede documentarse, explicando el resultado. |
| 7. Bloque E: embeddings | Cumple | Ollama `embeddinggemma`, 768 dimensiones; texto formado con Title, Description y las listas skills/prerequisites de AdditionalAttributes. Python genera los vectores y los guarda en VECTOR(768), con modelo y fecha. CREATE EXTERNAL MODEL y AI_GENERATE_EMBEDDINGS aparecen como ejemplos, no como obligación exclusiva. |
| 8. Bloque F: Intelligent Search | Funcional; documentación parcial | Petición natural, embedding, ranking por distancia coseno y filtros SQL. Falta justificar por qué se eligió coseno y aportar un ejemplo documentado con paráfrasis/sin coincidencia literal relevante. El umbral 0,70 tiene validación preliminar y no debe presentarse como universal. |
| 9. Bloque G: RAG | Opcional, no implementado | No se genera una respuesta con un LLM y contexto recuperado. No hace falta añadirlo si se declara el alcance de nivel intermedio. |
| 10. Arquitectura | Pendiente | No existe un diagrama de navegador, aplicación Python, Ollama y SQL Server, ni del flujo de carga de embeddings. |
| 11. GitHub | Pendiente | El repositorio Git local no tiene commits ni remotos configurados. Los archivos del proyecto aparecen sin seguimiento. No hay evidencia de publicación en GitHub desde este checkout. |
| 12. README | Parcial | Incluye modelo, archivos, instalación básica y ejecución. Faltan diagrama, tecnologías reunidas, nivel elegido, correspondencia con bloques DP-800, ejemplos con resultados y conclusiones/problemas resueltos. También falta explicar o automatizar la creación de la base desde cero. |
| 13. PDF | Pendiente | No existe informe PDF con portada, arquitectura, modelo, implementación, evidencias y conclusiones. La extensión de 5–10 páginas es una recomendación. |
| 14. Presentación | Pendiente | No existe archivo PowerPoint ni guion de demostración. Los 5–8 minutos y las ocho diapositivas son orientativos. La aplicación sí permite una demostración en directo. |
| 15. Entregables | Parcial | Código y scripts de tablas, datos y vectores presentes. Faltan repositorio publicado, PDF, PowerPoint y creación reproducible de la base de datos. |
| 16. Evaluación | No procede asignar nota | Hay evidencias para diseño, T-SQL e IA. Seguridad/optimización, GitHub y los entregables incompletos afectan a varias áreas. No se puede inferir una calificación sin la evaluación del profesor. |
| 17. Nivel | Pendiente de declarar/completar | La funcionalidad de IA corresponde al objetivo de nivel 2. Para acreditarlo según el esquema del enunciado falta completar seguridad u optimización del nivel 1 y declarar el nivel en README. No corresponde afirmar nivel 3 sin RAG. |
| 18. Evidencias reproducibles | Parcial | Existen pruebas descritas, métricas y un script de validación. Faltan capturas y salidas guardadas dentro del repositorio y una reproducción desde una base nueva. Las imágenes compartidas en el chat no forman parte de la entrega actual. |

## Observaciones técnicas que afectan a la evidencia

1. Los filtros de Query Store en `sql/04_query_store_baseline.sql` y `sql/05_query_store_plan.sql` pueden volver a incluir los diagnósticos: las cadenas `course.DescriptionEmbedding` y `VECTOR_DISTANCE` también aparecen dentro de los literales LIKE de los propios scripts. La modificación anterior no elimina completamente ese falso positivo. Conviene identificar la consulta por el objeto de un procedimiento almacenado o excluir expresamente las consultas a los catálogos de Query Store.
2. La ventana de métricas posterior a la ampliación mezcla ejecuciones con distintos tamaños de catálogo. El documento de línea base ya avisa de ello: esas cifras no sirven como una comparación antes/después controlada de una optimización.
3. `scripts/validate_catalog_scale.py` imprime avisos, pero termina sin fallar si hay resultados incorrectos. Tampoco comprueba explícitamente la categoría devuelta o la calidad del ranking. Sirve como inspección, no como prueba automática completa de todos los criterios.

## Trabajo mínimo para preparar la entrega

1. Añadir objetos SQL útiles, por ejemplo un procedimiento de recomendación y una vista del catálogo.
2. Completar seguridad reproducible con roles/usuarios y permisos, acompañada de consultas que demuestren accesos permitidos y rechazados. Si se selecciona el bloque C, mostrar al menos dos mecanismos del enunciado.
3. Completar el bloque D con una modificación medible sobre la misma consulta y los mismos 131 cursos. Por ejemplo, estudiar si recuperar las categorías después de seleccionar los diez cursos reduce trabajo; medirlo sin prometer una ganancia de antemano.
4. Documentar la asistencia real de IA, los errores corregidos y su validación utilizando la conversación y las evidencias disponibles, sin inventar pruebas ni respuestas.
5. Añadir creación de base, diagrama y README completo, con elección de nivel 2 y justificación de la métrica de similitud. Validar la instalación en una base nueva.
6. Guardar evidencias en `docs/`, elaborar el PDF y el PowerPoint, y preparar el guion de demostración.
7. Crear commits y publicar el repositorio en GitHub con los entregables y sin secretos.

No se han implementado estas correcciones como parte de la auditoría: el resultado de esta revisión es identificar el estado real frente a las condiciones recibidas.
