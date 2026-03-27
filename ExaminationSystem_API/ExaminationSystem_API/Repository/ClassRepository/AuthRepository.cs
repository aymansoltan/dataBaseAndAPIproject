using ExaminationSystem_API.QueryResults;

namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class AuthRepository : GenericRepository<UserAccount>, IAuthRepository
    {
        private readonly ExaminationContext _context;
        public AuthRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddUserWithStoredAsync(RegisterBaseDTO dto)
        {
            string typeTarget = dto.TargetType.ToString();
            object? branchId = null, trackId = null, salary = null, hireDate = null, spec = null, deptId = null;
            if (dto is RegisterStudentDTO studentDTO)
            {
                branchId = studentDTO.BranchId;
                trackId = studentDTO.TrackId;
            }
            if (dto is RegisterInstructorDTO instructorDTO)
            {
                salary = instructorDTO.Salary;
                hireDate = instructorDTO.HireDate;
                spec = instructorDTO.Specialization;
                deptId = instructorDTO.DeptId;
            }

            await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].[stp_RegisterMemberByType] @UserName = {dto.UserName}, @Email = {dto.Email}, @Password = {dto.Password}, @TargetType = {typeTarget}, @FirstName = {dto.FirstName}, @LastName = {dto.LastName} , @Gender = {dto.Gender},@BirthDate = {dto.BirthDate} , @Address = {dto.Address},@Phone = {dto.Phone}, @NationalID = {dto.NationalId}, @BranchId = {branchId} , @TrackId = {trackId}, @Salary = {salary}, @HireDate = {hireDate}, @Specialization = {spec} , @DeptId = {deptId}");

        }

        public async Task UpdateUserWithStoredAsync(BaseUpdateMemberDTO dto)
        {
            object? branchId = null, trackId = null, intakeId = null, salary = null, spec = null, deptId = null, hireDate = null;

            if (dto is UpdateStudentDTO std)
            {
                branchId = std.BranchId;
                trackId = std.TrackId;
                intakeId = std.IntakeId;
            }
            else if (dto is UpdateInstructorDTO ins)
            {
                salary = ins.Salary;
                spec = ins.Specialization;
                deptId = ins.DeptId;
                hireDate = ins.HireDate.HasValue ? ins.HireDate.Value.ToDateTime(TimeOnly.MinValue) : null;
            }

            await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].[stp_UpdateMemberFull] @UserId = {dto.UserId}, @UserName = {dto.UserName}, @Email = {dto.Email}, @Password = {dto.Password}, @FirstName = {dto.FirstName}, @LastName = {dto.LastName}, @Gender = {dto.Gender}, @Address = {dto.Address}, @Phone = {dto.Phone}, @NationalID = {dto.NationalId}, @BranchId = {branchId}, @IntakeId = {intakeId}, @TrackId = {trackId}, @Salary = {salary}, @HireDate = {hireDate}, @Specialization = {spec}, @DeptId = {deptId}");
        }
        public async Task DeleteUserWithStoredAsync(int UserId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteUserAccount @UserId = {UserId}");
        public async Task<UserLoginResult?> GetUserByEmailAsync(string email)
        {
            var UserEmail = await _context.Set<UserLoginResult>().FromSqlInterpolated($"EXEC [TrainingMangerStp].stp_GetUserByEmail @Email = {email}").ToListAsync();
            var result = UserEmail.FirstOrDefault();
            return result;

        }

    }
}
