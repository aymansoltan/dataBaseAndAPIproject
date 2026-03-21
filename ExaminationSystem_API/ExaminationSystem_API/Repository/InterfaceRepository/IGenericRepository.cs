using ExaminationSystem_API.Enumeration;
using System.Linq.Expressions;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IGenericRepository<T> where T : class
    {
        Task AddAsync(T entity);
        void Update(T entity);
        Task Delete(int id);
        Task<IEnumerable<T>> GetAllAsync();
        Task<T?> GetByIdAsync(int id);
        IQueryable<T> GetAllQueryable();
        IQueryable<T> Find(Expression<Func<T, bool>> predicate, Tracking tracking = Tracking.NoTracking);
    }
}
