using ExaminationSystem_API.Dto.CourseInstanceDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface ICourseInstanceService
    {
        Task AddCourseInstanceAsync(AddCourseInstaceDTO instaceDTO);
        Task UpdateCourseInstanceAsync(UpdateCourseInstanceDTO instaceDTO);
        Task DeleteCourseInstanceAsync(int id);
    }
}
