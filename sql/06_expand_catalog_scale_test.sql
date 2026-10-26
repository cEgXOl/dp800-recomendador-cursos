/*
    Ampliación opcional de catálogo para una prueba de escala moderada.
    Añade 100 cursos sintéticos (el catálogo pasará de 31 a 131 en una carga inicial).
    Idempotente: no inserta títulos existentes y no duplica relaciones.
    Tras ejecutarlo, genera embeddings locales con scripts/generate_embeddings.py.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Seed TABLE
(
    CategoryName nvarchar(100) NOT NULL,
    Title nvarchar(200) NOT NULL,
    Description nvarchar(max) NOT NULL,
    AdditionalAttributes nvarchar(max) NOT NULL
);

INSERT INTO @Seed (CategoryName, Title, Description, AdditionalAttributes)
VALUES
    (N'SQL', N'Consultas para segmentar clientes', N'Construye consultas con filtros y agrupaciones para comparar compras, frecuencia y valor por segmento.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'JOIN de ventas, clientes y productos', N'Relaciona tablas transaccionales y detecta filas sin correspondencia mediante consultas de unión.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'CTE para análisis de inventario', N'Descompón consultas de stock y calcula disponibilidad por almacén y producto.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Funciones de ventana para evolución mensual', N'Calcula acumulados, posiciones y variación entre periodos conservando el detalle de cada fila.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Procedimientos de carga con validaciones', N'Valida parámetros y registra resultados de una carga de datos mediante procedimientos T-SQL.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Transacciones para actualizar pedidos', N'Agrupa cambios relacionados con BEGIN TRAN, COMMIT y ROLLBACK para conservar consistencia.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Consultas JSON para atributos de productos', N'Lee y filtra propiedades JSON en SQL Server y combínalas con columnas relacionales.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Tablas temporales para seguir cambios', N'Consulta versiones históricas y reconstruye el estado de una fila con tablas temporales.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Paginación eficiente de resultados SQL', N'Diseña consultas con OFFSET y FETCH para presentar catálogos grandes por páginas.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'SQL', N'Búsqueda semántica con vectores en SQL Server', N'Compara embeddings con VECTOR_DISTANCE y analiza cómo afecta la distancia al ranking.', N'{"skills":["SQL"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Limpieza de datos de pedidos', N'Detecta nulos, duplicados y formatos inconsistentes antes de calcular indicadores de entregas.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Rentabilidad por producto y canal', N'Combina ingresos, costes y descuentos para comparar márgenes entre productos y canales.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Indicadores de conversión comercial', N'Define tasas de conversión desde visitas hasta ventas y valida numeradores y denominadores.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Cohortes de retención de clientes', N'Agrupa clientes por fecha de alta y compara su actividad a lo largo del tiempo.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Estacionalidad en series de ventas', N'Separa tendencia y estacionalidad para interpretar cambios recurrentes en ventas mensuales.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Anomalías en consumos operativos', N'Identifica valores inusuales respecto a patrones históricos y prepara alertas para su revisión.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Perfilado estadístico de columnas', N'Resume distribuciones, valores distintos y proporción de nulos de un conjunto de datos.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Rotación de inventario y cobertura', N'Calcula rotación y días de cobertura para localizar existencias lentas o riesgo de agotamiento.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Campañas con grupos de control', N'Compara resultados entre grupos y revisa tamaños de muestra y sesgos de selección.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Análisis de datos', N'Narrativa para comunicar hallazgos', N'Convierte resultados analíticos en mensajes claros, gráficos adecuados y recomendaciones.', N'{"skills":["Análisis de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Modelo estrella para ventas minoristas', N'Organiza hechos y dimensiones de ventas, fechas y productos para facilitar filtros y agregaciones.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Medidas DAX de margen y descuento', N'Crea medidas para margen neto y descuentos con el contexto de filtro del modelo.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Cardinalidad y dirección de relaciones', N'Configura relaciones entre tablas y diagnostica ambigüedades que alteran los resultados.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Seguridad por filas para regiones', N'Filtra datos por usuario y región con roles RLS y valida el acceso desde el modelo.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Transformaciones reutilizables en Power Query', N'Limpia columnas y crea pasos parametrizados para repetir la preparación de ficheros.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Actualización incremental de modelos', N'Configura particiones por fecha para refrescar solo los datos recientes.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Diagnóstico de informes con Performance Analyzer', N'Localiza visuales lentos y separa el tiempo de consulta del renderizado.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Navegación de informes con marcadores', N'Diseña páginas, botones y marcadores para guiar la exploración de indicadores.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Inteligencia temporal con DAX', N'Compara ventas con periodos anteriores y construye acumulados sobre un calendario.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Power BI', N'Publicación gobernada de espacios de trabajo', N'Organiza permisos, aplicaciones y ciclos de publicación para compartir informes.', N'{"skills":["Power BI"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Migración de bases SQL a Azure SQL', N'Evalúa compatibilidad y dependencias antes de trasladar una base relacional a Azure SQL.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Escalado de Azure SQL Database', N'Selecciona niveles de servicio y dimensiona recursos según concurrencia y carga.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Analítica con Azure Synapse', N'Combina almacenamiento analítico y consultas distribuidas para explorar datos empresariales.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Almacenamiento en Azure Data Lake', N'Organiza ficheros analíticos en zonas y define formatos que facilitan su consumo.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Supervisión con Azure Monitor', N'Configura métricas y alertas para detectar problemas de disponibilidad y recursos.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Identidades administradas para datos', N'Reduce secretos en aplicaciones usando identidades administradas para acceder a datos.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Conectividad privada para servicios de datos', N'Diseña redes privadas y reglas de acceso para reducir la exposición de bases.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Control del gasto en plataformas Azure', N'Revisa consumo, etiquetas y presupuestos para identificar recursos sobredimensionados.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Continuidad de Azure SQL ante interrupciones', N'Planifica replicación y recuperación ante desastres con objetivos RPO y RTO.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Azure', N'Orquestación de cargas en servicios Azure', N'Programa dependencias, parámetros y reintentos para ejecutar cargas entre servicios.', N'{"skills":["Azure"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Agregación de pedidos con pandas', N'Agrupa transacciones por cliente y producto para calcular cantidades, medias y totales.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Conciliación de ficheros con pandas', N'Une ficheros de distintas fuentes y detecta registros que faltan o no coinciden.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Visualización exploratoria con Matplotlib', N'Representa tendencias y distribuciones con gráficos que ayudan a revisar datos.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Informes CSV automatizados con Python', N'Lee datos tabulares, aplica transformaciones y exporta informes repetibles.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Extracción de datos desde API REST', N'Consume endpoints HTTP, gestiona respuestas JSON y prepara registros para análisis.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Calendarios y zonas horarias con pandas', N'Normaliza fechas, zonas horarias y calendarios para analizar eventos en periodos coherentes.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Pruebas automáticas para datos tabulares', N'Comprueba rangos, esquemas y reglas de calidad con validaciones repetibles.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Conexión a SQL Server desde Python', N'Consulta SQL Server desde pyodbc y convierte resultados para el análisis.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Procesamiento por lotes de ficheros grandes', N'Divide ficheros voluminosos en bloques para procesarlos con memoria limitada.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Python', N'Cuadernos reproducibles de análisis', N'Organiza parámetros y transformaciones para que otro analista pueda repetir el análisis.', N'{"skills":["Python"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Mantenimiento de índices y estadísticas', N'Programa mantenimiento y comprueba cómo las estadísticas actualizadas afectan a los planes.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Diagnóstico de bloqueos y deadlocks', N'Interpreta sesiones bloqueadas y grafos de interbloqueo para localizar conflictos.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Alta disponibilidad con Always On', N'Revisa grupos de disponibilidad y valida objetivos de continuidad del servicio.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Gestión de archivos y espacio de datos', N'Supervisa crecimiento de archivos y planifica capacidad para evitar falta de espacio.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Automatización con SQL Server Agent', N'Programa trabajos, pasos y alertas para tareas administrativas recurrentes.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Eventos extendidos para diagnóstico', N'Captura eventos del motor para analizar errores y consultas lentas.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Planes de recuperación RPO y RTO', N'Relaciona copias y restauraciones con objetivos de pérdida y tiempo de recuperación.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Gestión de logins y credenciales', N'Administra identidades de instancia, logins y mapeos de usuarios de base de datos.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Verificación de restauraciones periódicas', N'Comprueba integridad y tiempos de recuperación mediante ejercicios programados.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Administración de bases de datos', N'Control de cambios de esquema', N'Planifica despliegues, revisiones y vuelta atrás para cambios en bases compartidas.', N'{"skills":["Administración de bases de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Cargas incrementales para almacenes', N'Carga filas nuevas o modificadas y mantiene una marca de agua de ejecución.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Procesos ETL con control de errores', N'Diseña extracción, transformación y carga con registro de errores y reintentos.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Orquestación de dependencias de datos', N'Coordina tareas con dependencias, calendarios y condiciones de éxito.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Captura de cambios para integrar sistemas', N'Propaga modificaciones entre sistemas sin recargar todos los datos del origen.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Contratos de esquema en la ingesta', N'Valida nombres y tipos de campos antes de aceptar datos externos.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Arquitectura de zonas para un lago', N'Separa datos originales, depurados y listos para consumo analítico.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Procesamiento diario de ficheros por lotes', N'Ingiere entregas periódicas, controla duplicados y registra el estado de ficheros.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Calidad de datos en pipelines', N'Aplica reglas de completitud, unicidad y consistencia durante transformaciones.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Observabilidad y reintentos de pipelines', N'Registra duración y fallos para recuperar cargas degradadas.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Ingeniería de datos', N'Modelo dimensional para un data warehouse', N'Construye hechos y dimensiones para consultas históricas de ventas y operaciones.', N'{"skills":["Ingeniería de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Lakehouse con tablas Delta', N'Carga ficheros en un lakehouse y organiza tablas Delta para consultas analíticas.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Consultas de almacén con Fabric Warehouse', N'Crea tablas y consultas SQL en un almacén integrado con Microsoft Fabric.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Transformaciones con Dataflows Gen2', N'Prepara datos con pasos visuales reutilizables y publica resultados en Fabric.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Pipelines de orquestación en Fabric', N'Coordina actividades, parámetros y dependencias en pipelines de Fabric.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Notebooks Spark para transformar datos', N'Usa notebooks y operaciones distribuidas para depurar tablas analíticas.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Acceso compartido a OneLake', N'Organiza rutas y accesos a datos compartidos en elementos de Fabric.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Modelos semánticos con Direct Lake', N'Conecta modelos semánticos a datos de Fabric mediante el modo Direct Lake.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Permisos y gobierno en workspaces Fabric', N'Define roles de espacio y permisos para compartir activos analíticos.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Analítica de eventos en tiempo real con Fabric', N'Explora eventos, filtra flujos y prepara vistas de análisis casi en tiempo real.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Microsoft Fabric', N'Supervisión de capacidad de Fabric', N'Interpreta consumo de capacidad y planifica cargas para evitar saturación.', N'{"skills":["Microsoft Fabric"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Regresión para estimar ingresos de clientes', N'Entrena un modelo con variables históricas y evalúa el error de las predicciones.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Clasificación de abandono de clientes', N'Prepara variables para estimar qué clientes podrían dejar de utilizar un servicio.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Segmentación de clientes con clustering', N'Agrupa perfiles por comportamiento y describe diferencias entre segmentos.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Ingeniería de variables para modelos', N'Transforma variables categóricas, fechas y valores numéricos para el aprendizaje.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Validación cruzada y métricas de clasificación', N'Compara precisión, recall y otras métricas con particiones repetibles.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Predicción de demanda estacional', N'Construye predicciones considerando tendencias, calendario y variaciones de temporada.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Detección de fraude en transacciones', N'Evalúa clasificadores con datos desbalanceados y analiza falsos positivos.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Interpretabilidad de predicciones', N'Explica contribuciones de variables y revisa predicciones concretas.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Evaluación de sesgo en datos y modelos', N'Compara resultados entre grupos y revisa riesgos de sesgo.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Aprendizaje automático', N'Despliegue y seguimiento de modelos', N'Registra versiones y métricas para supervisar modelos en producción.', N'{"skills":["Aprendizaje automático"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Auditoría de accesos a SQL Server', N'Registra accesos y operaciones para revisar quién consultó o modificó datos.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Cifrado transparente de datos', N'Protege archivos de base de datos en reposo y revisa certificados.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Enmascaramiento de información personal', N'Limita la exposición de valores sensibles en resultados.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Seguridad por filas con políticas T-SQL', N'Restringe las filas visibles según usuario o contexto de sesión.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Secretos seguros para integraciones', N'Evita contraseñas incrustadas en código y aplica rotación de credenciales.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Evaluación de vulnerabilidades de bases', N'Revisa configuraciones y permisos para identificar superficies de riesgo.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Clasificación de datos sensibles', N'Etiqueta columnas personales o financieras para orientar su protección.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Compartición segura de datos analíticos', N'Prepara conjuntos compartidos aplicando controles de acceso y minimización.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Cifrado de copias de seguridad', N'Protege archivos de backup y valida los requisitos de recuperación de claves.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}'),
    (N'Seguridad de datos', N'Revisión de cuentas privilegiadas', N'Audita roles elevados y cuentas sin uso para reducir privilegios.', N'{"skills":["Seguridad de datos"],"prerequisites":[],"source":"synthetic_scale_test"}');

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS
    (
        SELECT 1
        FROM @Seed AS seed
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Categories AS category
            WHERE category.CategoryName = seed.CategoryName
        )
    )
        THROW 50006, 'Falta alguna categoría. Ejecuta primero sql/02_seed_catalog.sql.', 1;

    ;WITH NumberedCourses AS
    (
        SELECT
            seed.*,
            ROW_NUMBER() OVER (ORDER BY seed.CategoryName, seed.Title) AS SequenceNumber
        FROM @Seed AS seed
    )
    INSERT INTO dbo.Courses (Title, Description, Level, DurationMinutes, AdditionalAttributes)
    SELECT
        seed.Title,
        seed.Description,
        CASE seed.SequenceNumber % 3
            WHEN 0 THEN 'Beginner'
            WHEN 1 THEN 'Intermediate'
            ELSE 'Advanced'
        END,
        90 + (seed.SequenceNumber % 10) * 30,
        seed.AdditionalAttributes
    FROM NumberedCourses AS seed
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Courses AS existing
        WHERE existing.Title = seed.Title
    );

    INSERT INTO dbo.CourseCategories (CourseId, CategoryId)
    SELECT course.CourseId, category.CategoryId
    FROM @Seed AS seed
    INNER JOIN dbo.Courses AS course
        ON course.Title = seed.Title
    INNER JOIN dbo.Categories AS category
        ON category.CategoryName = seed.CategoryName
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.CourseCategories AS existing
        WHERE existing.CourseId = course.CourseId
          AND existing.CategoryId = category.CategoryId
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT
    COUNT(*) AS TotalCourses,
    SUM(CASE WHEN JSON_VALUE(AdditionalAttributes, '$.source') = N'synthetic_scale_test' THEN 1 ELSE 0 END) AS SyntheticScaleCourses,
    SUM(CASE WHEN DescriptionEmbedding IS NULL THEN 1 ELSE 0 END) AS PendingEmbeddings
FROM dbo.Courses;
