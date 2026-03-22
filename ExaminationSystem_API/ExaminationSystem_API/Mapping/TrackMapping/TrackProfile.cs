using ExaminationSystem_API.Dto.TrackDTO;

namespace ExaminationSystem_API.Mapping.TrackMapping
{
    public class TrackProfile :Profile
    {
        public TrackProfile()
        {
            CreateMap<Track, TrackReadAllDTO>()
                .ForMember(dest => dest.DepartmentName, opt => opt.MapFrom(src => src.Deprtment.DeptName))
                .ForMember(dest => dest.BranchName, opt => opt.MapFrom(src => src.Deprtment.Branch.BranchName));
        }
    }
}
