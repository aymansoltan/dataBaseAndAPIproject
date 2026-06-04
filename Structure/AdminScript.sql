use [ExaminationSystemDB]
go
create role [adminrole] 
create role [instructorerole] 
create role [trainningmangerrole]
create role [studentrole]
go







deny insert , update , delete ,select on schema :: [orgnization] to  instructoreRole ,trainningMangerRole ,studentRole ,[adminrole]
deny insert , update , delete ,select on schema :: [Courses] to  instructoreRole ,trainningMangerRole ,studentRole ,[adminrole]
deny insert , update , delete ,select on schema :: [exams]  to   instructoreRole ,trainningMangerRole ,studentRole ,[adminrole]
deny insert , update , delete ,select on schema :: [userAcc] to   instructoreRole ,trainningMangerRole ,studentRole ,[adminrole]

deny execute on schema :: [trainingmangerstp] to studentrole, instructorerole,adminRole;
deny select on schema :: [MangerViews] to studentRole, instructoreRole ,adminRole;

deny execute on schema :: [InstructorStp] to studentrole, trainningMangerRole,adminRole;

grant execute on schema :: [trainingmangerstp] to trainningmangerrole;
grant select on schema :: [MangerViews] to trainningMangerRole;

grant execute on schema :: [InstructorStp] to instructoreRole;
    grant execute on schema :: [StudentStp] to studentRole;

select * from [userAcc].[Instructor]