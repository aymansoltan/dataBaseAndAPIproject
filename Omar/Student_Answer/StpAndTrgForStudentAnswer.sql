CREATE or alter PROCEDURE [StudentStp].stp_StudentSubmitAnswer 
    @ExamId          int,
    @QuestionId      int,
    @StudentResponse nvarchar(max)
as
begin
    set nocount on;
    begin try
        begin transaction;

        declare @CurrentStudentId int;

        select @CurrentStudentId = s.StudentId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Student s
            on ua.UserId  = s.UserId
           and s.isActive = 1
        where  ua.UserName = suser_name()
          and  ua.isActive = 'true';

        if @CurrentStudentId is null
        begin
            raiserror('Access Denied. Only active students can submit answers.', 16, 1);
            rollback; return;
        end

        declare @ExamStart    datetime,
                @ExamEnd      datetime,
                @ExamTrackId  int,
                @ExamIntakeId int,
                @ExamBranchId int;

        select @ExamStart    = StartTime,
               @ExamEnd      = EndTime,
               @ExamTrackId  = TrackId,
               @ExamIntakeId = IntakeId,
               @ExamBranchId = BranchId
        from   [exams].Exam
        where  ExamId    = @ExamId
          and  IsDeleted = 0;

        if @ExamStart is null
        begin
            raiserror('Exam not found or has been deleted.', 16, 1);
            rollback; return;
        end

        if getdate() < @ExamStart
        begin
            raiserror('Exam has not started yet.', 16, 1);
            rollback; return;
        end


        if getdate() > @ExamEnd
        begin
            raiserror('Exam has already ended. Answers can no longer be submitted.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 4: Check student belongs to same Track, Intake and Branch
        -- ══════════════════════════════════════════════════════════════
        if not exists (
            select 1
            from   [userAcc].Student s
            where  s.StudentId = @CurrentStudentId
              and  s.TrackId   = @ExamTrackId
              and  s.IntakeId  = @ExamIntakeId
              and  s.BranchId  = @ExamBranchId
        )
        begin
            raiserror('Access Denied. You are not enrolled in the track/intake/branch for this exam.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 5: Check question exists in this exam
        -- ══════════════════════════════════════════════════════════════
        if not exists (
            select 1
            from   [exams].ExamQuestion
            where  ExamId     = @ExamId
              and  QuestionId = @QuestionId
        )
        begin
            raiserror('This question does not belong to the specified exam.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 6: Get question details needed for grading
        -- ══════════════════════════════════════════════════════════════
        declare @QuestionType nvarchar(20),
                @BestAnswer   nvarchar(max),
                @Points       int,
                @correct   nvarchar(max);

        select @QuestionType = QuestionType,
               @correct=[CorrectAnswer],
               @BestAnswer   = BestAnswer,
               @Points       = Points
        from   [exams].Question
        where  QuestionId = @QuestionId
          and  IsDeleted  = 0;

        if @QuestionType is null
        begin
            raiserror('Question not found or has been deleted.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 7: Validate response based on question type
        --
        -- MCQ  → must match one of the available options
        -- T/F  → only 'true' or 'false' accepted
        -- Text → empty response is allowed (auto zero, no reject)
        -- ══════════════════════════════════════════════════════════════
        if @QuestionType = 'MCQ'
        begin
            if @StudentResponse is null or trim(@StudentResponse) = ''
            begin
                raiserror('MCQ questions require a response.', 16, 1);
                rollback; return;
            end

            -- if not exists (
            --     select 1
            --     from   [exams].QuestionOption
            --     where  QuestionId        = @QuestionId
            --       and  lower(trim(QuestionOptionText)) = lower(trim(@StudentResponse))
            -- )
            -- begin
            --     raiserror('Invalid MCQ response: answer is not among the available options.', 16, 1);
            --     rollback; return;
            -- end
        end

        if @QuestionType = 'T/F'
        begin
            if @StudentResponse is null or trim(@StudentResponse) = ''
            begin
                raiserror('T/F questions require a response.', 16, 1);
                rollback; return;
            end

            if trim(lower(@StudentResponse)) not in ('true', 'false')
            begin
                raiserror('Invalid response for T/F question. Answer must be True or False.', 16, 1);
                rollback; return;
            end
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 8: Calculate SystemGrade and InstructorGrade
        --
        -- MCQ / T/F:
        --   Correct   → SystemGrade = Points | InstructorGrade = NULL
        --   Incorrect → SystemGrade = 0      | InstructorGrade = NULL
        --
        -- Text:
        --   Empty response   → SystemGrade = 0 | InstructorGrade = 0    (auto zero)
        --   Keyword match    → SystemGrade = 0 | InstructorGrade = NULL (pending review)
        --   No keyword match → SystemGrade = 0 | InstructorGrade = 0    (auto zero)
        -- ══════════════════════════════════════════════════════════════
        declare @SystemGrade     int = 0,
                @InstructorGrade int = null;

        if @QuestionType in ('MCQ', 'T/F')
        begin
            if trim(lower(@StudentResponse)) = trim(lower(@correct))
                set @SystemGrade = @Points;
            else
                set @SystemGrade = 0;
            -- InstructorGrade stays NULL (no manual grading needed)
        end

        else if @QuestionType = 'Text'
        begin
            -- Empty response → auto zero, no instructor review needed
            if @StudentResponse is null or trim(@StudentResponse) = ''
            begin
                set @SystemGrade     = 0;
                set @InstructorGrade = 0;
            end
            else
            begin
                -- Keyword matching: ignore short words (len < 3)
                -- to avoid false matches from words like 'a', 'is', 'to'
                declare @KeywordFound bit = 0;

                select top 1 @KeywordFound = 1
                from   string_split(@BestAnswer, ' ')
                where  len(trim(value)) >= 3
                  and  charindex(
                           trim(lower(value)),
                           trim(lower(@StudentResponse))
                       ) > 0;

                if @KeywordFound = 1
                begin
                    -- Keyword found → instructor must review
                    set @SystemGrade     = 0;
                    set @InstructorGrade = null;
                end
                else
                begin
                    -- No keyword found → auto zero
                    set @SystemGrade     = 0;
                    set @InstructorGrade = 0;
                end
            end
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 9: Insert or Update answer
        -- Already answered → UPDATE (allowed within exam time window)
        -- First time       → INSERT
        -- ══════════════════════════════════════════════════════════════
        if exists (
            select 1
            from   [exams].Student_Answer
            where  StudentId  = @CurrentStudentId
              and  ExamId     = @ExamId
              and  QuestionId = @QuestionId
        )
        begin
            update [exams].Student_Answer
            set    StudentResponse = @StudentResponse,
                   SystemGrade     = @SystemGrade,
                   InstructorGrade = @InstructorGrade
            where  StudentId  = @CurrentStudentId
              and  ExamId     = @ExamId
              and  QuestionId = @QuestionId;
        end
        else
        begin
            insert into [exams].Student_Answer
                (StudentId, ExamId, QuestionId,
                 StudentResponse, SystemGrade, InstructorGrade)
            values
                (@CurrentStudentId, @ExamId, @QuestionId,
                 @StudentResponse, @SystemGrade, @InstructorGrade);
        end


        print 'Answer submitted successfully for QuestionId: '
            + cast(@QuestionId as nvarchar(10));

        commit transaction;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @ErrMsg nvarchar(2000) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end
go
---------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [InstructorStp].stp_InstructorGradeText
    @ExamId          INT,
    @StudentId       INT,
    @QuestionId      INT,
    @InstructorGrade INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -------------------------------------------------
        -- 1️⃣ Get Current Instructor
        -------------------------------------------------
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = i.InsId
        FROM   [userAcc].UserAccount ua
        JOIN   [userAcc].Instructor  i
               ON ua.UserId = i.UserId
              AND i.IsActive = 1
        WHERE  ua.UserName = SUSER_NAME()
          AND  ua.IsActive = 'true';

        IF @CurrentInsId IS NULL
            THROW 50001, 'Access Denied. Only active instructors can grade.', 1;


        -------------------------------------------------
        -- 2️⃣ Validate Exam
        -------------------------------------------------
        DECLARE @ExamEnd DATETIME,
                @CourseInstanceId INT,
                @ExamTotalGrade INT,
                @MinDegree INT,
                @MaxDegree INT;

        SELECT  @ExamEnd = e.EndTime,
                @CourseInstanceId = e.CourseInstanceId,
                @ExamTotalGrade = e.TotalGrade,
                @MinDegree = c.MinDegree,
                @MaxDegree = c.MaxDegree
        FROM    [exams].Exam e
        JOIN    [Courses].CourseInstance ci ON e.CourseInstanceId = ci.CourseInstanceId
        JOIN    [Courses].Course c ON ci.CourseId = c.CourseId
        WHERE   e.ExamId = @ExamId
          AND   e.IsDeleted = 0;

        IF @ExamEnd IS NULL
            THROW 50002, 'Exam not found or deleted.', 1;


        -------------------------------------------------
        -- 3️⃣ Exam must be finished
        -------------------------------------------------
        IF GETDATE() <= @ExamEnd
            THROW 50003, 'Exam is still active.', 1;


        -------------------------------------------------
        -- 4️⃣ Check if grading window closed (3 hours)
        -------------------------------------------------
        IF GETDATE() > DATEADD(HOUR,3,@ExamEnd)
        BEGIN

            -- give half grade to ungraded text answers
            UPDATE sa
            SET    sa.InstructorGrade = CEILING(q.Points / 2.0)
            FROM   [exams].Student_Answer sa
            JOIN   [exams].Question q ON sa.QuestionId = q.QuestionId
            WHERE  sa.ExamId = @ExamId
              AND  q.QuestionType = 'Text'
              AND  sa.InstructorGrade IS NULL;

            DECLARE @PassMark INT =
                CEILING(@ExamTotalGrade * CAST(@MinDegree AS FLOAT) / @MaxDegree);

            MERGE [exams].Student_Exam_Result AS target
            USING (
                SELECT
                    sa.StudentId,
                    SUM(ISNULL(sa.SystemGrade,0) + ISNULL(sa.InstructorGrade,0)) AS TotalGrade
                FROM [exams].Student_Answer sa
                WHERE sa.ExamId = @ExamId
                GROUP BY sa.StudentId
            ) AS source
            ON target.StudentId = source.StudentId
            AND target.ExamId = @ExamId

            WHEN MATCHED THEN
                UPDATE SET
                    target.TotalGrade = source.TotalGrade,
                    target.IsPassed =
                        CASE WHEN source.TotalGrade >= @PassMark THEN 1 ELSE 0 END

            WHEN NOT MATCHED THEN
                INSERT (StudentId, ExamId, TotalGrade, IsPassed)
                VALUES (
                    source.StudentId,
                    @ExamId,
                    source.TotalGrade,
                    CASE WHEN source.TotalGrade >= @PassMark THEN 1 ELSE 0 END
                );

            COMMIT;
            THROW 50004, 'Grading window closed. Results finalized.', 1;
        END


        -------------------------------------------------
        -- 5️⃣ Check ownership
        -------------------------------------------------
        IF NOT EXISTS (
            SELECT 1
            FROM [Courses].CourseInstance
            WHERE CourseInstanceId = @CourseInstanceId
              AND InstructorId = @CurrentInsId
        )
            THROW 50005, 'Access Denied. Not your course.', 1;


        -------------------------------------------------
        -- 6️⃣ Validate Question
        -------------------------------------------------
        DECLARE @Points INT;

        SELECT @Points = Points
        FROM [exams].Question
        WHERE QuestionId = @QuestionId
          AND QuestionType = 'Text'
          AND IsDeleted = 0;

        IF @Points IS NULL
            THROW 50006, 'Invalid or non-text question.', 1;


        -------------------------------------------------
        -- 7️⃣ Validate Answer Exists
        -------------------------------------------------
        DECLARE @CurrentInstructorGrade INT;

        SELECT @CurrentInstructorGrade = InstructorGrade
        FROM [exams].Student_Answer
        WHERE StudentId = @StudentId
          AND ExamId = @ExamId
          AND QuestionId = @QuestionId;

        IF @@ROWCOUNT = 0
            THROW 50007, 'Student answer not found.', 1;

        IF @CurrentInstructorGrade = 0
            THROW 50008, 'Auto zero answer cannot be modified.', 1;


        -------------------------------------------------
        -- 8️⃣ Validate Grade Range
        -------------------------------------------------
        IF @InstructorGrade < 0
            THROW 50009, 'Grade cannot be negative.', 1;

        IF @InstructorGrade > @Points
            THROW 50010, 'Grade exceeds question points.', 1;


        -------------------------------------------------
        -- 9️⃣ Update Grade
        -------------------------------------------------
        UPDATE [exams].Student_Answer
        SET InstructorGrade = @InstructorGrade
        WHERE StudentId = @StudentId
          AND ExamId = @ExamId
          AND QuestionId = @QuestionId;


        -------------------------------------------------
        -- 🔟 Show remaining ungraded
        -------------------------------------------------
        DECLARE @Remaining INT;

        SELECT @Remaining = COUNT(*)
        FROM [exams].Student_Answer sa
        JOIN [exams].Question q ON sa.QuestionId = q.QuestionId
        WHERE sa.ExamId = @ExamId
          AND q.QuestionType = 'Text'
          AND sa.InstructorGrade IS NULL;

        PRINT 'Remaining text answers: ' + CAST(@Remaining AS NVARCHAR(10));

        COMMIT;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK;

        THROW;
    END CATCH
END
GO
--------------------------------- ----------------------------------------------
create  or alter procedure [InstructorStp].stp_deletstudentanswer 
@studentid int
as 
begin
delete from [exams].[Student_Answer]
where @studentid = StudentId
end
go
--------------------------------------------------------------------
create or alter trigger [exams].trg_StudentAnswer
on [exams].Student_Answer
instead of delete, update
as
begin
    set nocount on;

    -- ══════════════════════════════════════════════════════════════
    -- BLOCK DELETE: student answers can never be deleted
    -- ══════════════════════════════════════════════════════════════
    if exists (select 1 from deleted)
       and not exists (select 1 from inserted)
    begin
        raiserror('Student answers cannot be deleted.', 16, 1);
        rollback; return;
    end

    -- ══════════════════════════════════════════════════════════════
    -- HANDLE UPDATE
    -- ══════════════════════════════════════════════════════════════
    if exists (select 1 from inserted)
    begin
        -- ══════════════════════════════════════════════════════════
        -- CASE 1: exam is still active (checked per row)
        -- allow all columns to change
        -- SP already calculated SystemGrade + InstructorGrade correctly
        -- ══════════════════════════════════════════════════════════
        update sa
        set    sa.StudentResponse = i.StudentResponse,
               sa.SystemGrade     = i.SystemGrade,
               sa.InstructorGrade = i.InstructorGrade
        from   [exams].Student_Answer sa
        join   inserted i
            on sa.StudentId  = i.StudentId
           and sa.ExamId     = i.ExamId
           and sa.QuestionId = i.QuestionId
        join   [exams].Exam e
            on i.ExamId = e.ExamId
        where  getdate() between e.StartTime and e.EndTime;

        -- exit only if no rows need CASE 2 handling
        if not exists (
            select 1
            from   inserted i
            join   [exams].Exam e on i.ExamId = e.ExamId
            where  getdate() > e.EndTime
        )
        return;

        -- ══════════════════════════════════════════════════════════
        -- CASE 2: exam is over
        -- block if StudentResponse or SystemGrade changed
        -- isnull used to handle NULL comparisons correctly
        -- ══════════════════════════════════════════════════════════
        if exists (
            select 1
            from   inserted i
            join   deleted  d
                on i.StudentId  = d.StudentId
               and i.ExamId     = d.ExamId
               and i.QuestionId = d.QuestionId
            join   [exams].Exam e
                on i.ExamId = e.ExamId
            where  getdate() > e.EndTime
              and (
                    isnull(i.StudentResponse, '') != isnull(d.StudentResponse, '')
                 or isnull(i.SystemGrade, -1)     != isnull(d.SystemGrade, -1)
              )
        )
        begin
            raiserror('Exam is over. Only InstructorGrade can be updated.', 16, 1);
            rollback; return;
        end

        -- only InstructorGrade changed after exam ended → allow
        update sa
        set    sa.InstructorGrade = i.InstructorGrade
        from   [exams].Student_Answer sa
        join   inserted i
            on sa.StudentId  = i.StudentId
           and sa.ExamId     = i.ExamId
           and sa.QuestionId = i.QuestionId
        join   [exams].Exam e
            on i.ExamId = e.ExamId
        where  getdate() > e.EndTime;
    end
end
go
