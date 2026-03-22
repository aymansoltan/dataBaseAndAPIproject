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
        public TrackController(ITrackService trackService  )
        {
            _trackService = trackService;
        }
        [HttpGet("Track-lookup")]
        public async Task<IActionResult> GetTrack()
        {
            var tracks = await _trackService.GetTrackLookupAsync();
            return Ok(tracks);
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

        [HttpPut("Update-Track/{id}")]
        public async Task<IActionResult> UpdateTrackAsync([FromRoute]short id , [FromBody] UpdateTrackDTO trackDTO)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(trackDTO.TrackId != id)
                return BadRequest(new { message = "ID mismatch between URL and Body." });

            try
            {
                await _trackService.UpdateTrackAsync(trackDTO);
                return Ok(new { success = true, message = "Track updated  successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("Delete-Track/{id}")]
        public async Task<IActionResult> DeleteTrackAsync([FromRoute] short id)
        {
            try
            {
                await _trackService.DeleteTrackAsync(id);
                return Ok(new { success = true, message = "Track Deleted successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }

        }
        [HttpGet("All-Track")]
        public async Task<IActionResult> GetAllTrackAsync([FromQuery] string? searchTerm, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _trackService.GetAllTrackAsync(searchTerm, pageNumber, pageSize);
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
