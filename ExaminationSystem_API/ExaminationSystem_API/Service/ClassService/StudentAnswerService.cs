using ExaminationSystem_API.Dto.StudentAnswerDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class StudentAnswerService : IStudentAnswerService
    {
        private readonly IUnitOfWork _unitOfWork;
        public StudentAnswerService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task StudentSubmitAnswerAsync(SubmitExamDTO dto, int studentId)
        {
            await _unitOfWork.StudentAnswer.SubmitStudentAnswersAsync(dto, studentId);
        }
    }
}
