namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IIntakeRepository :IGenericRepository<Intake>
    {
        Task AddIntakeWithStoredAsync(string name);
    }
}
