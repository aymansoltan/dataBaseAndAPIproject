using ExaminationSystem_API.Dto.CourseDTO;


namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourseController : ControllerBase
    {
        private readonly ICourseService _courseService;
        public CourseController(ICourseService courseService)
        {
            _courseService = courseService;
        }
        [HttpPost("Add-Course")]
        public async Task<IActionResult> AddCourseAsync([FromBody]AddCourseDTO courseDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _courseService.AddCourseAsync(courseDTO);
                return this.SuccessResponse("course Added Successfully");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpPut("Update-Course/{id}")]
        public async Task<IActionResult> UpdateCourseAsync([FromRoute]short id,[FromBody]UpdateCourseDTO courseDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            if (courseDTO.CourseId != id)
                return this.BadRequestResponse("ID mismatch between URL and body.");
            try
            {
                await _courseService.UpdateCourseAsync(courseDTO);
                return this.SuccessResponse("course Updated Successfully");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpDelete("Delete-Course/{id}")]
        public async Task<IActionResult> DeleteCourseAsync([FromRoute]short id)
        {
            try
            {
                await _courseService.DeleteCourseAsync(id);
                return this.SuccessResponse("course Deleted Successfully");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
    }
}
