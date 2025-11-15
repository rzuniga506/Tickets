using System;

namespace Tickets.Domain.Exceptions
{
    /// <summary>
    /// Excepción para errores de lógica de negocio
    /// </summary>
    public class BusinessException : Exception
    {
        public BusinessException() : base()
        {
        }

        public BusinessException(string message) : base(message)
        {
        }

        public BusinessException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }
}
