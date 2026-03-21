using ExaminationSystem_API.Dto.BranchDTO;
using ExaminationSystem_API.Dto.DepartmentDTO;
using ExaminationSystem_API.Helper;
using System.ComponentModel;
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
            var DeptMapper = _mapper.Map<Department>(departmentDTO);
            await _unitOfWork.Departments.AddDepartmentWithStoredAsync(DeptMapper.DeptName,(int)(DeptMapper.BranchId ??0));
        }
        public async Task UpdateDepartmentAsync(UpdateDepartmentDTO departmentDTO)
        {
            var DeptMapper = _mapper.Map<Department>(departmentDTO);
            await _unitOfWork.Departments.UpdateDepartmentWithStoredAsync(DeptMapper.DeptId , DeptMapper.DeptName , (int)(DeptMapper.BranchId ?? 0));
        }

        public async Task DeleteDepartmentAsync(int id)
        {
            await _unitOfWork.Departments.DeleteDepartmentWithStoredAsync(id); 
        }

        public async Task<DepartmentReadByIDDTO> GetDepartmentByID(int id)
        {
            var department = await _unitOfWork.Departments.GetAllQueryable()
                .Include(d => d.Branch)
                .FirstOrDefaultAsync(d => d.DeptId == id && d.IsDeleted == false);
            if (department == null)
                return null;
            var deptMapper = _mapper.Map<DepartmentReadByIDDTO>(department);

            return deptMapper;
        }

        public async Task<PaginatedList<DepartmentReadAll>> GetAllDepartment(string? searchTerm , int pageNumber , int pageSize)
        {
            IQueryable<Department> query = _unitOfWork.Departments.GetAllQueryable()
                .AsNoTracking()
                .Where(d => d.IsDeleted==false)
                .Include(d => d.Branch);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim().ToLower();
                query = query.Where(d => d.DeptName.ToLower().Contains(searchTerm));
            }
            var paginatedList =await PaginatedList<Department>.CreateAsync(query, pageNumber, pageSize);

            var mapper = _mapper.Map<List<DepartmentReadAll>>(paginatedList.Items);

            var result = new PaginatedList<DepartmentReadAll>(mapper, paginatedList.TotalCount, pageNumber, pageSize);
            return result;
        }
        public async Task<IEnumerable<DepartmentLookupDTO>> GetDepartmentLookupAsync()
        {
            return await _unitOfWork.Departments
                .GetAllQueryable().Where(d => d.IsActive == true && d.IsDeleted == false)
                .Select(d => new DepartmentLookupDTO
                {
                    DepartmentId = d.DeptId,
                    DepartmentName = d.DeptName
                })
                .ToListAsync();
        }

    }
}
