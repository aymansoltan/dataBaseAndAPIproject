namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class TrackRepository : GenericRepository<Track>, ITrackRepository
    {
        private readonly ExaminationContext _context;
        public TrackRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddTrackWithStoredAsync(string name , byte deptId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddTrack @TrackName = {name} , @DeptId = {deptId} ");
        public async Task UpdateTrackWithStoredAsync(short trackId,string name , byte deptId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateTrack @TrackId = {trackId} , @TrackName = {name} , @DeptId = {deptId} ");
        public async Task DeleteTrackWithStoredAsync(short trackId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteTrack @trackid = {trackId} ");

    }
}
