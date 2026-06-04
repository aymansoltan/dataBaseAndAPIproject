create or alter procedure [InstructorStp].stp_createquestion
    @questiontext  nvarchar(max),
    @questiontype  nvarchar(20),        
    @correctanswer nvarchar(max) = null,
    @bestanswer    nvarchar(max),
    @points        int           = 1,
    @courseid      int,
    @optionslist   nvarchar(max) = null  
as
begin
    set nocount on;

    set @questiontext = trim(@questiontext);
    set @questiontype = lower(trim(@questiontype));
    set @correctanswer = lower(trim(@correctanswer));
    set @bestanswer = trim(@bestanswer);

    begin try
        begin transaction;

        declare @currentinsid int;
        select @currentinsid = i.insid
        from [useracc].useraccount ua 
        join [useracc].instructor i on ua.userid = i.userid 
        where ua.username =suser_name()  and i.isactive = 'true';

      
        if @currentinsid is null
        begin
            raiserror('access denied. only active instructors can create questions.', 16, 1);
            rollback; return;
        end
        
        if not exists(select 1 from [courses].[course] where [courseid] = @courseid and [isactive] = 1)
        begin
            raiserror('course not found or is currently inactive.', 16, 1);
            rollback; return;
        end
    
        if not exists (select 1 from [courses].[courseinstance]
                       where courseid = @courseid and instructorid = @currentinsid)
        begin
            raiserror('access denied: you are not assigned to teach this course.', 16, 1);
            rollback; return;
        end

        if len(@questiontext) < 10
            raiserror('question text must be at least 10 characters.', 16, 1);

        if len(@bestanswer) = 0
            raiserror('bestanswer is required for all question types.', 16, 1);

        if @questiontype not in ('mcq', 't/f', 'text')
            raiserror('invalid question type. must be mcq, t/f, or text.', 16, 1);

        if @points <= 0
            raiserror('points must be greater than 0.', 16, 1);

        if @questiontype = 'mcq'
        begin
            if @optionslist is null or len(trim(@optionslist)) = 0
                raiserror('options list is required for mcq questions.', 16, 1);

            declare @totalcount int, @distinctcount int;
            select @totalcount = count(*), @distinctcount = count(distinct trim(value)) 
            from string_split(@optionslist, '|') where len(trim(value)) > 0;

            if @totalcount < 2
                raiserror('mcq must have at least 2 options.', 16, 1);

            if @totalcount <> @distinctcount
                raiserror('duplicate options are not allowed.', 16, 1);

            if not exists (select 1 from string_split(@optionslist, '|') where lower(trim(value)) = @bestanswer)
                raiserror('bestanswer must match one of the provided options.', 16, 1);
        end

        if @questiontype = 't/f'
        begin
            if @correctanswer not in ('true', 'false')
                raiserror('for t/f questions, correctanswer must be either ''true'' or ''false''.', 16, 1);
        end

        if exists (select 1 from [exams].[question] 
                   where courseid = @courseid and questiontext = @questiontext and isdeleted = 0)
        begin
            raiserror('this question already exists for this course.', 16, 1);
            rollback; return;
        end

        declare @questionid int;
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
        print 'question created successfully with id: ' + cast(@questionid as nvarchar(10));

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end;

go

create or alter procedure [InstructorStp].stp_updatequestion
    @questionid    int,
    @questiontext  nvarchar(max),
    @questiontype  nvarchar(20),
    @correctanswer nvarchar(max) = null,
    @bestanswer    nvarchar(max),
    @points        int           = 1,
    @optionslist   nvarchar(max) = null  
as
begin
    set nocount on;

    set @questiontext = trim(@questiontext);
    set @questiontype = lower(trim(@questiontype));
    set @correctanswer = lower(trim(@correctanswer));
    set @bestanswer = trim(@bestanswer);

    begin try
        begin transaction;

        declare @currentinsid int;
        select @currentinsid = i.insid
        from [useracc].useraccount ua
        inner join [useracc].instructor i on ua.userid = i.userid
        where ua.username = suser_name()
          and i.isactive = 'true';

        if @currentinsid is null
        begin
            raiserror('access denied. only active instructors can update questions.', 16, 1);
            rollback; return;
        end

        declare @oldtype nvarchar(20), @courseid int, @isdeleted bit;

        select @oldtype = [QuestionType], @courseid = [CourseId], @isdeleted = [IsDeleted]
        from [exams].[Question] where [QuestionId] = @questionid;

        if @oldtype is null
        begin
            raiserror('question not found.', 16, 1);
            rollback; return;
        end

        if @isdeleted = 1
        begin
            raiserror('cannot update a deleted question.', 16, 1);
            rollback; return;
        end

        if not exists (
            select 1 from [courses].course c
            join [courses].courseinstance ci on c.courseid = ci.courseid
            where c.courseid = @courseid and ci.instructorid = @currentinsid and c.isactive = 1
        )
        begin
            raiserror('access denied: you do not teach this active course.', 16, 1);
            rollback; return;
        end


        if exists (select 1 from [exams].[Student_Answer] where [QuestionId] = @questionid)
        begin
            raiserror('cannot update: students have already answered this question.', 16, 1);
            rollback; return;
        end

        if len(@questiontext) < 10
            raiserror('question text must be at least 10 characters.', 16, 1);

        if @questiontype not in ('mcq', 't/f', 'text')
            raiserror('invalid type. must be mcq, t/f, or text.', 16, 1);

        if @points <= 0
            raiserror('points must be greater than 0.', 16, 1);

        if @questiontype = 'mcq'
        begin
            if @optionslist is null or len(trim(@optionslist)) = 0
                raiserror('options list is required for mcq.', 16, 1);

            declare @totalcount int, @distinctcount int;
            select @totalcount = count(*), @distinctcount = count(distinct trim(value)) 
            from string_split(@optionslist, '|') where len(trim(value)) > 0;

            if @totalcount <> @distinctcount
                raiserror('duplicate options are not allowed.', 16, 1);

            if not exists (select 1 from string_split(@optionslist, '|') where lower(trim(value)) = @correctanswer)
                raiserror('correctanswer must match one of the options.', 16, 1);
        end

        if exists (select 1 from [exams].question 
                   where courseid = @courseid and questiontext = @questiontext 
                   and questionid != @questionid and isdeleted = 0)
        begin
            raiserror('another question with the same text already exists.', 16, 1);
            rollback; return;
        end

        delete from[exams].[QuestionOption] where [QuestionId] = @questionid;

        if @questiontype = 'mcq'
        begin
            insert into[exams].[QuestionOption]  ([QuestionOptionText], [QuestionId])
            select trim(value), @questionid from string_split(@optionslist, '|') where len(trim(value)) > 0;
        end
        else if @questiontype = 't/f'
        begin
            insert into [exams].[QuestionOption]  ([QuestionOptionText], [QuestionId])
            values ('true', @questionid), ('false', @questionid);
        end

        update[exams].[Question] 
        set [QuestionText]  = @questiontext,
            [QuestionType]  = @questiontype,
            [CorrectAnswer] = case when @questiontype = 'text' then null else @correctanswer end,
            [BestAnswer]    = @bestanswer,
            [Points]        = @points
        where [QuestionId]  = @questionid;

        commit transaction;
        print 'question updated successfully. id = ' + cast(@questionid as nvarchar(10));

    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end;
go

create or alter procedure [InstructorStp].stp_deletequestion
    @questionid int
as
begin
    set nocount on;
    begin try
        begin transaction;

        declare @currentinsid int;
        select @currentinsid = i.insid
        from [useracc].useraccount ua
        inner join [useracc].instructor i on ua.userid = i.userid
        where ua.username = suser_name()
          and i.isactive = 'true';

        if @currentinsid is null
        begin
            raiserror('access denied. only active instructors can delete questions.', 16, 1);
            rollback; return;
        end

        declare @courseid int, @isdeleted bit;
        select @courseid = courseid, @isdeleted = isdeleted
        from [exams].question where questionid = @questionid;

        if @courseid is null
            raiserror('question not found.', 16, 1);

        if @isdeleted = 1
            raiserror('question is already deleted.', 16, 1);

        if not exists (select 1 from [courses].courseinstance 
                       where courseid = @courseid and instructorid = @currentinsid)
        begin
            raiserror('access denied: you do not teach this course.', 16, 1);
            rollback; return;
        end

        delete from [exams].question where questionid = @questionid;

        commit transaction;
    end try
    begin catch
        if xact_state() <> 0 rollback;
        declare @errmsg_del nvarchar(2000) = error_message();
        raiserror(@errmsg_del, 16, 1);
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

    if @@rowcount > 0 print 'delete operation completed successfully (hybrid logic applied).';
end;
go

