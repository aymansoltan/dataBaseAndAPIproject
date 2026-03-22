using ExaminationSystem_API.Dto.IntakeDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IIntakeService
    {
        Task AddIntakeAsync(AddIntakeDTO intakeDTO);
        Task UpdateIntakeAsync(UpdateIntakeDTO intakeDTO);
        Task DeleteIntakeAsync(byte id);

    }
}
