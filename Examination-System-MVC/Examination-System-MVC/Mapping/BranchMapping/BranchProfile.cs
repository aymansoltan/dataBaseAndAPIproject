global using AutoMapper;
global using Examination_System_MVC.ViewModel.BranchVM;

namespace Examination_System_MVC.Mapping.BranchMapping
{
    public class BranchProfile : Profile
    {
        public BranchProfile()
        {
            CreateMap<AddBranchVM, Branch>();
        }
    }
}
