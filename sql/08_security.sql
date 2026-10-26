-- Dos mecanismos: roles/usuarios y permisos explicitos GRANT/DENY (minimo privilegio).
-- Usuarios WITHOUT LOGIN: demostracion local reproducible, sin contrasenas en Git.
IF DATABASE_PRINCIPAL_ID(N'CourseReader') IS NULL CREATE ROLE CourseReader AUTHORIZATION dbo;
IF DATABASE_PRINCIPAL_ID(N'CourseEditor') IS NULL CREATE ROLE CourseEditor AUTHORIZATION dbo;
IF DATABASE_PRINCIPAL_ID(N'CourseReaderDemo') IS NULL CREATE USER CourseReaderDemo WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'CourseEditorDemo') IS NULL CREATE USER CourseEditorDemo WITHOUT LOGIN;
ALTER ROLE CourseReader ADD MEMBER CourseReaderDemo;
ALTER ROLE CourseEditor ADD MEMBER CourseEditorDemo;
GRANT SELECT ON OBJECT::dbo.vCategories TO CourseReader;
GRANT SELECT ON OBJECT::dbo.vCourseCatalog TO CourseReader;
GRANT EXECUTE ON OBJECT::dbo.usp_RecommendCourses TO CourseReader;
DENY SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.Courses TO CourseReader;
GRANT SELECT ON OBJECT::dbo.vCategories TO CourseEditor;
GRANT SELECT ON OBJECT::dbo.vCourseCatalog TO CourseEditor;
GRANT SELECT, INSERT, UPDATE ON OBJECT::dbo.Courses TO CourseEditor;
DENY DELETE ON OBJECT::dbo.Courses TO CourseEditor;
GO
