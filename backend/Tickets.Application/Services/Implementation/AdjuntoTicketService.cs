using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.DTOs.Adjuntos;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;
using Tickets.Infrastructure.Services;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de gestión de adjuntos de tickets
    /// </summary>
    public class AdjuntoTicketService : IAdjuntoTicketService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IFileStorageService _fileStorageService;

        // Tipos MIME permitidos
        private readonly HashSet<string> _allowedMimeTypes = new()
        {
            // Imágenes
            "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp",
            // Documentos
            "application/pdf", "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // .docx
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // .xlsx
            // Texto
            "text/plain", "text/csv",
            // Comprimidos
            "application/zip", "application/x-rar-compressed"
        };

        public AdjuntoTicketService(
            IUnitOfWork unitOfWork,
            IFileStorageService fileStorageService)
        {
            _unitOfWork = unitOfWork;
            _fileStorageService = fileStorageService;
        }

        public async Task<List<AdjuntoTicketDto>> GetByTicketIdAsync(int ticketId)
        {
            // Verificar que el ticket existe
            var ticket = await _unitOfWork.Repository<Ticket>()
                .GetByIdAsync(ticketId);

            if (ticket == null)
            {
                throw new NotFoundException($"Ticket con ID {ticketId} no encontrado");
            }

            var adjuntos = await _unitOfWork.Repository<AdjuntoTicket>()
                .GetQueryable()
                .Include(a => a.Usuario)
                .Include(a => a.Ticket)
                .Where(a => a.TicketId == ticketId)
                .OrderBy(a => a.FechaCreacion)
                .ToListAsync();

            return adjuntos.Select(a => new AdjuntoTicketDto
            {
                Id = a.Id,
                NombreArchivo = a.NombreArchivo,
                NombreArchivoServidor = a.NombreArchivoServidor,
                RutaArchivo = a.RutaArchivo,
                TipoMime = a.TipoMime,
                TamanoBytes = a.TamanoBytes,
                TamanoFormateado = a.TamanoFormateado,
                Extension = a.Extension,
                EsImagen = a.EsImagen,
                EsPdf = a.EsPdf,
                TicketId = a.TicketId,
                NumeroTicket = a.Ticket.NumeroTicket,
                UsuarioId = a.UsuarioId,
                UsuarioNombre = $"{a.Usuario.Nombre} {a.Usuario.Apellido}",
                UsuarioEmail = a.Usuario.Email,
                FechaCreacion = a.FechaCreacion
            }).ToList();
        }

        public async Task<AdjuntoTicketDto> GetByIdAsync(int id)
        {
            var adjunto = await _unitOfWork.Repository<AdjuntoTicket>()
                .GetQueryable()
                .Include(a => a.Usuario)
                .Include(a => a.Ticket)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (adjunto == null)
            {
                throw new NotFoundException($"Adjunto con ID {id} no encontrado");
            }

            return new AdjuntoTicketDto
            {
                Id = adjunto.Id,
                NombreArchivo = adjunto.NombreArchivo,
                NombreArchivoServidor = adjunto.NombreArchivoServidor,
                RutaArchivo = adjunto.RutaArchivo,
                TipoMime = adjunto.TipoMime,
                TamanoBytes = adjunto.TamanoBytes,
                TamanoFormateado = adjunto.TamanoFormateado,
                Extension = adjunto.Extension,
                EsImagen = adjunto.EsImagen,
                EsPdf = adjunto.EsPdf,
                TicketId = adjunto.TicketId,
                NumeroTicket = adjunto.Ticket.NumeroTicket,
                UsuarioId = adjunto.UsuarioId,
                UsuarioNombre = $"{adjunto.Usuario.Nombre} {adjunto.Usuario.Apellido}",
                UsuarioEmail = adjunto.Usuario.Email,
                FechaCreacion = adjunto.FechaCreacion
            };
        }

        public async Task<AdjuntoTicketDto> UploadAsync(IFormFile file, int ticketId, int usuarioId)
        {
            // Validaciones
            if (file == null || file.Length == 0)
            {
                throw new BusinessException("No se ha proporcionado un archivo");
            }

            if (file.Length > _fileStorageService.GetMaxFileSizeBytes())
            {
                throw new BusinessException($"El archivo excede el tamaño máximo permitido de {_fileStorageService.GetMaxFileSizeBytes() / (1024 * 1024)} MB");
            }

            if (!_allowedMimeTypes.Contains(file.ContentType.ToLower()))
            {
                throw new BusinessException($"Tipo de archivo no permitido: {file.ContentType}");
            }

            // Verificar que el ticket existe
            var ticket = await _unitOfWork.Repository<Ticket>().GetByIdAsync(ticketId);
            if (ticket == null)
            {
                throw new NotFoundException($"Ticket con ID {ticketId} no encontrado");
            }

            // Verificar que el usuario existe
            var usuario = await _unitOfWork.Repository<Usuario>().GetByIdAsync(usuarioId);
            if (usuario == null)
            {
                throw new NotFoundException($"Usuario con ID {usuarioId} no encontrado");
            }

            // Guardar archivo
            var (rutaRelativa, nombreArchivoServidor) = await _fileStorageService.SaveFileAsync(file, "tickets");

            // Crear registro en base de datos
            var adjunto = new AdjuntoTicket
            {
                NombreArchivo = file.FileName,
                NombreArchivoServidor = nombreArchivoServidor,
                RutaArchivo = rutaRelativa,
                TipoMime = file.ContentType,
                TamanoBytes = file.Length,
                Extension = Path.GetExtension(file.FileName),
                TicketId = ticketId,
                UsuarioId = usuarioId,
                CreadoPor = usuario.Email
            };

            await _unitOfWork.Repository<AdjuntoTicket>().AddAsync(adjunto);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(adjunto.Id);
        }

        public async Task<(byte[] contenido, string nombreArchivo, string tipoMime)> DownloadAsync(int id)
        {
            var adjunto = await _unitOfWork.Repository<AdjuntoTicket>()
                .GetByIdAsync(id);

            if (adjunto == null)
            {
                throw new NotFoundException($"Adjunto con ID {id} no encontrado");
            }

            var rutaCompleta = _fileStorageService.GetFullPath(adjunto.RutaArchivo);

            if (!_fileStorageService.FileExists(adjunto.RutaArchivo))
            {
                throw new NotFoundException($"Archivo físico no encontrado: {adjunto.NombreArchivo}");
            }

            var contenido = await File.ReadAllBytesAsync(rutaCompleta);

            return (contenido, adjunto.NombreArchivo, adjunto.TipoMime);
        }

        public async Task DeleteAsync(int id, int usuarioId)
        {
            var adjunto = await _unitOfWork.Repository<AdjuntoTicket>()
                .GetByIdAsync(id);

            if (adjunto == null)
            {
                throw new NotFoundException($"Adjunto con ID {id} no encontrado");
            }

            // Solo el usuario que subió el archivo puede eliminarlo
            // O un administrador (esto se puede agregar después)
            if (adjunto.UsuarioId != usuarioId)
            {
                throw new BusinessException("No tienes permiso para eliminar este archivo");
            }

            // Eliminar archivo físico
            await _fileStorageService.DeleteFileAsync(adjunto.RutaArchivo);

            // Eliminar registro de base de datos
            _unitOfWork.Repository<AdjuntoTicket>().Delete(adjunto);
            await _unitOfWork.SaveChangesAsync();
        }
    }
}
