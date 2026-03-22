namespace ExaminationSystem_API.Helper
{
    public static class PaginationExtensions
    {
        public static async Task<PaginatedList<TDestination>> ToPaginatedListAsync<TSource, TDestination>(
            this IQueryable<TSource> query,
            IMapper mapper,
            int pageNumber,
            int pageSize)
        {

            var paginatedList = await PaginatedList<TSource>.CreateAsync(query, pageNumber, pageSize);
            var mappedItems = mapper.Map<List<TDestination>>(paginatedList.Items);
            return new PaginatedList<TDestination>(mappedItems, paginatedList.TotalCount, pageNumber, pageSize);
        }
    }
}
