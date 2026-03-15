
namespace Examination_System_MVC.Repository.ClassRepository
{
    public class GenericRepository<T> : IGenericRepository<T> where T : class
    {
        protected readonly ExaminationContext _context;
        protected readonly DbSet<T> _dbSet;
        public GenericRepository(ExaminationContext context)
        {
            _context = context;
            _dbSet = _context.Set<T>();
        }
        public async Task<IEnumerable<T>> GetAllAsync() => await _dbSet.AsNoTracking().ToListAsync();
        public IQueryable<T> GetAllQueryable() => _dbSet.AsNoTracking().AsQueryable();
        public async Task<T?> GetByIdAsync(int id) => await _dbSet.FindAsync(id);
        public async Task AddAsync(T entity) => await _dbSet.AddAsync(entity);
        public void Update(T entity) => _dbSet.Update(entity);
        public async Task Delete(int id)
        {
            var item = await _dbSet.FindAsync(id);
            if (item != null)
                _dbSet.Remove(item);
        }

        public IQueryable<T> Find(Expression<Func<T, bool>> predicate, Tracking tracking = Tracking.NoTracking)
        {
            var query = _dbSet.Where(predicate);

            if (tracking == Tracking.NoTracking)
                query = query.AsNoTracking();

            return query;
        }


    }
}
