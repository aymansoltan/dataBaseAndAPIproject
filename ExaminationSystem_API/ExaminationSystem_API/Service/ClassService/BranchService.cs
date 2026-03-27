
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
        public async Task AddBranchAsync(AddBranchDTO dto) => await _unitOfWork.Branches.AddBranchWithStoredAsync(dto);
        public async Task UpdateBranchAsync(UpdateBranchDTO dto) =>  await _unitOfWork.Branches.UpdateBranchWithStoredAsync(dto);
        public async Task DeleteBranchAsync(byte id) => await _unitOfWork.Branches.DeleteBranchWithStoredAsync(id);
        public async Task ActivateBranchAsync(byte id) => await _unitOfWork.Branches.ActivateBranchWithStoredAsync(id);

        public async Task<PaginatedList<BranchSummaryDTO>> GetAllBranchSummryAsync(string? searchTerm, int pageNumber, int pageSize)
        {
            var query = _unitOfWork.Branches.GetAllBranchSummaryWithStoredAsync();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim().ToLower();
                query = query.Where(b => b.BranchName != null && b.BranchName.ToLower().Contains(searchTerm));
            }
            return await query.ToPaginatedListAsync<VBranchsummary, BranchSummaryDTO>(_mapper, pageNumber, pageSize);
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
