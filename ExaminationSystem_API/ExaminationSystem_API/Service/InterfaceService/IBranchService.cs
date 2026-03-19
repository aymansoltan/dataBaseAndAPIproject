namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IBranchService
    {
        Task AddBranchAsync(AddBranchDTO branchdto);
    }
}
