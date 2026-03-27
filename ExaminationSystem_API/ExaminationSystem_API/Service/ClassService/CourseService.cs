using ExaminationSystem_API.Dto.CourseDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class CourseService : ICourseService
    {
        private readonly IUnitOfWork _unitOfWork;
        public CourseService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task AddCourseAsync(AddCourseDTO courseDTO) => 
            await _unitOfWork.Courses.AddCourseWithStoredAsync(courseDTO);
        public async Task UpdateCourseAsync(UpdateCourseDTO courseDTO) => 
            await _unitOfWork.Courses.UpdateCourseWithStoredAsync(courseDTO);
        public async Task DeleteCourseAsync(short id) => 
            await _unitOfWork.Courses.DeleteCourseWithStoredAsync(id);
        public async Task<IEnumerable<CourseLookupDTO>> GetCourseLookupAsync()
        {
            return await _unitOfWork.Courses
                .GetAllQueryable()
                .Where(c => c.IsActive == true && c.IsDeleted == false)
                .Select(c => new CourseLookupDTO
                {
                    courseId = c.CourseId,
                    courseName = c.CourseName,
                })
                .ToListAsync();
        }

    }
}
