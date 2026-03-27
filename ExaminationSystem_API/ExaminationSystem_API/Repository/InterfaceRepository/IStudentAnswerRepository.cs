using ExaminationSystem_API.Dto.StudentAnswerDTO;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IStudentAnswerRepository : IGenericRepository<StudentAnswer>
    {
        Task SubmitStudentAnswersAsync(SubmitExamDTO dto, int studentId);
    }
}
