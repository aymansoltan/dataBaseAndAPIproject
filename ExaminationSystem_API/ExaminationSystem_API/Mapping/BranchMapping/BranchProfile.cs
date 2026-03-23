

namespace ExaminationSystem_API.Mapping.BranchMapping
{
    public class BranchProfile : Profile
    {
        public BranchProfile()
        {

            CreateMap<VBranchsummary, BranchSummaryDTO>();
        }
    }
}
