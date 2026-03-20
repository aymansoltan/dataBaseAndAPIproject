namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class BranchRepository : GenericRepository<Branch>, IBranchRepository
    {
        public BranchRepository(ExaminationContext context) : base(context){ }
        public async Task AddBranchWithStoredAsync(string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddBranch @BranchName ={name}");
        public async Task UpdateBranchWithStoredAsync(int id, string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateBranch @BranchId ={id}  ,@BranchName ={name}");
        public async Task DeleteBranchWithStoredAsync(int id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteBranch @BranchId={id}");
        public async Task ActivateBranchWithStoredAsync(int id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_ActivateBranch @BranchId={id}");
        public async Task<IEnumerable<VBranchsummary>> GetAllBranchSummaryWithStoredAsync() => await _context.VBranchsummaries.ToListAsync();
       
    }
}
