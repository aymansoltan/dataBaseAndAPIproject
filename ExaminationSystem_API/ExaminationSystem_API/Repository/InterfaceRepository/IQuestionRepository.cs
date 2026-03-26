using ExaminationSystem_API.Dto.QuestionDTO;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IQuestionRepository : IGenericRepository<Question>
    {
        Task AddQuestionWithStoredAsync(BaseQuestionDTO dto, int InstructorId);
        Task DeleteQuestionWithStoredAsync(int questionID, int instructorId);
    }
}
