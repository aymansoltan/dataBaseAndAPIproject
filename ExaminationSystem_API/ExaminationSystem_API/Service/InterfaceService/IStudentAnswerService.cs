using ExaminationSystem_API.Dto.StudentAnswerDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IStudentAnswerService
    {
        Task StudentSubmitAnswerAsync(SubmitExamDTO dto, int studentId);
    }
}
