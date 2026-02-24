USE [ExaminationSystemDB]
GO

/* =========================================================
   Module: Instructor (Enterprise Soft Delete Version)
   Schema: userAcc
   ========================================================= */

------------------------------------------------------------
-- 1) Add Instructor
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_AddInstructor 
    @FirstName nvarchar(50),
    @LastName nvarchar(50),
    @BirthDate date,
    @InsAddress nvarchar(150),
    @Phone nvarchar(11),
    @NationalID nchar(14),
    @Salary decimal(10,2),
    @Specialization nvarchar(50),
    @UserId int,
    @DeptId int
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate names
        IF LEN(LTRIM(RTRIM(@FirstName))) < 3 
           OR LEN(LTRIM(RTRIM(@LastName))) < 3
            THROW 52001, 'First and Last name must be at least 3 characters.', 1;

        -- Validate salary
        IF @Salary < 4000
            THROW 52002, 'Salary must be at least 4000.', 1;

        -- Check User exists AND active
        IF NOT EXISTS (
            SELECT 1 
            FROM [userAcc].[UserAccount]
            WHERE UserId = @UserId
              AND isActive = 1
        )
            THROW 52003, 'UserId does not exist or inactive.', 1;

        -- Check RoleName = instructor
        IF NOT EXISTS (
            SELECT 1
            FROM [userAcc].[UserAccount] UA
            JOIN [userAcc].[UserRole] R
                ON UA.RoleId = R.RoleId
            WHERE UA.UserId = @UserId
              AND R.RoleName = 'instructor'
        )
            THROW 52004, 'User must have instructor role.', 1;

        -- Prevent duplicate Instructor
        IF EXISTS (
            SELECT 1 FROM [userAcc].[Instructor]
            WHERE UserId = @UserId
        )
            THROW 52005, 'User already linked to Instructor.', 1;

        -- Prevent Student + Instructor conflict
        IF EXISTS (
            SELECT 1 FROM [userAcc].[Student]
            WHERE UserId = @UserId
        )
            THROW 52006, 'User cannot be both Instructor and Student.', 1;

        -- Validate Department
        IF NOT EXISTS (
            SELECT 1 FROM [orgnization].[Department]
            WHERE DeptId = @DeptId
        )
            THROW 52007, 'Invalid DeptId.', 1;

        INSERT INTO [userAcc].[Instructor]
        (
            FirstName, LastName, BirthDate,
            InsAddress, Phone, NationalID,
            Salary, Specialization,
            UserId, DeptId, isActive
        )
        VALUES
        (
            LTRIM(RTRIM(@FirstName)),
            LTRIM(RTRIM(@LastName)),
            @BirthDate,
            @InsAddress,
            @Phone,
            @NationalID,
            @Salary,
            @Specialization,
            @UserId,
            @DeptId,
            1
        );

        PRINT 'Instructor added successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 2) Update Instructor
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_UpdateInstructor 
    @InsId int,
    @FirstName nvarchar(50) = NULL,
    @LastName nvarchar(50) = NULL,
    @BirthDate date = NULL,
    @InsAddress nvarchar(150) = NULL,
    @Phone nvarchar(11) = NULL,
    @NationalID nchar(14) = NULL,
    @Salary decimal(10,2) = NULL,
    @Specialization nvarchar(50) = NULL,
    @DeptId int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 FROM [userAcc].[Instructor]
            WHERE InsId = @InsId
        )
            THROW 52020, 'Instructor not found.', 1;

        IF @Salary IS NOT NULL AND @Salary < 4000
            THROW 52021, 'Salary must be at least 4000.', 1;

        -- Phone uniqueness validation
        IF @Phone IS NOT NULL
           AND EXISTS (
                SELECT 1 FROM [userAcc].[Instructor]
                WHERE Phone = @Phone
                  AND InsId <> @InsId
           )
            THROW 52040, 'Phone already exists.', 1;

        -- NationalID uniqueness validation
        IF @NationalID IS NOT NULL
           AND EXISTS (
                SELECT 1 FROM [userAcc].[Instructor]
                WHERE NationalID = @NationalID
                  AND InsId <> @InsId
           )
            THROW 52041, 'NationalID already exists.', 1;

        IF @DeptId IS NOT NULL
           AND NOT EXISTS (
               SELECT 1 FROM [orgnization].[Department]
               WHERE DeptId = @DeptId
           )
            THROW 52022, 'Invalid DeptId.', 1;

        UPDATE [userAcc].[Instructor]
        SET
            FirstName      = COALESCE(LTRIM(RTRIM(@FirstName)), FirstName),
            LastName       = COALESCE(LTRIM(RTRIM(@LastName)), LastName),
            BirthDate      = COALESCE(@BirthDate, BirthDate),
            InsAddress     = COALESCE(@InsAddress, InsAddress),
            Phone          = COALESCE(@Phone, Phone),
            NationalID     = COALESCE(@NationalID, NationalID),
            Salary         = COALESCE(@Salary, Salary),
            Specialization = COALESCE(@Specialization, Specialization),
            DeptId         = COALESCE(@DeptId, DeptId),
            isActive       = COALESCE(@IsActive, isActive)
        WHERE InsId = @InsId;

        PRINT 'Instructor updated successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 3) Delete Instructor (Soft Delete Only)
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_DeleteInstructor 
    @InsId int
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [userAcc].[Instructor]
    WHERE InsId = @InsId
      AND isActive = 1;
END
GO


------------------------------------------------------------
-- 4) Soft Delete Trigger (Corrected Version)
------------------------------------------------------------
CREATE OR ALTER TRIGGER [userAcc].trg_PreventDeleteInstructor
ON [userAcc].[Instructor]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Block if assigned to CourseInstance
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN [Courses].[CourseInstance] CI
            ON d.InsId = CI.InstructorId
    )
        THROW 52030, 'Cannot delete instructor assigned to course instances.', 1;

    -- Block if assigned to Exams (through CourseInstance)
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN [Courses].[CourseInstance] CI
            ON d.InsId = CI.InstructorId
        JOIN [exams].[Exam] E
            ON CI.CourseInstanceId = E.CourseInstanceId
    )
        THROW 52031, 'Cannot delete instructor assigned to exams.', 1;

    -- Soft Delete
    UPDATE I
    SET isActive = 0
    FROM [userAcc].[Instructor] I
    JOIN deleted d ON I.InsId = d.InsId;

END
GO


PRINT 'Instructor module enterprise-ready successfully.'
GO