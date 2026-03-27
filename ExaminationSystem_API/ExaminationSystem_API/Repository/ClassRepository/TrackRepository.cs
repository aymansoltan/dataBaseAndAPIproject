namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class TrackRepository : GenericRepository<Track>, ITrackRepository
    {
        private readonly ExaminationContext _context;
        public TrackRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddTrackWithStoredAsync(AddTrackDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddTrack @TrackName = {dto.TrackName} , @DeptId = {dto.DeptId} ");
        public async Task UpdateTrackWithStoredAsync(UpdateTrackDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateTrack @TrackId = {dto.TrackId} , @TrackName = {dto.TrackName} , @DeptId = {dto.DeptId} ");
        public async Task DeleteTrackWithStoredAsync(short trackId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteTrack @trackid = {trackId} ");

    }
}
