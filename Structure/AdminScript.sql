use [ExaminationSystemDB]
go
create role [adminrole] 
create role [instructorerole] 
create role [trainningmangerrole]
create role [studentrole]
go




deny execute on schema :: [trainingmangerstp] to studentrole, instructorerole,adminRole;
deny select on schema :: [MangerViews] to studentRole, instructoreRole ,adminRole;

deny execute on schema :: [InstructorStp] to trainningMangerRole ,studentRole ,[adminrole]
deny select on schema :: [InstructorViews] to trainningMangerRole ,studentRole ,[adminrole]

deny execute on schema :: [StudentStp] to instructoreRole ,trainningMangerRole  ,[adminrole]
deny select on schema :: [studentViews] to instructoreRole ,trainningMangerRole  ,[adminrole]

deny execute on schema :: [admin] to instructoreRole ,trainningMangerRole  ,studentRole

grant execute on schema :: [trainingmangerstp] to trainningmangerrole;
grant select on schema :: [MangerViews] to trainningMangerRole;

grant execute on schema :: [InstructorStp] to instructoreRole;
grant select on schema :: [InstructorViews] to instructoreRole;

grant execute on schema :: [StudentStp] to studentRole;
grant select on schema :: [studentViews] to studentRole;

grant execute on schema :: [admin] to [adminrole];

deny select , insert , delete , update on schema ::[Courses] to studentRole, instructoreRole ,trainningMangerRole  ,[adminrole]
deny select , insert , delete , update on schema ::[exams] to studentRole, instructoreRole ,trainningMangerRole  ,[adminrole]
deny select , insert , delete , update on schema ::[orgnization] to studentRole, instructoreRole ,trainningMangerRole  ,[adminrole]
deny select , insert , delete , update on schema ::[userAcc] to studentRole, instructoreRole ,trainningMangerRole  ,[adminrole]