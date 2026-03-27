using ExaminationSystem_API.Dto.CourseInstanceDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class CourseInstanceService : ICourseInstanceService
    {
        private readonly IUnitOfWork _unitOfWork;
        public CourseInstanceService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task AddCourseInstanceAsync(AddCourseInstaceDTO instaceDTO) =>
            await _unitOfWork.CoursesInstances.AddCourseInstaceWithStoredAsync(instaceDTO);
        public async Task UpdateCourseInstanceAsync(UpdateCourseInstanceDTO instaceDTO) =>
            await _unitOfWork.CoursesInstances.UpdateCourseInstanceWithStoredAsync(instaceDTO);
        public async Task DeleteCourseInstanceAsync(int id)=>
            await _unitOfWork.CoursesInstances.DeleteCourseInstaceWithStoredAsync(id);
    }
}
