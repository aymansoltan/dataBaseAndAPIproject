namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IIntakeRepository : IGenericRepository<Intake>
    {
        Task AddIntakeWithStoredAsync(AddIntakeDTO dto);
        Task UpdateIntakeWithStoredAsync(UpdateIntakeDTO dto);
        Task DeleteIntakeWithStoredAsync(byte intakeId);
    }
}
