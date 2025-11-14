using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Tickets.Domain.Common;
using Tickets.Infrastructure.Data;
using Tickets.Infrastructure.Repositories.Interfaces;

namespace Tickets.Infrastructure.Repositories.Implementation
{
    /// <summary>
    /// Implementación de la Unidad de Trabajo
    /// </summary>
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private readonly Dictionary<Type, object> _repositories;
        private IDbContextTransaction? _transaction;
        private bool _disposed;

        public UnitOfWork(ApplicationDbContext context)
        {
            _context = context;
            _repositories = new Dictionary<Type, object>();
        }

        public IGenericRepository<T> Repository<T>() where T : BaseEntity
        {
            var type = typeof(T);

            if (!_repositories.ContainsKey(type))
            {
                var repositoryInstance = new GenericRepository<T>(_context);
                _repositories.Add(type, repositoryInstance);
            }

            return (IGenericRepository<T>)_repositories[type];
        }

        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return await _context.SaveChangesAsync(cancellationToken);
        }

        public async Task BeginTransactionAsync()
        {
            _transaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            try
            {
                await _context.SaveChangesAsync();
                if (_transaction != null)
                {
                    await _transaction.CommitAsync();
                }
            }
            catch
            {
                await RollbackTransactionAsync();
                throw;
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            if (_transaction != null)
            {
                await _transaction.RollbackAsync();
                await _transaction.DisposeAsync();
                _transaction = null;
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    _transaction?.Dispose();
                    _context.Dispose();
                }
                _disposed = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
