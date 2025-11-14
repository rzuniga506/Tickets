using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Tickets.Domain.Common;

namespace Tickets.Infrastructure.Repositories.Interfaces
{
    /// <summary>
    /// Repositorio genérico con operaciones CRUD estándar
    /// </summary>
    /// <typeparam name="T">Entidad que hereda de BaseEntity</typeparam>
    public interface IGenericRepository<T> where T : BaseEntity
    {
        /// <summary>
        /// Obtiene una entidad por su ID
        /// </summary>
        Task<T?> GetByIdAsync(int id);

        /// <summary>
        /// Obtiene todas las entidades
        /// </summary>
        Task<IEnumerable<T>> GetAllAsync();

        /// <summary>
        /// Busca entidades que cumplan con un predicado
        /// </summary>
        Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);

        /// <summary>
        /// Obtiene la primera entidad que cumple con el predicado
        /// </summary>
        Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate);

        /// <summary>
        /// Verifica si existe alguna entidad que cumple con el predicado
        /// </summary>
        Task<bool> AnyAsync(Expression<Func<T, bool>> predicate);

        /// <summary>
        /// Cuenta las entidades que cumplen con el predicado
        /// </summary>
        Task<int> CountAsync(Expression<Func<T, bool>>? predicate = null);

        /// <summary>
        /// Obtiene un queryable para consultas complejas
        /// </summary>
        IQueryable<T> GetQueryable();

        /// <summary>
        /// Agrega una nueva entidad
        /// </summary>
        void Add(T entity);

        /// <summary>
        /// Agrega múltiples entidades
        /// </summary>
        void AddRange(IEnumerable<T> entities);

        /// <summary>
        /// Actualiza una entidad
        /// </summary>
        void Update(T entity);

        /// <summary>
        /// Actualiza múltiples entidades
        /// </summary>
        void UpdateRange(IEnumerable<T> entities);

        /// <summary>
        /// Elimina una entidad (soft delete)
        /// </summary>
        void Remove(T entity);

        /// <summary>
        /// Elimina múltiples entidades (soft delete)
        /// </summary>
        void RemoveRange(IEnumerable<T> entities);

        /// <summary>
        /// Elimina permanentemente una entidad
        /// </summary>
        void HardRemove(T entity);
    }
}
