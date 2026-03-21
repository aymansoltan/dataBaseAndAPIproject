namespace ExaminationSystem_API.Repository.UnitWork
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ExaminationContext _context;
        public IBranchRepository Branches { get; private set; }
        public IDepartmentRepository Departments { get; private set; }
        public ITrackRepository Tracks { get; private set; }


        public UnitOfWork(ExaminationContext context)
        {
            _context = context;
            Branches = new BranchRepository(_context);
            Departments = new DepartmentRepository(_context);
            Tracks = new TrackRepository(_context);
        }
        public async Task<int> CompleteAsync() => await _context.SaveChangesAsync();

    }
}
