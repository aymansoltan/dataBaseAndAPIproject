using ExaminationSystem_API.Dto.ExamDto;
using ExaminationSystem_API.Dto.GradingDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IExamService
    {
        Task AddManaulExamAsync(ManualExamDTO examDTO, int instructorId);
        Task AddRandomExamAsync(RandomExamDTO examDTO, int instructorId);
        Task DeleteExamAsync(short ExamId, int instructorId);
        Task GradingAsync(InstructorGradingDTO dto, int instructorId);
    }
}
