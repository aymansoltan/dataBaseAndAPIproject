using ExaminationSystem_API.Dto.CourseDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class CourseService :ICourseService
    {
        private readonly IUnitOfWork _unitOfWork;
        public CourseService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task AddCourseAsync(AddCourseDTO courseDTO)
        {
            await _unitOfWork.Courses.AddCourseWithStoredAsync(courseDTO);
        }
        public async Task UpdateCourseAsync(UpdateCourseDTO courseDTO)
        {
            await _unitOfWork.Courses.UpdateCourseWithStoredAsync(courseDTO);
        }
        public async Task DeleteCourseAsync(short id)
        {
            await _unitOfWork.Courses.DeleteCourseWithStoredAsync(id);
        }
    }
}
