

namespace ExaminationSystem_API.Mapping.DepartmentMapping
{
    public class DepartmentProfile : Profile
    {
        public DepartmentProfile()
        {
            CreateMap<Department, DepartmentReadByIDDTO>()
               .ForMember(dest => dest.BranchName, opt => opt.MapFrom(src => src.Branch.BranchName));
            CreateMap<Department, DepartmentReadAll>()
               .ForMember(dest => dest.BranchName, opt => opt.MapFrom(src => src.Branch.BranchName));

        }
    }
}
