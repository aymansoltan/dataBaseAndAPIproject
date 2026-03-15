namespace Examination_System_MVC.Service.InterfaceService
{
    public interface IBranchService
    {
        Task AddBranchAsync(AddBranchVM branchVM);
    }
}
