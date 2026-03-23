
namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class DepartmentRepository : GenericRepository<Department>, IDepartmentRepository
    {
        private readonly ExaminationContext _context;
        public DepartmentRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddDepartmentWithStoredAsync(string name, byte BranchID) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddDepartment @Deptname={name},@BranchId ={BranchID} ");
        public async Task UpdateDepartmentWithStoredAsync(byte DeptId , string name, byte BranchID) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateDepartment @DeptId ={DeptId},@DeptName={name},@BranchId ={BranchID}");
        public async Task DeleteDepartmentWithStoredAsync(byte DeptId )  => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteDepartment @DeptId={DeptId}");

    }
}
