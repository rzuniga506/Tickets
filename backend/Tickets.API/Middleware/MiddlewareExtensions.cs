using Microsoft.AspNetCore.Builder;

namespace Tickets.API.Middleware
{
    /// <summary>
    /// Extensiones para registrar middlewares
    /// </summary>
    public static class MiddlewareExtensions
    {
        /// <summary>
        /// Registra el middleware de manejo de excepciones
        /// </summary>
        public static IApplicationBuilder UseExceptionMiddleware(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<ExceptionMiddleware>();
        }
    }
}
