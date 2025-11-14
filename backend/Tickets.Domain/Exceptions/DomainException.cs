using System;

namespace Tickets.Domain.Exceptions
{
    /// <summary>
    /// Excepción base para errores de dominio
    /// </summary>
    public abstract class DomainException : Exception
    {
        protected DomainException(string message) : base(message)
        {
        }

        protected DomainException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }

    /// <summary>
    /// Excepción lanzada cuando una entidad no se encuentra
    /// </summary>
    public class NotFoundException : DomainException
    {
        public NotFoundException(string entityName, object key)
            : base($"Entidad '{entityName}' con id '{key}' no fue encontrada.")
        {
        }

        public NotFoundException(string message) : base(message)
        {
        }
    }

    /// <summary>
    /// Excepción lanzada cuando una validación de negocio falla
    /// </summary>
    public class ValidationException : DomainException
    {
        public ValidationException(string message) : base(message)
        {
        }

        public ValidationException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }

    /// <summary>
    /// Excepción lanzada cuando hay un conflicto (ej: duplicado)
    /// </summary>
    public class ConflictException : DomainException
    {
        public ConflictException(string message) : base(message)
        {
        }
    }

    /// <summary>
    /// Excepción lanzada cuando una operación no está autorizada
    /// </summary>
    public class UnauthorizedException : DomainException
    {
        public UnauthorizedException(string message) : base(message)
        {
        }
    }

    /// <summary>
    /// Excepción lanzada cuando un usuario no tiene permisos
    /// </summary>
    public class ForbiddenException : DomainException
    {
        public ForbiddenException(string message) : base(message)
        {
        }
    }
}
