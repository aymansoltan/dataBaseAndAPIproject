go
create or alter proc [TrainingMangerStp].stp_AddCourse 
    @CourseName nvarchar(50),
    @MaxDegree  int,
    @MinDegree  int,
    @Description nvarchar(max) = null 
as 
begin
      set nocount on;
    begin try
        
        if ltrim(rtrim(@coursename)) = '' or len(ltrim(rtrim(@coursename))) < 2
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

        print 'course added successfully.';
    end try
    begin catch
        throw;
    end catch 
end
go
create or alter proc [TrainingMangerStp].stp_UpdateCourse
    @CourseId   int,
    @CourseName nvarchar(50) = null,
    @MaxDegree  int = null,
    @MinDegree  int = null,
    @Description nvarchar(max) = null,
    @IsActive   bit = null
as 
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Courses].[Course]  where [CourseId] = @CourseId)
            throw 53020, 'error: course not found.', 1;

        declare @CurrentMax int, @CurrentMin int;

        select @CurrentMax = MaxDegree, @CurrentMin = MinDegree 
        from [Courses].[Course]  where [CourseId] = @CourseId;

        set @CurrentMax = coalesce(@MaxDegree, @CurrentMax);
        set @CurrentMin = coalesce(@MinDegree, @CurrentMin);

        if @CourseName is not null and exists (
            select 1 from [Courses].[Course]
            where [CourseName] = lower(trim(@CourseName)) and [CourseId] <> @CourseId
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
            [CourseDescription] = coalesce(trim(@Description),[CourseDescription] ),
            [isActive]    = coalesce(@IsActive, isActive)
        where [CourseId] = @CourseId;

        print 'course updated successfully.';
    end try 
    begin catch
        throw;
    end catch 
end;

go
create or alter proc [TrainingMangerStp].stp_DeleteCourse
    @CourseId int
as 
begin
    set nocount on;
        if not exists (select 1 from [Courses].[Course]  where [CourseId] = @CourseId)
            throw  53030, 'Error: Course not found.', 1;
        
        delete from [Courses].[Course] where [CourseId] =@CourseId

        print 'Course deactivated successfully (Soft Delete).';
end;
go
create or alter trigger [courses].trg_Softcoursedelete
on [courses].[course]
instead of delete
as
begin
    set nocount on;

    declare @courseid int, @coursename nvarchar(100);
    
    select @courseid = CourseId, @coursename = CourseName from deleted;

    if exists (select 1 from[Courses].[CourseInstance]  where [CourseId] = @courseid)
       or exists (select 1 from [exams].[Question] where [CourseId] = @courseid)
    begin
        update [courses].[course]
        set [isActive] = 0
        where [CourseId] = @courseid;

        print 'note: course (' + @coursename + ') has related data. so it was marked as "inactive" instead of being deleted';
    end
    else
    begin
        delete from [courses].[course]
        where [CourseId] = @courseid;

        print 'success: course (' + @coursename + ') deleted permanently.';
    end
end;
go