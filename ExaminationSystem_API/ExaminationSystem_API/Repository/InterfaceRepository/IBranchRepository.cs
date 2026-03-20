using Microsoft.EntityFrameworkCore;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IBranchRepository : IGenericRepository<Branch>
    {
        Task AddBranchWithStoredAsync(string name);
        Task UpdateBranchWithStoredAsync(int id, string name);
        Task DeleteBranchWithStoredAsync(int id);
        Task ActivateBranchWithStoredAsync(int id);
        Task<IEnumerable<VBranchsummary>> GetAllBranchSummaryWithStoredAsync();
    }
}
