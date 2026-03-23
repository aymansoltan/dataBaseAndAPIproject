using ExaminationSystem_API.Dto.CourseDTO;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class CourseRepository : GenericRepository<Course>, ICourseRepository
    {
        private readonly ExaminationContext _context;
        public CourseRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddCourseWithStoredAsync(AddCourseDTO dTO) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddCourse @CourseName = {dTO.CourseName} , @MaxDegree = {dTO.MaxDegree} , @MinDegree = {dTO.MinDegree} , @Description = {dTO.Description}");
        public async Task UpdateCourseWithStoredAsync(UpdateCourseDTO dTO) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateCourse @CourseId = {dTO.CourseId} , @CourseName = {dTO.CourseName} , @MaxDegree = {dTO.MaxDegree} , @MinDegree = {dTO.MinDegree} , @Description = {dTO.Description}");

    }
}
