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
           and s.isActive =1
        where  ua.UserName = replace(suser_name() ,'login' , 'user')  and ua.[isActive]=1;

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
        declare @ExamType nvarchar(20),
        @CourseInstanceId int;

        select @ExamType         = ExamType,
               @CourseInstanceId = CourseInstanceId
        from   [exams].Exam
        where  ExamId = @ExamId;

        if @ExamType = 'Regular'
        begin
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
        end
         else if @ExamType = 'Corrective'
        begin
            -- get the Regular exam for the same CourseInstance
            declare @RegularExamId int;

            select @RegularExamId = ExamId
            from   [exams].Exam
            where  CourseInstanceId = @CourseInstanceId
              and  ExamType         = 'Regular'
              and  IsDeleted        = 0;

            if @RegularExamId is null
            begin
                raiserror('No Regular exam found for this course instance.', 16, 1);
                rollback; return;
            end

            -- block student if they passed the Regular exam
            if exists (
                select 1
                from   [exams].Student_Exam_Result
                where  StudentId = @CurrentStudentId
                  and  ExamId    = @RegularExamId
                  and  IsPassed  = 1
            )
            begin
                raiserror('Access Denied. You passed the Regular exam and cannot take the Corrective exam.', 16, 1);
                rollback; return;
            end
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
               @correct      =[CorrectAnswer],
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



        declare @TotalQuestions   int,
                    @AnsweredQuestions int;

            select @TotalQuestions = count(*)
            from   [exams].ExamQuestion
            where  ExamId = @ExamId;

            select @AnsweredQuestions = count(*)
            from   [exams].Student_Answer
            where  StudentId = @CurrentStudentId
            and  ExamId    = @ExamId;

            print 'Answer submitted successfully for QuestionId: '
                + cast(@QuestionId as nvarchar(10));

            print 'Progress: '
                + cast(@AnsweredQuestions as nvarchar(10))
                + ' out of '
                + cast(@TotalQuestions as nvarchar(10))
                + ' questions answered.';

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
go
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

        DECLARE @CurrentInsId INT;
        SELECT @CurrentInsId = i.InsId
        FROM [userAcc].[UserAccount] ua JOIN [userAcc].Instructor i ON 
        ua.UserId = i.UserId AND i.IsActive = 1
        WHERE ua.UserName = replace(suser_name() ,'login' , 'user') AND ua.isactive = 1;

        IF @CurrentInsId IS NULL
            THROW 50001, 'Access Denied. Only active instructors can grade.', 1;

        DECLARE @ExamEnd DATETIME,
                @ExamCourseInstId int, -- سيتم استخدامه لاحقاً
                @ExamTotalGrade   int,
                @MinDegree        int,
                @MaxDegree        int;

        -- تصحيح: إضافة جلب CourseInstanceId هنا عشان ميدي الكود Error تحت
        SELECT @ExamEnd          = e.EndTime,
               @ExamCourseInstId = e.CourseInstanceId, 
               @ExamTotalGrade   = e.TotalGrade,
               @MinDegree        = c.MinDegree,
               @MaxDegree        = c.MaxDegree
        FROM [exams].Exam e
         JOIN [Courses].CourseInstance ci on e.CourseInstanceId = ci.CourseInstanceId
         JOIN [Courses].Course c on ci.CourseId = c.CourseId
        WHERE e.ExamId = @ExamId AND e.IsDeleted = 0;

        IF @ExamEnd IS NULL
            THROW 50002, 'Exam not found or deleted.', 1;

        IF GETDATE() <= @ExamEnd
            THROW 50003, 'Exam is still active.', 1;

        DECLARE @PassMark INT = CEILING(@ExamTotalGrade * CAST(@MinDegree AS FLOAT) / @MaxDegree);

        IF GETDATE() > DATEADD(HOUR,3,@ExamEnd)
        BEGIN
            UPDATE sa
            SET sa.InstructorGrade = CEILING(q.Points / 2.0)
            FROM [exams].Student_Answer sa
            JOIN [exams].Question q ON sa.QuestionId = q.QuestionId
            WHERE sa.ExamId = @ExamId AND q.QuestionType = 'Text' AND sa.InstructorGrade IS NULL;

            MERGE [exams].Student_Exam_Result AS target
            USING (
                SELECT sa.StudentId, sa.ExamId,
                       SUM(ISNULL(sa.SystemGrade, 0) 
                       + ISNULL(sa.InstructorGrade, 0))
                       as TotalGrade,
                       CASE
                       WHEN SUM(ISNULL(sa.SystemGrade, 0) + ISNULL(sa.InstructorGrade, 0)) >= @PassMark THEN 1 ELSE 0 END as IsPassed
                FROM [exams].Student_Answer sa
                WHERE sa.ExamId = @ExamId
                GROUP BY sa.StudentId, sa.ExamId
            ) AS source
            ON target.StudentId = source.StudentId AND target.ExamId = source.ExamId
            WHEN MATCHED THEN UPDATE SET target.TotalGrade = source.TotalGrade, target.IsPassed = source.IsPassed
            WHEN NOT MATCHED THEN INSERT (StudentId, ExamId, TotalGrade, IsPassed) VALUES (source.StudentId, source.ExamId, source.TotalGrade, source.IsPassed);
            
            COMMIT TRANSACTION;
            PRINT 'Grading window closed. Results finalized automatically.';
            RETURN;
        END

        -- تصحيح: استخدام @ExamCourseInstId اللي جبناه فوق
        IF NOT EXISTS (SELECT 1 FROM [Courses].CourseInstance WHERE CourseInstanceId = @ExamCourseInstId AND InstructorId = @CurrentInsId)
            THROW 50005, 'Access Denied. Not your course.', 1;


                    IF NOT EXISTS (
                SELECT 1
                FROM   [exams].ExamQuestion
                WHERE  ExamId     = @ExamId
                AND  QuestionId = @QuestionId
            )
                THROW 50006, 'This question does not belong to the specified exam.', 1;

        DECLARE @Points INT;
        SELECT @Points = Points FROM [exams].Question WHERE QuestionId = @QuestionId AND QuestionType = 'Text' AND IsDeleted = 0;
        
        IF @Points IS NULL THROW 50007, 'Invalid or non-text question.', 1;

        DECLARE @CurrentInstructorGrade INT, @AnswerExists bit = 0;
        SELECT @CurrentInstructorGrade = InstructorGrade, @AnswerExists = 1 
        FROM [exams].Student_Answer WHERE StudentId = @StudentId AND ExamId = @ExamId AND QuestionId = @QuestionId;

        IF @AnswerExists = 0 THROW 50008, 'No answer found.', 1;
        IF @CurrentInstructorGrade = 0 THROW 50009, 'Already auto-graded as zero.', 1;
        IF @InstructorGrade < 0
            THROW 50010, 'Instructor grade cannot be negative.', 1;

        IF @InstructorGrade > @Points
            THROW 50011, 'Instructor grade exceeds question points.', 1;

        UPDATE [exams].Student_Answer SET InstructorGrade = @InstructorGrade 
        WHERE StudentId = @StudentId AND ExamId = @ExamId AND QuestionId = @QuestionId;

        -- تصحيح القوس الـ ناقص في الـ Print والـ Cast
        PRINT 'Grade updated. Student: ' + cast(@StudentId as nvarchar(10)) + ' | Question: ' + cast(@QuestionId as nvarchar(10)) + ' | New Grade: ' + cast(@InstructorGrade as nvarchar(10));

        DECLARE @Remaining INT;
        SELECT @Remaining = COUNT(*) FROM [exams].Student_Answer sa JOIN [exams].Question q ON sa.QuestionId = q.QuestionId
        WHERE sa.ExamId = @ExamId AND q.QuestionType = 'Text' AND sa.InstructorGrade IS NULL;

        IF @Remaining = 0
        BEGIN
            PRINT 'All text answers graded. Finalizing results...';
            MERGE [exams].[Student_Exam_Result] AS target
            USING (
                SELECT sa.StudentId, sa.ExamId, SUM(ISNULL(sa.SystemGrade, 0) + ISNULL(sa.InstructorGrade, 0)) as TotalGrade,
                       CASE WHEN SUM(ISNULL(sa.SystemGrade, 0) + ISNULL(sa.InstructorGrade, 0)) >= @PassMark THEN 1 ELSE 0 END as IsPassed
                FROM [exams].Student_Answer sa WHERE sa.ExamId = @ExamId GROUP BY sa.StudentId, sa.ExamId
            ) AS source
            ON target.StudentId = source.StudentId AND target.ExamId = source.ExamId
            WHEN MATCHED THEN UPDATE SET target.TotalGrade = source.TotalGrade, target.IsPassed = source.IsPassed
            WHEN NOT MATCHED THEN INSERT (StudentId, ExamId, TotalGrade, IsPassed) VALUES (source.StudentId, source.ExamId, source.TotalGrade, source.IsPassed);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @ErrMsg nvarchar(2000) = error_message();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
go
------------------------- ----------------------------------------------
CREATE or ALTER PROCEDURE [InstructorStp].stp_deletstudentanswer 
    @studentid INT,
    @examid INT,    
    @questionid INT
AS 
BEGIN

    DELETE FROM [exams].[Student_Answer]
    WHERE StudentId = @studentid 
      AND ExamId = @examid 
      AND QuestionId = @questionid;
END
GO
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
