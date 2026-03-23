using ExaminationSystem_API.Dto.CourseDTO;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface ICourseRepository : IGenericRepository<Course>
    {
        Task AddCourseWithStoredAsync(AddCourseDTO dTO);
        Task UpdateCourseWithStoredAsync(UpdateCourseDTO dTO);
        Task DeleteCourseWithStoredAsync(short id);
    }
}
