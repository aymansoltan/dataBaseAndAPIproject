using ExaminationSystem_API.Dto.BranchDTO;
using ExaminationSystem_API.Helper;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IBranchService
    {
        Task AddBranchAsync(AddBranchDTO branchdto);
        Task UpdateBranchAsync(int id, UpdateBranchDTO updateBranch);
        Task DeleteBranchAsync(int id);
        Task ActivateBranchAsync(int id);
        Task<PaginatedList<BranchSummaryDTO>> GetAllBranchSummryAsync(string? searchTerm ,int pageNumber, int pageSize);
    }
}
