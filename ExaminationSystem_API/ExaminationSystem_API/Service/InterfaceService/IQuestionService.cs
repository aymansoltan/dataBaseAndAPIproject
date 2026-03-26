using ExaminationSystem_API.Dto.QuestionDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IQuestionService
    {
        Task AddTfQuestionAsync(TfQuestionDTO question, int instructorId);
        Task AddMCQQuestionAsync(McqQuestionDTO question, int instructorId);
        Task AddTextQuestionAsync(TextQuestionDTO question, int instructorId);
        Task DeleteQuestionAsync(int questionId, int instructorId);
     
    }
}
