go
create or alter proc [TrainingMangerStp].stp_AddCourse 
    @CourseName varchar(20),
    @MaxDegree  tinyint,
    @MinDegree  tinyint,
    @Description varchar(500) = null 
as 
begin
set nocount on;
    begin try
        
        if trim(@coursename) = '' or len(trim(@coursename)) < 2
            throw 53001, 'error: course name cannot be empty and must be at least 2 characters.', 1;

        if exists (select 1 from[Courses].[Course] where [CourseName] = lower(trim(@coursename)))
            throw 53002, 'error: course name already exists.', 1;

        if @description is not null and len(ltrim(rtrim(@description))) <= 10
            throw 53003, 'error: description must be more than 10 characters if provided.', 1;

        if @mindegree >= @maxdegree
            throw 53004, 'error: min degree must be strictly less than max degree.', 1;

        if @mindegree <= (@maxdegree * 1.0 / 3.0)
            throw 53005, 'error: min degree must be greater than one-third of the max degree.', 1;

        insert into [Courses].[Course] ([CourseName] , [MaxDegree] , [MinDegree] , [CourseDescription]   )
        values (lower(trim(@coursename)), @maxdegree, @mindegree, ltrim(rtrim(@description)));

        select SCOPE_IDENTITY() as NewCourseId , 1 as Success, 'Course added successfully.' as Message  ;
    end try
    begin catch
        throw;
    end catch 
end
go
create or alter proc [TrainingMangerStp].stp_UpdateCourse
    @CourseId   smallint,
    @CourseName varchar(30) = null,
    @MaxDegree  tinyint = null,
    @MinDegree  tinyint = null,
    @Description varchar(500) = null
as 
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Courses].[Course]  where [CourseId] = @CourseId and [isDeleted] = 0)
            throw 53020, 'Error: Course not found or it has been deleted.', 1;
        
        if @CourseName is not null and (trim(@CourseName) = '' or len(trim(@CourseName)) < 2)
            throw 53001, 'error: course name cannot be empty and must be at least 2 characters.', 1;
        
        declare @CurrentMax tinyint, @CurrentMin tinyint;

        select @CurrentMax = MaxDegree, @CurrentMin = MinDegree 
        from [Courses].[Course]  where [CourseId] = @CourseId;

        set @CurrentMax = coalesce(@MaxDegree, @CurrentMax);
        set @CurrentMin = coalesce(@MinDegree, @CurrentMin);

        if @CourseName is not null and exists (select 1 from [Courses].[Course]
            where [CourseName] = lower(trim(@CourseName)) and [CourseId] <> @CourseId and [isDeleted] = 0
        )
            throw 53021, 'error: course name already exists.', 1;

        if @Description is not null and len(trim(@Description)) <= 10
            throw 53022, 'error: description must be more than 10 characters.', 1;

        if @CurrentMin >= @CurrentMax
            throw 53023, 'error: min degree must be strictly less than max degree.', 1;

        if @CurrentMin <= (@CurrentMax * 1.0 / 3.0)
            throw 53024, 'error: min degree must be greater than one-third of the max degree.', 1;

        update [Courses].[Course]
        set 
            [CourseName]  = coalesce(lower(trim(@CourseName)), CourseName),
            [MaxDegree]   = @CurrentMax,
            [MinDegree]   = @CurrentMin,
            [CourseDescription] = coalesce(trim(@Description),[CourseDescription] )
        where [CourseId] = @CourseId;

        select @CourseId as UpdatedCourseId, 1 as Success, 'Course updated successfully.' as Message;
        
    end try 
    begin catch
        throw;
    end catch 
end;

go
create or alter proc [TrainingMangerStp].stp_DeleteCourse
    @CourseId smallint
as 
begin
    set nocount on;
        if not exists (select 1 from [Courses].[Course]  where [CourseId] = @CourseId and [isDeleted] = 0)
            throw  53030, 'Error: Course not found or it has been deleted.', 1;
        
        delete from [Courses].[Course] where [CourseId] =@CourseId
        select 1 as Success, 'Course deleted successfully.' as Message;
        
end;
go

create or alter trigger [courses].trg_Softcoursedelete
on [courses].[course]
instead of delete
as
begin
    set nocount on;

    declare @courseid smallint
    
    select @courseid = CourseId from deleted;

    if exists (select 1 from[Courses].[CourseInstance]  where [CourseId] = @courseid)
       or exists (select 1 from [exams].[Question] where [CourseId] = @courseid)
    begin
        update [courses].[course]
        set [isActive] = 0 , isDeleted = 1
        where [CourseId] = @courseid;

    end
    else
    begin
        delete from [courses].[course]
        where [CourseId] = @courseid;
    end
end;
go