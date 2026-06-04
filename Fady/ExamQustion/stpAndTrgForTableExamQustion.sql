USE [ExaminationSystemDB]
GO

create or alter procedure [InstructorStp].stp_addexamquestion
    @examid        int,
    @questionids   nvarchar(max),
    @skipexisting  bit = 0,
    @addedcount    int = null output
as
begin
    set nocount on;
    begin try
        begin transaction;

        declare @currentinsid int, @courseid int, @starttime datetime, @isdeleted bit;

        select 
            @currentinsid = i.insid,
            @courseid     = ci.courseid,
            @starttime    = e.starttime,
            @isdeleted    = e.isdeleted
        from [exams].exam e
        join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
        join [useracc].instructor i on ci.instructorid = i.insid
        join [useracc].useraccount ua on i.userid = ua.userid
        where e.examid = @examid 
          and ua.username = replace(suser_name(), 'login', 'user')
          and i.isactive = 1;

        if @currentinsid is null throw 50001, 'access denied: you are not the owner or exam not found.', 1;
        if @isdeleted = 1    throw 50002, 'cannot modify a deleted exam.', 1;
        if @starttime <= getdate() throw 50003, 'exam has already started.', 1;
        
        if getdate() >= dateadd(hour, -1, @starttime)
            throw 50004, 'exam is locked: 1 hour before start.', 1;

        if exists (select 1 from [exams].student_answer where examid = @examid)
            throw 50005, 'cannot modify: students are already testing.', 1;

        if isnull(trim(@questionids), '') = '' throw 50006, 'questionids cannot be empty.', 1;

        declare @qids table (qid int primary key); -- Primary key هنا بيمنع التكرار أوتوماتيكياً أسرع من Distinct
        insert into @qids (qid)
        select distinct cast(trim(value) as int)
        from string_split(@questionids, ',')
        where trim(value) <> '';

        if exists (
            select 1 from @qids qt
            left join [exams].question q on qt.qid = q.questionid 
                and q.courseid = @courseid and q.isdeleted = 0
            where q.questionid is null
        )
        throw 50007, 'one or more questions are invalid, deleted, or belong to another course.', 1;

        if @skipexisting = 0 and exists (
            select 1 from @qids qt 
            join [exams].examquestion eq on qt.qid = eq.questionid and eq.examid = @examid
        )
        throw 50008, 'some questions already exist in this exam. set @skipexisting=1 to ignore.', 1;

        insert into [exams].examquestion (examid, questionid)
        select @examid, qt.qid
        from @qids qt
        where not exists (
            select 1 from [exams].examquestion eq 
            where eq.examid = @examid and eq.questionid = qt.qid
        );

        set @addedcount = @@rowcount;
        
        commit transaction;
        print 'success: ' + cast(@addedcount as nvarchar(10)) + ' questions processed.';

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;

--=====================================================================
go
create or alter procedure [InstructorStp].stp_updateexamquestion
    @examid        int,
    @oldquestionid int           = null,   
    @newquestionid int           = null,   
    @swaplist      nvarchar(max) = null    
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- 1. جلب بيانات المدرس والامتحان في خبطة واحدة (Optimization)
        declare @currentinsid int, @courseid int, @starttime datetime, @isdeleted bit;

        select 
            @currentinsid = i.insid,
            @courseid     = ci.courseid,
            @starttime    = e.starttime,
            @isdeleted    = e.isdeleted
        from [exams].exam e
        join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
        join [useracc].instructor i on ci.instructorid = i.insid
        join [useracc].useraccount ua on i.userid = ua.userid
        where e.examid = @examid 
          and ua.username = replace(suser_name(), 'login', 'user')
          and i.isactive = 1;

        -- 2. التحقق من الصلاحيات والقيود الأساسية
        if @currentinsid is null throw 50001, 'access denied: instructor profile not found or not owner.', 1;
        if @isdeleted = 1    throw 50002, 'cannot update questions of a deleted exam.', 1;
        
        -- قيد الوقت (قبل الامتحان بساعة)
        if getdate() >= dateadd(hour, -1, @starttime)
            throw 50003, 'locked: cannot update questions within 1 hour of start.', 1;

        -- فحص لو طلاب بدأوا فعلياً
        if exists (select 1 from [exams].student_answer where examid = @examid)
            throw 50004, 'locked: students have already started this exam.', 1;

        -- 3. بناء جدول الـ Swaps (تجهيز البيانات)
        declare @swaps table (oldid int primary key, newid int unique);

        if isnull(trim(@swaplist), '') <> ''
        begin
            insert into @swaps (oldid, newid)
            select
                cast(trim(left(trim(value), charindex(':', trim(value)) - 1)) as int),
                cast(trim(right(trim(value), len(trim(value)) - charindex(':', trim(value)))) as int)
            from string_split(@swaplist, ',')
            where trim(value) like '%:%';
        end
        else if @oldquestionid is not null and @newquestionid is not null
        begin
            insert into @swaps (oldid, newid) values (@oldquestionid, @newquestionid);
        end
        else
            throw 50005, 'must provide either (@oldquestionid + @newquestionid) or @swaplist.', 1;

        -- 4. Validate Swaps (تأمين جودة البيانات)
        
        -- أ. فحص لو السؤال القديم مش في الامتحان أصلاً
        if exists (
            select 1 from @swaps s 
            left join [exams].examquestion eq on eq.questionid = s.oldid and eq.examid = @examid
            where eq.questionid is null
        )
        throw 50006, 'one or more old questions are not assigned to this exam.', 1;

        -- ب. فحص لو السؤال الجديد مش تبع المادة أو ممسوح
        if exists (
            select 1 from @swaps s 
            left join [exams].question q on q.questionid = s.newid and q.courseid = @courseid and q.isdeleted = 0
            where q.questionid is null
        )
        throw 50007, 'one or more new questions are invalid or belong to another course.', 1;

        -- جـ. فحص لو السؤال الجديد موجود "فعلياً" في الامتحان (ومش موجود في لستة الـ Old اللي هتتبدل)
        if exists (
            select 1 from @swaps s
            join [exams].examquestion eq on eq.questionid = s.newid and eq.examid = @examid
            where s.newid not in (select oldid from @swaps)
        )
        throw 50008, 'one or more new questions are already in the exam.', 1;

        -- 5. تنفيذ التحديث (Execution)
        update eq
        set eq.questionid = s.newid
        from [exams].examquestion eq
        inner join @swaps s on eq.questionid = s.oldid
        where eq.examid = @examid;

        declare @updatedcount int = @@rowcount;

        commit transaction;
        print 'success: ' + cast(@updatedcount as nvarchar(10)) + ' swaps applied.';

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;
go


-- =====================================================================
--  stp_DeleteExamQuestion  (v2 - Improved)
create or alter procedure [InstructorStp].stp_deleteexamquestion
    @examid        int,
    @questionids   nvarchar(max),
    @skipnotfound  bit = 0,
    @removedcount  int = null output
as
begin
    set nocount on;
    begin try
        begin transaction;

        declare @currentinsid int, @starttime datetime, @isdeleted bit, @courseinstanceid int;

        select 
            @currentinsid     = i.insid,
            @starttime        = e.starttime,
            @isdeleted        = e.isdeleted,
            @courseinstanceid = e.courseinstanceid
        from [exams].exam e
        join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
        join [useracc].instructor i on ci.instructorid = i.insid
        join [useracc].useraccount ua on i.userid = ua.userid
        where e.examid = @examid 
          and ua.username = replace(suser_name(), 'login', 'user')
          and i.isactive = 1;

        if @currentinsid is null throw 50001, 'access denied: instructor profile not found or not owner.', 1;
        if @isdeleted = 1    throw 50002, 'cannot remove questions from a deleted exam.', 1;
        if @starttime <= getdate() throw 50003, 'exam has already started.', 1;
        
        if getdate() >= dateadd(hour, -1, @starttime)
            throw 50004, 'locked: cannot modify within 1 hour of start.', 1;

        if exists (select 1 from [exams].student_answer where examid = @examid)
            throw 50005, 'cannot modify: students have already started the exam.', 1;

        if isnull(trim(@questionids), '') = '' throw 50006, 'questionids cannot be empty.', 1;

        declare @qids table (qid int primary key);
        insert into @qids (qid)
        select distinct cast(trim(value) as int)
        from string_split(@questionids, ',')
        where trim(value) <> '';

        declare @notfoundcount int;
        select @notfoundcount = count(*)
        from @qids qt
        left join [exams].examquestion eq on qt.qid = eq.questionid and eq.examid = @examid
        where eq.questionid is null;

        if @notfoundcount > 0 and @skipnotfound = 0
            throw 50007, 'one or more questions are not assigned to this exam.', 1;

        declare @currenttotal int, @todeletecount int;
        
        select @currenttotal = count(*) from [exams].examquestion where examid = @examid;
        
        select @todeletecount = count(*) 
        from @qids qt
        join [exams].examquestion eq on qt.qid = eq.questionid and eq.examid = @examid;

        if (@currenttotal - @todeletecount) < 1
            throw 50008, 'invalid action: an exam must contain at least one question.', 1;

        delete eq
        from [exams].examquestion eq
        join @qids qt on eq.questionid = qt.qid
        where eq.examid = @examid;

        set @removedcount = @@rowcount;

        commit transaction;
        print 'success: ' + cast(@removedcount as nvarchar(10)) + ' questions removed.';

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;
go

CREATE OR ALTER TRIGGER trg_UpdateExamTotalDegree
ON [exams].[ExamQuestion]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    
    DECLARE @AffectedExams TABLE (ExamId INT);


    INSERT INTO @AffectedExams
    SELECT ExamId FROM inserted
    UNION
    SELECT ExamId FROM deleted;

    UPDATE E
    SET E.[TotalGrade]= ISNULL(
        (SELECT SUM(Q.Points) 
         FROM [exams].ExamQuestion EQ
         JOIN [exams].Question Q ON EQ.QuestionId = Q.QuestionId
         WHERE EQ.ExamId = E.ExamId), 0)
    FROM [exams].Exam E
    WHERE E.ExamId IN (SELECT ExamId FROM @AffectedExams);
END;

