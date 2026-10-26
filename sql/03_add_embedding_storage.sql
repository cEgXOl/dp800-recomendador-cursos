/*
    Recomendador de cursos por intereses
    Fase 3: preparar almacenamiento para embeddings.

    Modelo local del prototipo: Ollama embeddinggemma, 768 dimensiones,
    representación VECTOR float32 de SQL Server 2025.
    Ejecutable más de una vez; no reemplaza ni recalcula vectores existentes.
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NULL
    THROW 50002, 'No existe dbo.Courses. Ejecuta primero el esquema del catálogo.', 1;
GO

-- Evita mezclar espacios vectoriales o dejar una dimensión antigua sin detectar.
IF EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Courses')
      AND name = N'DescriptionEmbedding'
      AND vector_dimensions <> 768
)
    THROW 50003, 'DescriptionEmbedding ya existe con otra dimensión. Revisa la columna antes de continuar.', 1;
GO

IF COL_LENGTH(N'dbo.Courses', N'DescriptionEmbedding') IS NULL
BEGIN
    ALTER TABLE dbo.Courses
        ADD DescriptionEmbedding VECTOR(768) NULL;
END;
GO

IF COL_LENGTH(N'dbo.Courses', N'EmbeddingModel') IS NULL
BEGIN
    ALTER TABLE dbo.Courses
        ADD EmbeddingModel varchar(100) NULL;
END;
GO

IF COL_LENGTH(N'dbo.Courses', N'EmbeddingGeneratedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Courses
        ADD EmbeddingGeneratedAt datetime2(0) NULL;
END;
GO

-- Comprueba que la columna vectorial y los campos de trazabilidad estén disponibles.
SELECT
    c.name AS ColumnName,
    TYPE_NAME(c.user_type_id) AS DataType,
    c.is_nullable AS IsNullable
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID(N'dbo.Courses')
  AND c.name IN (N'DescriptionEmbedding', N'EmbeddingModel', N'EmbeddingGeneratedAt')
ORDER BY c.column_id;
GO
