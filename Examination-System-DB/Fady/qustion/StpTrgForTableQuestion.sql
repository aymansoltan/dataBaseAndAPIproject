create or alter procedure [InstructorStp].stp_createquestion
    @questiontext  varchar(4000),
    @questiontype  varchar(5),        
    @correctanswer char(5) = null,
    @bestanswer    varchar(4000),
    @points        tinyint = 1,
    @courseid      smallint,
    @instructorid   int ,
    @optionslist   varchar(4000) = null  
as
begin
    set nocount on;

    set @questiontext = trim(@questiontext);
    set @questiontype = lower(trim(@questiontype));
    set @correctanswer = lower(trim(@correctanswer));
    set @bestanswer = trim(@bestanswer);

    begin try
        begin transaction;

        if not exists (select 1 from [Instructors] where InstructorId = @instructorid and isactive = 1 and isdeleted = 0)
            throw 50001, 'Access denied. Only active instructors can create questions.', 1;

        if not exists (select 1 from [Course] where courseid = @courseid and isactive = 1 and isdeleted = 0)
            throw 50002, 'Course not found or is currently inactive.', 1;

        if not exists (select 1 from [CourseInstance] where courseid = @courseid and instructorid = @instructorid)
            throw 50003, 'Access denied: You are not assigned to teach this course.', 1;

        if len(@questiontext) < 10
            throw 50004, 'Question text must be at least 10 characters.', 1;

        if len(@bestanswer) = 0
            throw 50005, 'bestanswer is required for all question types.', 1;

        if @questiontype not in ('mcq', 't/f', 'text')
            throw 50006, 'invalid question type. must be mcq, t/f, or text.', 1;

        if @points <= 0
            throw 50007, 'points must be greater than 0.', 1;

        if @questiontype = 'mcq'
        begin
            if @correctanswer is null or len(trim(@correctanswer)) = 0
                throw 50008, 'correctanswer is required for mcq questions and insert like a or b or c.', 1;
            if @optionslist is null or len(trim(@optionslist)) = 0
                throw 50008, 'options list is required for mcq questions and insert like "A-ans1 | b-ans2 | c-Ans3".', 1;

            declare @totalcount int, @distinctcount int;
            select @totalcount = count(*), @distinctcount = count(distinct trim(value)) 
            from string_split(@optionslist, '|') where len(trim(value)) > 0;

            if @totalcount < 2
                throw 50009, 'mcq must have at least 2 options.', 1;

            if @totalcount <> @distinctcount
                throw 50010, 'duplicate options are not allowed.', 1;

            if not exists (select 1 from string_split(@optionslist, '|') where lower(trim(value)) = @bestanswer)
                throw 50011, 'bestanswer must match one of the provided options.', 1;
        end

        if @questiontype = 't/f'
        begin
            if @correctanswer not in ('true', 'false')
                throw 50012, 'for t/f questions, correctanswer must be either ''true'' or ''false''.', 1;
        end

        if exists (select 1 from [exams].[question] 
                   where courseid = @courseid and questiontext = @questiontext and isdeleted = 0)
        begin
            throw 50013, 'this question already exists for this course.', 1;
            rollback; return;
        end

        declare @questionid smallint;
        insert into [exams].[question] ([questiontext], [questiontype], [correctanswer], [bestanswer], [points], [courseid])
        values (@questiontext, @questiontype, 
                case when @questiontype = 'text' then null else @correctanswer end,
                @bestanswer, @points, @courseid);

        set @questionid = scope_identity();

        if @questiontype = 'mcq'
        begin
            insert into [exams].[questionoption] ([questionoptiontext], [questionid])
            select trim(value), @questionid from string_split(@optionslist, '|') where len(trim(value)) > 0;
        end
        else if @questiontype = 't/f'
        begin
            insert into [exams].[questionoption] ([questionoptiontext], [questionid])
            values ('true', @questionid), ('false', @questionid);
        end

        commit transaction;
        SELECT @questionid AS QuestionId, 1 as Success ,'qustion added successfully' as Message;
    end try
    begin catch
        if xact_state() <> 0 rollback;
       throw;
    end catch
end;

go

create or alter procedure [InstructorStp].stp_updatequestion
    @questionid    smallint,
    @questiontext  varchar(4000),
    @questiontype  varchar(5),
    @correctanswer char(5) = null,
    @bestanswer    varchar(4000),
    @points        tinyint = 1,
    @instructorid  int, 
    @courseid      smallint,
    @optionslist   varchar(4000) = null  
as
begin
    set nocount on;

    set @questiontext  = trim(@questiontext);
    set @questiontype  = lower(trim(@questiontype));
    set @correctanswer = lower(trim(@correctanswer));
    set @bestanswer    = trim(@bestanswer);

    begin try
        begin transaction;

    
        if not exists (select 1 from [Instructors] where InstructorId = @instructorid and isactive = 1 and isdeleted = 0)
            throw 50001, 'Access denied. Only active instructors can update questions.', 1;

        if not exists (select 1 from [exams].[question] where questionid = @questionid and isdeleted = 0)
            throw 50014, 'Error: Question not found or has been deleted.', 1;

     
        if not exists (select 1 from [CourseInstance] where courseid = @courseid and instructorid = @instructorid)
            throw 50003, 'Access denied: You are not assigned to teach this course.', 1;

   
        if exists (select 1 from [exams].[StudentAnswer] where questionid = @questionid)
            throw 51000, 'Cannot update: Students have already started answering this question. Try creating a new one.', 1;

  
        if len(@questiontext) < 10
            throw 50004, 'Question text must be at least 10 characters.', 1;

        if @questiontype not in ('mcq', 't/f', 'text')
            throw 50006, 'Invalid question type. Must be mcq, t/f, or text.', 1;

        if @points <= 0
            throw 50007, 'Points must be greater than 0.', 1;
        delete from [exams].[questionoption] where questionid = @questionid;

        if @questiontype = 'mcq'
        begin
            if @optionslist is null or len(trim(@optionslist)) = 0
                throw 50008, 'Options list is required for MCQ questions.', 1;

            insert into [exams].[questionoption] ([questionoptiontext], [questionid])
            select trim(value), @questionid from string_split(@optionslist, '|') where len(trim(value)) > 0;
            
         
            if not exists (select 1 from string_split(@optionslist, '|') where lower(trim(value)) = @bestanswer)
                throw 50011, 'Updated bestanswer must match one of the provided options.', 1;
        end
        else if @questiontype = 't/f'
        begin
            insert into [exams].[questionoption] ([questionoptiontext], [questionid])
            values ('true', @questionid), ('false', @questionid);
        end


        update [exams].[question]
        set questiontext  = @questiontext,
            questiontype  = @questiontype,
            correctanswer = case when @questiontype = 'text' then null else @correctanswer end,
            bestanswer    = @bestanswer,
            points        = @points,
            courseid      = @courseid
        where questionid  = @questionid;

        commit transaction;

   
        SELECT @questionid AS QuestionId, 1 as Success, 'Question updated successfully' as Message;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        throw; 
    end catch
end;
go

create or alter procedure [InstructorStp].stp_deletequestion
    @questionid int,
    @instructorid int
as
begin
    set nocount on;
    begin try
        begin transaction;
        if not exists (select 1 from [useracc].instructor where [InstructorId] = @instructorid and isactive = 1)
            throw 50001, 'Access denied. Only active instructors can delete questions.', 1;

        declare @courseid int, @isdeleted bit;
        select @courseid = courseid, @isdeleted = isdeleted
        from [exams].question where questionid = @questionid;

        if @courseid is null
            throw 50014, 'Question not found.', 1;

        if @isdeleted = 1
            throw 50015, 'Question is already deleted.', 1;

        if not exists (select 1 from [courses].courseinstance where courseid = @courseid and instructorid = @instructorid)
            throw 50003, 'Access denied: You do not teach this course.', 1;

        delete from [exams].question where questionid = @questionid;

        commit transaction;

        SELECT @questionid AS QuestionId, 1 as Success, 'Question deleted successfully' as Message;

    end try
    begin catch
        if xact_state() <> 0 rollback;
        throw; 
    end catch
end;
go
create or alter trigger [exams].trg_softdeletequestion
on [exams].question
instead of delete
as
begin
    set nocount on;
    update q
    set q.isdeleted = 1
    from [exams].question q
    inner join deleted d on q.questionid = d.questionid
    where exists (select 1 from [exams].examquestion eq where eq.questionid = d.questionid)
        or exists (select 1 from [exams].student_answer sa where sa.questionid = d.questionid);


    delete qo
    from [exams].questionoption qo
    inner join deleted d on qo.questionid = d.questionid
    where not exists (select 1 from [exams].examquestion eq where eq.questionid = d.questionid)
        and not exists (select 1 from [exams].student_answer sa where sa.questionid = d.questionid);


    delete q
    from [exams].question q
    inner join deleted d on q.questionid = d.questionid
    where not exists (select 1 from [exams].examquestion eq where eq.questionid = d.questionid)
        and not exists (select 1 from [exams].student_answer sa where sa.questionid = d.questionid);
end;
go