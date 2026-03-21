namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class BranchRepository : GenericRepository<Branch>, IBranchRepository
    {
        private readonly ExaminationContext _context;
        public BranchRepository(ExaminationContext context) : base(context) { _context = context; }
        public async Task AddBranchWithStoredAsync(string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddBranch @BranchName ={name}");
        public async Task UpdateBranchWithStoredAsync(byte id, string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateBranch @BranchId ={id}  ,@BranchName ={name}");
        public async Task DeleteBranchWithStoredAsync(byte id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteBranch @BranchId={id}");
        public async Task ActivateBranchWithStoredAsync(byte id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_ActivateBranch @BranchId={id}");
        public async Task<IEnumerable<VBranchsummary>> GetAllBranchSummaryWithStoredAsync() => await _context.VBranchsummaries.ToListAsync();

    }
}
