

global using ExaminationSystem_API.Repository.UnitWork;

namespace ExaminationSystem_API.Service.ClassService
{
    public class BranchService : IBranchService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public BranchService(IUnitOfWork unitOfWork , IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task AddBranchAsync(AddBranchDTO branchdto)
        {
            await _unitOfWork.Branches.AddBranchWithStoredAsync(branchdto.BranchName);
            await _unitOfWork.CompleteAsync();
        }
    }
}
