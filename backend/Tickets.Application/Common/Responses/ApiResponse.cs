namespace Tickets.Application.Common.Responses
{
    /// <summary>
    /// Respuesta estándar de la API
    /// </summary>
    public class ApiResponse<T>
    {
        /// <summary>
        /// Indica si la operación fue exitosa
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Datos de la respuesta
        /// </summary>
        public T? Data { get; set; }

        /// <summary>
        /// Mensaje de la respuesta
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// Información de error (si existe)
        /// </summary>
        public ErrorDetails? Error { get; set; }

        /// <summary>
        /// Crea una respuesta exitosa
        /// </summary>
        public static ApiResponse<T> SuccessResponse(T data, string? message = null)
        {
            return new ApiResponse<T>
            {
                Success = true,
                Data = data,
                Message = message
            };
        }

        /// <summary>
        /// Crea una respuesta de error
        /// </summary>
        public static ApiResponse<T> ErrorResponse(string message, string? code = null, object? details = null)
        {
            return new ApiResponse<T>
            {
                Success = false,
                Error = new ErrorDetails
                {
                    Code = code,
                    Message = message,
                    Details = details
                }
            };
        }
    }

    /// <summary>
    /// Detalles de un error
    /// </summary>
    public class ErrorDetails
    {
        /// <summary>
        /// Código del error
        /// </summary>
        public string? Code { get; set; }

        /// <summary>
        /// Mensaje de error
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// Detalles adicionales del error
        /// </summary>
        public object? Details { get; set; }
    }

    /// <summary>
    /// Resultado paginado
    /// </summary>
    public class PagedResult<T>
    {
        /// <summary>
        /// Lista de elementos
        /// </summary>
        public List<T> Items { get; set; } = new();

        /// <summary>
        /// Página actual
        /// </summary>
        public int Page { get; set; }

        /// <summary>
        /// Tamaño de página
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Total de elementos
        /// </summary>
        public int TotalItems { get; set; }

        /// <summary>
        /// Total de páginas
        /// </summary>
        public int TotalPages => (int)Math.Ceiling(TotalItems / (double)PageSize);

        /// <summary>
        /// Indica si hay página anterior
        /// </summary>
        public bool HasPreviousPage => Page > 1;

        /// <summary>
        /// Indica si hay página siguiente
        /// </summary>
        public bool HasNextPage => Page < TotalPages;
    }
}
