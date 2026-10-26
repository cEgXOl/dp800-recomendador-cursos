/*
    Recomendador de cursos por intereses
    Fase 2: catálogo de prueba ampliado.

    La carga es repetible: añade solo categorías y cursos que no existan ya
    por nombre/título y relaciones curso-temática que falten. No actualiza ni
    elimina datos existentes.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Categories (CategoryName, Description)
    SELECT seed.CategoryName, seed.Description
    FROM (VALUES
        (N'SQL', N'Consultas, modelado y administración de bases de datos relacionales.'),
        (N'Análisis de datos', N'Análisis, limpieza e interpretación de datos.'),
        (N'Power BI', N'Modelos semánticos, informes y visualización con Power BI.'),
        (N'Azure', N'Servicios de datos y analítica en Microsoft Azure.'),
        (N'Python', N'Programación y análisis de datos con Python.'),
        (N'Administración de bases de datos', N'Operación, mantenimiento, copias de seguridad y alta disponibilidad de bases de datos.'),
        (N'Ingeniería de datos', N'Integración, transformación y orquestación de flujos de datos.'),
        (N'Microsoft Fabric', N'Analítica e ingeniería de datos con Microsoft Fabric.'),
        (N'Aprendizaje automático', N'Preparación de datos y fundamentos de modelos de aprendizaje automático.'),
        (N'Seguridad de datos', N'Permisos, protección y auditoría de datos y bases de datos.')
    ) AS seed(CategoryName, Description)
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Categories AS existing
        WHERE existing.CategoryName = seed.CategoryName
    );

    INSERT INTO dbo.Courses
        (Title, Description, Level, DurationMinutes, AdditionalAttributes)
    SELECT seed.Title, seed.Description, seed.Level, seed.DurationMinutes,
           seed.AdditionalAttributes
    FROM (VALUES
        (N'Fundamentos de SQL para análisis de ventas',
         N'Aprende a consultar tablas de ventas con SELECT, filtros, agrupaciones y JOIN para responder preguntas habituales del negocio.',
         'Beginner', 180,
         N'{"skills":["SELECT","WHERE","GROUP BY","JOIN"],"prerequisites":[]}'),
        (N'T-SQL intermedio: CTE y funciones de ventana',
         N'Resuelve análisis por periodos y comparaciones entre filas con CTE, funciones de ventana y expresiones T-SQL.',
         'Intermediate', 240,
         N'{"skills":["CTE","OVER","ROW_NUMBER","LAG"],"prerequisites":["SQL básico"]}'),
        (N'Diseño de bases de datos relacionales',
         N'Diseña tablas normalizadas, claves primarias y foráneas, restricciones y relaciones para aplicaciones de datos.',
         'Beginner', 210,
         N'{"skills":["modelado relacional","normalización","claves"],"prerequisites":[]}'),
        (N'Power BI: primeros informes de ventas',
         N'Conecta datos de ventas, crea visualizaciones y construye un informe interactivo para explorar resultados comerciales.',
         'Beginner', 150,
         N'{"skills":["Power BI","visualización","informes"],"prerequisites":[]}'),
        (N'Modelado de datos y DAX en Power BI',
         N'Crea modelos semánticos con relaciones y medidas DAX para analizar ventas por fecha, producto y región.',
         'Intermediate', 300,
         N'{"skills":["modelo semántico","DAX","relaciones"],"prerequisites":["Power BI básico"]}'),
        (N'Introducción a Python para análisis de datos',
         N'Usa Python y pandas para cargar, limpiar, resumir y explorar conjuntos de datos tabulares.',
         'Beginner', 240,
         N'{"skills":["Python","pandas","limpieza de datos"],"prerequisites":[]}'),
        (N'Integración de datos en Azure',
         N'Conoce los conceptos de integración y transformación de datos en servicios de Azure para construir flujos analíticos.',
         'Intermediate', 270,
         N'{"skills":["Azure","integración de datos","ETL"],"prerequisites":["conceptos de bases de datos"]}'),
        (N'Optimización de consultas SQL Server',
         N'Interpreta planes de ejecución e índices y aplica técnicas para mejorar consultas de lectura en SQL Server.',
         'Advanced', 360,
         N'{"skills":["planes de ejecución","índices","rendimiento"],"prerequisites":["T-SQL intermedio"]}'),
        (N'SQL básico para filtrar y resumir datos',
         N'Practica consultas sencillas para buscar registros, ordenar resultados y calcular totales por cliente o producto.',
         'Beginner', 90,
         N'{"skills":["SELECT","ORDER BY","filtros","agregaciones"],"prerequisites":[]}'),
        (N'Consultas SQL para inventario y logística',
         N'Combina existencias, pedidos y envíos para detectar roturas de stock y medir tiempos de entrega.',
         'Intermediate', 210,
         N'{"skills":["JOIN","GROUP BY","inventario","logística"],"prerequisites":["SQL básico"]}'),
        (N'T-SQL avanzado: procedimientos y transacciones',
         N'Construye procedimientos almacenados seguros y controla operaciones con transacciones, TRY CATCH y manejo de errores.',
         'Advanced', 330,
         N'{"skills":["procedimientos almacenados","transacciones","TRY CATCH"],"prerequisites":["T-SQL intermedio"]}'),
        (N'Funciones de ventana para tendencias de ventas',
         N'Calcula acumulados, rankings y variaciones entre meses para explicar la evolución de ventas sin perder el detalle de cada fila.',
         'Intermediate', 180,
         N'{"skills":["SUM OVER","RANK","LAG","series temporales"],"prerequisites":["SQL básico"]}'),
        (N'Introducción a la administración de SQL Server',
         N'Revisa configuración básica, usuarios, trabajos, mantenimiento y supervisión de una instancia de SQL Server.',
         'Beginner', 240,
         N'{"skills":["SQL Server","administración","supervisión"],"prerequisites":[]}'),
        (N'Copias de seguridad y restauración en SQL Server',
         N'Planifica copias completas, diferenciales y de log, y practica la restauración para cumplir objetivos de recuperación.',
         'Intermediate', 180,
         N'{"skills":["backup","restore","recuperación"],"prerequisites":["conceptos básicos de SQL Server"]}'),
        (N'Seguridad y permisos en bases de datos',
         N'Aplica el principio de mínimo privilegio con usuarios, roles, permisos y separación de responsabilidades.',
         'Intermediate', 150,
         N'{"skills":["permisos","roles","seguridad de datos"],"prerequisites":["bases de datos relacionales"]}'),
        (N'Excel y SQL para preparar informes',
         N'Compara el análisis en hojas de cálculo con consultas SQL y prepara resultados consistentes para informes periódicos.',
         'Beginner', 120,
         N'{"skills":["Excel","SQL","informes"],"prerequisites":[]}'),
        (N'Power BI para analizar finanzas',
         N'Construye indicadores de ingresos, gastos y margen, y explora desviaciones frente al presupuesto con informes interactivos.',
         'Beginner', 180,
         N'{"skills":["Power BI","finanzas","KPI"],"prerequisites":[]}'),
        (N'DAX intermedio: contexto de filtro y tiempo',
         N'Comprende el contexto de evaluación y crea medidas para comparar periodos, acumulados anuales y crecimiento interanual.',
         'Advanced', 240,
         N'{"skills":["DAX","contexto de filtro","inteligencia temporal"],"prerequisites":["modelado de datos y DAX"]}'),
        (N'Python para limpiar datos de clientes',
         N'Detecta valores ausentes, formatos inconsistentes y duplicados en datos de clientes con pandas.',
         'Beginner', 150,
         N'{"skills":["Python","pandas","calidad de datos"],"prerequisites":[]}'),
        (N'Análisis exploratorio con Python',
         N'Explora distribuciones, relaciones y valores atípicos para formular hipótesis antes de crear un modelo analítico.',
         'Intermediate', 240,
         N'{"skills":["Python","pandas","visualización","estadística descriptiva"],"prerequisites":["Python básico"]}'),
        (N'Introducción al aprendizaje automático',
         N'Conoce clasificación y regresión, prepara variables y evalúa modelos sencillos con ejemplos de predicción de demanda.',
         'Intermediate', 300,
         N'{"skills":["machine learning","clasificación","regresión"],"prerequisites":["Python básico","estadística básica"]}'),
        (N'Pipelines de datos en Azure Data Factory',
         N'Orquesta la copia y transformación de datos desde distintas fuentes mediante pipelines, actividades y disparadores.',
         'Intermediate', 300,
         N'{"skills":["Azure Data Factory","pipelines","ETL","orquestación"],"prerequisites":[]}'),
        (N'Azure SQL Database: fundamentos',
         N'Aprende a aprovisionar y consultar una base de datos SQL administrada en Azure, y entiende sus opciones de conectividad.',
         'Beginner', 180,
         N'{"skills":["Azure SQL","Azure","T-SQL"],"prerequisites":["SQL básico"]}'),
        (N'Introducción a Microsoft Fabric y OneLake',
         N'Explora los elementos principales de Microsoft Fabric y cómo OneLake unifica el acceso a datos analíticos.',
         'Beginner', 120,
         N'{"skills":["Microsoft Fabric","OneLake","analítica"],"prerequisites":[]}'),
        (N'Ingeniería de datos con Fabric Lakehouse',
         N'Organiza datos en un lakehouse, carga archivos y transforma tablas para su consumo analítico en Microsoft Fabric.',
         'Intermediate', 270,
         N'{"skills":["Fabric","Lakehouse","Spark","transformación"],"prerequisites":["conceptos de ingeniería de datos"]}'),
        (N'Introducción a Azure Databricks y Spark',
         N'Procesa conjuntos de datos grandes con notebooks y transformaciones distribuidas usando Apache Spark en Azure Databricks.',
         'Intermediate', 360,
         N'{"skills":["Azure Databricks","Spark","notebooks","datos distribuidos"],"prerequisites":["SQL o Python básico"]}'),
        (N'Calidad y gobierno de datos',
         N'Define reglas de calidad, responsables, metadatos y procesos de seguimiento para mejorar la confianza en los datos.',
         'Intermediate', 210,
         N'{"skills":["calidad de datos","gobierno","metadatos"],"prerequisites":[]}'),
        (N'Query Store y diagnóstico de rendimiento',
         N'Usa Query Store para observar consultas, detectar regresiones y comparar planes de ejecución en SQL Server.',
         'Advanced', 180,
         N'{"skills":["Query Store","rendimiento","planes de ejecución"],"prerequisites":["administración de SQL Server"]}'),
        (N'Índices y planes de ejecución en SQL Server',
         N'Interpreta operadores de planes y elige índices para reducir lecturas y mejorar consultas de reporting.',
         'Advanced', 240,
         N'{"skills":["índices","planes de ejecución","tuning"],"prerequisites":["T-SQL intermedio"]}'),
        (N'Introducción a embeddings y búsqueda semántica',
         N'Entiende cómo representar texto con embeddings y comparar descripciones para recuperar contenido relacionado por significado.',
         'Beginner', 150,
         N'{"skills":["embeddings","búsqueda semántica","vectores"],"prerequisites":[]}'),
        (N'Modelado de datos para un catálogo de cursos',
         N'Diseña un catálogo con cursos, temáticas y relaciones, y aplica claves y restricciones para mantener la integridad.',
         'Beginner', 120,
         N'{"skills":["modelado relacional","claves foráneas","integridad"],"prerequisites":[]}')
    ) AS seed(Title, Description, Level, DurationMinutes, AdditionalAttributes)
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Courses AS existing
        WHERE existing.Title = seed.Title
    );

    INSERT INTO dbo.CourseCategories (CourseId, CategoryId)
    SELECT course.CourseId, category.CategoryId
    FROM (VALUES
        (N'Fundamentos de SQL para análisis de ventas', N'SQL'),
        (N'Fundamentos de SQL para análisis de ventas', N'Análisis de datos'),
        (N'T-SQL intermedio: CTE y funciones de ventana', N'SQL'),
        (N'T-SQL intermedio: CTE y funciones de ventana', N'Análisis de datos'),
        (N'Diseño de bases de datos relacionales', N'SQL'),
        (N'Power BI: primeros informes de ventas', N'Power BI'),
        (N'Power BI: primeros informes de ventas', N'Análisis de datos'),
        (N'Modelado de datos y DAX en Power BI', N'Power BI'),
        (N'Modelado de datos y DAX en Power BI', N'Análisis de datos'),
        (N'Introducción a Python para análisis de datos', N'Python'),
        (N'Introducción a Python para análisis de datos', N'Análisis de datos'),
        (N'Integración de datos en Azure', N'Azure'),
        (N'Integración de datos en Azure', N'SQL'),
        (N'Optimización de consultas SQL Server', N'SQL'),
        (N'SQL básico para filtrar y resumir datos', N'SQL'),
        (N'Consultas SQL para inventario y logística', N'SQL'),
        (N'Consultas SQL para inventario y logística', N'Análisis de datos'),
        (N'T-SQL avanzado: procedimientos y transacciones', N'SQL'),
        (N'Funciones de ventana para tendencias de ventas', N'SQL'),
        (N'Funciones de ventana para tendencias de ventas', N'Análisis de datos'),
        (N'Introducción a la administración de SQL Server', N'Administración de bases de datos'),
        (N'Introducción a la administración de SQL Server', N'SQL'),
        (N'Copias de seguridad y restauración en SQL Server', N'Administración de bases de datos'),
        (N'Copias de seguridad y restauración en SQL Server', N'SQL'),
        (N'Seguridad y permisos en bases de datos', N'Seguridad de datos'),
        (N'Seguridad y permisos en bases de datos', N'Administración de bases de datos'),
        (N'Excel y SQL para preparar informes', N'SQL'),
        (N'Excel y SQL para preparar informes', N'Análisis de datos'),
        (N'Power BI para analizar finanzas', N'Power BI'),
        (N'Power BI para analizar finanzas', N'Análisis de datos'),
        (N'DAX intermedio: contexto de filtro y tiempo', N'Power BI'),
        (N'DAX intermedio: contexto de filtro y tiempo', N'Análisis de datos'),
        (N'Python para limpiar datos de clientes', N'Python'),
        (N'Python para limpiar datos de clientes', N'Análisis de datos'),
        (N'Análisis exploratorio con Python', N'Python'),
        (N'Análisis exploratorio con Python', N'Aprendizaje automático'),
        (N'Introducción al aprendizaje automático', N'Python'),
        (N'Introducción al aprendizaje automático', N'Aprendizaje automático'),
        (N'Pipelines de datos en Azure Data Factory', N'Azure'),
        (N'Pipelines de datos en Azure Data Factory', N'Ingeniería de datos'),
        (N'Azure SQL Database: fundamentos', N'Azure'),
        (N'Azure SQL Database: fundamentos', N'SQL'),
        (N'Introducción a Microsoft Fabric y OneLake', N'Microsoft Fabric'),
        (N'Introducción a Microsoft Fabric y OneLake', N'Ingeniería de datos'),
        (N'Ingeniería de datos con Fabric Lakehouse', N'Microsoft Fabric'),
        (N'Ingeniería de datos con Fabric Lakehouse', N'Ingeniería de datos'),
        (N'Introducción a Azure Databricks y Spark', N'Azure'),
        (N'Introducción a Azure Databricks y Spark', N'Ingeniería de datos'),
        (N'Calidad y gobierno de datos', N'Análisis de datos'),
        (N'Calidad y gobierno de datos', N'Ingeniería de datos'),
        (N'Query Store y diagnóstico de rendimiento', N'SQL'),
        (N'Query Store y diagnóstico de rendimiento', N'Administración de bases de datos'),
        (N'Índices y planes de ejecución en SQL Server', N'SQL'),
        (N'Índices y planes de ejecución en SQL Server', N'Administración de bases de datos'),
        (N'Introducción a embeddings y búsqueda semántica', N'Aprendizaje automático'),
        (N'Introducción a embeddings y búsqueda semántica', N'Análisis de datos'),
        (N'Modelado de datos para un catálogo de cursos', N'SQL'),
        (N'Modelado de datos para un catálogo de cursos', N'Análisis de datos')
    ) AS seed(Title, CategoryName)
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
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Resumen para revisar la carga y detectar títulos repetidos o datos incompletos.
SELECT
    (SELECT COUNT(*) FROM dbo.Courses) AS TotalCourses,
    (SELECT COUNT(*) FROM dbo.Categories) AS TotalCategories,
    (SELECT COUNT(*) FROM dbo.CourseCategories) AS CourseCategoryLinks;

SELECT Title, COUNT(*) AS DuplicateCount
FROM dbo.Courses
GROUP BY Title
HAVING COUNT(*) > 1;

SELECT CourseId, Title
FROM dbo.Courses
WHERE NULLIF(LTRIM(RTRIM(Title)), N'') IS NULL
   OR NULLIF(LTRIM(RTRIM(Description)), N'') IS NULL
   OR DurationMinutes <= 0;

SELECT course.CourseId, course.Title
FROM dbo.Courses AS course
LEFT JOIN dbo.CourseCategories AS link
    ON link.CourseId = course.CourseId
WHERE link.CourseId IS NULL;
GO
