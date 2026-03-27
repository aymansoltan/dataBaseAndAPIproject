using ExaminationSystem_API.Dto.ExamDto;
using ExaminationSystem_API.Dto.GradingDTO;
using ExaminationSystem_API.Dto.QuestionDTO;
using ExaminationSystem_API.Dto.StudentAnswerDTO;

namespace ExaminationSystem_API.Service.ClassService
{
    public class ExamService : IExamService
    {
        private readonly IUnitOfWork _unitOfWork;
        public ExamService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task AddManaulExamAsync(ManualExamDTO examDTO, int instructorId)
        {
            await _unitOfWork.Exams.AddExamWithStoredAsync(examDTO, instructorId);
        }
        public async Task AddRandomExamAsync(RandomExamDTO examDTO, int instructorId)
        {
            await _unitOfWork.Exams.AddExamWithStoredAsync(examDTO, instructorId);
        }
        public async Task DeleteExamAsync(short ExamId, int instructorId)
        {
            await _unitOfWork.Exams.DeleteExamWithStoredAsync(ExamId, instructorId);
        }
        public async Task GradingAsync(InstructorGradingDTO dto, int instructorId)
        {
            await _unitOfWork.Exams.GradeTextQuestionsAsync(instructorId, dto);
        }

    }
}
