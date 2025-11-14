using System.Collections.Generic;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un rol en el sistema de autorización
    /// </summary>
    public class Rol : BaseEntity
    {
        /// <summary>
        /// Nombre único del rol
        /// </summary>
        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Descripción del rol
        /// </summary>
        public string? Descripcion { get; set; }

        /// <summary>
        /// Indica si es un rol del sistema (no se puede eliminar)
        /// </summary>
        public bool EsSistema { get; set; }

        // Relaciones
        /// <summary>
        /// Usuarios que tienen este rol
        /// </summary>
        public virtual ICollection<UsuarioRol> UsuarioRoles { get; set; }

        /// <summary>
        /// Permisos asignados a este rol
        /// </summary>
        public virtual ICollection<RolPermiso> RolPermisos { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Rol()
        {
            EsSistema = false;
            UsuarioRoles = new HashSet<UsuarioRol>();
            RolPermisos = new HashSet<RolPermiso>();
        }
    }
}
