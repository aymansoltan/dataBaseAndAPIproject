using ExaminationSystem_API.Dto.ExamDto;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IExamRepository : IGenericRepository<Exam>
    {
        Task AddExamWithStoredAsync(BaseExamDTO dto, int instructorId);
        Task DeleteExamWithStoredAsync(short ExamId, int instructorId);
    }
}
