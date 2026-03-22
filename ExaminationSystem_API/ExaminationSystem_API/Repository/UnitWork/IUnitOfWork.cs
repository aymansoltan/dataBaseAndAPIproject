namespace ExaminationSystem_API.Repository.UnitWork
{
    public interface IUnitOfWork
    {
        IBranchRepository Branches { get; }
        IDepartmentRepository Departments {  get; }
        ITrackRepository Tracks { get; }
        IIntakeRepository Intakes { get; }
        IAuthRepository Auths { get; }
        Task<int> CompleteAsync();
    }
}
