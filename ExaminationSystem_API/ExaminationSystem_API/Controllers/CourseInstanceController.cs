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
        [HttpPost("Add-Instace")]
        public async Task<IActionResult> AddInstaceAsync(AddCourseInstaceDTO instaceDTO)
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
    }
}
