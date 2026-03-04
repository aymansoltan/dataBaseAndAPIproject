create or alter proc [admin].stp_fullBackup_ExaminationSystemDB
as
begin
	declare @dbName varchar(100) ='ExaminationSystemDB';
	declare @path varchar(300) ='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\';
	declare @tag varchar(50) =format(getdate() , 'yyyyMMdd_HHmmss')
	declare @FullName nvarchar(450) =@path+@dbName +'_full_'+@tag+'.bak';
	begin try
    DECLARE @BackupName NVARCHAR(200);
SET @BackupName = 'Full Backup of ' + @dbName;
	backup database @dbName
	to disk =@FullName
        with format , init , name = @BackupName, STATS = 10;
	   PRINT 'Success: Full Backup saved to ' + @FullName;
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
end


go
CREATE OR ALTER PROCEDURE [admin].sp_DiffBackup_ExaminationSystem
AS
BEGIN
    SET NOCOUNT ON;
	declare @dbName varchar(100) ='ExaminationSystemDB';
	declare @path varchar(300) ='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\';
	declare @tag varchar(50) =format(getdate() , 'yyyyMMdd_HHmmss')
	declare @DiffFileName nvarchar(450) =@path+@dbName +'_Diff_'+@tag+'.bak';

    BEGIN TRY
        DECLARE @BackupName NVARCHAR(200);
        SET @BackupName = 'Diff Backup of' + @dbName;
        PRINT '--- Starting DIFFERENTIAL Backup ---';
        BACKUP DATABASE @dbName 
        TO DISK = @DiffFileName 
        WITH DIFFERENTIAL, NAME = @BackupName, STATS = 10;

        PRINT 'Success: Differential Backup saved to ' + @DiffFileName;
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END
GO




















CREATE OR ALTER PROCEDURE [admin].stp_RestoreFull_ExaminationSystemDB
    @FullBackupPath NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DBName NVARCHAR(50) = 'ExaminationSystemDB';
    DECLARE @DataPath NVARCHAR(512) = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\';
    DECLARE @LogicalName NVARCHAR(128);
    DECLARE @PhysicalName NVARCHAR(260);
    DECLARE @RestoreSQL NVARCHAR(MAX);

    BEGIN TRY
        -- Œ·Ì «·œ« « »Ì“ Single User
        IF EXISTS (SELECT name FROM sys.databases WHERE name = @DBName)
            EXEC('ALTER DATABASE [' + @DBName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE');

        -- Ã·» Logical Names „‰ Full Backup
        DECLARE @Files TABLE (LogicalName NVARCHAR(128), PhysicalName NVARCHAR(260), Type CHAR(1));
        INSERT INTO @Files (LogicalName, PhysicalName, Type)
        SELECT [LogicalName], [PhysicalName], [Type]
        FROM RESTORE FILELISTONLY FROM DISK = @FullBackupPath;

        --  ﬂÊÌ‰ Ã„·… RESTORE œÌ‰«„ÌﬂÌ
        SET @RestoreSQL = 'RESTORE DATABASE [' + @DBName + '] FROM DISK = ''' + @FullBackupPath + ''' WITH NORECOVERY, REPLACE, ';
        SELECT @RestoreSQL = @RestoreSQL +
            'MOVE ''' + LogicalName + ''' TO ''' + @DataPath + RIGHT(PhysicalName, CHARINDEX('\', REVERSE(PhysicalName)) -1) + ''', '
        FROM @Files;
        SET @RestoreSQL = LEFT(@RestoreSQL, LEN(@RestoreSQL)-1);

        --  ‰›Ì– Full Restore
        PRINT '--- Executing Full Restore ---';
        EXEC(@RestoreSQL);

    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END
GO
CREATE OR ALTER PROCEDURE [admin].stp_RestoreDiff_ExaminationSystemDB
    @DiffBackupPath NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DBName NVARCHAR(50) = 'ExaminationSystemDB';

    BEGIN TRY
        PRINT '--- Restoring Differential Backup ---';
        RESTORE DATABASE [ExaminationSystemDB]
        FROM DISK = @DiffBackupPath
        WITH RECOVERY;

    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END
GO
use [ExaminationSystemDB]
