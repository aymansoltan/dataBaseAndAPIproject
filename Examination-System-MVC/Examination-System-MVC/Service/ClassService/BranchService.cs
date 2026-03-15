

namespace Examination_System_MVC.Service.ClassService
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

        public async Task AddBranchAsync(AddBranchVM branchVM)
        {
            await _unitOfWork.Branches.AddBranchWithStoredAsync(branchVM.BranchName);
            await _unitOfWork.CompleteAsync();
        }
    }
}
