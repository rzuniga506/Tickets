using System.Collections.Generic;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un permiso en el sistema
    /// </summary>
    public class Permiso : BaseEntity
    {
        /// <summary>
        /// Código único del permiso (ej: "inventario.read")
        /// </summary>
        public string Codigo { get; set; } = string.Empty;

        /// <summary>
        /// Nombre descriptivo del permiso
        /// </summary>
        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Descripción detallada del permiso
        /// </summary>
        public string? Descripcion { get; set; }

        /// <summary>
        /// Módulo al que pertenece el permiso
        /// </summary>
        public string Modulo { get; set; } = string.Empty;

        // Relaciones
        /// <summary>
        /// Roles que tienen este permiso
        /// </summary>
        public virtual ICollection<RolPermiso> RolPermisos { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Permiso()
        {
            RolPermisos = new HashSet<RolPermiso>();
        }
    }
}
