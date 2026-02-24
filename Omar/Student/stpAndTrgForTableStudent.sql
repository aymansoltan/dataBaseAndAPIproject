USE [ExaminationSystemDB]
GO

/* =========================================================
   Student Module (Production-Ready Enterprise Version)
   ========================================================= */

------------------------------------------------------------
-- 1) Add Student
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_AddStudent
    @FirstName nvarchar(50),
    @LastName nvarchar(50),
    @Gender char(1),
    @BirthDate date,
    @StuAddress nvarchar(150),
    @Phone nvarchar(11),
    @NationalID nchar(14),
    @UserId int,
    @BranchId int,
    @IntakeId int,
    @TrackId int
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate names
        IF LEN(LTRIM(RTRIM(@FirstName))) < 3 
           OR LEN(LTRIM(RTRIM(@LastName))) < 3
            THROW 51000, 'First and Last name must be at least 3 characters.', 1;

        -- Validate phone uniqueness
        IF EXISTS (SELECT 1 FROM userAcc.Student WHERE Phone = @Phone)
            THROW 51008, 'Phone already exists.', 1;

        -- Validate NationalID uniqueness
        IF EXISTS (SELECT 1 FROM userAcc.Student WHERE NationalID = @NationalID)
            THROW 51009, 'National ID already exists.', 1;

        -- Validate active user with student role
        IF NOT EXISTS (
            SELECT 1
            FROM userAcc.UserAccount UA
            JOIN userAcc.UserRole R ON UA.RoleId = R.RoleId
            WHERE UA.UserId = @UserId
              AND UA.isActive = 1
              AND R.RoleName = 'student'
        )
            THROW 51001, 'Invalid active student user.', 1;

        -- Prevent duplicate link
        IF EXISTS (SELECT 1 FROM userAcc.Student WHERE UserId = @UserId)
            THROW 51002, 'User already linked to Student.', 1;

        IF EXISTS (SELECT 1 FROM userAcc.Instructor WHERE UserId = @UserId)
            THROW 51003, 'User cannot be both Student and Instructor.', 1;

        -- Validate active Branch
        IF NOT EXISTS (
            SELECT 1 FROM orgnization.Branch
            WHERE BranchId = @BranchId AND isActive = 1
        )
            THROW 51004, 'Invalid or inactive Branch.', 1;

        -- Validate active Intake
        IF NOT EXISTS (
            SELECT 1 FROM orgnization.Intake
            WHERE IntakeId = @IntakeId AND isActive = 1
        )
            THROW 51005, 'Invalid or inactive Intake.', 1;

        -- Validate active Track
        IF NOT EXISTS (
            SELECT 1 FROM orgnization.Track
            WHERE TrackId = @TrackId AND isActive = 1
        )
            THROW 51006, 'Invalid or inactive Track.', 1;

        -- Validate IntakeTrack relationship
        IF NOT EXISTS (
            SELECT 1
            FROM orgnization.IntakeTrack
            WHERE IntakeId = @IntakeId
              AND TrackId = @TrackId
              AND isActive = 1
        )
            THROW 51007, 'Track does not belong to this Intake.', 1;

        INSERT INTO userAcc.Student
        (
            FirstName, LastName, Gender, BirthDate,
            StuAddress, Phone, NationalID,
            UserId, BranchId, IntakeId, TrackId
        )
        VALUES
        (
            LTRIM(RTRIM(@FirstName)),
            LTRIM(RTRIM(@LastName)),
            @Gender,
            @BirthDate,
            @StuAddress,
            @Phone,
            @NationalID,
            @UserId,
            @BranchId,
            @IntakeId,
            @TrackId
        );

        PRINT 'Student added successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 2) Update Student
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_UpdateStudent
    @StudentId int,
    @FirstName nvarchar(50) = NULL,
    @LastName nvarchar(50) = NULL,
    @Gender char(1) = NULL,
    @BirthDate date = NULL,
    @StuAddress nvarchar(150) = NULL,
    @Phone nvarchar(11) = NULL,
    @NationalID nchar(14) = NULL,
    @BranchId int = NULL,
    @IntakeId int = NULL,
    @TrackId int = NULL,
    @IsActive bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1 FROM userAcc.Student WHERE StudentId = @StudentId
        )
            THROW 51020, 'Student not found.', 1;

        -- Validate phone uniqueness
        IF @Phone IS NOT NULL
           AND EXISTS (
                SELECT 1 FROM userAcc.Student
                WHERE Phone = @Phone
                  AND StudentId <> @StudentId
           )
            THROW 51022, 'Phone already exists.', 1;

        -- Validate NationalID uniqueness
        IF @NationalID IS NOT NULL
           AND EXISTS (
                SELECT 1 FROM userAcc.Student
                WHERE NationalID = @NationalID
                  AND StudentId <> @StudentId
           )
            THROW 51023, 'National ID already exists.', 1;

        -- Validate Branch if changed
        IF @BranchId IS NOT NULL
           AND NOT EXISTS (
                SELECT 1 FROM orgnization.Branch
                WHERE BranchId = @BranchId AND isActive = 1
           )
            THROW 51024, 'Invalid or inactive Branch.', 1;

        DECLARE @CurrentIntake int, @CurrentTrack int;

        SELECT 
            @CurrentIntake = IntakeId,
            @CurrentTrack  = TrackId
        FROM userAcc.Student
        WHERE StudentId = @StudentId;

        DECLARE @FinalIntake int = COALESCE(@IntakeId, @CurrentIntake);
        DECLARE @FinalTrack  int = COALESCE(@TrackId, @CurrentTrack);

        -- Always validate final IntakeTrack relationship
        IF NOT EXISTS (
            SELECT 1
            FROM orgnization.IntakeTrack
            WHERE IntakeId = @FinalIntake
              AND TrackId  = @FinalTrack
              AND isActive = 1
        )
            THROW 51021, 'Invalid Intake/Track combination.', 1;

        UPDATE userAcc.Student
        SET
            FirstName  = COALESCE(LTRIM(RTRIM(@FirstName)), FirstName),
            LastName   = COALESCE(LTRIM(RTRIM(@LastName)), LastName),
            Gender     = COALESCE(@Gender, Gender),
            BirthDate  = COALESCE(@BirthDate, BirthDate),
            StuAddress = COALESCE(@StuAddress, StuAddress),
            Phone      = COALESCE(@Phone, Phone),
            NationalID = COALESCE(@NationalID, NationalID),
            BranchId   = COALESCE(@BranchId, BranchId),
            IntakeId   = @FinalIntake,
            TrackId    = @FinalTrack,
            isActive   = COALESCE(@IsActive, isActive)
        WHERE StudentId = @StudentId;

        PRINT 'Student updated successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


------------------------------------------------------------
-- 3) Delete Student (Soft Delete Only)
------------------------------------------------------------
CREATE OR ALTER PROC [userAcc].stp_DeleteStudent
    @StudentId int
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM userAcc.Student
    WHERE StudentId = @StudentId
      AND isActive = 1;
END
GO


------------------------------------------------------------
-- 4) Soft Delete Trigger
------------------------------------------------------------
CREATE OR ALTER TRIGGER [userAcc].trg_PreventDeleteStudent
ON userAcc.Student
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent delete if answers exist
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN exams.Student_Answer SA
            ON d.StudentId = SA.StudentId
    )
        THROW 51030, 'Cannot delete student with submitted answers.', 1;

    -- Prevent delete if results exist
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN exams.Student_Exam_Result SR
            ON d.StudentId = SR.StudentId
    )
        THROW 51031, 'Cannot delete student with exam results.', 1;

    -- Soft deactivate Student
    UPDATE S
    SET isActive = 0
    FROM userAcc.Student S
    JOIN deleted d ON S.StudentId = d.StudentId;

    -- Also deactivate related UserAccount
    UPDATE UA
    SET isActive = 0
    FROM userAcc.UserAccount UA
    JOIN userAcc.Student S ON UA.UserId = S.UserId
    JOIN deleted d ON S.StudentId = d.StudentId;

END
GO
