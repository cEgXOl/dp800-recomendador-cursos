/*
    Recomendador de cursos por intereses
    Fase 1: modelo relacional del catálogo.

    Ejecutable más de una vez: cada objeto se crea solo si no existe.
    No elimina ni modifica objetos existentes.
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories
    (
        CategoryId   int IDENTITY(1,1) NOT NULL,
        CategoryName nvarchar(100) NOT NULL,
        Description  nvarchar(500) NULL,

        CONSTRAINT PK_Categories PRIMARY KEY (CategoryId),
        CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName)
    );
END;
GO

IF OBJECT_ID(N'dbo.Courses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Courses
    (
        CourseId           int IDENTITY(1,1) NOT NULL,
        Title              nvarchar(200) NOT NULL,
        Description        nvarchar(max) NOT NULL,
        Level              varchar(20) NOT NULL,
        DurationMinutes    int NOT NULL,
        AdditionalAttributes nvarchar(max) NULL,

        CONSTRAINT PK_Courses PRIMARY KEY (CourseId),
        CONSTRAINT CK_Courses_Level
            CHECK (Level IN ('Beginner', 'Intermediate', 'Advanced')),
        CONSTRAINT CK_Courses_DurationMinutes
            CHECK (DurationMinutes > 0),
        CONSTRAINT CK_Courses_AdditionalAttributes_Json
            CHECK (AdditionalAttributes IS NULL OR ISJSON(AdditionalAttributes) = 1)
    );
END;
GO

IF OBJECT_ID(N'dbo.CourseCategories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CourseCategories
    (
        CourseId   int NOT NULL,
        CategoryId int NOT NULL,

        CONSTRAINT PK_CourseCategories PRIMARY KEY (CourseId, CategoryId),
        CONSTRAINT FK_CourseCategories_Courses
            FOREIGN KEY (CourseId) REFERENCES dbo.Courses (CourseId),
        CONSTRAINT FK_CourseCategories_Categories
            FOREIGN KEY (CategoryId) REFERENCES dbo.Categories (CategoryId)
    );
END;
GO

-- Comprobaciones básicas de que los tres objetos esperados existen.
IF OBJECT_ID(N'dbo.Courses', N'U') IS NULL
   OR OBJECT_ID(N'dbo.Categories', N'U') IS NULL
   OR OBJECT_ID(N'dbo.CourseCategories', N'U') IS NULL
BEGIN
    THROW 50001, 'No se crearon todas las tablas del esquema del catálogo.', 1;
END;
GO
