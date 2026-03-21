namespace ExaminationSystem_API.Repository.UnitWork
{
    public interface IUnitOfWork
    {
        IBranchRepository Branches { get; }
        IDepartmentRepository Departments {  get; }


        Task<int> CompleteAsync();
    }
}
