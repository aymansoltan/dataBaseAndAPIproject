

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DepartmentController : ControllerBase
    {
        private readonly IDepartmentService _departmentService;
        public DepartmentController(IDepartmentService departmentService )
        {
            _departmentService = departmentService;
        }
     

        [HttpGet("Department-lookup")]
        public async Task<IActionResult> GetDepartment()
        {
            var Departments = await _departmentService.GetDepartmentLookupAsync();
            return Ok(Departments);
        }
        [HttpPost("Add-Department")]
        public async Task<IActionResult> AddDepartment([FromBody]AddDepartmentDTO addDepartment)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _departmentService.AddDepartmentAsync(addDepartment);
                return this.SuccessResponse("Department added successfully using SP");
            }catch(Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        
        [HttpPut("Update-Department/{id}")]
        public async Task<IActionResult> UpdateDepartment([FromRoute]byte id ,[FromBody] UpdateDepartmentDTO Department)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(id!=Department.DeptId)
                return BadRequest(new { message = "ID mismatch between URL and Body." });
            try
            {
                await _departmentService.UpdateDepartmentAsync(Department);
                return  this.SuccessResponse("Department Updated successfully using SP");
            }
            catch(Exception ex)
            {
                return this.HandleException(ex);
            }
        }
       
        [HttpDelete("delete-Department/{id}")]
        public async Task<IActionResult> DeleteDepartment([FromRoute]byte id)
        {
            try
            {
                await _departmentService.DeleteDepartmentAsync(id);
                return this.SuccessResponse("Department Deleted successfully using SP");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }

        [HttpGet("get-Department/{id}")]
        public async Task<IActionResult> GetDepartmentByID([FromRoute]byte id)
        {
            try
            {
                var result =  await _departmentService.GetDepartmentByID(id);
                if (result == null)
                    return NotFound(new { message = $"Department with ID {id} not found." });

                return this.SuccessResponse("department get successfully" , result);
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);

            }
        }

        [HttpGet("All_Department")]
        public async Task<IActionResult> GetAllDepartment([FromQuery]string? searchTerm ,[FromQuery] int pageNumber =1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _departmentService.GetAllDepartment(searchTerm, pageNumber, pageSize);
                return this.SuccessResponse(" all department get successfully", result);
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);

            }
        }
    }
}
