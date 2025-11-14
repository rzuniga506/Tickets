namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Tabla intermedia Many-to-Many entre Rol y Permiso
    /// </summary>
    public class RolPermiso
    {
        /// <summary>
        /// ID del rol
        /// </summary>
        public int RolId { get; set; }
        public virtual Rol Rol { get; set; } = null!;

        /// <summary>
        /// ID del permiso
        /// </summary>
        public int PermisoId { get; set; }
        public virtual Permiso Permiso { get; set; } = null!;
    }
}
