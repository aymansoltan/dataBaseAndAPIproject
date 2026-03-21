using ExaminationSystem_API.Dto.TrackDTO;

namespace ExaminationSystem_API.Service.ClassService
{
    public interface ITrackService
    {
        Task AddTrackAsync(AddTrackDTO trackDTO);
    }
}
