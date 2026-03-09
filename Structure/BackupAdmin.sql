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



















