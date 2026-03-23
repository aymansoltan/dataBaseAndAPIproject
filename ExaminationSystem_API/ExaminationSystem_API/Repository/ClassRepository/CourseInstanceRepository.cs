using ExaminationSystem_API.Dto.CourseDTO;
using ExaminationSystem_API.Dto.CourseInstanceDTO;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class CourseInstanceRepository : GenericRepository<CourseInstance>, ICourseInstanceRepository
    {
        private readonly ExaminationContext _context;
        public CourseInstanceRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddCourseInstaceWithStoredAsync(AddCourseInstaceDTO dTO)
            => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_addCourseInstance @courseid = {dTO.CourseId} , @instructorid ={dTO.InstructorId} , @branchid = {dTO.BranchId} , @trackid = {dTO.TrackId} , @academicyear = {dTO.AcademicYear}");

    }
}
