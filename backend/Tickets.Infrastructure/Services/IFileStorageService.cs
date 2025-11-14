using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace Tickets.Infrastructure.Services
{
    /// <summary>
    /// Interfaz para el servicio de almacenamiento de archivos
    /// </summary>
    public interface IFileStorageService
    {
        /// <summary>
        /// Guarda un archivo en el servidor
        /// </summary>
        /// <param name="file">Archivo a guardar</param>
        /// <param name="subfolder">Subcarpeta donde guardar (ej: "tickets", "usuarios")</param>
        /// <returns>Ruta relativa del archivo guardado</returns>
        Task<(string rutaRelativa, string nombreArchivoServidor)> SaveFileAsync(IFormFile file, string subfolder);

        /// <summary>
        /// Elimina un archivo del servidor
        /// </summary>
        /// <param name="rutaRelativa">Ruta relativa del archivo</param>
        Task DeleteFileAsync(string rutaRelativa);

        /// <summary>
        /// Obtiene el archivo físico
        /// </summary>
        /// <param name="rutaRelativa">Ruta relativa del archivo</param>
        /// <returns>Ruta completa del archivo</returns>
        string GetFullPath(string rutaRelativa);

        /// <summary>
        /// Verifica si un archivo existe
        /// </summary>
        /// <param name="rutaRelativa">Ruta relativa del archivo</param>
        bool FileExists(string rutaRelativa);

        /// <summary>
        /// Obtiene el tamaño máximo permitido en bytes
        /// </summary>
        long GetMaxFileSizeBytes();
    }
}
