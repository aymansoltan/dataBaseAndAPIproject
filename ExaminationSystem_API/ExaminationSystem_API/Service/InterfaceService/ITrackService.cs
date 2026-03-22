using ExaminationSystem_API.Dto.TrackDTO;
using ExaminationSystem_API.Helper;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface ITrackService
    {
        Task AddTrackAsync(AddTrackDTO trackDTO);
        Task UpdateTrackAsync(UpdateTrackDTO trackDTO);
        Task DeleteTrackAsync(short id);
        Task<PaginatedList<TrackReadAllDTO>> GetAllTrackAsync(string? searchTerm, int pageNumber, int pageSize);
        Task<IEnumerable<TrackLookupDTO>> GetTrackLookupAsync();
    }
}
