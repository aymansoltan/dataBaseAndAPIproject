namespace ExaminationSystem_API.Helper
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddRepositories(this IServiceCollection services)
        {

            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
            services.AddScoped<IBranchRepository, BranchRepository>();
            services.AddScoped<IDepartmentRepository, DepartmentRepository>();
            services.AddScoped<ITrackRepository, TrackRepository>();
            services.AddScoped<IIntakeRepository, intakeRepository>();
            services.AddScoped<IAuthRepository,AuthRepository>();
            services.AddScoped<ICourseRepository,CourseRepository>();

            return services;
        }
        public static IServiceCollection AddServices(this IServiceCollection services)
        {
            services.AddScoped<IBranchService, BranchService>();
            services.AddScoped<IDepartmentService, DepartmentService>();
            services.AddScoped<ITrackService, TrackService>();
            services.AddScoped<IIntakeService, IntakeService>();
            services.AddScoped<ICourseService, CourseService>();
            return services;
        }
        public static IServiceCollection AddMapping(this IServiceCollection services)
        {
            services.AddAutoMapper(typeof(ServiceCollectionExtensions).Assembly);
            return services;
        }

    }
}
