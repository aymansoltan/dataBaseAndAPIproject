//namespace ExaminationSystem_API.Helper
//{
//    public static class IQueryableExtensions
//    {
//        public static IQueryable<T> ApplySorting<T>(this IQueryable<T> query, string sortBy, bool ascending = true)
//        {
//            if (string.IsNullOrWhiteSpace(sortBy))
//                return query;

//            var parameter = Expression.Parameter(typeof(T), "x");
//            var property = Expression.Property(parameter, sortBy);
//            var lambda = Expression.Lambda(property, parameter);

//            string method = ascending ? "OrderBy" : "OrderByDescending";

//            var call = Expression.Call(
//                typeof(Queryable),
//                method,
//                new[] { typeof(T), property.Type },
//                query.Expression,
//                lambda
//            );

//            return query.Provider.CreateQuery<T>(call);
//        }
//        public static IQueryable<T> ApplySearch<T>(
//            this IQueryable<T> query,
//            string searchTerm,
//            params Expression<Func<T, string?>>[] properties)
//        {
//            if (string.IsNullOrWhiteSpace(searchTerm))
//                return query;

//            var parameter = Expression.Parameter(typeof(T), "x");
//            var searchConst = Expression.Constant(searchTerm);

//            Expression? finalExpression = null;

//            foreach (var prop in properties)
//            {

//                var propertyExpr = Expression.Property(parameter,
//                    ((MemberExpression)prop.Body).Member.Name);


//                var toLowerCall = Expression.Call(propertyExpr,
//                    typeof(string).GetMethod("ToLower", Type.EmptyTypes)!);


//                var containsCall = Expression.Call(
//                    toLowerCall,
//                    typeof(string).GetMethod("Contains", new[] { typeof(string) })!,
//                    Expression.Call(searchConst, "ToLower", null)
//                );

//                finalExpression = finalExpression == null
//                    ? containsCall
//                    : Expression.OrElse(finalExpression, containsCall);
//            }

//            if (finalExpression == null)
//                return query;

//            var lambda = Expression.Lambda<Func<T, bool>>(finalExpression, parameter);

//            return query.Where(lambda);
//        }
//    }
//}
