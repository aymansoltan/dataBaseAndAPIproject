using ExaminationSystem_API.Dto.CourseInstanceDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourseInstanceController : ControllerBase
    {
        private readonly ICourseInstanceService _courseInstanceService;
        public CourseInstanceController(ICourseInstanceService courseInstanceService)
        {
            _courseInstanceService = courseInstanceService;
        }
        [HttpPost("Add-Instance")]
        public async Task<IActionResult> AddInstaceAsync([FromBody]AddCourseInstaceDTO instaceDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _courseInstanceService.AddCourseInstanceAsync(instaceDTO);
                return this.SuccessResponse("Course instance Added Successfully");
            }
            catch(Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpPut("Update-Instance/{id}")]
        public async Task<IActionResult> UpdateInstaceAsync([FromRoute] int id ,[FromBody]UpdateCourseInstanceDTO instaceDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            if (instaceDTO.CourseInstanceId != id)
                return this.BadRequestResponse("id Mistake");
            try
            {
                await _courseInstanceService.UpdateCourseInstanceAsync(instaceDTO);
                return this.SuccessResponse("Course instance updated Successfully");
            }
            catch(Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpDelete("delete-Instance/{id}")]
        public async Task<IActionResult> DeleteInstaceAsync([FromRoute] int id )
        {
            try
            {
                await _courseInstanceService.DeleteCourseInstanceAsync(id);
                return this.SuccessResponse("Course instance deleted Successfully");
            }
            catch(Exception ex)
            {
                return this.HandleException(ex);
            }
        }
    }
}
