global using AutoMapper;
global using ExaminationSystem_API.ViewModel.BranchVM;

namespace ExaminationSystem_API.Mapping.BranchMapping
{
    public class BranchProfile : Profile
    {
        public BranchProfile()
        {
            CreateMap<AddBranchDTO, Branch>();
        }
    }
}
