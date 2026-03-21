using Microsoft.EntityFrameworkCore;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IBranchRepository : IGenericRepository<Branch>
    {
        Task AddBranchWithStoredAsync(string name);
        Task UpdateBranchWithStoredAsync(byte id, string name);
        Task DeleteBranchWithStoredAsync(byte id);
        Task ActivateBranchWithStoredAsync(byte id);
        Task<IEnumerable<VBranchsummary>> GetAllBranchSummaryWithStoredAsync();
    }
}
