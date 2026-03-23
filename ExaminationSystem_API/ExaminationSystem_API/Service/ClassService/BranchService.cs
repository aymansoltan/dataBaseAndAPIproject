
namespace ExaminationSystem_API.Service.ClassService
{
    public class BranchService : IBranchService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public BranchService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task AddBranchAsync(AddBranchDTO branchdto)
        {
            await _unitOfWork.Branches.AddBranchWithStoredAsync(branchdto.BranchName);
        }

        public async Task UpdateBranchAsync(byte id, UpdateBranchDTO updateBranch)
        {
            await _unitOfWork.Branches.UpdateBranchWithStoredAsync(id, updateBranch.BranchName);
        }
        public async Task DeleteBranchAsync(byte id)
        {
            await _unitOfWork.Branches.DeleteBranchWithStoredAsync(id);
        }
        public async Task ActivateBranchAsync(byte id)
        {
            await _unitOfWork.Branches.ActivateBranchWithStoredAsync(id);
        }
        public async Task<PaginatedList<BranchSummaryDTO>> GetAllBranchSummryAsync(string? searchTerm, int pageNumber, int pageSize)
        {
            var summary = await _unitOfWork.Branches.GetAllBranchSummaryWithStoredAsync();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim().ToLower();
                summary = summary.Where(b => b.BranchName != null && b.BranchName.ToLower().Contains(searchTerm));
            }
            var paginatedList = PaginatedList<VBranchsummary>.Create(summary, pageNumber, pageSize);

            var mapper = _mapper.Map<List<BranchSummaryDTO>>(paginatedList.Items);

            var result = new PaginatedList<BranchSummaryDTO>(mapper, paginatedList.TotalCount, pageNumber, pageSize);

            return result;
        }

        public async Task<IEnumerable<BranchLookupDTO>> GetBranchesLookupAsync()
        {
            return await _unitOfWork.Branches
                .GetAllQueryable().Where(b => b.IsActive == true && b.IsDeleted == false) 
                .Select(b => new BranchLookupDTO
                {
                    BranchId = b.BranchId,
                    BranchName = b.BranchName
                })
                .ToListAsync();
        }


    }
}
