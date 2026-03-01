
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
@correctanswer='color',
@bestanswer='color',
@points=4,
@courseid=1,
@optionslist='background |color |font-size'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which SQL keyword is used to retrieve data?',
@questiontype='mcq',
@correctanswer='SELECT',
@bestanswer='SELECT',
@points=4,
@courseid=1,
@optionslist='DELETE |INSERT |SELECT'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which is a C# data type?',
@questiontype='mcq',
@correctanswer='int',
@bestanswer='int',
@points=4,
@courseid=1,
@optionslist='int |number |decimalnumber'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which HTTP method is used to create data?',
@questiontype='mcq',
@correctanswer='POST',
@bestanswer='POST',
@points=4,
@courseid=1,
@optionslist='GET |POST |DELETE'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which symbol is used for comments in C#?',
@questiontype='mcq',
@correctanswer='//',
@bestanswer='//',
@points=4,
@courseid=1,
@optionslist='// |<!-- --> |#'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which constraint ensures uniqueness?',
@questiontype='mcq',
@correctanswer='UNIQUE',
@bestanswer='UNIQUE',
@points=4,
@courseid=1,
@optionslist='CHECK |DEFAULT |UNIQUE'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which is not an OOP principle?',
@questiontype='mcq',
@correctanswer='Compilation',
@bestanswer='Compilation',
@points=4,
@courseid=1,
@optionslist='Inheritance |Compilation |Encapsulation'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which keyword is used to inherit a class in C#?',
@questiontype='mcq',
@correctanswer=':',
@bestanswer=':',
@points=4,
@courseid=1,
@optionslist='implement |extends |:'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which SQL clause filters results?',
@questiontype='mcq',
@correctanswer='WHERE',
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
----------------------------------------

EXEC [InstructorStp].stp_createquestion
    @questiontext='JavaScript is a dynamically typed programming language.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The let keyword allows block-scoped variables in ES6.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='const variables can be reassigned after declaration.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Arrow functions were introduced in ES6.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='JavaScript is only used for front-end development.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Template literals use backticks (`) instead of single or double quotes.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The === operator checks both value and type.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='var is block-scoped like let.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Promises are used to handle asynchronous operations.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Array.map() modifies the original array.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=2
GO



/* ===================== MCQ ===================== */
EXEC [InstructorStp].stp_createquestion
    @questiontext='Which keyword declares a block-scoped variable?',
    @questiontype='mcq',
    @correctanswer='let',
    @bestanswer='let',
    @points =4,
    @courseid=2,
    @optionslist='var |let |function'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which method is used to add an element to the end of an array?',
    @questiontype='mcq',
    @correctanswer='push',
    @bestanswer='push',
    @points =4,
    @courseid=2,
    @optionslist='shift |unshift |push'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What does JSON stand for?',
    @questiontype='mcq',
    @correctanswer='JavaScript Object Notation',
    @bestanswer='JavaScript Object Notation',
    @points =4,
    @courseid=2,
    @optionslist='JavaScript Object Notation |Java Syntax Object Network |Joint Script Object Name'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which symbol is used for arrow functions?',
    @questiontype='mcq',
    @correctanswer='=>',
    @bestanswer='=>',
    @points =4,
    @courseid=2,
    @optionslist='=>= |=> |==>'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which method converts a JSON string into an object?',
    @questiontype='mcq',
    @correctanswer='JSON.parse',
    @bestanswer='JSON.parse',
    @points =4,
    @courseid=2,
    @optionslist='JSON.stringify |JSON.convert |JSON.parse'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which loop is commonly used to iterate over arrays?',
    @questiontype='mcq',
    @correctanswer='for',
    @bestanswer='for',
    @points =4,
    @courseid=2,
    @optionslist='for |switch |try'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which ES6 feature allows unpacking values from arrays?',
    @questiontype='mcq',
    @correctanswer='Destructuring',
    @bestanswer='Destructuring',
    @points =4,
    @courseid=2,
    @optionslist='Closure |Destructuring |Callback'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which keyword is used to define a class in ES6?',
    @questiontype='mcq',
    @correctanswer='class',
    @bestanswer='class',
    @points =4,
    @courseid=2,
    @optionslist='object |struct |class'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which method creates a new array with transformed elements?',
    @questiontype='mcq',
    @correctanswer='map',
    @bestanswer='map',
    @points =4,
    @courseid=2,
    @optionslist='map |forEach |filter'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which keyword is used to handle errors?',
    @questiontype='mcq',
    @correctanswer='try',
    @bestanswer='try',
    @points =4,
    @courseid=2,
    @optionslist='while |try |loop'
GO

/* ===================== TEXT QUESTIONS ===================== */

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain the difference between var, let, and const.',
    @questiontype='text',
    @bestanswer='var is function-scoped, while let and const are block-scoped. const cannot be reassigned after declaration.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is an arrow function and how is it different from a regular function?',
    @questiontype='text',
    @bestanswer='Arrow functions provide a shorter syntax and do not bind their own this value.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain how promises work in JavaScript.',
    @questiontype='text',
    @bestanswer='A promise represents a future value and has three states: pending, fulfilled, and rejected.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Describe what destructuring is in ES6.',
    @questiontype='text',
    @bestanswer='Destructuring allows extracting values from arrays or properties from objects into distinct variables.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the purpose of template literals?',
    @questiontype='text',
    @bestanswer='Template literals allow embedded expressions and multi-line strings using backticks.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is a closure in JavaScript?',
    @questiontype='text',
    @bestanswer='A closure is a function that has access to variables from its outer scope even after the outer function has returned.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the difference between == and === in JavaScript?',
    @questiontype='text',
    @bestanswer='== checks value only with type coercion, while === checks both value and type without coercion.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain what async and await do in JavaScript.',
    @questiontype='text',
    @bestanswer='async declares a function that returns a promise, and await pauses execution until the promise is resolved.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the spread operator in ES6?',
    @questiontype='text',
    @bestanswer='The spread operator (...) expands an iterable such as an array into individual elements.',
    @points =4,
    @courseid=2
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the difference between null and undefined in JavaScript?',
    @questiontype='text',
    @bestanswer='undefined means a variable has been declared but not assigned a value, while null is an intentional assignment representing no value.',
    @points =4,
    @courseid=2
GO


---------------------------------------------------------Mariam-------------------------------


--Azure courseid=4 -------------------------------------------------------------------------------

/* ===================== TRUE / FALSE ===================== */

EXEC [InstructorStp].stp_createquestion
@questiontext='Azure is a cloud computing platform provided by Microsoft.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='IaaS stands for Infrastructure as a Service.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='PaaS requires managing physical servers.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Azure Virtual Machines are an example of IaaS.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='SaaS requires users to manage the operating system.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Azure Blob Storage is used to store unstructured data.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Azure SQL Database is a fully managed service.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Public cloud is only accessible by one organization.',
@questiontype='t/f',
@correctanswer='False',
@bestanswer='False',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Azure supports hybrid cloud environments.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Region in Azure refers to a physical data center location.',
@questiontype='t/f',
@correctanswer='True',
@bestanswer='True',
@points=2,
@courseid=4

/* ===================== MCQ ===================== */

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure service is used for hosting virtual machines?',
@questiontype='mcq',
@correctanswer='Azure Virtual Machines',
@bestanswer='Azure Virtual Machines',
@points=4,
@courseid=4,
@optionslist='Azure Virtual Machines |Azure DevOps |Azure Monitor'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which service is used for object storage in Azure?',
@questiontype='mcq',
@correctanswer='Azure Blob Storage',
@bestanswer='Azure Blob Storage',
@points=4,
@courseid=4,
@optionslist='Azure Files |Azure Blob Storage |Azure Backup'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which cloud model provides full control over infrastructure?',
@questiontype='mcq',
@correctanswer='IaaS',
@bestanswer='IaaS',
@points=4,
@courseid=4,
@optionslist='SaaS |PaaS |IaaS'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure service is used for monitoring resources?',
@questiontype='mcq',
@correctanswer='Azure Monitor',
@bestanswer='Azure Monitor',
@points=4,
@courseid=4,
@optionslist='Azure Monitor |Azure VM |Azure DNS'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure service provides serverless computing?',
@questiontype='mcq',
@correctanswer='Azure Functions',
@bestanswer='Azure Functions',
@points=4,
@courseid=4,
@optionslist='Azure VM |Azure Functions |Azure Storage'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure service is used for relational databases?',
@questiontype='mcq',
@correctanswer='Azure SQL Database',
@bestanswer='Azure SQL Database',
@points=4,
@courseid=4,
@optionslist='Azure Blob |Azure CDN |Azure SQL Database'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which service manages identities in Azure?',
@questiontype='mcq',
@correctanswer='Azure Active Directory',
@bestanswer='Azure Active Directory',
@points=4,
@courseid=4,
@optionslist='Azure Active Directory |Azure VM |Azure Storage'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure feature helps with scaling automatically?',
@questiontype='mcq',
@correctanswer='Auto Scaling',
@bestanswer='Auto Scaling',
@points=4,
@courseid=4,
@optionslist='Azure Backup |Auto Scaling |Azure Policy'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which Azure storage type is best for file sharing?',
@questiontype='mcq',
@correctanswer='Azure Files',
@bestanswer='Azure Files',
@points=4,
@courseid=4,
@optionslist='Blob Storage |Queue Storage |Azure Files'

EXEC [InstructorStp].stp_createquestion
@questiontext='Which pricing model charges only for what you use?',
@questiontype='mcq',
@correctanswer='Pay-As-You-Go',
@bestanswer='Pay-As-You-Go',
@points=4,
@courseid=4,
@optionslist='Pay-As-You-Go |Fixed Monthly |Free Forever'

/* ===================== TEXT ===================== */

EXEC [InstructorStp].stp_createquestion
@questiontext='Define Cloud Computing.',
@questiontype='text',
@bestanswer='Delivery of computing services over the internet',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What does IaaS stand for?',
@questiontype='text',
@bestanswer='Infrastructure as a Service',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Explain PaaS.',
@questiontype='text',
@bestanswer='Platform as a Service provides environment to develop and deploy applications',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What is Azure Blob Storage?',
@questiontype='text',
@bestanswer='Service for storing unstructured data in Azure',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What is a Resource Group in Azure?',
@questiontype='text',
@bestanswer='Logical container for Azure resources',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Define SaaS.',
@questiontype='text',
@bestanswer='Software as a Service delivers software over the internet',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What is Azure Virtual Network?',
@questiontype='text',
@bestanswer='Service that provides isolated network in Azure',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What is Auto Scaling?',
@questiontype='text',
@bestanswer='Automatic adjustment of resources based on demand',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='Explain serverless computing.',
@questiontype='text',
@bestanswer='Cloud execution model where provider manages infrastructure automatically',
@points=4,
@courseid=4

EXEC [InstructorStp].stp_createquestion
@questiontext='What is Azure Active Directory?',
@questiontype='text',
@bestanswer='Cloud based identity and access management service',
@points=4,
@courseid=4

--- Linux Courseid = 3 --------------------------------------------------------

/* ===================== TRUE / FALSE ===================== */

EXEC [InstructorStp].stp_createquestion
    @questiontext='Linux is an open-source operating system.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The root directory in Linux is represented by /.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The pwd command is used to delete files.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Linux file names are case-sensitive.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The mkdir command is used to create a new file.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The cd command changes the current directory.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Linux supports multi-user environments.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The rm command is used to rename files.',
    @questiontype='t/f',
    @correctanswer='False',
    @bestanswer='False',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='The man command displays the manual pages of commands.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Linux was originally developed by Linus Torvalds.',
    @questiontype='t/f',
    @correctanswer='True',
    @bestanswer='True',
    @points =2,
    @courseid=3
GO

/* ===================== MCQ ===================== */

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command is used to display the current directory?',
    @questiontype='mcq',
    @correctanswer='pwd',
    @bestanswer='pwd',
    @points =4,
    @courseid=3,
    @optionslist='pwd |ls |rm'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command is used to create a directory?',
    @questiontype='mcq',
    @correctanswer='mkdir',
    @bestanswer='mkdir',
    @points =4,
    @courseid=3,
    @optionslist='touch |cd |mkdir'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command removes a file?',
    @questiontype='mcq',
    @correctanswer='rm',
    @bestanswer='rm',
    @points =4,
    @courseid=3,
    @optionslist='mv |rm |pwd'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which symbol represents the home directory?',
    @questiontype='mcq',
    @correctanswer='~',
    @bestanswer='~',
    @points =4,
    @courseid=3,
    @optionslist='~ |/ |*'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command shows the content of a file?',
    @questiontype='mcq',
    @correctanswer='cat',
    @bestanswer='cat',
    @points =4,
    @courseid=3,
    @optionslist='mkdir |cd |cat'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command copies files?',
    @questiontype='mcq',
    @correctanswer='cp',
    @bestanswer='cp',
    @points =4,
    @courseid=3,
    @optionslist='rm |cp |ls'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command moves or renames files?',
    @questiontype='mcq',
    @correctanswer='mv',
    @bestanswer='mv',
    @points =4,
    @courseid=3,
    @optionslist='mv |cat |man'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which file contains user account information?',
    @questiontype='mcq',
    @correctanswer='/etc/passwd',
    @bestanswer='/etc/passwd',
    @points =4,
    @courseid=3,
    @optionslist='/etc/shadow |/bin/bash |/etc/passwd'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command displays running processes?',
    @questiontype='mcq',
    @correctanswer='ps',
    @bestanswer='ps',
    @points =4,
    @courseid=3,
    @optionslist='ps |ls |touch'
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Which command is used to change file permissions?',
    @questiontype='mcq',
    @correctanswer='chmod',
    @bestanswer='chmod',
    @points =4,
    @courseid=3,
    @optionslist='chown |chmod |grep'
GO

/* ===================== TEXT QUESTIONS ===================== */

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain the purpose of the Linux kernel.',
    @questiontype='text',
    @bestanswer='The Linux kernel manages system resources such as CPU, memory, and hardware devices, and allows communication between hardware and software.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Describe the function of the ls command with common options.',
    @questiontype='text',
    @bestanswer='The ls command lists files and directories. Common options include -l for long listing format and -a to show hidden files.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the difference between chmod and chown?',
    @questiontype='text',
    @bestanswer='chmod changes file permissions, while chown changes file ownership.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain what a Linux distribution is.',
    @questiontype='text',
    @bestanswer='A Linux distribution is a packaged version of Linux that includes the kernel, system tools, libraries, and applications such as Ubuntu or Fedora.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Describe the Linux file system hierarchy.',
    @questiontype='text',
    @bestanswer='The Linux file system hierarchy starts at the root directory / and includes directories like /home, /etc, /bin, and /usr, each serving a specific purpose.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is a shell in Linux?',
    @questiontype='text',
    @bestanswer='A shell is a command-line interpreter that allows users to interact with the operating system by executing commands.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain the difference between absolute and relative paths.',
    @questiontype='text',
    @bestanswer='An absolute path starts from the root directory, while a relative path starts from the current working directory.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='What is the purpose of the grep command?',
    @questiontype='text',
    @bestanswer='The grep command searches for specific patterns or text within files.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Explain file permissions in Linux.',
    @questiontype='text',
    @bestanswer='File permissions define who can read, write, or execute a file. They are assigned to the owner, group, and others.',
    @points =4,
    @courseid=3
GO

EXEC [InstructorStp].stp_createquestion
    @questiontext='Describe the role of package managers in Linux.',
    @questiontype='text',
    @bestanswer='Package managers are tools used to install, update, and remove software packages in Linux distributions.',
    @points =4,
    @courseid=3
GO