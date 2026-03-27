CREATE TYPE [StudentStp].StudentAnswersTableType AS TABLE (
    QuestionId      smallint,
    StudentResponse varchar(max)
);
go
CREATE OR ALTER PROCEDURE [StudentStp].stp_StudentSubmitAnswer 
    @examid          smallint,
    @studentid       int,  
    @answers         [StudentStp].StudentAnswersTableType READONLY 
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- 1. التحقق من صلاحية الامتحان
        DECLARE @examstart datetime2(0), @examend datetime2(0);
        SELECT @examstart = starttime, @examend = endtime 
        FROM [exams].exam WHERE examid = @examid AND isdeleted = 0;

        IF @@ROWCOUNT = 0 THROW 53020, 'Error: Exam not found.', 1;
        IF GETDATE() NOT BETWEEN @examstart AND @examend THROW 53023, 'Error: Exam is not active.', 1;

        BEGIN TRANSACTION;

            -- 2. تحديث الإجابات الموجودة مسبقاً (سيقوم بتفعيل التريجر INSTEAD OF UPDATE)
            UPDATE sa
            SET sa.studentresponse = ans.StudentResponse,
                sa.systemgrade = CASE 
                                    WHEN LOWER(q.QuestionType) IN ('mcq', 't/f') 
                                         AND LOWER(TRIM(ans.StudentResponse)) = LOWER(TRIM(q.CorrectAnswer)) THEN q.Points
                                    ELSE 0 
                                 END,
                sa.instructorgrade = CASE 
                                        WHEN LOWER(q.QuestionType) = 'text' AND (ans.StudentResponse IS NULL OR TRIM(ans.StudentResponse) = '') THEN 0
                                        ELSE sa.instructorgrade -- احتفظ بالدرجة القديمة لو موجودة
                                     END
            FROM [exams].student_answer sa
            JOIN @answers ans ON sa.questionid = ans.QuestionId
            JOIN [exams].question q ON sa.questionid = q.questionid
            WHERE sa.studentid = @studentid AND sa.examid = @examid;

            -- 3. إضافة الإجابات الجديدة (التي لم تكن موجودة)
            INSERT INTO [exams].student_answer (studentid, examid, questionid, studentresponse, systemgrade, instructorgrade)
            SELECT 
                @studentid, @examid, ans.QuestionId, ans.StudentResponse,
                CASE 
                    WHEN LOWER(q.QuestionType) IN ('mcq', 't/f') 
                         AND LOWER(TRIM(ans.StudentResponse)) = LOWER(TRIM(q.CorrectAnswer)) THEN q.Points
                    ELSE 0 
                END,
                CASE 
                    WHEN LOWER(q.QuestionType) = 'text' AND (ans.StudentResponse IS NULL OR TRIM(ans.StudentResponse) = '') THEN 0
                    ELSE NULL 
                END
            FROM @answers ans
            JOIN [exams].question q ON ans.QuestionId = q.questionid
            JOIN [exams].examquestion eq ON q.questionid = eq.questionid AND eq.examid = @examid
            WHERE NOT EXISTS (
                SELECT 1 FROM [exams].student_answer sa 
                WHERE sa.studentid = @studentid AND sa.examid = @examid AND sa.questionid = ans.QuestionId
            );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
---------------------------------------------------------------------------------------------

create type [InstructorStp].InstructorGradingTableType as table (
    studentid    int,
    questionid   smallint,
    grade        tinyint
);
go
create or alter procedure [InstructorStp].stp_InstructorGradeText
    @examid          smallint,
    @instructorid    int, 
    @gradingtable    [InstructorStp].InstructorGradingTableType readonly
as
begin
    set nocount on;
    begin try
        begin transaction;


        if not exists (select 1 from [userAcc].instructor where InstructorId = @instructorid and isactive = 1 and isdeleted = 0)
            throw 50001, 'access denied: instructor not found or inactive.', 1;

        -- 2. جلب بيانات الامتحان والدرجات المطلوبة للنجاح
        declare @examend datetime2(0), @examcourseinstid smallint, @examtotalgrade tinyint, @mindegree tinyint, @maxdegree tinyint;

        select @examend          = e.endtime,
               @examcourseinstid = e.courseinstanceid, 
               @examtotalgrade   = e.totalgrade,
               @mindegree        = c.mindegree,
               @maxdegree        = c.maxdegree
        from [exams].exam e
        join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
        join [courses].course c on ci.courseid = c.courseid
        where e.examid = @examid and e.isdeleted = 0;

        if @examend is null throw 50002, 'error: exam not found or deleted.', 1;
        if getdate() <= @examend throw 50003, 'error: exam is still active. grading starts after exam ends.', 1;

  
        declare @passmark int = ceiling(@examtotalgrade * cast(@mindegree as float) / @maxdegree);

  
        if not exists (select 1 from [courses].courseinstance where courseinstanceid = @examcourseinstid and instructorid = @instructorid)
            throw 50005, 'access denied: you are not assigned to this course.', 1;

   
        declare @sid int, @qid smallint, @grade tinyint;
        declare grade_cursor cursor local fast_forward for 
        select studentid, questionid, grade from @gradingtable;

        open grade_cursor;
        fetch next from grade_cursor into @sid, @qid, @grade;

        while @@fetch_status = 0
        begin

            declare @qpoints tinyint;
            select @qpoints = points from [exams].question q
            join [exams].examquestion eq on q.questionid = eq.questionid
            where q.questionid = @qid and eq.examid = @examid and q.questiontype = 'text' and q.isdeleted = 0;

            if @qpoints is not null
            begin
           
                if @grade >= 0 and @grade <= @qpoints
                begin
                    update [exams].student_answer 
                    set instructorgrade = @grade 
                    where studentid = @sid and examid = @examid and questionid = @qid 
                      and (instructorgrade is null or instructorgrade <> 0); 
                end
            end

            fetch next from grade_cursor into @sid, @qid, @grade;
        end

        close grade_cursor;
        deallocate grade_cursor;

  
        merge [exams].student_exam_result as target
        using (
            select sa.studentid, sa.examid, 
                   sum(isnull(sa.systemgrade, 0) + isnull(sa.instructorgrade, 0)) as totalgrade,
                   case when sum(isnull(sa.systemgrade, 0) + isnull(sa.instructorgrade, 0)) >= @passmark then 1 else 0 end as ispassed
            from [exams].student_answer sa 
            where sa.examid = @examid 
            group by sa.studentid, sa.examid
        ) as source
        on target.studentid = source.studentid and target.examid = source.examid
        when matched then 
            update set target.totalgrade = source.totalgrade, target.ispassed = source.ispassed
        when not matched then 
            insert (studentid, examid, totalgrade, ispassed) 
            values (source.studentid, source.examid, source.totalgrade, source.ispassed);

        commit transaction;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        throw;
    end catch
end;
go
------------------------- ----------------------------------------------
CREATE or ALTER PROCEDURE [InstructorStp].stp_deletstudentanswer 
    @studentid INT,
    @examid smallint,    
    @questionid smallint
AS 
BEGIN

    DELETE FROM [exams].[Student_Answer]
    WHERE StudentId = @studentid 
      AND ExamId = @examid 
      AND QuestionId = @questionid;
END
GO
--------------------------------------------------------------------
create or alter trigger [exams].trg_studentanswer
on [exams].student_answer
instead of delete, update
as
begin
    set nocount on;

  
    if exists (select 1 from deleted) and not exists (select 1 from inserted)
        throw 53025, 'error: student answers cannot be deleted.', 1;
    


    if exists (select 1 from inserted)
    begin

        update sa
        set    sa.studentresponse = i.studentresponse,
               sa.systemgrade     = i.systemgrade,
               sa.instructorgrade = i.instructorgrade
        from   [exams].student_answer sa
        join   inserted i on sa.studentid = i.studentid and sa.examid = i.examid and sa.questionid = i.questionid
        join   [exams].exam e on i.examid = e.examid
        where  getdate() between e.starttime and e.endtime;

        update sa
        set    sa.instructorgrade = i.instructorgrade
        from   [exams].student_answer sa
        join   inserted i on sa.studentid = i.studentid and sa.examid = i.examid and sa.questionid = i.questionid
        join   [exams].exam e on i.examid = e.examid
        where  getdate() > e.endtime;
        
    end
end
go