namespace Examination_System_MVC.Repository.InterfaceRepository
{
    public interface IBranchRepository : IGenericRepository<Branch>
    {
        Task AddBranchWithStoredAsync(string name);
        Task UpdateBranchWithStoredAsync(int id, string name);
    }
}
