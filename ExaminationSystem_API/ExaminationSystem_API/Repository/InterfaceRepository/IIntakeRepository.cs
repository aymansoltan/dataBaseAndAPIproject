namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IIntakeRepository : IGenericRepository<Intake>
    {
        Task AddIntakeWithStoredAsync(string name);
        Task UpdateIntakeWithStoredAsync(byte intakeId, string name);
        Task DeleteIntakeWithStoredAsync(byte intakeId);
    }
}
