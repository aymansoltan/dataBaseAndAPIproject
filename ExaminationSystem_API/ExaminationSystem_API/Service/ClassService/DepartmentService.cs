

namespace ExaminationSystem_API.Service.ClassService
{
    public class DepartmentService : IDepartmentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public DepartmentService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task AddDepartmentAsync(AddDepartmentDTO dto) => await _unitOfWork.Departments.AddDepartmentWithStoredAsync(dto);

        public async Task UpdateDepartmentAsync(UpdateDepartmentDTO dto) => await _unitOfWork.Departments.UpdateDepartmentWithStoredAsync(dto);
        
        public async Task DeleteDepartmentAsync(byte id) => await _unitOfWork.Departments.DeleteDepartmentWithStoredAsync(id);

        public async Task<DepartmentReadByIDDTO> GetDepartmentByID(byte id)
        {
            var department = await _unitOfWork.Departments.GetAllQueryable()
                .Include(d => d.Branch)
                .FirstOrDefaultAsync(d => d.DeptId == id && d.IsDeleted == false);
            if (department == null)
                return null;
            var deptMapper = _mapper.Map<DepartmentReadByIDDTO>(department);

            return deptMapper;
        }

        public async Task<PaginatedList<DepartmentReadAll>> GetAllDepartment(string? searchTerm, int pageNumber, int pageSize)
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
            return await query.ToPaginatedListAsync<Department, DepartmentReadAll>(_mapper, pageNumber, pageSize);

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
