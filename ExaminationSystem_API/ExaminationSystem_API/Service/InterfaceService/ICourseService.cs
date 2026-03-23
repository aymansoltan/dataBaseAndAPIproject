using ExaminationSystem_API.Dto.CourseDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface ICourseService
    {
        Task AddCourseAsync(AddCourseDTO courseDTO);
        Task UpdateCourseAsync(UpdateCourseDTO courseDTO);
        Task DeleteCourseAsync(short id);
    }
}
