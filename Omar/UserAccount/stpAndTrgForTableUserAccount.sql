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
    @HireDate date = null,
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
        if len(@Email) < 10 or charindex('@', @Email) = 0 or charindex('.', @Email) = 0
            throw 50002, 'Error: Invalid Email format.', 1;

        if len(@Password) < 8
            throw 50005, 'Error: Password must be at least 8 characters long.', 1;

        if len(@FirstName) <2 or len(@LastName)<2
            throw 50006, 'Error: FirstName or lastName must be at least 2 characters long.', 1;

        if @Gender not in ('M', 'F','m','f')
            throw 50007, 'Error: Invalid Gender. Use (M) or (F).', 1;

        if len(@Phone) <> 11
            throw 50008, 'Error: Phone number must be exactly 11 digits.',1;

        if len(@NationalID) <> 14
            throw 50009, 'Error: NationalID must be exactly 14 digits.', 1;
        if @BirthDate >= GETDATE()
            throw 50011, 'Error: BirthDate must be a past date.', 1;   
      
        if lower(@TargetType) not in ('std', 'ins')
            throw 50010, 'Error: Invalid TargetType. Use (std) or (ins).', 1;

        begin transaction;
  
            select @RoleId = RoleId from [userAcc].[UserRole] where RoleName = case when lower(@TargetType) = 'std' then 'student' else 'instructor' end;

    
            insert into [Accounts] (UserName, Email, UserPassword, RoleId)
            values (trim(@UserName), lower(trim(@Email)), @Password, @RoleId);

            set @NewUserId = SCOPE_IDENTITY();

            if lower(@TargetType) = 'std'
            begin
                if @birthdate >= DATEADD(year, -18, GETDATE())
                    throw 50012, 'Error: Student must be at least 18 years old.', 1;

                if @BranchId is null or @IntakeId is null or @TrackId is null
                    throw 50014, 'Error: BranchId, IntakeId, and TrackId are required for students.', 1;

                if not exists (select 1 from [Branch] where BranchId = @BranchId and isActive = 1 and isDeleted = 0)
                    throw 50015, 'Error: BranchId does not exist or is inactive.', 1;

                if not exists (select 1 from [Intake] where IntakeId = @IntakeId and isActive = 1 and isDeleted = 0)
                    throw 50016, 'Error: IntakeId does not exist or is inactive.', 1;

                if not exists (select 1 from [Track] where TrackId = @TrackId and isActive = 1 and isDeleted = 0)
                    throw 50017, 'Error: TrackId does not exist or is inactive.', 1;

                insert into [Students] (
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
                if @birthdate >= DATEADD(year, -20, GETDATE())
                    throw 50013, 'Error: Instructor must be at least 20 years old.', 1;

                if @Salary is null or @Specialization is null or @DeptId is null
                    throw 50018, 'Error: Salary, Specialization, and DeptId are required for instructors.', 1;

                if not exists (select 1 from [Department] where DeptId = @DeptId and isActive = 1 and isDeleted = 0)
                    throw 50019, 'Error: DeptId does not exist or is inactive.', 1;

                if @Salary <= 0
                    throw 50020, 'Error: Salary must be a positive number.', 1;

                insert into [Instructors] (
                    FirstName, LastName,BirthDate, InsAddress,Phone,NationalID,HireDate,Salary, Specialization, DeptId, UserId
                )
                values (
                    @FirstName, @LastName, @BirthDate, @Address, @Phone, @NationalID, @HireDate, @Salary, @Specialization, @DeptId, @NewUserId
                );
            end

        commit transaction;

        select @NewUserId as UserId, 1 as Success, 'Registration completed for ' + @TargetType as Message;

    end try
    begin catch
        if @@trancount > 0 rollback transaction;

        if error_number() in (2627, 2601)
            throw 50021, 'Error: UserName, Email, Phone, or NationalID already exists.', 1;
        else
            throw;
    end catch
end
go

create or alter proc [TrainingMangerStp].[stp_UpdateMemberFull]
    @UserId int,
    @UserName varchar(50) = null,
    @Email varchar(100) = null,
    @Password varchar(250) = null,
    @FirstName varchar(20) = null,
    @LastName varchar(20) = null,
    @Gender char(1) = null,
    @BirthDate date = null,
    @Address varchar(150) = null,
    @Phone char(11) = null,
    @NationalID char(14) = null,
    @BranchId tinyint = null,
    @IntakeId tinyint = null,
    @TrackId smallint = null,
    @Salary decimal(10,2) = null,
    @HireDate date = null,
    @Specialization varchar(50) = null,
    @DeptId tinyint = null
as
begin
    set nocount on;
    begin try
        if @UserName is not null and len(trim(@UserName)) < 10
            throw 50001, 'Error: New UserName must be at least 10 characters.', 1;

        if @Email is not null and (@Email not like '%_@__%.__%')
            throw 50002, 'Error: New Email format is invalid.', 1;

        if @Password is not null and len(@Password) < 8
            throw 50005, 'Error: New Password must be at least 8 characters.', 1;

        if (@FirstName is not null and len(trim(@FirstName)) < 2) or (@LastName is not null and len(trim(@LastName)) < 2)
            throw 50006, 'Error: Name fields must be at least 2 characters.', 1;

        if @Gender is not null and upper(trim(@Gender)) not in ('M', 'F','m','f')
            throw 50007, 'Error: Gender must be M or F.', 1;

        if @Phone is not null and (len(@Phone) <> 11 or @Phone not like '[0-9]%')
            throw 50008, 'Error: Phone must be exactly 11 digits.', 1;

        if @NationalID is not null and len(@NationalID) <> 14
            throw 50009, 'Error: NationalID must be 14 digits.', 1;

        if @BirthDate is not null and @BirthDate >= getdate()
            throw 50011, 'Error: BirthDate must be a past date.', 1;

        begin transaction;
        if not exists (select 1 from [Accounts] where UserId = @UserId)
            throw 50008, 'Error: User ID not found.', 1;
        
        update [Accounts]
        set UserName = isnull(trim(@UserName), UserName),
            Email = isnull(lower(trim(@Email)), Email),
            UserPassword = isnull(@Password, UserPassword)
        where UserId = @UserId;

        if exists (select 1 from [Students] where UserId = @UserId)
        begin
            if @BranchId is not null and not exists (select 1 from [Branch] where BranchId = @BranchId and isActive = 1 and isDeleted = 0)
                throw 50030, 'Error: Selected Branch is invalid or inactive.', 1;

            if @IntakeId is not null and not exists (select 1 from [Intake] where IntakeId = @IntakeId and isActive = 1 and isDeleted = 0)
                throw 50031, 'Error: Selected Intake is invalid or inactive.', 1;

            if @TrackId is not null and not exists (select 1 from [Track] where TrackId = @TrackId and isActive = 1 and isDeleted = 0)
                throw 50032, 'Error: Selected Track is invalid or inactive.', 1;

            update [Students]
            set FirstName = isnull(trim(@FirstName), FirstName),
                LastName = isnull(trim(@LastName), LastName),
                Gender = isnull(upper(trim(@Gender)), Gender),
                BirthDate = isnull(@BirthDate, BirthDate),
                StuAddress = isnull(trim(@Address), StuAddress),
                Phone = isnull(@Phone, Phone),
                NationalID = isnull(@NationalID, NationalID),
                BranchId = isnull(@BranchId, BranchId),
                IntakeId = isnull(@IntakeId, IntakeId),
                TrackId = isnull(@TrackId, TrackId)
            where UserId = @UserId;
        end
        else if exists (select 1 from [Instructors] where UserId = @UserId)
        begin
            if @DeptId is not null and not exists (select 1 from [Department] where DeptId = @DeptId and isActive = 1 and isDeleted = 0)
                throw 50034, 'Error: Selected Department is invalid or inactive.', 1;

            if @Salary is not null and @Salary <= 0
                throw 50020, 'Error: Salary must be a positive number.', 1;

            update [Instructors]
            set FirstName = isnull(trim(@FirstName), FirstName),
                LastName = isnull(trim(@LastName), LastName),
                BirthDate = isnull(@BirthDate, BirthDate),
                InsAddress = isnull(trim(@Address), InsAddress),
                Phone = isnull(@Phone, Phone),
                NationalID = isnull(@NationalID, NationalID),
                HireDate = isnull(@HireDate, HireDate),
                Salary = isnull(@Salary, Salary),
                Specialization = isnull(trim(@Specialization), Specialization),
                DeptId = isnull(@DeptId, DeptId)
            where UserId = @UserId;
        end

        commit transaction;
        select @UserId as UserId, 1 as Success, 'Update completed successfully' as Message;

    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        if error_number() in (2627, 2601)
            throw 50021, 'Error: Duplicate data detected (UserName, Email, Phone, or NationalID).', 1;
        else
            throw;
    end catch
end
go

go
create or alter proc [TrainingMangerStp].stp_DeleteUserAccount 
    @UserId int
as
begin
    set nocount on;

    begin try

        if not exists (
            select 1 
            from [Accounts]
            where UserId = @UserId
        )
            throw 50008, 'User ID not found.', 1;

        delete from [Accounts] where UserId = @UserId;

        select @UserId as UserId, 1 as Success, 'User account deleted successfully.' as Message;    
    end try
    begin catch
        throw;
    end catch
end



create or alter trigger [userAcc].trg_SoftDeleteUserAccount
on [Accounts] 
instead of delete
as
begin
    set nocount on;
    if exists (
        select 1 from deleted d
        join [Accounts] UA on UA.UserId = d.UserId
        join [Roles] R on UA.RoleId = R.RoleId
        where R.RoleName = 'admin'
    )
    throw 50022, 'Error: Cannot delete an admin account.', 1;

    if exists (
        select 1 from deleted d
        join [Students] S on d.UserId = S.UserId
        where exists (select 1 from [StudentAnswers] SA where SA.StudentId = S.StudentId)
           or exists (select 1 from [FinalResults] SR where SR.StudentId = S.StudentId)
    )
    throw 51030, 'Error: Cannot delete student with submitted answers or exam results.', 1;


    if exists (
        select 1 from deleted d
        join [Instructors] I on d.UserId = I.UserId
        where  exists (select 1 from [CourseInstance] CI_INST where CI_INST.InstructorId = I.InstructorId)
    )
    throw 51035, 'Error: Cannot delete instructor assigned to active courses or course instances.', 1;


    begin transaction ;
        update S 
        set isActive = 0, isDeleted = 1
        from [Students] S
        join deleted d on S.UserId = d.UserId;

     
        update I 
        set isActive = 0, isDeleted = 1
        from [Instructors] I
        join deleted d on I.UserId = d.UserId;

  
        update UA 
        set isActive = 0, isDeleted = 1
        from [Accounts] UA
        join deleted d on UA.UserId = d.UserId;
    commit transaction;
end
