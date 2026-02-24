USE [ExaminationSystemDB]
GO

/* =========================================================
   Module: UserAccount (Enterprise Secured Version)
   Schema: userAcc
   ========================================================= */

------------------------------------------------------------
-- 1) Add User
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_AddUserAccount 
    @UserName nvarchar(50),
    @Email nvarchar(100),
    @UserPassword nvarchar(250),
    @RoleId int
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 
            FROM [userAcc].[UserRole] 
            WHERE RoleId = @RoleId
        )
            THROW 50001, 'Invalid RoleId.', 1;

        -- Prevent multiple admins
        IF EXISTS (
            SELECT 1 
            FROM [userAcc].[UserRole]
            WHERE RoleId = @RoleId AND RoleName = 'admin'
        )
        AND EXISTS (
            SELECT 1 
            FROM [userAcc].[UserAccount] UA
            JOIN [userAcc].[UserRole] R
                ON UA.RoleId = R.RoleId
            WHERE R.RoleName = 'admin'
        )
            THROW 50002, 'Only one admin account is allowed.', 1;

        INSERT INTO [userAcc].[UserAccount]
            (UserName, Email, UserPassword, RoleId)
        VALUES
            (LTRIM(RTRIM(@UserName)),
             LTRIM(RTRIM(@Email)),
             @UserPassword,
             @RoleId);

        PRINT 'User account added successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 2) Update User (Fully Secured)
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_UpdateUserAccount 
    @UserId int,
    @UserName nvarchar(50) = NULL,
    @Email nvarchar(100) = NULL,
    @UserPassword nvarchar(250) = NULL,
    @IsActive bit = NULL,
    @RoleId int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 
            FROM [userAcc].[UserAccount] 
            WHERE UserId = @UserId
        )
            THROW 50003, 'User ID not found.', 1;

        DECLARE @CurrentRoleName nvarchar(20);
        DECLARE @NewRoleName nvarchar(20);

        SELECT @CurrentRoleName = R.RoleName
        FROM [userAcc].[UserAccount] UA
        JOIN [userAcc].[UserRole] R
            ON UA.RoleId = R.RoleId
        WHERE UA.UserId = @UserId;

        -- Prevent modifying existing admin
        IF @CurrentRoleName = 'admin'
            THROW 50004, 'Admin account cannot be modified.', 1;

        IF @RoleId IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM [userAcc].[UserRole] WHERE RoleId = @RoleId
            )
                THROW 50005, 'Invalid new RoleId.', 1;

            SELECT @NewRoleName = RoleName
            FROM [userAcc].[UserRole]
            WHERE RoleId = @RoleId;

            -- Prevent promoting anyone to admin
            IF @NewRoleName = 'admin'
                THROW 50006, 'Cannot promote user to admin.', 1;

            -- Prevent changing role if linked to Student or Instructor
            IF EXISTS (SELECT 1 FROM [userAcc].[Student] WHERE UserId = @UserId)
               OR EXISTS (SELECT 1 FROM [userAcc].[Instructor] WHERE UserId = @UserId)
                THROW 50007, 'Cannot change role of linked Student/Instructor.', 1;
        END

        UPDATE [userAcc].[UserAccount]
        SET UserName     = ISNULL(LTRIM(RTRIM(@UserName)), UserName),
            Email        = ISNULL(LTRIM(RTRIM(@Email)), Email),
            UserPassword = ISNULL(@UserPassword, UserPassword),
            isActive     = ISNULL(@IsActive, isActive),
            RoleId       = ISNULL(@RoleId, RoleId)
        WHERE UserId = @UserId;

        PRINT 'User account updated successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 3) Delete User (Soft Delete Driven)
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_DeleteUserAccount 
    @UserId int
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 
            FROM [userAcc].[UserAccount] 
            WHERE UserId = @UserId
        )
            THROW 50008, 'User ID not found.', 1;

        DELETE FROM [userAcc].[UserAccount]
        WHERE UserId = @UserId;

        PRINT 'Delete request processed.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 4) Soft Delete Trigger
------------------------------------------------------------
CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccount
ON [userAcc].[UserAccount]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent Admin deletion
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN [userAcc].[UserAccount] UA 
            ON UA.UserId = d.UserId
        JOIN [userAcc].[UserRole] R
            ON UA.RoleId = R.RoleId
        WHERE R.RoleName = 'admin'
    )
        THROW 50009, 'Admin account cannot be deleted.', 1;

    -- Deactivate related Student
    UPDATE S
    SET isActive = 0
    FROM [userAcc].[Student] S
    JOIN deleted d ON S.UserId = d.UserId;

    -- Deactivate related Instructor
    UPDATE I
    SET isActive = 0
    FROM [userAcc].[Instructor] I
    JOIN deleted d ON I.UserId = d.UserId;

    -- Deactivate UserAccount
    UPDATE UA
    SET isActive = 0
    FROM [userAcc].[UserAccount] UA
    JOIN deleted d ON UA.UserId = d.UserId;

END
GO


PRINT 'UserAccount module enterprise-secured successfully.'
GO