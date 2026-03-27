namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface ITrackRepository : IGenericRepository<Track>
    {
        Task AddTrackWithStoredAsync(AddTrackDTO dto);
        Task UpdateTrackWithStoredAsync(UpdateTrackDTO dto);
        Task DeleteTrackWithStoredAsync(short trackId);
    }
}
