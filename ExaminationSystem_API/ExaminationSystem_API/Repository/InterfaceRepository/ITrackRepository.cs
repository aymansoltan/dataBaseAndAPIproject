namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface ITrackRepository :IGenericRepository<Track>
    {
        Task AddTrackWithStoredAsync(string name, int deptId);
        Task UpdateTrackWithStoredAsync(short trackId, string name, byte deptId);
    }
}
