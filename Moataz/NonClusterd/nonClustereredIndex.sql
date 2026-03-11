create nonClustered index ix_userAcc_userName
on [userAcc].[UserAccount] ( [UserName])
include ([isActive] ,[RoleId])
go
create nonClustered index ix_userAccount_email
on [userAcc].[UserAccount] ( [Email])
include ([UserName],[isActive] ,[RoleId])
go
create nonclustered index ix_userAcc_Branch_track_intake
on [userAcc].[Student] ([BranchId] ,[IntakeId],[TrackId])
include([StudentId],[FirstName],[LastName])
go
create nonclustered index ix_userAcc_userID_deptId_insId
on [userAcc].[Instructor] ([UserId],[DeptId],[InstructorId])
include ([FirstName],[LastName])
go
create nonclustered index ix_track_branch_intake_instructor_course
on[Courses].[CourseInstance] ([CourseId],[InstructorId],[BranchId],[TrackId],[IntakeId])
go
create nonclustered index ix_CourseInstace
on[exams].[Exam]([CourseInstanceId])
go
create nonclustered index ix_courseName
on[Courses].[Course] ([CourseName])
include([isActive])
