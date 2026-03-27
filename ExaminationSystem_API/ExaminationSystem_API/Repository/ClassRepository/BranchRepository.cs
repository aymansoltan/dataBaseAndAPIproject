namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class BranchRepository : GenericRepository<Branch>, IBranchRepository
    {
        private readonly ExaminationContext _context;
        public BranchRepository(ExaminationContext context) : base(context) { _context = context; }
        public async Task AddBranchWithStoredAsync(AddBranchDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddBranch @BranchName ={dto.BranchName}");
        public async Task UpdateBranchWithStoredAsync(UpdateBranchDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateBranch @BranchId ={dto.BranchId}  ,@BranchName ={dto.BranchName}");
        public async Task DeleteBranchWithStoredAsync(byte id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteBranch @BranchId={id}");
        public async Task ActivateBranchWithStoredAsync(byte id) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_ActivateBranch @BranchId={id}");
        public IQueryable<VBranchsummary> GetAllBranchSummaryWithStoredAsync() => _context.VBranchsummaries.AsNoTracking();

    }
}
