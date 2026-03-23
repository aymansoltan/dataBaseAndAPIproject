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
                return this.SuccessResponse("Track added and linked to intake successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }

        [HttpPut("Update-Track/{id}")]
        public async Task<IActionResult> UpdateTrackAsync([FromRoute]short id , [FromBody] UpdateTrackDTO trackDTO)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(trackDTO.TrackId != id)
                return this.BadRequestResponse("ID mismatch between URL and Body.");

            try
            {
                await _trackService.UpdateTrackAsync(trackDTO);
                return this.SuccessResponse("Track updated  successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }

        [HttpDelete("Delete-Track/{id}")]
        public async Task<IActionResult> DeleteTrackAsync([FromRoute] short id)
        {
            try
            {
                await _trackService.DeleteTrackAsync(id);
                return this.SuccessResponse("Track Deleted successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }

        }
        [HttpGet("All-Track")]
        public async Task<IActionResult> GetAllTrackAsync([FromQuery] string? searchTerm, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _trackService.GetAllTrackAsync(searchTerm, pageNumber, pageSize);
                return this.SuccessResponse(" all track get successfully", result);

            }
            catch (Exception ex)
            {
                return this.HandleException(ex);

            }
        }
    }
}
