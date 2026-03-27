using ExaminationSystem_API.Dto.ExamDto;
using ExaminationSystem_API.Dto.GradingDTO;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class ExamRepository : GenericRepository<Exam>, IExamRepository
    {
        private readonly ExaminationContext _context;
        public ExamRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddExamWithStoredAsync(BaseExamDTO dto, int instructorId)
        {
            string mode = "";
            object? questionIds = null;
            object? questionCount = null;
            object? mcqCount = null;
            object? tfCount = null;
            object? textCount = null;

            if (dto is ManualExamDTO manual)
            {
                mode = "manual";
                questionIds = manual.QuestionIds;
            }
            else if (dto is RandomExamDTO random)
            {
                mode = "random";
                questionCount = random.QuestionCount;
                mcqCount = random.McqCount;
                tfCount = random.TfCount;
                textCount = random.TextCount;
            }

            await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC [InstructorStp].stp_createexam 
                    @InstructorId = {instructorId}, 
                    @examtitle = {dto.ExamTitle}, 
                    @examtype = {dto.ExamType}, 
                    @starttime = {dto.StartTime}, 
                    @endtime = {dto.EndTime}, 
                    @courseinstanceid = {dto.CourseInstanceId}, 
                    @branchid = {dto.BranchId}, 
                    @trackid = {dto.TrackId}, 
                    @mode = {mode}, 
                    @questionids = {questionIds ?? DBNull.Value}, 
                    @questioncount = {questionCount ?? DBNull.Value}, 
                    @mcqcount = {mcqCount ?? DBNull.Value}, 
                    @tfcount = {tfCount ?? DBNull.Value}, 
                    @textcount = {textCount ?? DBNull.Value}");
        }

        public async Task DeleteExamWithStoredAsync(short ExamId, int instructorId)
    => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [InstructorStp].stp_deleteexam @examid = {ExamId} , @InstructorId = {instructorId}");

        public async Task GradeTextQuestionsAsync(int instructorId, InstructorGradingDTO dto)
        {
            var table = new DataTable();
            table.Columns.Add("studentid", typeof(int));
            table.Columns.Add("questionid", typeof(short));
            table.Columns.Add("grade", typeof(byte));

            foreach (var item in dto.Grades)
            {
                table.Rows.Add(item.StudentId, item.QuestionId, item.Grade);
            }

            var examIdParam = new SqlParameter("@examid", dto.ExamId);
            var instructorIdParam = new SqlParameter("@instructorid", instructorId);
            var gradingTableParam = new SqlParameter("@gradingtable", table)
            {
                TypeName = "[InstructorStp].InstructorGradingTableType",
                SqlDbType = SqlDbType.Structured
            };

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC [InstructorStp].stp_InstructorGradeText @examid, @instructorid, @gradingtable",
                examIdParam, instructorIdParam, gradingTableParam);
        }
    }
}
