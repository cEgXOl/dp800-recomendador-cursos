-- Ejecutar en master. No elimina una base existente.
IF DB_ID(N'CourseRecommender') IS NULL
    CREATE DATABASE [CourseRecommender];
GO
