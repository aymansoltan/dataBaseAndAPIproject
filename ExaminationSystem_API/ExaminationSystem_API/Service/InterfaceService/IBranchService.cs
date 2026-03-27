
namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IBranchService
    {
        Task<IEnumerable<BranchLookupDTO>> GetBranchesLookupAsync();
        Task AddBranchAsync(AddBranchDTO dto);
        Task UpdateBranchAsync(UpdateBranchDTO dto);
        Task DeleteBranchAsync(byte id);
        Task ActivateBranchAsync(byte id);
        Task<PaginatedList<BranchSummaryDTO>> GetAllBranchSummryAsync(string? searchTerm, int pageNumber, int pageSize);
    }
}
