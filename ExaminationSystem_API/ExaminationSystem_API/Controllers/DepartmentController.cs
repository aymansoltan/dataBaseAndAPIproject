using ExaminationSystem_API.Dto.DepartmentDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
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
        public async Task<IActionResult> AddDepartment([FromBody]AddDepartmentDTO addDepartment)
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
        public async Task<IActionResult> UpdateDepartment([FromRoute]int id ,[FromBody] UpdateDepartmentDTO Department)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(id!=Department.DeptId)
                return BadRequest(new { message = "ID mismatch between URL and Body." });
            try
            {
                await _departmentService.UpdateDepartmentAsync(Department);
                return Ok(new { success = true, message = "Department Updated successfully using SP" });
            }
            catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
       
        [HttpDelete("delete-Department/{id}")]
        public async Task<IActionResult> DeleteDepartment([FromRoute]int id)
        {
            try
            {
                await _departmentService.DeleteDepartmentAsync(id);
                return Ok(new { success = true, message = "Department Deleted successfully using SP" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("get-Department/{id}")]
        public async Task<IActionResult> GetDepartmentByID([FromRoute]int id)
        {
            try
            {
                var result =  await _departmentService.GetDepartmentByID(id);
                if (result == null)
                    return NotFound(new { message = $"Department with ID {id} not found." });

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "An unexpected error occurred on the server.",
                    error = ex.Message 
                });
            }
        }

        [HttpGet("All_Department")]
        public async Task<IActionResult> GetAllDepartment([FromQuery]string? searchTerm ,[FromQuery] int pageNumber =1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _departmentService.GetAllDepartment(searchTerm, pageNumber, pageSize);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "An unexpected error occurred on the server.",
                    error = ex.Message
                });
            }
        }
    }
}
