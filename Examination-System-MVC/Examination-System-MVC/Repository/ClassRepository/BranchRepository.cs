namespace Examination_System_MVC.Repository.ClassRepository
{
    public class BranchRepository : GenericRepository<Branch>, IBranchRepository
    {
        public BranchRepository(ExaminationContext context) : base(context){ }
        public async Task AddBranchWithStoredAsync(string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddBranch @BranchName ={name}");
        public async Task UpdateBranchWithStoredAsync(int id, string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateBranch @BranchId ={id}  ,@BranchName ={name}");

    }
}
