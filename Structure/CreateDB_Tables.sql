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
use ExaminationSystemDB;
create schema userAcc;
create schema orgnization;
create schema Courses;
create schema exams;
create schema students;

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

create table [orgnization].IntakeTrack(
    IntakeId int,
    TrackId int,
    isActive bit constraint IntakeTrackActiveDefault default 1,

    constraint IntakeTrackPK primary key (IntakeId ,TrackId),
    constraint IT_IntackFK foreign key (IntakeId) references [orgnization].Intake(IntakeId),
    constraint IT_TrackFK foreign key (TrackId) references [orgnization].Track(TrackId)
) on [primary]
 
create table [userAcc].UserRole(
    RoleId int identity(1,1),
    RoleName nvarchar(20) not null,

    constraint RolePK primary key (RoleId),
    constraint RoleNameUniqe unique (RoleName),
    constraint RoleNamelenCheck check(len(RoleName) >=3),
    constraint RoleNameCheck check (RoleName in ('admin' , 'instructor','student','Training Manager'))
) on [FG_Users]

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


create table [Courses].Course(
    CourseId int identity(1,1),
    CourseName nvarchar(50) not null,
    CourseDescription nvarchar(max),
    MinDegree int constraint MinDegreeDefault default 50,
    MaxDegree int constraint MaxDegreeDefault default 100,

    constraint CoursePK primary key (CourseId),
    constraint CourseNameUnique unique (CourseName),
    constraint CourseNameFormatCheck check (CourseName NOT like '[0-9]%' AND CourseName NOT like '[!@#$%^&*]%'),
    constraint MinDegreeCheck check (MinDegree >= (MaxDegree * 0.3)) 
) on [FG_Courses];

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

create table [exams].QuestionOption (
    QuestionOptionId int identity(1,1),
    QuestionOptionText nvarchar(max) not null,
    QuestionId int not null,

    constraint QuestionOptionPK primary key (QuestionOptionId),
    constraint OQ_QuestionFK foreign key (QuestionId) references [exams].Question(QuestionId)
) on [FG_Questions];

create table [exams].Exam (
    ExamId int identity(1,1),
    ExamTitle nvarchar(100) not null,
    StartTime datetime not null,
    EndTime datetime not null,
    DurationMinutes as (datediff(minute, StartTime, EndTime)),
    CourseInstanceId int not null,
    IsDeleted BIT DEFAULT 0,
    constraint ExamPK primary key (ExamId),
    constraint StartTimeRangeCheck check (cast(StartTime as time) >= '08:00:00'),
    constraint EndTimeRangeCheck check (cast(EndTime as time) <= '16:00:00'),
    constraint ExamTimeOrderCheck check (EndTime > StartTime),
    constraint ExamDurationCheck check (datediff(minute, StartTime, EndTime) >= 30),
    constraint FK_Exam_CourseInstance foreign key (CourseInstanceId) references [Courses].CourseInstance(CourseInstanceId)
) on [FG_Exams];

create table [exams].ExamQuestion (
    ExamId int not null,
    QuestionId int not null,

    constraint ExamQuestionPK primary key (ExamId, QuestionId),
    constraint EQ_ExamFK foreign key (ExamId) references [exams].Exam(ExamId),
    constraint EQ_QuestionFK foreign key (QuestionId) references [exams].Question(QuestionId)
) on [FG_Exams];


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


create table [exams].Student_Exam_Result (
    StudentId int not null,
    ExamId int not null,
    TotalGrade int,                 
    IsPassed bit,                  
    
    constraint StudentResultPK primary key (StudentId, ExamId),
    constraint FK_Res_Student foreign key (StudentId) references [userAcc].Student(StudentId),
    constraint FK_Res_Exam foreign key (ExamId) references [exams].Exam(ExamId)
) on [FG_Exams];
create synonym Branch for [orgnization].Branch;
create synonym Dept for [orgnization].Department;
create synonym Track for [orgnization].Track;
create synonym Intake for [orgnization].Intake;
create synonym IntakeTrack for [orgnization].IntakeTrack;
create synonym Roles for [userAcc].UserRole;
create synonym Accounts for [userAcc].UserAccount;
create synonym Students for [userAcc].Student;
create synonym Instructors for [userAcc].Instructor;
create synonym Course for [Courses].Course;
create synonym CourseInstance for [Courses].CourseInstance;
create synonym Questions for [exams].Question;
create synonym Options for [exams].QuestionOption;
create synonym Exams for [exams].Exam;
create synonym ExamQuestions for [exams].ExamQuestion;
create synonym StudentAnswers for [exams].Student_Answer;
create synonym FinalResults for [exams].Student_Exam_Result;



INSERT INTO [orgnization].Branch (BranchName) VALUES 
('Smart Village'), ('Alexandria'), ('Mansoura'), ('Assiut'), ('Menofia');

INSERT INTO [orgnization].Department (DeptName, BranchId) VALUES 
('Software Engineering', 1), ('Data Science', 1), ('Cloud Computing', 2), 
('Embedded Systems', 3), ('Cyber Security', 4);

INSERT INTO [orgnization].Track (TrackName, DeprtmentId) VALUES 
('Full Stack .NET', 1), ('Python for BI', 2), ('Azure Cloud Admin', 3),
('Embedded C', 4), ('Ethical Hacking', 5);


INSERT INTO [orgnization].Intake (IntakeName) VALUES 
('Intake 42'), ('Intake 43'), ('Intake 44'), ('Intake 45'), ('Intake 46');

INSERT INTO [userAcc].UserRole (RoleName) 
VALUES 
('admin'), 
('instructor'), 
('student'), 
('Training Manager');

-- (1 Admin, 4 Instructors, 10 Students)
INSERT INTO [userAcc].UserAccount (UserName, Email, UserPassword, RoleId) VALUES 
('admin_iti', 'admin@iti.gov.eg', 'admin123', 1),
('moataz_ins', 'moataz@iti.gov.eg', 'ins123', 2),
('sara_ins', 'sara@iti.gov.eg', 'ins123', 2),
('ahmed_ins', 'ahmed@iti.gov.eg', 'ins123', 2),
('omar_ins', 'omar@iti.gov.eg', 'ins123', 2),
('stu_ali', 'ali@gmail.com', 'stu123', 3), 
('stu_mona', 'mona@gmail.com', 'stu123', 3),
('stu_zein', 'zein@gmail.com', 'stu123', 3),
('stu_nour', 'nour@gmail.com', 'stu123', 3),
('stu_hady', 'hady@gmail.com', 'stu123', 3), 
('stu_mai', 'mai@gmail.com', 'stu123', 3),
('stu_fady', 'fady@gmail.com', 'stu123', 3), 
('stu_layla', 'layla@gmail.com', 'stu123', 3),
('stu_gad', 'gad@gmail.com', 'stu123', 3),
('stu_yara', 'yara@gmail.com', 'stu123', 3);

INSERT INTO [userAcc].Instructor (FirstName, LastName, BirthDate, InsAddress, Phone, NationalID, Salary, Specialization, UserId, DeptId) VALUES 
('Moataz', 'Leader', '1985-01-01', 'Cairo, District 5', '01012345678', '28501011234567', 12000, 'SQL & DB', 2, 1),
('Sara', 'Ahmed', '1990-03-12', 'Alexandria, Roushdy', '01222334455', '29003121234567', 9500, 'Programming', 3, 2),
('Ahmed', 'Hassan', '1988-11-05', 'Mansoura, Toriel', '01155667788', '28811051234567', 10000, 'Cloud Services', 4, 3),
('Omar', 'Khalid', '1992-07-20', 'Cairo, Maadi', '01599887766', '29207201234567', 8500, 'Networks', 5, 4);


INSERT INTO [userAcc].Student (FirstName, LastName, Gender, BirthDate, StuAddress, Phone, NationalID, UserId, BranchId, IntakeId, TrackId) VALUES 
('Ali', 'Samy', 'M', '2001-01-01', 'Cairo, Nasr City', '01011112222', '30101011234561', 6, 1, 3, 1),
('Mona', 'Zaki', 'F', '2002-02-02', 'Alex, Gleem', '01233334444', '30202021234562', 7, 2, 3, 2),
('Zein', 'Eldin', 'M', '2000-05-10', 'Mansoura, Nile St', '01144445555', '30005101234563', 8, 3, 3, 3),
('Nour', 'Amer', 'F', '2001-08-15', 'Assiut, University St', '01566667777', '30108151234564', 9, 4, 3, 4),
('Hady', 'Adel', 'M', '2002-12-20', 'Cairo, Shobra', '01077778888', '30212201234565', 10, 1, 4, 1),
('Mai', 'Ibrahim', 'F', '2001-04-05', 'Alex, Smouha', '01288889999', '30104051234566', 11, 2, 4, 2),
('Fady', 'George', 'M', '2000-09-30', 'Mansoura, Mashaya', '01199990000', '30009301234567', 12, 3, 4, 3),
('Layla', 'Mahmoud', 'F', '2001-11-11', 'Assiut, Free Zone', '01511113333', '30111111234568', 13, 4, 4, 4),
('Gad', 'Ezz', 'M', '2002-06-25', 'Menofia, Shebin', '01022224444', '30206251234569', 14, 5, 4, 5),
('Yara', 'Hany', 'F', '2001-10-01', 'Cairo, Rehab', '01233335555', '30110011234570', 15, 1, 4, 1);


INSERT INTO [Courses].Course (CourseName, CourseDescription, MinDegree, MaxDegree) VALUES 
('SQL Server', 'Database Design & T-SQL', 50, 100),
('C# Fundamentals', 'Basics of C# and .NET', 60, 100),
('Data Warehouse', 'ETL and BI Concepts', 50, 100),
('Cloud Architecture', 'AWS & Azure Basics', 50, 100),
('Python Basics', 'Syntax and Core Python', 50, 100),
('Network Security', 'Firewalls & Encryption', 50, 100);


INSERT INTO [Courses].CourseInstance (CourseId, InstructorId, BranchId, TrackId, IntakeId, AcademicYear) VALUES 
(1, 1, 1, 1, 3, 2024), -- SQL by Moataz
(2, 2, 1, 1, 3, 2024), -- C# by Sara
(3, 2, 1, 2, 3, 2024), -- BI by Sara
(4, 3, 2, 3, 4, 2024), -- Cloud by Ahmed
(5, 4, 4, 4, 4, 2024), -- Python by Omar
(6, 4, 4, 5, 4, 2024); -- Security by Omar


INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) VALUES 
('What does SQL stand for?', 'MCQ', 'Structured Query Language', 'Structured Query Language', 2, 1),
('Primary Key allows Null values?', 'T/F', 'False', 'False', 1, 1),
('Explain what is a Join?', 'Text', NULL, 'A way to combine rows from two or more tables based on a related column', 5, 1),
('Is C# an Object Oriented Language?', 'T/F', 'True', 'True', 1, 2),
('Define a Class in C#.', 'Text', NULL, 'A blueprint for creating objects', 5, 2),
('What is ETL?', 'MCQ', 'Extract Transform Load', 'Extract Transform Load', 2, 3),
('S3 is a storage service in AWS?', 'T/F', 'True', 'True', 1, 4),
('What is a List in Python?', 'Text', NULL, 'A mutable ordered collection of items', 5, 5),
('List 3 types of Joins.', 'Text', NULL, 'Inner, Left, Right Joins', 5, 1),
('Can we have multiple Primary Keys?', 'T/F', 'False', 'No, only one primary key per table', 1, 1),
('What is the default port for SQL Server?', 'MCQ', '1433', '1433', 2, 1),
('Dictionary in Python is unordered?', 'T/F', 'True', 'True in versions before 3.7', 1, 5);
