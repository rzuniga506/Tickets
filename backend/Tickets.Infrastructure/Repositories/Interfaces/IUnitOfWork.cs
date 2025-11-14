using System;
using System.Threading;
using System.Threading.Tasks;
using Tickets.Domain.Common;

namespace Tickets.Infrastructure.Repositories.Interfaces
{
    /// <summary>
    /// Unidad de trabajo que maneja las transacciones de la base de datos
    /// </summary>
    public interface IUnitOfWork : IDisposable
    {
        /// <summary>
        /// Obtiene un repositorio genérico para una entidad
        /// </summary>
        IGenericRepository<T> Repository<T>() where T : BaseEntity;

        /// <summary>
        /// Guarda todos los cambios pendientes
        /// </summary>
        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Inicia una transacción
        /// </summary>
        Task BeginTransactionAsync();

        /// <summary>
        /// Confirma la transacción actual
        /// </summary>
        Task CommitTransactionAsync();

        /// <summary>
        /// Revierte la transacción actual
        /// </summary>
        Task RollbackTransactionAsync();
    }
}
