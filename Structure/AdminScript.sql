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


GRANT SELECT ON SCHEMA::[userAcc] TO instructoreRole;
GRANT SELECT ON SCHEMA::[courses] TO instructoreRole;
GRANT SELECT ON SCHEMA::[orgnization] TO instructoreRole;
-- 1. › Õ «·’·«ÕÌ«  »«·ﬂ«„· ··—Ê· (⁄‘«‰ «·„œ—” Ì‘Ê› »‰ﬂ «·√”∆·… Ê«·«„ Õ«‰« )
GRANT SELECT, INSERT, UPDATE ON SCHEMA::[exams] TO instructoreRole;
GRANT SELECT ON SCHEMA::[userAcc] TO instructoreRole;
GRANT SELECT ON SCHEMA::[courses] TO instructoreRole;
GRANT SELECT ON SCHEMA::[orgnization] TO instructoreRole;

-- 2.  √ﬂœ ≈‰ «·‹ Role „÷«›… ··„œ—”Ì‰
ALTER ROLE instructoreRole ADD MEMBER [instructor_1user];

GRANT SELECT ON [exams].[Question] TO [studentRole];
GRANT SELECT ON [exams].[QuestionOption] TO [studentRole];
GRANT SELECT ON [exams].[ExamQuestion] TO [studentRole];
GRANT SELECT ON [exams].[Exam] TO [studentRole];

-- Ê·Ê „‘ ⁄«„· Role° «œÌÂ„ ··ÌÊ“— œÂ ﬂ⁄Ì‰… ·· Ã—»…:
GRANT SELECT ON SCHEMA::[exams] TO [student_5user];

-- 1. ≈⁄ÿ«¡ ’·«ÕÌ… «· ‰›Ì– ··ÿ·«» ⁄·Ï «·»—Ê”ÌœÃ—
GRANT EXECUTE ON SCHEMA::[StudentStp] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
-- √Ê ··—Ê· ·Ê ⁄«„· Ê«Õœ…
-- GRANT EXECUTE ON SCHEMA::[StudentStp] TO [studentRole];

-- 2. ≈⁄ÿ«¡ ’·«ÕÌ… «·ﬁ—«¡… ··Ãœ«Ê· «··Ì «·»—Ê”ÌœÃ— »ÌÕ «ÃÂ« ⁄‘«‰ Ì⁄„· Validation
GRANT SELECT ON [userAcc].[UserAccount] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT SELECT ON [userAcc].[Student] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT SELECT ON [exams].[Exam] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT SELECT ON [exams].[Question] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT SELECT ON [exams].[ExamQuestion] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT SELECT ON [exams].[QuestionOption] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];

-- 3. ’·«ÕÌ… «·‹ INSERT/UPDATE ⁄·Ï ÃœÊ· «·≈Ã«»«  (·√‰ «·»—Ê”ÌœÃ— »Ì⁄„· ﬂœ…)
GRANT SELECT, INSERT, UPDATE ON [exams].[Student_Answer] TO [student_1user], [student_2user], [student_3user], [student_4user], [student_5user];
GRANT EXECUTE ON SCHEMA::[InstructorStp] TO [instructor_1user];
GRANT EXECUTE ON SCHEMA::[InstructorStp] TO [dbo];