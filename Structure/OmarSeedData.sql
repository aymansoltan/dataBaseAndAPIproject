
EXEC [InstructorStp].stp_createquestion
@questiontext='CSS is used to style web pages.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='JavaScript runs only on the server.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Primary key must be unique.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Foreign key creates relationship between tables.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='SELECT is used to delete data.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='An interface can contain method declarations.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='C# supports OOP principles.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='NULL equals zero.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='GET method is used to retrieve data.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=1
-----------------------------------------------------------------


EXEC [InstructorStp].stp_createquestion
@questiontext='Which CSS property changes text color?',
@questiontype='mcq',
@correctanswer='b',
@bestanswer='color',
@points=4,
@courseid=1,
@optionslist='background |color |font-size'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which SQL keyword is used to retrieve data?',
@questiontype='mcq',
@correctanswer='c',
@bestanswer='SELECT',
@points=4,
@courseid=1,
@optionslist='DELETE |INSERT |SELECT'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which is a C# data type?',
@questiontype='mcq',
@correctanswer='a',
@bestanswer='int',
@points=4,
@courseid=1,
@optionslist='int |number |decimalnumber'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which HTTP method is used to create data?',
@questiontype='mcq',
@correctanswer='b',
@bestanswer='POST',
@points=4,
@courseid=1,
@optionslist='GET |POST |DELETE'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which symbol is used for comments in C#?',
@questiontype='mcq',
@correctanswer='a',
@bestanswer='//',
@points=4,
@courseid=1,
@optionslist='// |<!-- --> |#'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which constraint ensures uniqueness?',
@questiontype='mcq',
@correctanswer='c',
@bestanswer='UNIQUE',
@points=4,
@courseid=1,
@optionslist='CHECK |DEFAULT |UNIQUE'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which is not an OOP principle?',
@questiontype='mcq',
@correctanswer='b',
@bestanswer='Compilation',
@points=4,
@courseid=1,
@optionslist='Inheritance |Compilation |Encapsulation'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which keyword is used to inherit a class in C#?',
@questiontype='mcq',
@correctanswer='c',
@bestanswer=':',
@points=4,
@courseid=1,
@optionslist='implement |extends |:'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which SQL clause filters results?',
@questiontype='mcq',
@correctanswer='a',
@bestanswer='WHERE',
@points=4,
@courseid=1,
@optionslist='WHERE |GROUP BY |ORDER BY'



-------------------------

EXEC [InstructorStp].stp_createquestion
@questiontext='What does HTML stand for?',
@questiontype='text',
@bestanswer='HyperText Markup Language',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Define CSS.',
@questiontype='text',
@bestanswer='Cascading Style Sheets',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='What is a primary key?',
@questiontype='text',
@bestanswer='A column that uniquely identifies each row in a table',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Explain OOP.',
@questiontype='text',
@bestanswer='Object Oriented Programming paradigm based on objects and classes',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='What is an API?',
@questiontype='text',
@bestanswer='Application Programming Interface',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='What does SQL stand for?',
@questiontype='text',
@bestanswer='Structured Query Language',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Define Encapsulation.',
@questiontype='text',
@bestanswer='Wrapping data and methods into a single unit',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='What is a foreign key?',
@questiontype='text',
@bestanswer='A column that references primary key in another table',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='What is polymorphism?',
@questiontype='text',
@bestanswer='Ability of objects to take multiple forms',
@points=4,
@courseid=1

EXEC [InstructorStp].stp_createquestion
@questiontext='Explain REST.',
@questiontype='text',
@bestanswer='Architectural style for designing networked applications',
@points=4,
@courseid=1

-------------------------------------------------------
EXEC [InstructorStp].stp_createexam
    @examtitle ='Exam_1',
    @examtype  = 'regular',
    @StartTime = '2026-06-01 09:00',
    @EndTime = '2026-06-01 11:00',
    @courseinstanceid =1,
    @branchid         =1,
    @trackid          =1,
    @intakeid         =1,
    @mode             ='manual', -- 'manual' or 'random'
    @questionids      = '122,123,124,134,135,136,140,145'

    
-------------------------------------------------------
EXEC [InstructorStp].stp_createexam
    @examtitle ='Exam_1',
    @examtype  = 'regular',
    @StartTime = '2026-06-05 09:00',
    @EndTime = '2026-06-05 11:00',
    @courseinstanceid =1,
    @branchid         =1,
    @trackid          =1,
    @intakeid         =1,
    @mode             ='random', -- 'manual' or 'random'
    @questioncount   = 9,
    @mcqcount   = 3,
    @tfcount  = 5,
    @textcount =1      