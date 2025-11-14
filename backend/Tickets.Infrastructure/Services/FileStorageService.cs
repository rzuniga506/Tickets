using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Tickets.Infrastructure.Services
{
    /// <summary>
    /// Implementación del servicio de almacenamiento de archivos
    /// </summary>
    public class FileStorageService : IFileStorageService
    {
        private readonly string _uploadsPath;
        private readonly long _maxFileSizeBytes;

        public FileStorageService(IConfiguration configuration)
        {
            // Obtener ruta de uploads desde configuración o usar por defecto
            _uploadsPath = configuration["FileStorage:UploadsPath"] ?? Path.Combine(Directory.GetCurrentDirectory(), "uploads");

            // Tamaño máximo: 10MB por defecto
            var maxSizeMb = configuration.GetValue<int>("FileStorage:MaxFileSizeMB", 10);
            _maxFileSizeBytes = maxSizeMb * 1024 * 1024;

            // Crear directorio si no existe
            if (!Directory.Exists(_uploadsPath))
            {
                Directory.CreateDirectory(_uploadsPath);
            }
        }

        public async Task<(string rutaRelativa, string nombreArchivoServidor)> SaveFileAsync(IFormFile file, string subfolder)
        {
            if (file == null || file.Length == 0)
            {
                throw new ArgumentException("El archivo está vacío");
            }

            if (file.Length > _maxFileSizeBytes)
            {
                throw new ArgumentException($"El archivo excede el tamaño máximo permitido de {_maxFileSizeBytes / (1024 * 1024)} MB");
            }

            // Crear subcarpeta si no existe
            var subfolderPath = Path.Combine(_uploadsPath, subfolder);
            if (!Directory.Exists(subfolderPath))
            {
                Directory.CreateDirectory(subfolderPath);
            }

            // Generar nombre único para el archivo
            var extension = Path.GetExtension(file.FileName);
            var nombreArchivoServidor = $"{Guid.NewGuid()}{extension}";
            var rutaCompleta = Path.Combine(subfolderPath, nombreArchivoServidor);

            // Guardar archivo
            using (var stream = new FileStream(rutaCompleta, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Retornar ruta relativa
            var rutaRelativa = Path.Combine(subfolder, nombreArchivoServidor);
            return (rutaRelativa, nombreArchivoServidor);
        }

        public Task DeleteFileAsync(string rutaRelativa)
        {
            var rutaCompleta = Path.Combine(_uploadsPath, rutaRelativa);

            if (File.Exists(rutaCompleta))
            {
                File.Delete(rutaCompleta);
            }

            return Task.CompletedTask;
        }

        public string GetFullPath(string rutaRelativa)
        {
            return Path.Combine(_uploadsPath, rutaRelativa);
        }

        public bool FileExists(string rutaRelativa)
        {
            var rutaCompleta = Path.Combine(_uploadsPath, rutaRelativa);
            return File.Exists(rutaCompleta);
        }

        public long GetMaxFileSizeBytes()
        {
            return _maxFileSizeBytes;
        }
    }
}
