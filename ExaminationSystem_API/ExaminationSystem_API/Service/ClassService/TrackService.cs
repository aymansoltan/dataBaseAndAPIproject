using ExaminationSystem_API.Dto.TrackDTO;
using System.Threading.Tasks;

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

    }
}
