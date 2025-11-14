using System;

namespace Tickets.Application.Common.Exceptions
{
    /// <summary>
    /// Excepción base de la capa de aplicación
    /// </summary>
    public abstract class ApplicationException : Exception
    {
        protected ApplicationException(string message) : base(message)
        {
        }

        protected ApplicationException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }

    /// <summary>
    /// Excepción de validación de datos
    /// </summary>
    public class ValidationException : ApplicationException
    {
        public IDictionary<string, string[]>? Errors { get; }

        public ValidationException(string message) : base(message)
        {
        }

        public ValidationException(IDictionary<string, string[]> errors)
            : base("Se encontraron uno o más errores de validación")
        {
            Errors = errors;
        }
    }

    /// <summary>
    /// Excepción de negocio
    /// </summary>
    public class BusinessException : ApplicationException
    {
        public string Code { get; }

        public BusinessException(string message, string code = "BUSINESS_ERROR")
            : base(message)
        {
            Code = code;
        }
    }
}
