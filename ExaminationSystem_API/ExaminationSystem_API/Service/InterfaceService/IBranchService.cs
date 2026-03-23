
namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IBranchService
    {
        Task<IEnumerable<BranchLookupDTO>> GetBranchesLookupAsync();
        Task AddBranchAsync(AddBranchDTO branchdto);
        Task UpdateBranchAsync(byte id, UpdateBranchDTO updateBranch);
        Task DeleteBranchAsync(byte id);
        Task ActivateBranchAsync(byte id);
        Task<PaginatedList<BranchSummaryDTO>> GetAllBranchSummryAsync(string? searchTerm, int pageNumber, int pageSize);
    }
}
