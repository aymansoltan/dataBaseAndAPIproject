/* =========================================================
   Module: Instructor (Enterprise Soft Delete Version)
   Schema: useracc
   ========================================================= */

------------------------------------------------------------
-- 1) Add Instructor
------------------------------------------------------------
go
CREATE OR ALTER PROC [TrainingMangerStp].stp_addinstructor 
    @firstname nvarchar(50),
    @lastname  nvarchar(50),
    @birthdate date,
    @insaddress nvarchar(150),
    @phone      nvarchar(11),
    @nationalid nchar(14),
    @salary     decimal(10,2),
    @specialization nvarchar(50),
    @userid     int,
    @deptid     int
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate names
        IF LEN(LTRIM(RTRIM(@firstname))) < 3 OR LEN(LTRIM(RTRIM(@lastname))) < 3
            THROW 52001, 'error: first and last name must be at least 3 characters.', 1;

        -- Validate salary
        IF @salary < 4000
            THROW 52002, 'error: salary must be at least 4000.', 1;

        -- Check User exists AND active AND role is instructor
        IF NOT EXISTS (
            SELECT 1 FROM [useracc].[useraccount] ua
            JOIN [useracc].[userrole] r ON ua.roleid = r.roleid
            WHERE ua.userid = @userid AND ua.isactive = 1 AND r.rolename = 'instructor'
        )
            THROW 52003, 'error: userid does not exist, is inactive, or not an instructor.', 1;

        -- Prevent duplicate or Student conflict
        IF EXISTS (SELECT 1 FROM [useracc].[instructor] WHERE userid = @userid)
            THROW 52005, 'error: user already linked to an instructor profile.', 1;

        IF EXISTS (SELECT 1 FROM [useracc].[student] WHERE userid = @userid)
            THROW 52006, 'error: user cannot be both instructor and student.', 1;

        -- Validate Department (Fixed Schema Name)
        IF NOT EXISTS (SELECT 1 FROM [orgnization].[department] WHERE deptid = @deptid)
            THROW 52007, 'error: invalid department id.', 1;

        INSERT INTO [useracc].[instructor] (
            firstname, lastname, birthdate, insaddress, phone, 
            nationalid, salary, specialization, userid, deptid
        )
        VALUES (
            LOWER(TRIM(@firstname)), LOWER(TRIM(@lastname)), @birthdate, 
            @insaddress, @phone, @nationalid, @salary, 
            LOWER(TRIM(@specialization)), @userid, @deptid
        );

        PRINT 'instructor added successfully.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

------------------------------------------------------------
-- 2) Update Instructor
------------------------------------------------------------

CREATE OR ALTER PROC [TrainingMangerStp].stp_updateinstructor 
    @insid int,
    @firstname nvarchar(50) = NULL,
    @lastname  nvarchar(50) = NULL,
    @birthdate date = NULL,
    @insaddress nvarchar(150) = NULL,
    @phone      nvarchar(11) = NULL,
    @nationalid nchar(14) = NULL,
    @salary     decimal(10,2) = NULL,
    @specialization nvarchar(50) = NULL,
    @deptid     int = NULL,
    @isactive   bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [useracc].[instructor] WHERE insid = @insid)
            THROW 52020, 'error: instructor not found.', 1;

        -- Phone/NationalID uniqueness
        IF @phone IS NOT NULL AND EXISTS (SELECT 1 FROM [useracc].[instructor] WHERE phone = @phone AND insid <> @insid)
            THROW 52040, 'error: phone already exists.', 1;

        UPDATE [useracc].[instructor]
        SET
            firstname      = COALESCE(LOWER(TRIM(@firstname)), firstname),
            lastname       = COALESCE(LOWER(TRIM(@lastname)), lastname),
            birthdate      = COALESCE(@birthdate, birthdate),
            insaddress     = COALESCE(@insaddress, insaddress),
            phone          = COALESCE(@phone, phone),
            nationalid     = COALESCE(@nationalid, nationalid),
            salary         = COALESCE(@salary, salary),
            specialization = COALESCE(LOWER(TRIM(@specialization)), specialization),
            deptid         = COALESCE(@deptid, deptid),
            isactive       = COALESCE(@isactive, isactive)
        WHERE insid = @insid;

        PRINT 'instructor updated successfully.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
--==========================================

create or alter proc [TrainingMangerStp].stp_deleteinstructor 
    @instructoid int 
as 
begin
    set nocount on;

    if not exists(select 1 from[userAcc].[Instructor]  where [InsId] = @instructoid)
    begin
        throw 52031, 'error: instructor not found.', 1;
    end

    delete from [useracc].[instructor] where [insid] = @instructoid;
end;
go

------------------------------------------------------------
-- 3) Soft Delete Trigger (Enhanced)
------------------------------------------------------------
CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor]
ON [useracc].[instructor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Block if assigned to CourseInstance
    IF EXISTS (SELECT 1 FROM deleted d JOIN [courses].[courseinstance] ci ON d.insid = ci.instructorid)
        THROW 52030, 'error: cannot delete instructor assigned to course instances.', 1;

    -- Soft Delete Instructor
    UPDATE i SET isactive = 0 FROM [useracc].[instructor] i JOIN deleted d ON i.insid = d.insid;

    -- Deactivate associated UserAccount (The Safety Step)
    UPDATE ua SET isactive = 0 FROM [useracc].[useraccount] ua 
    JOIN [useracc].[instructor] i ON ua.userid = i.userid
    JOIN deleted d ON i.insid = d.insid;

    PRINT 'soft delete performed: instructor and user account deactivated.';
END;
GO