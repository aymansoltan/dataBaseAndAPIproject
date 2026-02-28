CREATE OR ALTER PROCEDURE [StudentStp].stp_StudentSubmitAnswer 
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
        where  ua.UserName =replace( suser_name(),'login','user')
          and  ua.isActive = 1;

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
                @Points       int;

        select @QuestionType = QuestionType,
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

            if not exists (
                select 1
                from   [exams].QuestionOption
                where  QuestionId        = @QuestionId
                  and  lower(trim(QuestionOptionText)) = lower(trim(@StudentResponse))
            )
            begin
                raiserror('Invalid MCQ response: answer is not among the available options.', 16, 1);
                rollback; return;
            end
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
            if trim(lower(@StudentResponse)) = trim(lower(@BestAnswer))
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

create or alter procedure [exams].stp_InstructorGradeText
    @ExamId          int,
    @StudentId       int,
    @QuestionId      int,
    @InstructorGrade int
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- ══════════════════════════════════════════════════════════════
        -- STEP 1: Get current instructor from SQL Server login
        -- Check role = 'instructor' + isActive on both tables
        -- ══════════════════════════════════════════════════════════════
        declare @CurrentInsId int;

        select @CurrentInsId = i.InsId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Instructor i
            on ua.UserId  = i.UserId
           and i.isActive = 1
        where  ua.UserName =replace( suser_name(),'login','user')
          and  ua.isActive = 1;

        if @CurrentInsId is null
        begin
            raiserror('Access Denied. Only active instructors can grade answers.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 2: Check exam exists and is not deleted
        -- ══════════════════════════════════════════════════════════════
        declare @ExamEnd          datetime,
                @ExamCourseInstId int;

        select @ExamEnd          = EndTime,
               @ExamCourseInstId = CourseInstanceId
        from   [exams].Exam
        where  ExamId    = @ExamId
          and  IsDeleted = 0;

        if @ExamEnd is null
        begin
            raiserror('Exam not found or has been deleted.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 3: Check exam has already ended
        -- Grading is only allowed after the exam is over
        -- ══════════════════════════════════════════════════════════════
        if getdate() <= @ExamEnd
        begin
            raiserror('Cannot grade answers while the exam is still active.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 4: Check this instructor owns the CourseInstance
        -- ══════════════════════════════════════════════════════════════
        if not exists (
            select 1
            from   [Courses].CourseInstance
            where  CourseInstanceId = @ExamCourseInstId
              and  InstructorId     = @CurrentInsId
        )
        begin
            raiserror('Access Denied. You can only grade exams for your own course instances.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 5: Check question type is Text and not deleted
        -- ══════════════════════════════════════════════════════════════
        declare @Points int;

        select @Points = Points
        from   [exams].Question
        where  QuestionId   = @QuestionId
          and  QuestionType = 'Text'
          and  IsDeleted    = 0;

        if @Points is null
        begin
            raiserror('Question not found, deleted, or is not a Text question.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 6: Check student answer exists in Student_Answer
        -- NULL + no record  = answer not submitted
        -- NULL + record     = keyword matched, pending review
        -- 0                 = auto zero, no keyword match
        -- ══════════════════════════════════════════════════════════════
        declare @CurrentInstructorGrade int;

        select @CurrentInstructorGrade = InstructorGrade
        from   [exams].Student_Answer
        where  StudentId  = @StudentId
          and  ExamId     = @ExamId
          and  QuestionId = @QuestionId;

        if @CurrentInstructorGrade = 0
        begin
            raiserror('This answer was auto-graded as zero (no keyword match). No review needed.', 16, 1);
            rollback; return;
        end


        --if @CurrentInstructorGrade is null (
        --    select 1
        --    from   [exams].Student_Answer
        --    where  StudentId  = @StudentId
        --      and  ExamId     = @ExamId
        --      and  QuestionId = @QuestionId
        --)
        --begin
        --    raiserror('No answer found for this student and question.', 16, 1);
        --    rollback; return;
        --end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 7: Block auto zero answers from manual grading
        -- 0   = auto zero (no keyword match) → block
        -- NULL = keyword matched, pending    → allow
        -- > 0  = already graded before       → allow re-grade
        -- ══════════════════════════════════════════════════════════════

        -- ══════════════════════════════════════════════════════════════
        -- STEP 8: Validate grade is not negative
        -- ══════════════════════════════════════════════════════════════
        if @InstructorGrade < 0
        begin
            raiserror('Instructor grade cannot be negative.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 9: Validate grade does not exceed question points
        -- ══════════════════════════════════════════════════════════════
        if @InstructorGrade > @Points
        begin
            raiserror(
                'Instructor grade (%d) cannot exceed question points (%d).',
                16, 1, @InstructorGrade, @Points
            );
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- STEP 10: Update InstructorGrade
        -- Print different message for new grade vs updated grade
        -- ══════════════════════════════════════════════════════════════
        update [exams].Student_Answer
        set    InstructorGrade = @InstructorGrade
        where  StudentId  = @StudentId
          and  ExamId     = @ExamId
          and  QuestionId = @QuestionId;

        if @CurrentInstructorGrade is  null
            print 'Grade added successfully. StudentId: '
                + cast(@StudentId       as nvarchar(10))
                + ' | QuestionId: '
                + cast(@QuestionId      as nvarchar(10))
                + ' | Grade: '
                + cast(@InstructorGrade as nvarchar(10))
                + ' / '
                + cast(@Points          as nvarchar(10));
        else
            print 'Grade updated successfully. StudentId: '
                + cast(@StudentId              as nvarchar(10))
                + ' | QuestionId: '
                + cast(@QuestionId             as nvarchar(10))
                + ' | Old Grade: '
                + cast(@CurrentInstructorGrade as nvarchar(10))
                + ' → New Grade: '
                + cast(@InstructorGrade        as nvarchar(10))
                + ' / '
                + cast(@Points                 as nvarchar(10));

        -- ══════════════════════════════════════════════════════════════
        -- STEP 11: Show remaining ungraded Text answers for this exam
        -- Helps instructor track how many answers still need review
        -- ══════════════════════════════════════════════════════════════
        declare @Remaining int;

        select @Remaining = count(*)
        from   [exams].Student_Answer sa
        join   [exams].Question       q  on sa.QuestionId = q.QuestionId
        where  sa.ExamId          = @ExamId
          and  q.QuestionType     = 'Text'
          and  sa.InstructorGrade is null;

        if @Remaining = 0
            print 'All text answers have been graded for this exam.';
        else
            print 'Remaining text answers to grade: '
                + cast(@Remaining as nvarchar(10));

        commit transaction;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @ErrMsg nvarchar(2000) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end
go
--------------------------------- ----------------------------------------------
create  or alter procedure stp_deletstudentanswer 
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