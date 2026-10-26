SET NOCOUNT ON;
DECLARE @Denied bit = 0;
EXECUTE AS USER = 'CourseReaderDemo';
SELECT USER_NAME() AS EffectiveUser, COUNT(*) AS VisibleCourses FROM dbo.vCourseCatalog;
BEGIN TRY
    EXEC(N'SELECT TOP (1) DescriptionEmbedding FROM dbo.Courses;');
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 229 BEGIN REVERT; THROW; END;
    SET @Denied = 1;
    SELECT ERROR_NUMBER() AS ExpectedError, N'Reader no puede leer la tabla base' AS Result;
END CATCH;
REVERT;
IF @Denied = 0 THROW 50020, 'Reader obtuvo acceso no autorizado.', 1;

SET @Denied = 0;
EXECUTE AS USER = 'CourseReaderDemo';
BEGIN TRY
    EXEC(N'UPDATE dbo.Courses SET DurationMinutes=DurationMinutes WHERE CourseId=-1;');
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 229 BEGIN REVERT; THROW; END;
    SET @Denied = 1;
    SELECT ERROR_NUMBER() AS ExpectedError, N'Reader no puede editar' AS Result;
END CATCH;
REVERT;
IF @Denied = 0 THROW 50021, 'Reader obtuvo permiso de escritura.', 1;

BEGIN TRANSACTION;
EXECUTE AS USER = 'CourseEditorDemo';
UPDATE dbo.Courses SET DurationMinutes=DurationMinutes WHERE CourseId=(SELECT MIN(CourseId) FROM dbo.Courses);
SELECT USER_NAME() AS EffectiveUser, @@ROWCOUNT AS UpdatedRows;
REVERT;
ROLLBACK TRANSACTION;

SET @Denied = 0;
EXECUTE AS USER = 'CourseEditorDemo';
BEGIN TRY
    EXEC(N'DELETE FROM dbo.Courses WHERE CourseId=-1;');
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 229 BEGIN REVERT; THROW; END;
    SET @Denied = 1;
    SELECT ERROR_NUMBER() AS ExpectedError, N'Editor no puede borrar' AS Result;
END CATCH;
REVERT;
IF @Denied = 0 THROW 50022, 'Editor obtuvo permiso de borrado.', 1;
GO
