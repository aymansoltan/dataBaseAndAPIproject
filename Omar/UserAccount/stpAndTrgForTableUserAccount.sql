USE [ExaminationSystemDB]
GO

create or alter procedure [TrainingMangerStp].[stp_createsystemuser]
    @username nvarchar(50),
    @password nvarchar(250),
    @email    nvarchar(100),
    @roletype nvarchar(20) 
as
begin
    set nocount on;
    begin try
        begin transaction;

      
        declare @cleanname nvarchar(50) = lower(trim(@username));
        declare @cleanrole nvarchar(20) = lower(trim(@roletype));
        declare @mappedrolename nvarchar(50) = (case when @cleanrole = 'manager' then 'training manager' else @cleanrole end);

        declare @targetroleid int;
        select @targetroleid = [RoleId] from [userAcc].[UserRole] where [RoleName] = @mappedrolename;

        if @targetroleid is null
        begin
            throw 50001, 'error: the specified role type does not exist in userrole table.', 1;
        end

        if @cleanrole in ('admin', 'manager')
        begin
            if exists (
                select 1 
                from [userAcc].[UserAccount] ua 
                join [userAcc].[UserRole] r on ua.[RoleId] = r.[RoleId] 
                where r.[RoleName] = @mappedrolename
            )
            begin
                declare @msg nvarchar(100) = 'error: only one ' + @mappedrolename + ' account is allowed.';
                throw 50002, @msg, 1;
            end
        end

  
        declare @loginname nvarchar(100) = @cleanname + 'login';
        declare @dbusername nvarchar(100) = @cleanname + 'user';
        
        if exists (select 1 from sys.server_principals where name = @loginname)
            throw 50003, 'error: login already exists on the server.', 1;

   
        declare @sqllogin nvarchar(max) = 'create login [' + @loginname + '] with password = ''' + @password + ''';';
        declare @sqluser  nvarchar(max) = 'create user [' + @dbusername + '] for login [' + @loginname + '];';
        
        declare @dbrolename nvarchar(50) = case 
            when @cleanrole = 'admin' then 'adminrole'
            when @cleanrole = 'instructor' then 'instructorerole'
            when @cleanrole = 'student' then 'studentrole'
            when @cleanrole = 'manager' then 'trainningmangerrole'
        end;

        exec sp_executesql @sqllogin;
        exec sp_executesql @sqluser;
        

        declare @sqladdrole nvarchar(max) = 'alter role [' + @dbrolename + '] add member [' + @dbusername + '];';
        exec sp_executesql @sqladdrole;

       
        insert into [useracc].useraccount (username, email, userpassword, roleid)
        values (@dbusername, lower(trim(@email)), @password, @targetroleid);

        commit transaction;
        print 'user account and server login created successfully.';
    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        declare @errormessage nvarchar(4000) = error_message();
        raiserror(@errormessage, 16, 1);
    end catch
end;
go

------------------------------------------------------------
-- 2) Update User (Fully Secured)
------------------------------------------------------------
go
create or alter procedure [TrainingMangerStp].[stp_updateuseraccount] 
    @userid int,
    @username nvarchar(50) = null,     -- ÇáÇÓã ÇáÌÏíÏ (áæ ÍÇÈÈ ÊÛíÑå)
    @email nvarchar(100) = null,
    @password nvarchar(250) = null,   -- ßáãÉ ÇáÓÑ ÇáÌÏíÏÉ
    @isactive bit = null
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- 1. ÇáÊÃßÏ ãä æÌæÏ ÇáíæÒÑ
        if not exists (select 1 from [useracc].[useraccount] where userid = @userid)
            throw 50003, 'error: user id not found.', 1;

        declare @olddbusername nvarchar(100);
        declare @oldloginname nvarchar(100);
        declare @rolename nvarchar(20);

        -- ÌáÈ ÇáÈíÇäÇÊ ÇáÍÇáíÉ
        select 
            @olddbusername = ua.username,
            @rolename = r.rolename
        from [useracc].useraccount ua
        join [useracc].userrole r on ua.roleid = r.roleid
        where ua.userid = @userid;

        -- 2. ÍãÇíÉ ÇáÃÏãä (ããäæÚ ÇáÊÚÏíá Úáíå ãä åäÇ)
        if @rolename = 'admin'
            throw 50004, 'error: admin account cannot be modified via this procedure.', 1;

        -- 3. ÊÍÏíË ßáãÉ ÇáÓÑ Úáì ÇáÓíÑÝÑ (áæ ãÈÚæÊÉ)
        if @password is not null
        begin
            -- ÈäÔÊÞ ÇÓã ÇááæÌä (ÇáÇÓã ÇáÞÏíã + login) Òí ãÇ ÚãáäÇ Ýí ÇáßÑíå
            set @oldloginname = replace(@olddbusername, 'user', 'login'); 
            
            declare @sqlpass nvarchar(max) = 'alter login [' + @oldloginname + '] with password = ''' + @password + ''';';
            exec sp_executesql @sqlpass;
        end

        -- 4. ÊÍÏíË ÍÇáÉ ÇáÍÓÇÈ (active / inactive) Úáì ÇáÓíÑÝÑ
        if @isactive is not null
        begin
            set @oldloginname = replace(@olddbusername, 'user', 'login');
            declare @sqlstatus nvarchar(max) = 'alter login [' + @oldloginname + '] ' + case when @isactive = 1 then 'enable' else 'disable' end + ';';
            exec sp_executesql @sqlstatus;
        end

        -- 5. ÊÍÏíË ÇáÌÏæá ÇáÏÇÎáí (useraccount)
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
CREATE OR ALTER PROC [TrainingMangerStp].stp_DeleteUserAccount 
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