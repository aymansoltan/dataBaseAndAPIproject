CREATE OR ALTER PROCEDURE [exams].stp_StudentSubmitAnswer 
    @ExamId          int,
    @QuestionId      int,
    @StudentResponse nvarchar(max)
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- ══════════════════════════════════════════════════════════════
        -- STEP 1: Get current student from SQL Server login
       
        -- ══════════════════════════════════════════════════════════════
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

        -- ══════════════════════════════════════════════════════════════
        -- STEP 2: Check exam exists and is not deleted
        -- ══════════════════════════════════════════════════════════════
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

        -- ══════════════════════════════════════════════════════════════
        -- STEP 3: Check exam is currently active (within time window)
        -- ══════════════════════════════════════════════════════════════
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
use [ExaminationSystemDB]
go

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
        -- step 1: get current instructor from sql server login
        -- ══════════════════════════════════════════════════════════════
        declare @CurrentInsId int;

        select @CurrentInsId = i.InsId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Instructor i
            on ua.UserId  = i.UserId
           and i.isActive = 1
        where  ua.UserName = replace(suser_name(), 'login', 'user')
          and  ua.isActive = 1;

        if @CurrentInsId is null
        begin
            raiserror('Access Denied. Only active instructors can grade answers.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 2: check exam exists, not deleted
        --         get EndTime + CourseInstanceId + TotalGrade
        --         TotalGrade needed later to calculate IsPassed
        -- ══════════════════════════════════════════════════════════════
        declare @ExamEnd          datetime,
                @ExamCourseInstId int,
                @ExamTotalGrade   int,
                @ExamTrackId      int,
                @ExamIntakeId     int,
                @ExamBranchId     int,
                @MinDegree        int,  -- course min pass degree
                @MaxDegree        int;  -- course max degree

        select @ExamEnd          = e.EndTime,
               @ExamCourseInstId = e.CourseInstanceId,
               @ExamTotalGrade   = e.TotalGrade,
               @ExamTrackId      = e.TrackId,
               @ExamIntakeId     = e.IntakeId,
               @ExamBranchId     = e.BranchId,
               @MinDegree        = c.MinDegree,
               @MaxDegree        = c.MaxDegree
        from   [exams].Exam                  e
        inner join [Courses].CourseInstance  ci on e.CourseInstanceId = ci.CourseInstanceId
        inner join [Courses].Course          c  on ci.CourseId        = c.CourseId
        where  e.ExamId    = @ExamId
          and  e.IsDeleted = 0;

        if @ExamEnd is null
        begin
            raiserror('Exam not found or has been deleted.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 3: exam must be over before grading
        -- ══════════════════════════════════════════════════════════════
        if getdate() <= @ExamEnd
        begin
            raiserror('Cannot grade answers while the exam is still active.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 4: check grading time window (EndTime to EndTime + 3h)
        --
        --         if window has passed and results not finalized yet:
        --           → set all null InstructorGrades to ceiling(Points/2)
        --           → calculate and insert results into Student_Exam_Result
        --           → raise error: grading period ended
        --
        --         if results already finalized:
        --           → raise error directly
        -- ══════════════════════════════════════════════════════════════
        if getdate() > dateadd(hour, 3, @ExamEnd)
        begin
            if not exists (
                select 1 from [exams].Student_Exam_Result
                where ExamId = @ExamId
            )
            begin
                -- give half points to all ungraded text answers
                update sa
                set    sa.InstructorGrade = ceiling(q.Points / 2.0)
                from   [exams].Student_Answer sa
                join   [exams].Question       q on sa.QuestionId = q.QuestionId
                where  sa.ExamId          = @ExamId
                  and  q.QuestionType     = 'Text'
                  and  sa.InstructorGrade is null;

                -- calculate passmark from course min/max degree
                declare @PassMark4 int = ceiling(
                    @ExamTotalGrade * cast(@MinDegree as float) / @MaxDegree
                );

                -- merge: update if result exists, insert if new
                merge [exams].Student_Exam_Result as target
                using (
                    select
                        sa.StudentId,
                        sum(isnull(sa.SystemGrade, 0) + isnull(sa.InstructorGrade, 0)) as TotalGrade,
                        case
                            when sum(isnull(sa.SystemGrade, 0) + isnull(sa.InstructorGrade, 0))
                                 >= @PassMark4
                            then 1 else 0
                        end as IsPassed
                    from   [exams].Student_Answer sa
                    where  sa.ExamId = @ExamId
                    group by sa.StudentId
                ) as source
                on  target.StudentId = source.StudentId
                and target.ExamId    = @ExamId
                when matched then
                    update set
                        target.TotalGrade = source.TotalGrade,
                        target.IsPassed   = source.IsPassed
                when not matched by target then
                    insert (StudentId, ExamId, TotalGrade, IsPassed)
                    values (source.StudentId, @ExamId, source.TotalGrade, source.IsPassed);

                print 'Grading window closed. Results finalized automatically for ExamId: '
                    + cast(@ExamId as nvarchar(10));
            end
            else
                print 'Grading window closed. Results were already finalized for ExamId: '
                    + cast(@ExamId as nvarchar(10));

            commit transaction;
            raiserror('Grading period has ended (3 hours after exam). No further grading is allowed.', 16, 1);
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 5: instructor must own this exam's courseinstance
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
        -- step 6: question must belong to this exam (via ExamQuestion)
        --         prevents grading a question from a different exam
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
        -- step 7: question must be of type text and not deleted
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
        -- step 8: get current InstructorGrade from Student_Answer
        --
        --         possible states:
        --         null → keyword matched, pending instructor review  → allow
        --         0    → auto zero (no keyword / empty answer)       → block
        --         > 0  → already graded, instructor wants to update  → allow
        -- ══════════════════════════════════════════════════════════════

        declare @CurrentInstructorGrade int;

        select @CurrentInstructorGrade = InstructorGrade
        from   [exams].Student_Answer
        where  StudentId  = @StudentId
          and  ExamId     = @ExamId
          and  QuestionId = @QuestionId;

        -- block auto-zero answers (no keyword match or empty response)
        if @CurrentInstructorGrade = 0
        begin
            raiserror('This answer was auto-graded as zero (no keyword match). No review needed.', 16, 1);
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 9: validate grade range
        -- ══════════════════════════════════════════════════════════════
        if @InstructorGrade < 0
        begin
            raiserror('Instructor grade cannot be negative.', 16, 1);
            rollback; return;
        end

        if @InstructorGrade > @Points
        begin
            raiserror(
                'Instructor grade (%d) cannot exceed question points (%d).',
                16, 1, @InstructorGrade, @Points
            );
            rollback; return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 10: update InstructorGrade
        --          print different message: new grade vs updated grade
        -- ══════════════════════════════════════════════════════════════
        update [exams].Student_Answer
        set    InstructorGrade = @InstructorGrade
        where  StudentId  = @StudentId
          and  ExamId     = @ExamId
          and  QuestionId = @QuestionId;

        if @CurrentInstructorGrade is null
            print 'Grade added. StudentId: '
                + cast(@StudentId       as nvarchar(10))
                + ' | QuestionId: '
                + cast(@QuestionId      as nvarchar(10))
                + ' | Grade: '
                + cast(@InstructorGrade as nvarchar(10))
                + ' / '
                + cast(@Points          as nvarchar(10));
        else
            print 'Grade updated. StudentId: '
                + cast(@StudentId              as nvarchar(10))
                + ' | QuestionId: '
                + cast(@QuestionId             as nvarchar(10))
                + ' | Old: '
                + cast(@CurrentInstructorGrade as nvarchar(10))
                + ' → New: '
                + cast(@InstructorGrade        as nvarchar(10))
                + ' / '
                + cast(@Points                 as nvarchar(10));

        -- ══════════════════════════════════════════════════════════════
        -- step 11: check remaining ungraded text answers
        --
        --          if none remaining → finalize results automatically
        --          if some remaining → print count and exit
        -- ══════════════════════════════════════════════════════════════
        declare @Remaining int;

        select @Remaining = count(*)
        from   [exams].Student_Answer sa
        join   [exams].Question       q on sa.QuestionId = q.QuestionId
        where  sa.ExamId          = @ExamId
          and  q.QuestionType     = 'Text'
          and  sa.InstructorGrade is null;

        if @Remaining > 0
        begin
            print 'Remaining text answers to grade: ' + cast(@Remaining as nvarchar(10));
            commit transaction;
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 12: finalize - all text answers graded
        --          insert results for every student who submitted answers
        --          students who never showed up → not inserted (no record)
        -- ══════════════════════════════════════════════════════════════
        print 'All text answers graded. Finalizing results...';

        -- calculate passmark from course min/max degree
        declare @PassMark int = ceiling(
            @ExamTotalGrade * cast(@MinDegree as float) / @MaxDegree
        );

        -- merge: update if result exists (instructor re-graded), insert if new
        merge [exams].Student_Exam_Result as target
        using (
            select
                sa.StudentId,
                sum(isnull(sa.SystemGrade, 0) + isnull(sa.InstructorGrade, 0)) as TotalGrade,
                case
                    when sum(isnull(sa.SystemGrade, 0) + isnull(sa.InstructorGrade, 0))
                         >= @PassMark
                    then 1 else 0
                end as IsPassed
            from   [exams].Student_Answer sa
            where  sa.ExamId = @ExamId
            group by sa.StudentId
        ) as source
        on  target.StudentId = source.StudentId
        and target.ExamId    = @ExamId
        when matched then
            update set
                target.TotalGrade = source.TotalGrade,
                target.IsPassed   = source.IsPassed
        when not matched by target then
            insert (StudentId, ExamId, TotalGrade, IsPassed)
            values (source.StudentId, @ExamId, source.TotalGrade, source.IsPassed);

        -- print summary
        declare @TotalStudents int,
                @PassedCount   int,
                @FailedCount   int;

        select @TotalStudents = count(*),
               @PassedCount   = sum(case when IsPassed = 1 then 1 else 0 end),
               @FailedCount   = sum(case when IsPassed = 0 then 1 else 0 end)
        from   [exams].Student_Exam_Result
        where  ExamId = @ExamId;

        print '══════════════════════════════════════';
        print 'Results finalized for ExamId : ' + cast(@ExamId        as nvarchar(10));
        print 'Total Students               : ' + cast(@TotalStudents as nvarchar(10));
        print 'Passed                       : ' + cast(@PassedCount   as nvarchar(10));
        print 'Failed                       : ' + cast(@FailedCount   as nvarchar(10));
        print '══════════════════════════════════════';

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