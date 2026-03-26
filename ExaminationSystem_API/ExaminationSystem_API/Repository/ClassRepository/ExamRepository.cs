using ExaminationSystem_API.Dto.ExamDto;

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

    }
}
