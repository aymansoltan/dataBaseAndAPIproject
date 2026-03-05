select * from [userAcc].[UserAccount]
EXECUTE AS USER = 'moatzuser';
EXECUTE AS USER = 'marcouser'; --id 
EXECUTE AS USER = 'ragabuser'; --id
revert
select SUSER_SNAME()
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =89,
    @StudentResponse ='true' --true 2points
go
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =90,
    @StudentResponse ='true' --error
go 
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =91,
    @StudentResponse ='true' -- false answer 2 points
go 
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =99,
    @StudentResponse ='a' -- true 4points
go
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =105,
    @StudentResponse ='a' -- true 4 points
go
exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =113,
    @StudentResponse ='container Azure' -- text
go

EXECUTE AS USER = 'mariamuser';
go
exec [InstructorStp].stp_InstructorGradeText --marco 4 points
    @ExamId   =   4   ,
    @StudentId = 8    ,
    @QuestionId =113     ,
    @InstructorGrade =2

    -------------------------------------------------------------------

    exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=,
    @QuestionId =,
    @StudentResponse ='true' -- text
-----------------------------------------------------
exec [InstructorStp].stp_InstructorGradeText --
    @ExamId   =   4  ,
    @StudentId = 8    ,
    @QuestionId =113     ,
    @InstructorGrade =2