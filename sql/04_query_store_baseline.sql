/*
    Recomendador de cursos por intereses
    Fase 5: inspección de Query Store para la consulta de recomendaciones.

    Solo lectura. Primero muestra el estado de Query Store y, si está activo,
    resume las ejecuciones capturadas para la consulta etiquetada en app.py.
    Duración y CPU se muestran en milisegundos; lecturas lógicas en páginas de 8 KB.
*/

SET NOCOUNT ON;
GO

SELECT
    actual_state_desc AS QueryStoreState,
    readonly_reason AS ReadOnlyReason,
    current_storage_size_mb AS CurrentStorageMB,
    max_storage_size_mb AS MaxStorageMB,
    interval_length_minutes AS IntervalMinutes
FROM sys.database_query_store_options;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.database_query_store_options
    WHERE actual_state = 0
)
BEGIN
    PRINT 'Query Store está desactivado. Para activarlo, ejecuta (con permisos ALTER DATABASE):';
    PRINT 'ALTER DATABASE [CourseRecommender] SET QUERY_STORE = ON;';
END
ELSE IF EXISTS
(
    SELECT 1
    FROM sys.query_store_query AS queryInfo
    WHERE queryInfo.object_id = OBJECT_ID(N'dbo.usp_RecommendCourses')
)
BEGIN
    SELECT
        query.query_id AS QueryId,
        qsPlan.plan_id AS PlanId,
        SUM(stats.count_executions) AS ExecutionCount,
        CAST
        (
            SUM(stats.avg_duration * stats.count_executions)
            / NULLIF(SUM(stats.count_executions), 0)
            / 1000.0
            AS decimal(18, 3)
        ) AS WeightedAvgDurationMs,
        CAST
        (
            SUM(stats.avg_cpu_time * stats.count_executions)
            / NULLIF(SUM(stats.count_executions), 0)
            / 1000.0
            AS decimal(18, 3)
        ) AS WeightedAvgCpuMs,
        CAST
        (
            SUM(stats.avg_logical_io_reads * stats.count_executions)
            / NULLIF(SUM(stats.count_executions), 0)
            AS decimal(18, 2)
        ) AS WeightedAvgLogicalReads,
        MIN(stats.first_execution_time) AS FirstExecution,
        MAX(stats.last_execution_time) AS LastExecution,
        text.query_sql_text AS CapturedSql
    FROM sys.query_store_query_text AS text
    INNER JOIN sys.query_store_query AS query
        ON query.query_text_id = text.query_text_id
    INNER JOIN sys.query_store_plan AS qsPlan
        ON qsPlan.query_id = query.query_id
    INNER JOIN sys.query_store_runtime_stats AS stats
        ON stats.plan_id = qsPlan.plan_id
    WHERE query.object_id = OBJECT_ID(N'dbo.usp_RecommendCourses')
      AND stats.execution_type = 0
    GROUP BY query.query_id, qsPlan.plan_id, text.query_sql_text
    ORDER BY LastExecution DESC, qsPlan.plan_id;
END
ELSE
BEGIN
    PRINT 'Query Store está activo, pero no ha capturado la consulta de recomendación.';
    PRINT 'Reinicia app.py, actualiza la página y ejecuta una búsqueda; después vuelve a ejecutar este script.';
END;
GO
