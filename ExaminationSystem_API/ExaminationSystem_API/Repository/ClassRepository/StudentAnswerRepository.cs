using ExaminationSystem_API.Dto.StudentAnswerDTO;
using ExaminationSystem_API.Models;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class StudentAnswerRepository : GenericRepository<StudentAnswer>, IStudentAnswerRepository
    {
        private readonly ExaminationContext _context;
        public StudentAnswerRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task SubmitStudentAnswersAsync(SubmitExamDTO dto, int studentId)
        {
            var table = new DataTable();
            table.Columns.Add("QuestionId", typeof(short));
            table.Columns.Add("StudentResponse", typeof(string));
            foreach (var ans in dto.Answers)
            {
                table.Rows.Add(ans.QuestionId, ans.StudentResponse);
            }
            var studentIdParam = new SqlParameter("@studentid", studentId);
            var examIdParam = new SqlParameter("@examid", dto.ExamId);
            var answersParam = new SqlParameter("@answers", table)
            {
                TypeName = "[StudentStp].StudentAnswersTableType",
                SqlDbType = SqlDbType.Structured
            };

            await _context.Database.ExecuteSqlRawAsync("EXEC [StudentStp].stp_StudentSubmitAnswer @examid , @studentid  , @answers", examIdParam, studentIdParam, answersParam);
        }
    }
}
