using ExaminationSystem_API.Dto.TrackDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TrackController : ControllerBase
    {
        private readonly ITrackService _trackService;
        private readonly IDepartmentService _departmentService;
        public TrackController(ITrackService trackService , IDepartmentService departmentService)
        {
            _trackService = trackService;
            _departmentService=departmentService;
        }
        [HttpGet("Department-lookup")]
        public async Task<IActionResult> GetDepartment()
        {
            var Departments = await _departmentService.GetDepartmentLookupAsync();
            return Ok(Departments);
        }
        [HttpPost("Add-Track")]
        public async Task<IActionResult> AddTrackAsync([FromBody]AddTrackDTO trackDTO)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _trackService.AddTrackAsync(trackDTO);
                return Ok(new { success = true, message = "Track added and linked to intake successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
