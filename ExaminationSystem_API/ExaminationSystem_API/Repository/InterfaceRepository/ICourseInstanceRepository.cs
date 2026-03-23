using ExaminationSystem_API.Dto.CourseInstanceDTO;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface ICourseInstanceRepository : IGenericRepository<CourseInstance>
    {
        Task AddCourseInstaceWithStoredAsync(AddCourseInstaceDTO dTO);
    }
}
