using System;

namespace Tickets.Domain.Common
{
    /// <summary>
    /// Clase base para todas las entidades del dominio
    /// Implementa campos de auditoría y soft delete
    /// </summary>
    public abstract class BaseEntity
    {
        /// <summary>
        /// Identificador único de la entidad
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Fecha de creación del registro
        /// </summary>
        public DateTime FechaCreacion { get; set; }

        /// <summary>
        /// Fecha de última modificación del registro
        /// </summary>
        public DateTime? FechaModificacion { get; set; }

        /// <summary>
        /// Usuario que creó el registro
        /// </summary>
        public string? CreadoPor { get; set; }

        /// <summary>
        /// Usuario que modificó por última vez el registro
        /// </summary>
        public string? ModificadoPor { get; set; }

        /// <summary>
        /// Indica si el registro está eliminado (Soft Delete)
        /// </summary>
        public bool Eliminado { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        protected BaseEntity()
        {
            FechaCreacion = DateTime.UtcNow;
            Eliminado = false;
        }
    }
}
