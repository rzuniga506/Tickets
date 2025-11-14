using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Tickets.Application.Common.Responses;
using Tickets.Domain.Exceptions;

namespace Tickets.API.Middleware
{
    /// <summary>
    /// Middleware para manejo global de excepciones
    /// </summary>
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error no manejado: {Message}", ex.Message);
                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            var response = exception switch
            {
                UnauthorizedException => new
                {
                    statusCode = (int)HttpStatusCode.Unauthorized,
                    response = ApiResponse<object>.ErrorResponse(exception.Message)
                },
                ForbiddenException => new
                {
                    statusCode = (int)HttpStatusCode.Forbidden,
                    response = ApiResponse<object>.ErrorResponse(exception.Message)
                },
                NotFoundException => new
                {
                    statusCode = (int)HttpStatusCode.NotFound,
                    response = ApiResponse<object>.ErrorResponse(exception.Message)
                },
                ValidationException => new
                {
                    statusCode = (int)HttpStatusCode.BadRequest,
                    response = ApiResponse<object>.ErrorResponse(exception.Message)
                },
                ConflictException => new
                {
                    statusCode = (int)HttpStatusCode.Conflict,
                    response = ApiResponse<object>.ErrorResponse(exception.Message)
                },
                _ => new
                {
                    statusCode = (int)HttpStatusCode.InternalServerError,
                    response = ApiResponse<object>.ErrorResponse("Ha ocurrido un error interno en el servidor")
                }
            };

            context.Response.StatusCode = response.statusCode;

            var options = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };

            var json = JsonSerializer.Serialize(response.response, options);
            await context.Response.WriteAsync(json);
        }
    }
}
