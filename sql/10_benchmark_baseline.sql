-- Consulta inicial: agrega categorias de candidatos antes del TOP, como el SQL original.
-- Solo para comparacion controlada; no la usa la aplicacion.
CREATE OR ALTER PROCEDURE dbo.usp_RecommendCoursesBaseline
    @QueryEmbeddingJson nvarchar(max),
    @EmbeddingModel varchar(100) = 'embeddinggemma',
    @Level varchar(20) = NULL,
    @MaxDuration int = NULL,
    @CategoryId int = NULL,
    @TopK int = 10,
    @MaxDistance float = 0.70
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Vector VECTOR(768) = CAST(@QueryEmbeddingJson AS VECTOR(768));
    SELECT TOP (@TopK) c.CourseId, c.Title, c.Description, c.Level, c.DurationMinutes,
           a.CategoryNames, a.CategoryIds,
           VECTOR_DISTANCE('cosine', c.DescriptionEmbedding, @Vector) AS CosineDistance
    FROM dbo.Courses AS c
    OUTER APPLY
    (
        SELECT STRING_AGG(cat.CategoryName, N', ') WITHIN GROUP (ORDER BY cat.CategoryName) AS CategoryNames,
               STRING_AGG(CONVERT(varchar(12),cat.CategoryId), ',') WITHIN GROUP (ORDER BY cat.CategoryName) AS CategoryIds
        FROM dbo.CourseCategories AS cc
        JOIN dbo.Categories AS cat ON cat.CategoryId=cc.CategoryId
        WHERE cc.CourseId=c.CourseId
    ) AS a
    WHERE c.DescriptionEmbedding IS NOT NULL AND c.EmbeddingModel=@EmbeddingModel
      AND (@Level IS NULL OR c.Level=@Level)
      AND (@MaxDuration IS NULL OR c.DurationMinutes<=@MaxDuration)
      AND (@CategoryId IS NULL OR EXISTS
          (SELECT 1 FROM dbo.CourseCategories AS f WHERE f.CourseId=c.CourseId AND f.CategoryId=@CategoryId))
      AND VECTOR_DISTANCE('cosine',c.DescriptionEmbedding,@Vector)<=@MaxDistance
    ORDER BY CosineDistance,c.CourseId;
END;
GO
