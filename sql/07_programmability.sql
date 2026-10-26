SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER VIEW dbo.vCategories
AS
SELECT CategoryId, CategoryName FROM dbo.Categories;
GO
CREATE OR ALTER VIEW dbo.vCourseCatalog
AS
SELECT c.CourseId, c.Title, c.Description, c.Level, c.DurationMinutes,
       JSON_VALUE(c.AdditionalAttributes, '$.source') AS DataSource,
       a.CategoryNames
FROM dbo.Courses AS c
OUTER APPLY
(
    SELECT STRING_AGG(cat.CategoryName, N', ') WITHIN GROUP (ORDER BY cat.CategoryName) AS CategoryNames
    FROM dbo.CourseCategories AS cc
    JOIN dbo.Categories AS cat ON cat.CategoryId = cc.CategoryId
    WHERE cc.CourseId = c.CourseId
) AS a;
GO
CREATE OR ALTER PROCEDURE dbo.usp_RecommendCourses
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
    IF @QueryEmbeddingJson IS NULL OR ISJSON(@QueryEmbeddingJson, ARRAY) <> 1
        THROW 50010, 'El embedding debe ser un array JSON.', 1;
    IF @Level IS NOT NULL AND @Level NOT IN ('Beginner','Intermediate','Advanced')
        THROW 50011, 'Nivel no valido.', 1;
    IF @TopK IS NULL OR @TopK NOT BETWEEN 1 AND 10
        THROW 50012, 'TopK debe estar entre 1 y 10.', 1;
    IF @MaxDistance IS NULL OR @MaxDistance NOT BETWEEN 0 AND 2
        THROW 50013, 'Distancia no valida.', 1;
    IF @MaxDuration IS NOT NULL AND @MaxDuration <= 0
        THROW 50014, 'Duracion no valida.', 1;
    IF @CategoryId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryId=@CategoryId)
        THROW 50015, 'Categoria no valida.', 1;

    DECLARE @Vector VECTOR(768) = CAST(@QueryEmbeddingJson AS VECTOR(768));
    -- TOP K dentro de una CTE limita el agregado de categorias sin tabla temporal.
    ;WITH Distances AS
    (
        SELECT c.CourseId, c.Title, c.Description, c.Level, c.DurationMinutes,
               VECTOR_DISTANCE('cosine', c.DescriptionEmbedding, @Vector) AS CosineDistance
        FROM dbo.Courses AS c
        WHERE c.DescriptionEmbedding IS NOT NULL AND c.EmbeddingModel = @EmbeddingModel
          AND (@Level IS NULL OR c.Level = @Level)
          AND (@MaxDuration IS NULL OR c.DurationMinutes <= @MaxDuration)
          AND (@CategoryId IS NULL OR EXISTS
              (SELECT 1 FROM dbo.CourseCategories AS f WHERE f.CourseId=c.CourseId AND f.CategoryId=@CategoryId))
    ), Selected AS
    (
        SELECT TOP (@TopK) *
        FROM Distances
        WHERE CosineDistance <= @MaxDistance
        ORDER BY CosineDistance, CourseId
    )
    SELECT s.CourseId, s.Title, s.Description, s.Level, s.DurationMinutes,
           a.CategoryNames, a.CategoryIds, s.CosineDistance
    FROM Selected AS s
    OUTER APPLY
    (
        SELECT STRING_AGG(cat.CategoryName, N', ') WITHIN GROUP (ORDER BY cat.CategoryName) AS CategoryNames,
               STRING_AGG(CONVERT(varchar(12),cat.CategoryId), ',') WITHIN GROUP (ORDER BY cat.CategoryName) AS CategoryIds
        FROM dbo.CourseCategories AS cc
        JOIN dbo.Categories AS cat ON cat.CategoryId=cc.CategoryId
        WHERE cc.CourseId=s.CourseId
    ) AS a
    ORDER BY s.CosineDistance, s.CourseId;
END;
GO
