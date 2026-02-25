use [ExaminationSystemDB]
create login adminLogin with password ='adminLogin123';
create login instructorLogin with password = 'instructorLogin123';
create login trainningMangerLogin with password ='trainningMangerLogin123'
create login studentLogin with password ='studentLogin123'

create user	adminUser for login [adminLogin]
create user	instructoreUser for login [instructoreLogin]
create user	trainningMangerUser for login [trainningMangerLogin]
create user	studentUser for login [studentLogin]

create role adminRole 
create role instructoreRole 
create role trainningMangerRole
create role studentRole

alter role adminRole add member adminUser
alter role instructoreRole add member instructoreUser
alter role trainningMangerRole add member trainningMangerUser
alter role studentRole add member studentUser

deny insert , update , delete ,select on schema :: [orgnization] to  instructoreRole ,trainningMangerRole ,studentRole
deny insert , update , delete ,select on schema :: [Courses] to  instructoreRole ,trainningMangerRole ,studentRole
deny insert , update , delete ,select on schema :: [exams]  to   instructoreRole ,trainningMangerRole ,studentRole
deny insert , update , delete ,select on schema :: [userAcc] to   instructoreRole ,trainningMangerRole ,studentRole

alter authorization on schema::[studentViews] to dbo;
alter authorization on schema::[InstructorViews] to dbo;
alter authorization on schema::[MangerViews] to dbo;

grant select on schema :: [studentViews] to studentRole
grant select on schema :: [InstructorViews] to instructoreRole
grant select on schema :: [MangerViews] to trainningMangerRole