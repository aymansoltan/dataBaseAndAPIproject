namespace ExaminationSystem_API.Repository.UnitWork
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ExaminationContext _context;
        public IBranchRepository Branches { get; private set; }
        public IDepartmentRepository Departments { get; private set; }
        public ITrackRepository Tracks { get; private set; }
        public IIntakeRepository Intakes { get; private set; }
        public IAuthRepository Auths { get; private set; }
        public ICourseRepository Courses { get; private set; }
        public ICourseInstanceRepository courseInstances { get; private set; }

        public UnitOfWork(ExaminationContext context)
        {
            _context = context;
            Branches = new BranchRepository(_context);
            Departments = new DepartmentRepository(_context);
            Tracks = new TrackRepository(_context);
            Intakes = new intakeRepository(_context);
            Auths = new AuthRepository(_context);
            Courses = new CourseRepository(_context);
            courseInstances = new CourseInstanceRepository(_context);
        }
        public async Task<int> CompleteAsync() => await _context.SaveChangesAsync();

    }
}
