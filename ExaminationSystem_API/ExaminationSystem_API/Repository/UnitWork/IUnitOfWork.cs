namespace ExaminationSystem_API.Repository.UnitWork
{
    public interface IUnitOfWork
    {
        IBranchRepository Branches { get; }
        IDepartmentRepository Departments {  get; }
        ITrackRepository Tracks { get; }
        IIntakeRepository Intakes { get; }
        IAuthRepository Auths { get; }
        ICourseRepository Courses { get; }
        ICourseInstanceRepository CoursesInstances { get; }
        IQuestionRepository Questions { get; }
        IExamRepository Exams { get; }
        IStudentAnswerRepository StudentAnswer { get; }
        Task<int> CompleteAsync();
    }
}
