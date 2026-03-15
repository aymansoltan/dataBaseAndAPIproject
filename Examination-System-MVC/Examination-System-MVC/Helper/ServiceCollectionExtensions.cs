using Examination_System_MVC.Repository.UnitWork;

namespace Examination_System_MVC.Helper
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {
            services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
            services.AddScoped<IBranchRepository, BranchRepository>();
      
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            return services;
        }
        public static IServiceCollection AddServices(this IServiceCollection services)
        {
            //services.AddScoped<IInstructorService, InstructorService>();
          


            return services;
        }
        public static IServiceCollection AddMapping(this IServiceCollection services)
        {
            //services.AddAutoMapper(typeof(CourseProfile).Assembly);
            return services;
        }
    }
}
