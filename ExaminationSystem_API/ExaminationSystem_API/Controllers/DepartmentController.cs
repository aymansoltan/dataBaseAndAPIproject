using ExaminationSystem_API.Dto.DepartmentDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DepartmentController : ControllerBase
    {
        private readonly IDepartmentService _departmentService;
        private readonly IBranchService _branchService;
        public DepartmentController(IDepartmentService departmentService , IBranchService branchService)
        {
            _departmentService = departmentService;
            _branchService = branchService;
        }
        [HttpGet("branches-lookup")]
        public async Task<IActionResult> GetBranches()
        {
           var Branches = await _branchService.GetBranchesLookupAsync();
            return Ok(Branches);
        }

        [HttpPost("Add-Department")]
        public async Task<IActionResult> AddDepartment(AddDepartmentDTO addDepartment)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _departmentService.AddDepartmentAsync(addDepartment);
                return Ok(new { success = true, message = "Department added successfully using SP" });
            }catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
        [HttpPut("Update-Department/{id}")]
        public async Task<IActionResult> UpdateDepartment(int id ,[FromBody] UpdateDepartmentDTO Department)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(id!=Department.DeptId)
                return BadRequest(new { message = "ID mismatch between URL and Body." });
            try
            {
                await _departmentService.UpdateDepartmentAsync(Department);
                return Ok(new { success = true, message = "Department Updated successfully using SP" });
            }catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

    }
}
