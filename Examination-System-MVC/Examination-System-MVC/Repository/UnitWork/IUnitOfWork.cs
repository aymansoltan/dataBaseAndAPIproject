namespace Examination_System_MVC.Repository.UnitWork
{
    public interface IUnitOfWork
    {
        IBranchRepository Branches { get; }


        Task<int> CompleteAsync(); 
    }
}
