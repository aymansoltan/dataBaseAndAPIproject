USE [ExaminationSystemDB]
GO
CREATE OR ALTER PROC [TrainingMangerStp].[stp_RegisterMemberByType]
    @UserName varchar(50),
    @Email varchar(100),
    @Password varchar(250),
    @TargetType varchar(5),      -- 'std' for student, 'ins' for instructor
    @FirstName varchar(20),
    @LastName varchar(20),
    @Gender char(1),
    @BirthDate date,
    @Address varchar(150),
    @Phone char(11),
    @NationalID char(14),
    @BranchId tinyint = null,  
    @TrackId smallint = null,    
    @Salary decimal(10,2) = null, 
    @HireDate date = null,    
    @Specialization varchar(50) = null,
    @DeptId tinyint = null      
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewUserId int;
    DECLARE @RoleId tinyint;
    DECLARE @AutoIntakeId tinyint; 

    BEGIN TRY

        IF LEN(@UserName) < 10
            THROW 50001, 'Error: UserName must be at least 10 characters long.', 1;

        IF LEN(@Email) < 10 OR CHARINDEX('@', @Email) = 0 OR CHARINDEX('.', @Email) = 0
            THROW 50002, 'Error: Invalid Email format.', 1;

        IF LEN(@Password) < 8
            THROW 50005, 'Error: Password must be at least 8 characters long.', 1;

        IF LEN(@FirstName) < 2 OR LEN(@LastName) < 2
            THROW 50006, 'Error: FirstName or LastName must be at least 2 characters long.', 1;

        IF @Gender NOT IN ('M', 'F', 'm', 'f')
            THROW 50007, 'Error: Invalid Gender. Use (M) or (F).', 1;

        IF LEN(@Phone) <> 11
            THROW 50008, 'Error: Phone number must be exactly 11 digits.', 1;

        IF LEN(@NationalID) <> 14
            THROW 50009, 'Error: NationalID must be exactly 14 digits.', 1;

        IF @BirthDate >= GETDATE()
            THROW 50011, 'Error: BirthDate must be a past date.', 1;

        IF LOWER(@TargetType) NOT IN ('std', 'ins')
            THROW 50010, 'Error: Invalid TargetType. Use (std) or (ins).', 1;

        BEGIN TRANSACTION;

            SELECT @RoleId = RoleId 
            FROM [userAcc].[UserRole] 
            WHERE RoleName = CASE WHEN LOWER(@TargetType) = 'std' THEN 'student' ELSE 'instructor' END;

            IF @RoleId IS NULL
                THROW 50023, 'Error: Defined role not found in UserRole table.', 1;

            INSERT INTO [userAcc].[UserAccount] (UserName, Email, UserPassword, RoleId)
            VALUES (TRIM(@UserName), LOWER(TRIM(@Email)), @Password, @RoleId);

            SET @NewUserId = SCOPE_IDENTITY();

            IF LOWER(@TargetType) = 'std'
            BEGIN
                SELECT TOP 1 @AutoIntakeId = IntakeId 
                FROM [orgnization].[Intake] 
                WHERE isActive = 1 AND isDeleted = 0 
                ORDER BY IntakeId DESC;

                IF @AutoIntakeId IS NULL
                    THROW 50022, 'Error: No active intake found to register the student.', 1;

                IF @BirthDate >= DATEADD(YEAR, -18, GETDATE())
                    THROW 50012, 'Error: Student must be at least 18 years old.', 1;

                IF @BranchId IS NULL OR @TrackId IS NULL
                    THROW 50014, 'Error: BranchId and TrackId are required for students.', 1;

                IF NOT EXISTS (SELECT 1 FROM [orgnization].[Branch] WHERE BranchId = @BranchId AND isActive = 1 AND isDeleted = 0)
                    THROW 50015, 'Error: BranchId does not exist or is inactive.', 1;

                IF NOT EXISTS (SELECT 1 FROM [orgnization].[Track] WHERE TrackId = @TrackId AND isActive = 1 AND isDeleted = 0)
                    THROW 50017, 'Error: TrackId does not exist or is inactive.', 1;

                INSERT INTO [userAcc].[Student] (
                    FirstName, LastName, Gender, BirthDate, StuAddress, 
                    Phone, NationalID, UserId, BranchId, IntakeId, TrackId
                )
                VALUES (
                    @FirstName, @LastName, UPPER(@Gender), @BirthDate, @Address, 
                    @Phone, @NationalID, @NewUserId, @BranchId, @AutoIntakeId, @TrackId
                );
            END

            ELSE IF LOWER(@TargetType) = 'ins'
            BEGIN
                IF @BirthDate >= DATEADD(YEAR, -20, GETDATE())
                    THROW 50013, 'Error: Instructor must be at least 20 years old.', 1;

                IF @Salary IS NULL OR @Specialization IS NULL OR @DeptId IS NULL
                    THROW 50018, 'Error: Salary, Specialization, and DeptId are required for instructors.', 1;

                IF NOT EXISTS (SELECT 1 FROM [orgnization].[Department] WHERE DeptId = @DeptId AND isActive = 1 AND isDeleted = 0)
                    THROW 50019, 'Error: DeptId does not exist or is inactive.', 1;

                IF @Salary <= 0
                    THROW 50020, 'Error: Salary must be a positive number.', 1;

                INSERT INTO [userAcc].[Instructor] (
                    FirstName, LastName, BirthDate, InsAddress, Phone, NationalID, 
                    HireDate, Salary, Specialization, DeptId, UserId
                )
                VALUES (
                    @FirstName, @LastName, @BirthDate, @Address, @Phone, @NationalID, 
                    ISNULL(@HireDate, GETDATE()), @Salary, @Specialization, @DeptId, @NewUserId
                );
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() IN (2627, 2601)
            THROW 50021, 'Error: UserName, Email, Phone, or NationalID already exists.', 1;
        ELSE
            THROW;
    END CATCH
END
GO



CREATE OR ALTER PROC [TrainingMangerStp].stp_GetUserByEmail
    @Email nvarchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [UserAcc].UserAccount WHERE Email = @Email AND isDeleted = 0 and isActive = 1)
    BEGIN
        RETURN; 
    END

    SELECT 
        u.UserId, u.UserName, u.Email, u.UserPassword, r.RoleName AS [Role],
        ins.InstructorId, 
        std.StudentId
   FROM [UserAcc].UserAccount u
    INNER JOIN [UserAcc].UserRole r ON u.RoleId = r.RoleId 
    LEFT JOIN [UserAcc].[Instructor] ins ON u.UserId = ins.UserId AND ins.isDeleted = 0
    LEFT JOIN [UserAcc].[Student] std ON u.UserId = std.UserId AND std.isDeleted = 0
    WHERE u.Email = @Email 
      AND u.isActive = 1;
END


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
    declare @AutoIntakeId tinyint;

    begin try

        if @UserName is not null and len(trim(@UserName)) < 10
            throw 50001, 'Error: New UserName must be at least 10 characters.', 1;

        if @Email is not null and (@Email not like '%_@__%.__%')
            throw 50002, 'Error: New Email format is invalid.', 1;

        if @Password is not null and len(@Password) < 8
            throw 50005, 'Error: New Password must be at least 8 characters.', 1;

        if (@FirstName is not null and len(trim(@FirstName)) < 2) or (@LastName is not null and len(trim(@LastName)) < 2)
            throw 50006, 'Error: Name fields must be at least 2 characters.', 1;

        if @Gender is not null and upper(trim(@Gender)) not in ('M', 'F')
            throw 50007, 'Error: Gender must be M or F.', 1;

        if @Phone is not null and (len(@Phone) <> 11 or @Phone like '%[^0-9]%')
            throw 50008, 'Error: Phone must be exactly 11 digits.', 1;

        if @NationalID is not null and len(@NationalID) <> 14
            throw 50009, 'Error: NationalID must be 14 digits.', 1;

        if @BirthDate is not null and @BirthDate >= getdate()
            throw 50011, 'Error: BirthDate must be a past date.', 1;

        begin transaction;

        if not exists (select 1 from [userAcc].[UserAccount] where UserId = @UserId)
            throw 50008, 'Error: User ID not found.', 1;
        
        update [userAcc].[UserAccount]
        set UserName = isnull(trim(@UserName), UserName),
            Email = isnull(lower(trim(@Email)), Email),
            UserPassword = isnull(@Password, UserPassword)
        where UserId = @UserId;

    
        if exists (select 1 from [userAcc].[Student] where UserId = @UserId)
        begin
            -- ·Ê «·‹ IntakeId „»⁄Ê  »‹ null° »‰‘Ê› Â· «·ÿ«·» ⁄‰œÂ √’·« Ê·« ·«¡ø
            -- »” ›Ì «·‹ Register ≈‰  ﬂ‰  » ÃÌ»Â √Ê Ê„« Ìﬂ.. 
            -- Â‰« «·√›÷· ‰ÃÌ» "√ÕœÀ Ê«Õœ" ›ﬁÿ ·Ê «·ÿ«·» «·‹ IntakeId » «⁄Â «·Õ«·Ì null
            
            select @AutoIntakeId = @IntakeId; -- Œœ «·ﬁÌ„… «·„»⁄Ê … „»œ∆Ì«

            if @AutoIntakeId is null
            begin
                -- »‰ÃÌ» «·‹ Current Intake » «⁄ «·ÿ«·» „‰ «·œ« «»Ì“
                declare @CurrentIntake tinyint;
                select @CurrentIntake = IntakeId from [userAcc].[Student] where UserId = @UserId;

                -- ·Ê «·ÿ«·» „·Ê‘ Intake (Õ«·… ‰«œ—…) √Ê ≈‰  ⁄«Ê“  Ãœœ·Â ·√ÕœÀ Ê«Õœ
                -- Â‰« Â‰„‘Ì »„»œ√: ·Ê „»⁄ ‘ ﬁÌ„…° ”Ì» «·ﬁœÌ„. ·Ê „›Ì‘ ﬁœÌ„° Â«  «·√ÕœÀ.
                if @CurrentIntake is null
                begin
                    select top 1 @AutoIntakeId = IntakeId from [orgnization].[Intake] 
                    where isActive = 1 and isDeleted = 0 order by IntakeId desc;
                end
                else 
                begin
                    set @AutoIntakeId = @CurrentIntake;
                end
            end

            --  Õﬁﬁ«  «·‹ FKs
            if @BranchId is not null and not exists (select 1 from [orgnization].[Branch] where BranchId = @BranchId and isActive = 1 and isDeleted = 0)
                throw 50030, 'Error: Selected Branch is invalid or inactive.', 1;

            if @AutoIntakeId is not null and not exists (select 1 from [orgnization].[Intake] where IntakeId = @AutoIntakeId and isActive = 1 and isDeleted = 0)
                throw 50031, 'Error: Intake is invalid or inactive.', 1;

            if @TrackId is not null and not exists (select 1 from [orgnization].[Track] where TrackId = @TrackId and isActive = 1 and isDeleted = 0)
                throw 50032, 'Error: Selected Track is invalid or inactive.', 1;

            update [userAcc].[Student]
            set FirstName = isnull(trim(@FirstName), FirstName),
                LastName = isnull(trim(@LastName), LastName),
                Gender = isnull(upper(trim(@Gender)), Gender),
                BirthDate = isnull(@BirthDate, BirthDate),
                StuAddress = isnull(trim(@Address), StuAddress),
                Phone = isnull(@Phone, Phone),
                NationalID = isnull(@NationalID, NationalID),
                BranchId = isnull(@BranchId, BranchId),
                IntakeId = @AutoIntakeId, -- »‰” Œœ„ «·ﬁÌ„… «··Ì «” ﬁ—Ì‰« ⁄·ÌÂ«
                TrackId = isnull(@TrackId, TrackId)
            where UserId = @UserId;
        end

        ---------------------------------------------------------
        -- 3.  ÕœÌÀ »Ì«‰«  «·„œ—” (Instructor Update Logic)
        ---------------------------------------------------------
        else if exists (select 1 from [userAcc].[Instructor] where UserId = @UserId)
        begin
            if @DeptId is not null and not exists (select 1 from [orgnization].[Department] where DeptId = @DeptId and isActive = 1 and isDeleted = 0)
                throw 50034, 'Error: Selected Department is invalid or inactive.', 1;

            if @Salary is not null and @Salary <= 0
                throw 50020, 'Error: Salary must be a positive number.', 1;

            update [userAcc].[Instructor]
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

    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        if error_number() in (2627, 2601)
            throw 50021, 'Error: Duplicate data detected (UserName, Email, Phone, or NationalID).', 1;
        else
            throw;
    end catch
end
GO
go
create or alter proc [TrainingMangerStp].stp_DeleteUserAccount 
    @UserId int
as
begin
    set nocount on;

    begin try

        if not exists (
            select 1 
            from [userAcc].[UserAccount]
            where UserId = @UserId
        )
            throw 50008, 'User ID not found.', 1;

        delete from [userAcc].[UserAccount] where UserId = @UserId;

    end try
    begin catch
        throw;
    end catch
end


go
create or alter trigger [userAcc].trg_SoftDeleteUserAccount
on [userAcc].[UserAccount]
instead of delete
as
begin
    set nocount on;
    if exists (
        select 1 from deleted d
        join [userAcc].[UserAccount] UA on UA.UserId = d.UserId
        join [userAcc].[UserRole] R on UA.RoleId = R.RoleId
        where R.RoleName = 'admin' or R.RoleName ='TrainingManager'
    )
    throw 50022, 'Error: Cannot delete an admin or Manger account.', 1;

    if exists (
        select 1 from deleted d
        join [userAcc].[Student] S on d.UserId = S.UserId
        where exists (select 1 from [exams].[Student_Answer] SA where SA.StudentId = S.StudentId)
           or exists (select 1 from [exams].[Student_Exam_Result] SR where SR.StudentId = S.StudentId)
    )
    throw 51030, 'Error: Cannot delete student with submitted answers or exam results.', 1;


    if exists (
        select 1 from deleted d
        join [userAcc].[Instructor] I on d.UserId = I.UserId
        where  exists (select 1 from [Courses].[CourseInstance] CI_INST where CI_INST.InstructorId = I.InstructorId)
    )
    throw 51035, 'Error: Cannot delete instructor assigned to active courses or course instances.', 1;



        update S 
        set isActive = 0, isDeleted = 1
        from [userAcc].[Student]  S
        join deleted d on S.UserId = d.UserId;

     
        update I 
        set isActive = 0, isDeleted = 1
        from [userAcc].[Instructor] I
        join deleted d on I.UserId = d.UserId;

  
        update UA 
        set isActive = 0, isDeleted = 1
        from [userAcc].[UserAccount] UA
        join deleted d on UA.UserId = d.UserId;
end
