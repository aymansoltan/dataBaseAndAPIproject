using ExaminationSystem_API.Dto.TrackDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface ITrackService
    {
        Task AddTrackAsync(AddTrackDTO trackDTO);
        Task UpdateTrackAsync(UpdateTrackDTO trackDTO);
    }
}
