using ExaminationSystem_API.Dto.QuestionDTO;
using ExaminationSystem_API.Models;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class QuestionRepository : GenericRepository<Question>, IQuestionRepository
    {
        private readonly ExaminationContext _context;
        public QuestionRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddQuestionWithStoredAsync(BaseQuestionDTO dto, int InstructorId)
        {
            string questionType = "";
            object? correctAnswer = null;
            string bestAnswer = "";
            object? optionsList = null;
            if (dto is McqQuestionDTO mcq)
            {
                questionType = "mcq";
                correctAnswer = mcq.CorrectAnswer;
                bestAnswer = mcq.BestAnswer;
                optionsList = mcq.OptionsList;
            }
            else if (dto is TfQuestionDTO tf)
            {
                questionType = "t/f";
                correctAnswer = tf.CorrectAnswer;
                bestAnswer = tf.BestAnswer;
            }
            else if (dto is TextQuestionDTO text)
            {
                questionType = "text";
                bestAnswer = text.BestAnswer;
            }
            await _context.Database.ExecuteSqlInterpolatedAsync($@"
                EXEC [InstructorStp].stp_createquestion 
                    @questiontext = {dto.QuestionText}, 
                    @questiontype = {questionType}, 
                    @correctanswer = {correctAnswer ?? DBNull.Value}, 
                    @bestanswer = {bestAnswer}, 
                    @points = {dto.Points}, 
                    @courseid = {dto.CourseId}, 
                    @instructorid = {InstructorId}, 
                    @optionslist = {optionsList ?? DBNull.Value}");
        }
        public async Task DeleteQuestionWithStoredAsync(int questionID, int instructorId)
            => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [InstructorStp].stp_deletequestion @questionid = {questionID} , @instructorid = {instructorId}");

    }
}
