using ExaminationSystem_API.Dto.DepartmentDTO;
using ExaminationSystem_API.Dto.TrackDTO;
using ExaminationSystem_API.Helper;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace ExaminationSystem_API.Service.ClassService
{
    public class TrackService :ITrackService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public TrackService(IUnitOfWork unitOfWork , IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task AddTrackAsync(AddTrackDTO trackDTO) 
            => await _unitOfWork.Tracks.AddTrackWithStoredAsync(trackDTO.TrackName, trackDTO.DeptId);
        public async Task UpdateTrackAsync(UpdateTrackDTO trackDTO) 
            => await _unitOfWork.Tracks.UpdateTrackWithStoredAsync(trackDTO.TrackId,trackDTO.TrackName, trackDTO.DeptId);
        public async Task DeleteTrackAsync(short id) 
            => await _unitOfWork.Tracks.DeleteTrackWithStoredAsync(id);
        public async Task<PaginatedList<TrackReadAllDTO>> GetAllTrackAsync(string? searchTerm  , int pageNumber , int pageSize)
        {
            IQueryable<Track> query = _unitOfWork.Tracks.GetAllQueryable()
                .AsNoTracking()
                .Where(t => t.IsDeleted==false)
                .Include(t => t.Deprtment)
                    .ThenInclude(d => d.Branch);
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim().ToLower();
                query = query.Where(t => t.TrackName.ToLower().Contains(searchTerm));
            }
            return await query.ToPaginatedListAsync<Track, TrackReadAllDTO>(_mapper, pageNumber, pageSize);
        }
    }
}
