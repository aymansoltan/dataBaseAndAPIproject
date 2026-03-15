namespace Examination_System_MVC.Repository.UnitWork
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ExaminationContext _context;
        public IBranchRepository Branches { get; private set; }
        public UnitOfWork(ExaminationContext context)
        {
            _context = context;
            Branches = new BranchRepository(_context);
        }
        public async Task<int> CompleteAsync() =>  await _context.SaveChangesAsync();

    }
}
