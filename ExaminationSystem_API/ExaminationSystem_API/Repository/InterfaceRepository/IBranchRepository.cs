
namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IBranchRepository : IGenericRepository<Branch>
    {
        Task AddBranchWithStoredAsync(AddBranchDTO dto);
        Task UpdateBranchWithStoredAsync(UpdateBranchDTO dto);
        Task DeleteBranchWithStoredAsync(byte id);
        Task ActivateBranchWithStoredAsync(byte id);
        IQueryable<VBranchsummary> GetAllBranchSummaryWithStoredAsync();
    }
}
