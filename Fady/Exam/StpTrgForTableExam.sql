create or alter procedure [InstructorStp].stp_createexam
    @examtitle        nvarchar(100),
    @examtype         nvarchar(20)  = 'regular',
    @starttime        datetime,
    @endtime          datetime,
    @courseinstanceid int,
    @branchid         int,
    @trackid          int,
    @intakeid         int,
    @mode             nvarchar(10), -- 'manual' or 'random'
    @questionids      nvarchar(max) = null,
    @questioncount    int           = null,
    @mcqcount         int           = null,
    @tfcount          int           = null,
    @textcount        int           = null
as
begin
    set nocount on;
    
    set @examtitle = trim(@examtitle);
    set @mode = lower(trim(@mode));
    set @examtype = lower(trim(@examtype));

    begin try
        begin transaction;

        declare @currentinsid int;
        select @currentinsid = i.insid
        from [useracc].useraccount ua
        inner join [useracc].instructor i on ua.userid = i.userid
        where ua.username = suser_name()
          and i.isactive = 'true';

        if @currentinsid is null
            throw 50001, 'access denied. only active instructors can create exams.', 1;

        declare @courseid int;
        select @courseid = ci.courseid
        from [courses].courseinstance ci
        where ci.courseinstanceid = @courseinstanceid 
          and ci.instructorid = @currentinsid
          and ci.branchid = @branchid 
          and ci.trackid = @trackid 
          and ci.intakeid = @intakeid;

        if @courseid is null
            throw 50002, 'invalid course instance or mismatch in branch/track/intake data.', 1;

        if len(@examtitle) < 3 
            throw 50003, 'exam title must be at least 3 characters.', 1;

        if @starttime < getdate() 
            throw 50004, 'exam start time must be in the future.', 1;

        if @endtime <= @starttime 
            throw 50005, 'endtime must be after starttime.', 1;

        declare @duration int = datediff(minute, @starttime, @endtime);
        if @duration not between 30 and 180
            throw 50006, 'exam duration must be between 30 and 180 minutes.', 1;

        if cast(@starttime as time) < '08:00:00' or cast(@endtime as time) > '23:00:00'
            throw 50007, 'exams can only be scheduled between 08:00 am and 11:00 pm.', 1;

        if exists (select 1 from [exams].exam e join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
                   where ci.instructorid = @currentinsid and e.isdeleted = 0 
                   and @starttime < e.endtime and @endtime > e.starttime)
            throw 50008, 'instructor has another exam at this time.', 1;


        if exists (select 1 from [exams].exam where trackid = @trackid and intakeid = @intakeid 
                   and isdeleted = 0 and @starttime < endtime and @endtime > starttime)
            throw 50009, 'this track already has an exam scheduled in this slot.', 1;

        declare @examid int;
        insert into [exams].exam (examtitle, examtype, starttime, endtime, courseinstanceid, branchid, trackid, intakeid)
        values (@examtitle, @examtype, @starttime, @endtime, @courseinstanceid, @branchid, @trackid, @intakeid);

        set @examid = scope_identity();

        -- ---------------------------------------------------------
        if @mode = 'manual'
        begin
            if @questionids is null or trim(@questionids) = ''
                throw 50010, 'questionids required for manual mode.', 1;

            insert into [exams].examquestion (examid, questionid)
            select distinct @examid, cast(trim(value) as int)
            from string_split(@questionids, ',')
            where trim(value) <> ''
            and exists (select 1 from [exams].question q where q.questionid = cast(trim(value) as int) 
                        and q.courseid = @courseid and q.isdeleted = 0);
        end
        -- ---------------------------------------------------------
        else if @mode = 'random'
        begin
            if @questioncount is null or @questioncount <= 0
                throw 50011, 'valid questioncount is required for random mode.', 1;

            declare @selectedq table (qid int);
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
        print 'exam created successfully. id = ' + cast(@examid as nvarchar(10));

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;
go

create or alter procedure [InstructorStp].stp_updateexam
    @examid           int,
    @examtitle        nvarchar(100),
    @examtype         nvarchar(20) = 'regular',
    @starttime        datetime,
    @endtime          datetime,
    @courseinstanceid int,
    @branchid         int,
    @trackid          int,
    @intakeid         int,
    @isdeleted        bit = 0
as
begin
    set nocount on;
    
    set @examtitle = trim(@examtitle);
    set @examtype  = lower(trim(@examtype));

    begin try
        begin transaction;

        declare @currentinsid int;
        select  @currentinsid = i.insid
        from [useracc].useraccount ua
        join [useracc].instructor i on ua.userid = i.userid and i.isactive = 1
        where ua.username = suser_name();

        if @currentinsid is null 
            throw 50001, 'access denied: instructor profile not found or inactive.', 1;


        declare @oldisdeleted bit, @oldstart datetime, @oldcourseinstanceid int;
        select @oldisdeleted = isdeleted, @oldstart = starttime, @oldcourseinstanceid = courseinstanceid
        from [exams].exam where examid = @examid;

        if @oldisdeleted is null throw 50002, 'exam not found.', 1;
        if @oldisdeleted = 1    throw 50003, 'cannot update a deleted exam.', 1;

        if not exists (select 1 from [courses].courseinstance where courseinstanceid = @oldcourseinstanceid and instructorid = @currentinsid)
            throw 50004, 'access denied: you are not the owner of this exam.', 1;

  
        if @isdeleted = 1 throw 50005, 'access denied: instructors cannot delete exams via update.', 1;

        if getdate() >= dateadd(hour, -1, @oldstart)
            throw 50006, 'exam is locked: cannot update within 1 hour of start time.', 1;

        if exists (select 1 from [exams].student_answer where examid = @examid)
            throw 50007, 'update failed: students have already started answering.', 1;

 
        if len(@examtitle) < 3 throw 50008, 'exam title must be at least 3 characters.', 1;
        if @endtime <= @starttime throw 50009, 'endtime must be after starttime.', 1;
        declare @duration int = datediff(minute, @starttime, @endtime);
        if @duration not between 30 and 180
            throw 50006, 'exam duration must be between 30 and 180 minutes.', 1;
        
        if not exists (select 1 from [courses].courseinstance 
                       where courseinstanceid = @courseinstanceid 
                       and branchid = @branchid and trackid = @trackid and intakeid = @intakeid
                       and instructorid = @currentinsid) 
            throw 50010, 'data mismatch: organizational details incorrect or you do not own the new course instance.', 1;

     
        if exists (select 1 from [exams].exam e join [courses].courseinstance ci on e.courseinstanceid = ci.courseinstanceid
                   where ci.instructorid = @currentinsid and e.examid <> @examid and e.isdeleted = 0 
                   and @starttime < e.endtime and @endtime > e.starttime)
            throw 50011, 'instructor conflict: you have another exam in this slot.', 1;

        if exists (select 1 from [exams].exam where trackid = @trackid and intakeid = @intakeid 
                   and examid <> @examid and isdeleted = 0 and @starttime < endtime and @endtime > starttime)
            throw 50012, 'track conflict: this track already has an exam in this slot.', 1;

        declare @oldcourseid int, @newcourseid int;
        select @oldcourseid = courseid from [courses].courseinstance where courseinstanceid = @oldcourseinstanceid;
        select @newcourseid = courseid from [courses].courseinstance where courseinstanceid = @courseinstanceid;

        if @oldcourseid <> @newcourseid
        begin
            delete from [exams].examquestion where examid = @examid;
            print 'warning: course changed. questions cleared for exam id: ' + cast(@examid as nvarchar(10));
        end

        update [exams].exam
        set examtitle = @examtitle,
            examtype = @examtype,
            starttime = @starttime,
            endtime = @endtime,
            courseinstanceid = @courseinstanceid,
            branchid = @branchid,
            trackid = @trackid,
            intakeid = @intakeid,
            isdeleted = @isdeleted
        where examid = @examid;

        commit transaction;
        print 'success: exam updated correctly.';

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;

go
create or alter procedure [InstructorStp].stp_deleteexam
    @examid int
as
begin
    set nocount on;
    begin try
        begin transaction;

        declare @currentinsid int;

        select @currentinsid = i.insid
        from [useracc].useraccount ua
        join [useracc].instructor i on ua.userid = i.userid and i.isactive = 1
        where ua.username = suser_name();

        if @currentinsid is null 
            throw 50001, 'access denied: you must be an active instructor to perform this action.', 1;

        declare @isdeleted bit, @starttime datetime, @courseinstanceid int;
        select @isdeleted = isdeleted, @starttime = starttime, @courseinstanceid = courseinstanceid
        from [exams].exam where examid = @examid;

        if @isdeleted is null throw 50002, 'exam not found.', 1;
        if @isdeleted = 1    throw 50003, 'exam is already deleted.', 1;

        if not exists (
            select 1 
            from [courses].courseinstance 
            where courseinstanceid = @courseinstanceid 
            and instructorid = @currentinsid
        )
            throw 50004, 'access denied: only the instructor who owns this course can delete the exam.', 1;


        if getdate() >= dateadd(hour, -1, @starttime)
            throw 50005, 'cannot delete: exam is locked 1 hour before start.', 1;


        if exists (select 1 from [exams].student_answer where examid = @examid)
            throw 50006, 'cannot delete: students have already started answering this exam.', 1;

        delete from [exams].exam where examid = @examid;

        commit transaction;
        print 'success: exam deleted by the instructor.';

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @err nvarchar(2000) = error_message();
        raiserror(@err, 16, 1);
    end catch
end;

go
create or alter trigger [exams].trg_softdeleteexam
on [exams].exam
instead of delete
as
begin
    set nocount on;


    declare @softcount int, @hardcount int;


    select @softcount = count(*) from deleted d
    where exists (select 1 from [exams].student_answer sa where sa.examid = d.examid)
       or exists (select 1 from [exams].student_exam_result sr where sr.examid = d.examid)
       or exists (select 1 from [exams].examquestion eq where eq.examid = d.examid);

    select @hardcount = count(*) from deleted d
    where not exists (select 1 from [exams].student_answer sa where sa.examid = d.examid)
      and not exists (select 1 from [exams].student_exam_result sr where sr.examid = d.examid)
      and not exists (select 1 from [exams].examquestion eq where eq.examid = d.examid);


    if @softcount > 0
    begin
        update e set e.isdeleted = 1
        from [exams].exam e
        inner join deleted d on e.examid = d.examid
        where exists (select 1 from [exams].student_answer sa where sa.examid = d.examid)
           or exists (select 1 from [exams].student_exam_result sr where sr.examid = d.examid)
           or exists (select 1 from [exams].examquestion eq where eq.examid = d.examid);
        
        print 'soft delete: ' + cast(@softcount as nvarchar(10)) + ' exam(s) marked as isdeleted=1.';
    end

    if @hardcount > 0
    begin
        delete e from [exams].exam e
        inner join deleted d on e.examid = d.examid
        where not exists (select 1 from [exams].student_answer sa where sa.examid = d.examid)
          and not exists (select 1 from [exams].student_exam_result sr where sr.examid = d.examid)
          and not exists (select 1 from [exams].examquestion eq where eq.examid = d.examid);
        
        print 'hard delete: ' + cast(@hardcount as nvarchar(10)) + ' exam(s) removed permanently.';
    end
end;
go