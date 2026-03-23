
namespace ExaminationSystem_API.Helper
{
    public static class ControllerExtensions
    {
        public static IActionResult BadRequestResponse(this ControllerBase controller, string message)
        {
            return controller.BadRequest(new { success = false, message = message });
        }
        public static IActionResult NotFoundResponse(this ControllerBase controller, string message)
        {
            return controller.NotFound(new { success = false, message = message });
        }
        public static IActionResult SuccessResponse(this ControllerBase controller, string message, object? data = null)
        {
            return controller.Ok(new
            {
                success = true,
                message = message,
                data = data 
            });
        }
        public static IActionResult HandleException(this ControllerBase controller, Exception ex)
        {
            var currentEx = ex;
            while (currentEx.InnerException != null)
            {
                currentEx = currentEx.InnerException;
            }

            if (ex is Microsoft.Data.SqlClient.SqlException || ex is Microsoft.EntityFrameworkCore.DbUpdateException)
            {
                return controller.BadRequest(new
                {
                    success = false,
                    message = currentEx.Message 
                });
            }
            return controller.StatusCode(500, new
            {
                success = false,
                message = "An unexpected error occurred on the server.",
                error = currentEx.Message 
            });
        }
    }
}
