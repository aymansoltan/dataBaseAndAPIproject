create database ExaminationSystemDB
on primary 
(
    name = 'ExamDB_Primary',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Primary\ExamDB_Primary.mdf',
    size = 10MB,
    maxsize = 100MB,
    filegrowth = 10MB
),
filegroup FG_Users
(
    name = 'ExamDB_Users',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Users\ExamDB_Users.ndf',
    size = 5MB,
    maxsize = 50MB,
    filegrowth = 5MB
),
filegroup FG_Courses
(
    name = 'ExamDB_Courses',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Courses\ExamDB_Courses.ndf',
    size = 5MB,
    maxsize = 50MB,
    filegrowth = 5MB
),
filegroup FG_Exams
(
    name = 'ExamDB_Exams',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Exams\ExamDB_Exams.ndf',
    size = 10MB,
    maxsize = 200MB,
    filegrowth = 10MB
),
filegroup FG_Questions
(
    name = 'ExamDB_Questions',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Questions\ExamDB_Questions.ndf',
    size = 5MB,
    maxsize = 100MB,
    filegrowth = 5MB
)
log on
(
    name = 'ExamDB_Log',
    filename = 'C:\Users\Administrator\Desktop\Examdb\Log\ExamDB_Log.ldf',
    size = 5MB,
    maxsize = 100MB,
    filegrowth = 5MB
);
go
use [ExaminationSystemDB];
go
create schema userAcc;
go
create schema orgnization;
go
create schema Courses;
go
create schema exams;
go
create schema [studentViews];
go
create schema [InstructorViews];
go
create schema [MangerViews] ;
go
create schema [InstructorStp]
go
create schema [StudentStp]
go
create schema [TrainingMangerStp]
go
create schema [admin]
go


create table [orgnization].Branch
(
    BranchId int identity(1,1),
    BranchName nvarchar(50) not null,
    isActive bit constraint branchActiveDefault default 1,
    createdAt datetime constraint createdAtDefault default getdate(),

    constraint BranchPK primary key (BranchId),
    constraint BranchNameUniqe unique (BranchName),
    constraint BranchNamelenCheck check(len(BranchName) >=3),
    constraint BranchNameFormatCheck check (BranchName NOT like '[0-9]%' AND BranchName NOT like '[!@#$%^&*]%'),
) on [primary]
go
create table [orgnization].Department(
    DeptId int identity(1,1),
    DeptName nvarchar(50) not null,
    isActive bit constraint DepartmentActiveDefault default 1 ,
    createdAt datetime constraint deptcreatedAtDefault default getdate(),
    BranchId int,

    constraint DepartmentPK primary key (DeptId),
    constraint DepartmentName_branchUniqe unique (DeptName ,BranchId ),
    constraint DepartmentNamelenCheck check(len(DeptName) >=3),
    constraint DepartmentNameFormatCheck check (DeptName NOT like '[0-9]%' AND DeptName NOT like '[!@#$%^&*]%'),
    constraint DepartmentBranchFK foreign key (BranchId) references [orgnization].[Branch](BranchId)
) on [primary]
go
create table [orgnization].Track(
    TrackId int identity(1,1),
    TrackName nvarchar(50) not null,
    isActive bit constraint TrackActiveDefault default 1,
    createdAt datetime constraint TrackCreatedAtDefault default getdate(),
    DeprtmentId int,

    constraint TrackPK primary key (TrackId),
    constraint TrackName_DeptUniqe unique (TrackName ,DeprtmentId ),
    constraint TrackNamelenCheck check(len(TrackName) >=3),
    constraint TrackNameFormatCheck check (TrackName NOT like '[0-9]%' AND TrackName NOT like '[!@#$%^&*]%'),
    constraint TrackDepartmentFK foreign key (DeprtmentId) references [orgnization].[Department](DeptId)
) on [primary]
go
create table [orgnization].Intake(
    IntakeId int identity(1,1),
    IntakeName nvarchar(50) not null,
    isActive bit constraint IntakeActiveDefault default 1,
    createdAt datetime constraint IntakeCreatedAtDefault default getdate(),

    constraint IntakePK primary key (IntakeId),
    constraint IntakeNameUniqe unique (IntakeName),
    constraint IntakeNamelenCheck check(len(IntakeName) >=3),
    constraint IntakeNameFormatCheck check (IntakeName NOT like '[0-9]%' AND IntakeName NOT like '[!@#$%^&*]%'),
) on [primary]
go
create table [orgnization].IntakeTrack(
    IntakeId int,
    TrackId int,
    isActive bit constraint IntakeTrackActiveDefault default 1,

    constraint IntakeTrackPK primary key (IntakeId ,TrackId),
    constraint IT_IntackFK foreign key (IntakeId) references [orgnization].Intake(IntakeId),
    constraint IT_TrackFK foreign key (TrackId) references [orgnization].Track(TrackId)
) on [primary]
go
create table [userAcc].UserRole(
    RoleId int identity(1,1),
    RoleName nvarchar(20) not null,

    constraint RolePK primary key (RoleId),
    constraint RoleNameUniqe unique (RoleName),
    constraint RoleNamelenCheck check(len(RoleName) >=3),
    constraint RoleNameCheck check (RoleName in ('admin' , 'instructor','student','Training Manager'))
) on [FG_Users]
go
create table [userAcc].UserAccount(
    UserId int identity(1,1),
    UserName nvarchar(50) not null,
    Email nvarchar(100) not null,
    UserPassword nvarchar(250) not null,
    isActive bit constraint UserActiveDefault default 1,
    createdAt datetime constraint UserCreatedAtDefault default getdate(),
    RoleId int,

    constraint UserPK primary key (UserId),
    constraint UserNameUnique unique (UserName),
    constraint UserNamelenCheck check(len(UserName) >=3),
    constraint UserNameFormatCheck check (UserName NOT like '[0-9]%' AND UserName NOT like '[!@#$%^&*]%'),
    constraint EmailUnique unique (Email),
    constraint EmaillenCheck check(len(Email) > 10),
    constraint UserEmailFormatCheck check (Email like '%_@__%.__%'),
    constraint UserRoleFK foreign key (RoleId) references [userAcc].UserRole(RoleId)
)on [FG_Users]
go
create table [userAcc].Student (
    StudentId int identity(1,1),
    FirstName nvarchar(50) not null,
    LastName nvarchar(50) not null,
    Gender char(1) not null,
    BirthDate date not null,
    StuAddress nvarchar(150) not null,
    Phone nvarchar(11) not null,
    NationalID nchar(14) not null,
    Age as (datediff(year, BirthDate, getdate())), 
    UserId int not null,
    BranchId int not null,
    IntakeId int not null,
    TrackId int not null,
    isActive bit default 1,
    constraint StudentPK primary key (StudentId),
    constraint FirstNamelenCheck check(len(FirstName) >= 3),
    constraint FirstNameFormatCheck check (FirstName NOT like '[0-9]%' AND FirstName NOT like '[!@#$%^&*]%'),

    constraint LastNamelenCheck check(len(LastName) >= 3),
    constraint LastNameFormatCheck check (LastName NOT like '[0-9]%' AND LastName NOT like '[!@#$%^&*]%'),

    constraint StudentGenderCheck check (Gender in ('M', 'F')),
    constraint StudentAgeCheck check (datediff(year, BirthDate, getdate()) >= 18),
    constraint StuAddresslenCheck check(len(StuAddress) >10),
    constraint StudentPhoneUnique unique (Phone),
    constraint PhonelenCheck check(len(Phone) = 11),
    constraint StudentPhoneFormat check (Phone like '01[0125]%'),
    constraint StudentNationalIDUnique unique (NationalID),
    constraint NationalIDlenCheck check(len(NationalID) = 14),
    constraint StudentNationalIDFormat check (NationalID like '3%'),
    constraint StudentUserUnique unique (UserId),   
    constraint StudentUserFK foreign key (UserId) references [userAcc].UserAccount(UserId),
    constraint StudentBranchFK foreign key (BranchId) references [orgnization].Branch(BranchId),
    constraint StudentIntakeFK foreign key (IntakeId) references [orgnization].Intake(IntakeId),
    constraint StudentTrackFK foreign key (TrackId) references [orgnization].Track(TrackId)
) on [FG_Users];
go
create table [userAcc].Instructor (
    InsId int identity(1,1),
    FirstName nvarchar(50) not null,
    LastName nvarchar(50) not null,
    BirthDate date,
    Age as (datediff(year, BirthDate, getdate())), 
    InsAddress nvarchar(150),
    Phone nvarchar(11) not null,
    NationalID nchar(14) not null,
    Salary decimal(10,2) not null,
    HireDate date constraint InsHireDateDefault default getdate(),
    Specialization nvarchar(50) not null,
    UserId int not null,
    DeptId int not null,
    isActive bit default 1
    constraint InstructorPK primary key (InsId),
    constraint InstructorFirstNamelenCheck check(len(FirstName) >= 3),
    constraint InstructorFirstNameFormatCheck check (FirstName NOT like '[0-9]%' AND FirstName NOT like '[!@#$%^&*]%'),

    constraint InstructorLastNamelenCheck check(len(LastName) >= 3),
    constraint InstructorLastNameFormatCheck check (LastName NOT like '[0-9]%' AND LastName NOT like '[!@#$%^&*]%'),

    constraint InstructorAgeCheck check (datediff(year, BirthDate, getdate()) >= 20),
    constraint InstructorAddresslenCheck check(len(InsAddress) >10),
    constraint InstructorPhoneUnique unique (Phone),
    constraint InstructorPhonelenCheck check(len(Phone) = 11),
    constraint InstructorPhoneFormat check (Phone like '01[0125]%'),
    constraint InstructorNationalIDUnique unique (NationalID),
    constraint InstructorNationalIDlenCheck check(len(NationalID) = 14),
    constraint InstructorNationalIDFormat check (NationalID like '[23]%'),
    constraint InstructorSalaryCheck check (Salary >= 4000), 
    constraint InstructorHireDateCheck check (HireDate >= '2020-01-01'),
    constraint InstructorUserUnique unique (UserId), 
    constraint InstructorUserFK foreign key (UserId) references [userAcc].UserAccount(UserId),
    constraint InstructorDeptFK foreign key (DeptId) references [orgnization].Department(DeptId)
) on [FG_Users];
go
create table [Courses].Course(
    CourseId int identity(1,1),
    CourseName nvarchar(50) not null,
    CourseDescription nvarchar(max),
    MinDegree int constraint MinDegreeDefault default 50,
    MaxDegree int constraint MaxDegreeDefault default 100,
    isActive bit default 1
    constraint CoursePK primary key (CourseId),
    constraint CourseNameUnique unique (CourseName),
    constraint CourseNameFormatCheck check (CourseName NOT like '[0-9]%' AND CourseName NOT like '[!@#$%^&*]%'),
    constraint MinDegreeCheck check (MinDegree >= (MaxDegree * 0.3)) 
) on [FG_Courses];
go
create table [Courses].CourseInstance(
CourseInstanceId int identity(1,1),
CourseId int not null,
InstructorId int not null , 
BranchId int not null,
TrackId int not null,
IntakeId int not null,
AcademicYear int not null,

constraint CourseInstancePK primary key (CourseInstanceId),

constraint CI_CourseFK foreign key (CourseId) references [Courses].Course(CourseId),
constraint CI_InstructorFK foreign key (InstructorId) references [userAcc].Instructor(InsId),
constraint CI_BranchFK foreign key (BranchId) references [orgnization].Branch(BranchId),
constraint CI_TrackFK foreign key (TrackId) references [orgnization].Track(TrackId),
constraint CI_IntakeFK foreign key (IntakeId) references [orgnization].Intake(IntakeId),
) on [FG_Courses];
go
create table [exams].Question(
QuestionId int identity(1,1),
QuestionText nvarchar(max) not null,
QuestionType nvarchar(20) not null,
CorrectAnswer nvarchar(max) ,
BestAnswer nvarchar(max) not null, 
Points int default 1,
CourseId int not null,
IsDeleted BIT DEFAULT 0,

constraint QuestionPK primary key (QuestionId),
constraint QuestionTypeCheck check (QuestionType in ('MCQ', 'T/F','Text')),
constraint FK_Question_Course foreign key (CourseId) references [Courses].Course(CourseId)
)on [FG_Questions] 
go
create table [exams].QuestionOption (
    QuestionOptionId int identity(1,1),
    QuestionOptionText nvarchar(max) not null,
    QuestionId int not null,

    constraint QuestionOptionPK primary key (QuestionOptionId),
    constraint OQ_QuestionFK foreign key (QuestionId) references [exams].Question(QuestionId)
) on [FG_Questions];
go
create  table [exams].Exam (
    ExamId int identity(1,1),
    ExamTitle nvarchar(100) not null ,
    ExamType nvarchar(20) not null default 'Regular', 
    StartTime datetime not null,
    EndTime datetime not null,
    DurationMinutes AS (datediff(minute, StartTime, EndTime)),
    CourseInstanceId int not null ,
    BranchId int not null ,
    TrackId int not null ,
    IntakeId int not null ,
    IsDeleted bit default 0,
    TotalGrade int 

    constraint ExamPK primary key (ExamId),
    constraint ExamTypeCheck check (ExamType IN ('Regular', 'Corrective')),
    constraint StartTimeRangeCheck check (cast(StartTime AS TIME) >= '08:00:00'),
    constraint EndTimeRangeCheck check (cast(EndTime AS TIME) <= '23:00:00'),
    constraint ExamTimeOrderCheck check (EndTime > StartTime),
    constraint ExamDurationCheck check (datediff(minute, StartTime, EndTime) >= 30),
    constraint Exam_CourseInstanceFK foreign key  (CourseInstanceId) references  [Courses].CourseInstance(CourseInstanceId),
    constraint Exam_BranchFK foreign key (BranchId) references [orgnization].Branch(BranchId),
    constraint Exam_TrackFK foreign key (TrackId) references [orgnization].Track(TrackId),
    constraint Exam_IntakeFK foreign key (IntakeId) references [orgnization].Intake(IntakeId)
) on [FG_Exams];
go
create table [exams].ExamQuestion (
    ExamId int not null,
    QuestionId int not null,

    constraint ExamQuestionPK primary key (ExamId, QuestionId),
    constraint EQ_ExamFK foreign key (ExamId) references [exams].Exam(ExamId),
    constraint EQ_QuestionFK foreign key (QuestionId) references [exams].Question(QuestionId)
) on [FG_Exams];
go
create table [exams].Student_Answer (
    StudentId int not null,
    ExamId int not null,
    QuestionId int not null,
    StudentResponse nvarchar(max), 
    SystemGrade int default 0,        
    InstructorGrade int,             
    
    constraint StudentAnswerPK primary key (StudentId, ExamId, QuestionId),
    constraint FK_Ans_Student foreign key (StudentId) references [userAcc].Student(StudentId),
    constraint FK_Ans_Exam foreign key (ExamId) references [exams].Exam(ExamId),
    constraint FK_Ans_Question foreign key (QuestionId) references [exams].Question(QuestionId)
) on [FG_Exams];
go
create table [exams].Student_Exam_Result (
    StudentId int not null,
    ExamId int not null,
    TotalGrade int,                 
    IsPassed bit default 0,                  
    
    constraint StudentResultPK primary key (StudentId, ExamId),
    constraint FK_Res_Student foreign key (StudentId) references [userAcc].Student(StudentId),
    constraint FK_Res_Exam foreign key (ExamId) references [exams].Exam(ExamId)
) on [FG_Exams];
go
create synonym Branch for [orgnization].Branch;
go
create synonym Dept for [orgnization].Department;
go
create synonym Track for [orgnization].Track;
go
create synonym Intake for [orgnization].Intake;
go
create synonym IntakeTrack for [orgnization].IntakeTrack;
go
create synonym Roles for [userAcc].UserRole;
go
create synonym Accounts for [userAcc].UserAccount;
go
create synonym Students for [userAcc].Student;
go
create synonym Instructors for [userAcc].Instructor;
go
create synonym Course for [Courses].Course;
go
create synonym CourseInstance for [Courses].CourseInstance;
go
create synonym Questions for [exams].Question;
go
create synonym Options for [exams].QuestionOption;
go
create synonym Exams for [exams].Exam;
go
create synonym ExamQuestions for [exams].ExamQuestion;
go
create synonym StudentAnswers for [exams].Student_Answer;
go
create synonym FinalResults for [exams].Student_Exam_Result;
go
alter database [ExaminationSystemDB] set recursive_triggers on;
go

