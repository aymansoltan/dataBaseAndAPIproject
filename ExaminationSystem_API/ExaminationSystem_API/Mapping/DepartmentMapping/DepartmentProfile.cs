using ExaminationSystem_API.Dto.BranchDTO;
using ExaminationSystem_API.Dto.DepartmentDTO;

namespace ExaminationSystem_API.Mapping.DepartmentMapping
{
    public class DepartmentProfile :Profile
    {
        public DepartmentProfile()
        {
            CreateMap<AddDepartmentDTO, Department>();
            CreateMap<UpdateDepartmentDTO, Department>();
        }
    }
}
