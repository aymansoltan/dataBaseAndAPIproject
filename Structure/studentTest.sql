exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =89,
    @StudentResponse ='true'
    exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =90,
    @StudentResponse ='true'
    exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =99,
    @StudentResponse ='a'
    exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =103,
    @StudentResponse ='b'
    exec [StudentStp].stp_StudentSubmitAnswer 
    @ExamId=4,
    @QuestionId =113,
    @StudentResponse =' container  Azure '
exec [InstructorStp].stp_InstructorGradeText
    @ExamId   =   4   ,
    @StudentId = 4    ,
    @QuestionId =113     ,
    @InstructorGrade =2