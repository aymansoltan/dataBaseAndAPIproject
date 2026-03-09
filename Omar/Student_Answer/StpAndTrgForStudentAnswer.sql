CREATE TYPE [StudentStp].StudentAnswersTableType AS TABLE (
    QuestionId      smallint,
    StudentResponse varchar(max)
);

create or alter procedure [StudentStp].stp_StudentSubmitAnswer 
    @examid          smallint,
    @studentid       int,  
    @answers         [StudentStp].StudentAnswersTableType readonly 
as
begin
    set nocount on;
    begin try
        begin transaction;

       
        if not exists (select 1 from [exams].exam where examid = @examid and isdeleted = 0)
            throw 53020, 'error: exam not found or has been deleted.', 1;

       
        if not exists (select 1 from [userAcc].student s where s.studentid = @studentid and s.isactive = 1 and s.isdeleted = 0)
            throw 53021, 'error: student not found, inactive, or deleted.', 1;

      
        declare @examstart datetime2(0), @examend datetime2(0), @examtrackid smallint, 
                @examintakeid tinyint, @exambranchid tinyint, @examtype varchar(11), @courseinstanceid smallint;

        select @examstart = starttime, @examend = endtime, @examtrackid = trackid, 
               @examintakeid = intakeid, @exambranchid = branchid, @examtype = lower(examtype), 
               @courseinstanceid = courseinstanceid
        from [exams].exam where examid = @examid and isdeleted = 0;

     
        if getdate() < @examstart throw 53022, 'error: exam not started yet.', 1;
        if getdate() > @examend   throw 53023, 'error: exam has already ended.', 1;

     
        if @examtype = 'regular'
        begin
            if not exists (select 1 from [userAcc].student s where s.studentid = @studentid and s.trackid = @examtrackid and s.intakeid = @examintakeid and s.branchid = @exambranchid)
                throw 53024, 'access denied: you are not enrolled in the track/intake/branch for this exam.', 1;
        end
        else if @examtype = 'corrective'
        begin
            declare @regularexamid smallint;
            select @regularexamid = examid from [exams].exam where courseinstanceid = @courseinstanceid and lower(examtype) = 'regular' and isdeleted = 0;

            if exists (select 1 from [exams].student_exam_result where studentid = @studentid and examid = @regularexamid and ispassed = 1)
                throw 53026, 'access denied: you passed the regular exam and cannot take the corrective exam.', 1;
        end

        declare @currentqid smallint, @currentresponse varchar(max);
        
        declare answer_cursor cursor local fast_forward for 
        select questionid, studentresponse from @answers;

        open answer_cursor;
        fetch next from answer_cursor into @currentqid, @currentresponse;

        while @@fetch_status = 0
        begin
            if exists (select 1 from [exams].examquestion where examid = @examid and questionid = @currentqid)
            begin
                declare @qtype varchar(11), @correctans varchar(1000), @bestans varchar(1000), @qpoints tinyint;
                declare @sysgrade int = 0, @instgrade int = null;

                select @qtype = lower(questiontype), @correctans = lower(correctanswer), @bestans = lower(bestanswer), @qpoints = points
                from [exams].question where questionid = @currentqid and isdeleted = 0;

                if @qtype in ('mcq', 't/f')
                begin
                    if trim(lower(@currentresponse)) = trim(@correctans) 
                        set @sysgrade = @qpoints;
                end
                else if @qtype = 'text'
                begin
                    if @currentresponse is null or trim(@currentresponse) = ''
                    begin
                        set @sysgrade = 0; set @instgrade = 0;
                    end
                    else
                    begin
                        declare @keywordfound bit = 0;
                        select top 1 @keywordfound = 1 
                        from string_split(@bestans, ' ') 
                        where len(trim(value)) >= 3 
                          and charindex(trim(lower(value)), trim(lower(@currentresponse))) > 0;

                        if @keywordfound = 1 set @instgrade = null; 
                        else set @instgrade = 0;
                    end
                end

                merge into [exams].student_answer as target
                using (select @studentid as sid, @examid as eid, @currentqid as qid) as source
                on target.studentid = source.sid and target.examid = source.eid and target.questionid = source.qid
                when matched then
                    update set studentresponse = @currentresponse, systemgrade = @sysgrade, instructorgrade = @instgrade
                when not matched then
                    insert (studentid, examid, questionid, studentresponse, systemgrade, instructorgrade)
                    values (@studentid, @examid, @currentqid, @currentresponse, @sysgrade, @instgrade);
            end

            fetch next from answer_cursor into @currentqid, @currentresponse;
        end

        close answer_cursor;
        deallocate answer_cursor;

        commit transaction;
        
        declare @totalqs int, @answeredqs int;
        select @totalqs = count(*) from [exams].examquestion where examid = @examid;
        select @answeredqs = count(*) from [exams].student_answer where studentid = @studentid and examid = @examid;

        select 1 as success, 'answers submitted successfully' as message, @answeredqs as answeredcount, @totalqs as totalcount;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @errmsg nvarchar(2000) = lower(error_message());
        raiserror(@errmsg, 16, 1);
    end catch
end;
go
---------------------------------------------------------------------------------------------

create type [InstructorStp].InstructorGradingTableType as table (
    studentid    int,
    questionid   smallint,
    grade        tinyint
);

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
        select 1 as success, 'grading completed and results finalized.' as message;

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