namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class InstructorRepository : GenericRepository<Instructor>, IInstructorRepository
    {
        public InstructorRepository(ExaminationContext context) : base(context)
        {
        }
    }
}
