using ExaminationSystem_API.Dto.QuestionDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class QuestionService : IQuestionService
    {
        private readonly IUnitOfWork _unitOfWork;
        public QuestionService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task AddTfQuestionAsync(TfQuestionDTO question, int instructorId) =>
            await _unitOfWork.Questions.AddQuestionWithStoredAsync(question, instructorId);
        public async Task AddMCQQuestionAsync(McqQuestionDTO question, int instructorId) => 
            await _unitOfWork.Questions.AddQuestionWithStoredAsync(question, instructorId);
        public async Task AddTextQuestionAsync(TextQuestionDTO question, int instructorId) =>
            await _unitOfWork.Questions.AddQuestionWithStoredAsync(question, instructorId);
        public async Task DeleteQuestionAsync(int questionId, int instructorId) =>
            await _unitOfWork.Questions.DeleteQuestionWithStoredAsync(questionId, instructorId);
    }
}
