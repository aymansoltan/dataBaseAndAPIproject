using ExaminationSystem_API.Dto.DepartmentDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class DepartmentService :IDepartmentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public DepartmentService(IUnitOfWork unitOfWork , IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        
        public async Task AddDepartmentAsync(AddDepartmentDTO departmentDTO)
        {

            await _unitOfWork.Departments.AddDepartmentWithStoredAsync(departmentDTO.DeptName, departmentDTO.BranchId);
        }
        public async Task UpdateDepartmentAsync(UpdateDepartmentDTO departmentDTO)
        {
            var existingDept = await _unitOfWork.Departments.GetByIdAsync(departmentDTO.DeptId);
            if (existingDept == null)
                throw new KeyNotFoundException("Department not found");
            var DeptMapper = _mapper.Map<Department>(departmentDTO);
            await _unitOfWork.Departments.UpdateDepartmentWithStoredAsync(DeptMapper.DeptId , DeptMapper.DeptName , (int)DeptMapper.BranchId);
        }

    }
}
