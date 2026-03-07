USE [ExaminationSystemDB]
GO
create or alter proc [TrainingMangerStp].[stp_RegisterMemberByType]
    @UserName varchar(50),
    @Email varchar(100),
    @Password varchar(250),
    @TargetType varchar(5),
    @FirstName varchar(20),
    @LastName varchar(20),
    @Gender char(1),
    @BirthDate date,
    @Address varchar(150),
    @Phone char(11),
    @NationalID char(14),
    @BranchId tinyint = null,
    @IntakeId tinyint = null,
    @TrackId smallint = null,
    @Salary decimal(10,2) = null,
    @Specialization varchar(50) = null,
    @DeptId tinyint = null
as
begin
    set nocount on;
    declare @NewUserId int;
    declare @RoleId tinyint;

    begin try
            if len( @UserName) <10
                throw 50001, 'Error: UserName must be at least 10 characters long.', 1;

            if len(@Password) < 8
                throw 50005, 'Error: Password must be at least 8 characters long.', 1;

            if len(@FirstName) <2
                throw 50006, 'Error: FirstName must be at least 2 characters long.', 1;
        begin transaction;
            if lower(trim(@TargetType)) = 'std'
                select @RoleId = RoleId from Roles where RoleName = 'student';
            else if lower(trim(@TargetType)) = 'ins'
                select @RoleId = RoleId from Roles where RoleName = 'instructor';
            else
                throw 50020, 'Error: Invalid TargetType. Use (std) or (ins).', 1;

    
            insert into [userAcc].[UserAccount] (UserName, Email, UserPassword, RoleId)
            values (trim(@UserName), lower(trim(@Email)), @Password, @RoleId);

            set @NewUserId = SCOPE_IDENTITY();

            if lower(@TargetType) = 'std'
            begin
                insert into [orgnization].[Students] (
                    FirstName, LastName, Gender, BirthDate, StuAddress, 
                    Phone, NationalID, UserId, BranchId, IntakeId, TrackId
                )
                values (
                    @FirstName, @LastName, @Gender, @BirthDate, @Address, 
                    @Phone, @NationalID, @NewUserId, @BranchId, @IntakeId, @TrackId
                );
            end
            else if lower(@TargetType) = 'ins'
            begin
                insert into [orgnization].[Instructors] (
                    InsName, Salary, Specialization, DeptId, UserId
                )
                values (
                    @FullInsName, @Salary, @Specialization, @DeptId, @NewUserId
                );
            end

        commit transaction;

        select @NewUserId as UserId, 1 as Success, 'Registration completed for ' + @TargetType as Message;

    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        
        -- معالجة تكرار البيانات الفريدة (Unique Constraints)
        if error_number() in (2627, 2601)
            throw 50021, 'Error: UserName, Email, Phone, or NationalID already exists.', 1;
        else
            throw;
    end catch
end
go
------------------------------------------------------------
-- 2) Update User (Fully Secured)
------------------------------------------------------------
go
create or alter procedure [TrainingMangerStp].[stp_updateuseraccount] 
    @userid int,
    @username nvarchar(50) = null,     -- ����� ������ (�� ���� �����)
    @email nvarchar(100) = null,
    @password nvarchar(250) = null,   -- ���� ���� �������
    @isactive bit = null
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- 1. ������ �� ���� ������
        if not exists (select 1 from [useracc].[useraccount] where userid = @userid)
            throw 50003, 'error: user id not found.', 1;

        declare @olddbusername nvarchar(100);
        declare @oldloginname nvarchar(100);
        declare @rolename nvarchar(20);

        -- ��� �������� �������
        select 
            @olddbusername = ua.username,
            @rolename = r.rolename
        from [useracc].useraccount ua
        join [useracc].userrole r on ua.roleid = r.roleid
        where ua.userid = @userid;

        -- 2. ����� ������ (����� ������� ���� �� ���)
        if @rolename = 'admin'
            throw 50004, 'error: admin account cannot be modified via this procedure.', 1;

        -- 3. ����� ���� ���� ��� ������� (�� ������)
        if @password is not null
        begin
            -- ����� ��� ������ (����� ������ + login) �� �� ����� �� ������
            set @oldloginname = replace(@olddbusername, 'user', 'login'); 
            
            declare @sqlpass nvarchar(max) = 'alter login [' + @oldloginname + '] with password = ''' + @password + ''';';
            exec sp_executesql @sqlpass;
        end

        -- 4. ����� ���� ������ (active / inactive) ��� �������
        if @isactive is not null
        begin
            set @oldloginname = replace(@olddbusername, 'user', 'login');
            declare @sqlstatus nvarchar(max) = 'alter login [' + @oldloginname + '] ' + case when @isactive = 1 then 'enable' else 'disable' end + ';';
            exec sp_executesql @sqlstatus;
        end

        -- 5. ����� ������ ������� (useraccount)
        update [useracc].[useraccount]
        set 
            email = isnull(lower(trim(@email)), email),
            userpassword = isnull(@password, userpassword),
            isactive = isnull(@isactive, isactive)
        where userid = @userid;

        commit transaction;
        print 'user account and server login updated successfully.';

    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        declare @err nvarchar(4000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;
go

------------------------------------------------------------
-- 3) Delete User (Soft Delete Driven)
------------------------------------------------------------
go
CREATE or alter PROC [TrainingMangerStp].stp_DeleteUserAccount 
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