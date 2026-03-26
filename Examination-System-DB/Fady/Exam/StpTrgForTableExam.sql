create or alter procedure [InstructorStp].stp_createexam
    @InstructorId     int ,
    @examtitle        varchar(100),
    @examtype         varchar(11)  = 'regular', 
    @starttime        datetime2(0),
    @endtime          datetime2(0),
    @courseinstanceid smallint,
    @branchid         tinyint,
    @trackid          smallint,
    @mode             varchar(7), -- 'manual' or 'random'
    @questionids      varchar(350) = null,
    @questioncount    tinyint = null,
    @mcqcount         tinyint = null,
    @tfcount          tinyint = null,
    @textcount        tinyint = null

as
begin
    set nocount on;
    
    set @examtitle = trim(@examtitle);
    set @mode = lower(trim(@mode));
    set @examtype = lower(trim(@examtype));
    declare @lastIntakeId tinyint;
    begin try
        select top 1 @lastIntakeId = [IntakeId] 
        from [orgnization].[Intake] 
        where isActive = 1 and isDeleted = 0 
        order by [IntakeId] desc;

        if @lastIntakeId is null
            throw 50020, 'Error: No active Intake found in the system.', 1;
        begin transaction 
            if not exists (select 1 from [useracc].Instructor where InstructorId = @InstructorId and isActive = 1 and isDeleted = 0)
                throw 50001, 'error: instructor not found or inactive.', 1;

            if not exists (select 1 from [courses].CourseInstance where CourseInstanceId = @courseinstanceid and InstructorId = @InstructorId and BranchId = @branchid and TrackId = @trackid and IntakeId = @intakeid)
                throw 50002, 'error: course instance not found or you do not have permission to create an exam for this course instance.', 1;

        declare @courseid smallint;
        select @courseid = ci.courseid
        from [courses].courseinstance ci
        where ci.courseinstanceid = @courseinstanceid 
            and ci.instructorid = @InstructorId
            and ci.branchid = @branchid 
            and ci.trackid = @trackid ;

        if @courseid is null
            throw 50002, 'you canot put this exam for course beacuse you dont have this course ', 1;

        if @examtype not in ('regular', 'corrective')
            throw 50003, 'error: invalid exam type. must be ''regular'' or ''corrective''.', 1; 

        if @examtype = 'corrective'
        begin
            if not exists (
                select 1
                from   [exams].Exam
                where  CourseInstanceId = @courseinstanceid
                and  ExamType           = 'Regular'
                and  IsDeleted          = 0
            )
                throw 50010, 'Cannot create a Corrective exam without a prior Regular exam for this course instance.', 1;
        end

        if @starttime < dateadd(hour, 24, getdate())
            throw 50003, 'error: exam start time must be at least 24 hours from now.', 1;

        if len(@examtitle) < 3 
            throw 50003, 'exam title must be at least 3 characters.', 1;

        if @starttime < getdate() 
            throw 50004, 'exam start time must be in the future.', 1;

        if @endtime <= @starttime 
            throw 50005, 'endtime must be after starttime.', 1;

        declare @duration tinyint = datediff(minute, @starttime, @endtime);
        if @duration not between 30 and 180
            throw 50006, 'exam duration must be between 30 and 180 minutes.', 1;

        if cast(@starttime as time) < '08:00:00' or cast(@endtime as time) > '23:00:00'
            throw 50007, 'exams can only be scheduled between 08:00 am and 11:00 pm.', 1;

        if exists (select 1 from [exams].exam e join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
                where ci.instructorid = @InstructorId and e.isdeleted = 0 
                and @starttime < e.endtime and @endtime > e.starttime)
            throw 50008, 'instructor has another exam at this time.', 1;


        if exists (select 1 from [exams].exam where trackid = @trackid and intakeid = @lastIntakeId 
                and isdeleted = 0 and @starttime < endtime and @endtime > starttime)
            throw 50009, 'this track already has an exam scheduled in this slot.', 1;

        

        declare @examid int;
        insert into [exams].exam (examtitle, examtype, starttime, endtime, courseinstanceid, branchid, trackid, intakeid)
        values (@examtitle, @examtype, @starttime, @endtime, @courseinstanceid, @branchid, @trackid, @lastIntakeId);

        set @examid = scope_identity();

        -- ---------------------------------------------------------
        if @mode = 'manual'
        begin
            if @questionids is null or trim(@questionids) = ''
                throw 50010, 'questionids required for manual mode.', 1;

            insert into [exams].examquestion (examid, questionid)
            select distinct @examid, cast(trim(value) as smallint)
            from string_split(@questionids, ',')
            where trim(value) <> ''
            and exists (select 1 from [exams].question q where q.questionid = cast(trim(value) as smallint) 
                        and q.courseid = @courseid and q.isdeleted = 0);
        end
        -- ---------------------------------------------------------
        else if @mode = 'random'
        begin
            if @questioncount is null or @questioncount <= 0
                throw 50011, 'valid questioncount is required for random mode.', 1;

            declare @selectedq table (qid smallint);
            set @mcqcount = isnull(@mcqcount, 0);
            set @tfcount = isnull(@tfcount, 0);
            set @textcount = isnull(@textcount, 0);

            if @mcqcount > (select count(*) from [exams].question where courseid = @courseid and questiontype = 'mcq' and isdeleted = 0)
                throw 50012, 'not enough mcq questions in the bank.', 1;
            
            if @tfcount > (select count(*) from [exams].question where courseid = @courseid and questiontype = 't/f' and isdeleted = 0)
                throw 50013, 'not enough t/f questions in the bank.', 1;

            if @textcount > (select count(*) from [exams].question where courseid = @courseid and questiontype = 'text' and isdeleted = 0)
                throw 50013, 'not enough text questions in the bank.', 1;

            insert into @selectedq
            select top (@mcqcount) questionid from [exams].question where courseid = @courseid and questiontype = 'mcq' and isdeleted = 0 order by newid();
            
            insert into @selectedq
            select top (@tfcount) questionid from [exams].question where courseid = @courseid and questiontype = 't/f' and isdeleted = 0 order by newid();
            
            insert into @selectedq
            select top (@textcount) questionid from [exams].question where courseid = @courseid and questiontype = 'text' and isdeleted = 0 order by newid();

            declare @needed int = @questioncount - (select count(*) from @selectedq);
            if @needed > 0
            begin
                insert into @selectedq
                select top (@needed) questionid from [exams].question 
                where courseid = @courseid and isdeleted = 0 and questionid not in (select qid from @selectedq)
                order by newid();
            end

            if (select count(*) from @selectedq) < @questioncount
                throw 50014, 'bank total questions are less than the requested questioncount.', 1;

            insert into [exams].examquestion (examid, questionid)
            select @examid, qid from @selectedq;
        end

        commit transaction;
        select @examid as CreatedExamId, 1 as Success, 'Exam created successfully.' as Message;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        throw;
    end catch
end;
go

create or alter procedure [InstructorStp].stp_deleteexam
    @examid smallint,
    @InstructorId int 
as
begin
    set nocount on;
    begin try

        declare @starttime datetime2(0), @courseinstanceid int, @isdeleted bit;
        select @isdeleted = isdeleted, @starttime = starttime, @courseinstanceid = courseinstanceid
        from [exams].exam where examid = @examid;

        if @@rowcount = 0 throw 50001, 'error: exam not found.', 1; 
        if @isdeleted = 1 throw 50003, 'error: exam is already deleted.', 1;


        if not exists (select 1 from [courses].courseinstance where courseinstanceid = @courseinstanceid and instructorid = @InstructorId)
            throw 50004, 'access denied: you do not own this course.', 1;


        if getdate() >= dateadd(hour, -6, @starttime)
            throw 50005, 'cannot delete: exam is locked 6 hour before start.', 1;

        delete from [exams].exam where examid = @examid;

        select 1 as Success, 'Exam deleted successfully.' as Message;
    end try
    begin catch
        throw;
    end catch
end;


create or alter trigger [exams].trg_softdeleteexam
on [exams].exam
instead of delete
as
begin
    set nocount on;

  
    declare @SoftDeleteIDs table (id int);
    insert into @SoftDeleteIDs
    select examid from deleted d
    where exists (select 1 from [exams].student_answer sa where sa.examid = d.examid)
       or exists (select 1 from [exams].student_exam_result sr where sr.examid = d.examid);

    declare @HardDeleteIDs table (id int);
    insert into @HardDeleteIDs
    select examid from deleted d
    where examid not in (select id from @SoftDeleteIDs);

  
    update [exams].exam 
    set isdeleted = 1 
    where examid in (select id from @SoftDeleteIDs);


    delete from [exams].examquestion 
    where examid in (select id from @HardDeleteIDs);
    

    delete from [exams].exam 
    where examid in (select id from @HardDeleteIDs);
end;
go
CREATE OR ALTER TRIGGER [exams].trg_UpdateExamTotalDegree
ON [exams].[ExamQuestion]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    WITH AffectedExams AS (
        SELECT ExamId FROM inserted
        UNION
        SELECT ExamId FROM deleted
    )
    UPDATE E
    SET E.[TotalGrade] = ISNULL(
        (SELECT SUM(Q.Points) 
        FROM [exams].ExamQuestion EQ
        JOIN [exams].Question Q ON EQ.QuestionId = Q.QuestionId
        WHERE EQ.ExamId = E.ExamId), 0)
    FROM [exams].Exam E
    JOIN AffectedExams AE ON E.ExamId = AE.ExamId;
END;
GO






