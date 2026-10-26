/*
    Recomendador de cursos por intereses
    Fase 5: inspección del plan capturado en Query Store.

    Solo lectura. Resume los operadores del plan de la consulta de recomendaciones.
    Identifica la consulta por object_id del procedimiento; evita falsos positivos.
*/

SET NOCOUNT ON;
GO

-- Metadatos y XML del plan capturado.
SELECT
    qsQuery.query_id AS QueryId,
    qsPlan.plan_id AS PlanId,
    qsPlan.engine_version AS EngineVersion,
    qsPlan.compatibility_level AS CompatibilityLevel,
    qsPlan.count_compiles AS CompileCount,
    CAST(qsPlan.avg_compile_duration / 1000.0 AS decimal(18, 3)) AS AvgCompileMs,
    qsPlan.is_forced_plan AS IsForcedPlan,
    qsPlan.query_plan AS QueryPlanXml
FROM sys.query_store_query_text AS queryText
INNER JOIN sys.query_store_query AS qsQuery
    ON qsQuery.query_text_id = queryText.query_text_id
INNER JOIN sys.query_store_plan AS qsPlan
    ON qsPlan.query_id = qsQuery.query_id
WHERE qsQuery.object_id = OBJECT_ID(N'dbo.usp_RecommendCourses')
ORDER BY qsQuery.query_id, qsPlan.plan_id;
GO

-- Resumen legible de los operadores del plan (el XML completo está en el primer resultado).
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
SELECT DISTINCT
    qsQuery.query_id AS QueryId,
    qsPlan.plan_id AS PlanId,
    relOp.value('@NodeId', 'int') AS NodeId,
    relOp.value('@PhysicalOp', 'nvarchar(100)') AS PhysicalOperator,
    relOp.value('@LogicalOp', 'nvarchar(100)') AS LogicalOperator,
    relOp.value('@EstimateRows', 'float') AS EstimatedRows,
    relOp.value('@EstimatedTotalSubtreeCost', 'float') AS EstimatedSubtreeCost
FROM sys.query_store_query_text AS queryText
INNER JOIN sys.query_store_query AS qsQuery
    ON qsQuery.query_text_id = queryText.query_text_id
INNER JOIN sys.query_store_plan AS qsPlan
    ON qsPlan.query_id = qsQuery.query_id
CROSS APPLY (SELECT TRY_CONVERT(xml, qsPlan.query_plan) AS PlanXml) AS planData
CROSS APPLY planData.PlanXml.nodes('//sp:RelOp') AS operators(relOp)
WHERE qsQuery.object_id = OBJECT_ID(N'dbo.usp_RecommendCourses')
ORDER BY qsQuery.query_id, qsPlan.plan_id, NodeId;
GO
