using ExaminationSystem_API.Dto.IntakeDTO;
using ExaminationSystem_API.Helper;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IIntakeService
    {
        Task AddIntakeAsync(AddIntakeDTO intakeDTO);
        Task UpdateIntakeAsync(UpdateIntakeDTO intakeDTO);
        Task DeleteIntakeAsync(byte id);
        Task<PaginatedList<IntakeReadAllDTO>> GetAllIntackeAsync(string? searchTerm, int pageNumber, int pageSize);

    }
}
