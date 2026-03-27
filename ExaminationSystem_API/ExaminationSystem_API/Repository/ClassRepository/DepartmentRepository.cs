
namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class DepartmentRepository : GenericRepository<Department>, IDepartmentRepository
    {
        private readonly ExaminationContext _context;
        public DepartmentRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddDepartmentWithStoredAsync(AddDepartmentDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddDepartment @Deptname={dto.DeptName},@BranchId ={dto.BranchId} ");
        public async Task UpdateDepartmentWithStoredAsync(UpdateDepartmentDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateDepartment @DeptId ={dto.DeptId},@DeptName={dto.DeptName},@BranchId ={dto.BranchId}");
        public async Task DeleteDepartmentWithStoredAsync(byte DeptId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteDepartment @DeptId={DeptId}");

    }
}
