namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Tabla intermedia Many-to-Many entre Usuario y Rol
    /// </summary>
    public class UsuarioRol
    {
        /// <summary>
        /// ID del usuario
        /// </summary>
        public int UsuarioId { get; set; }
        public virtual Usuario Usuario { get; set; } = null!;

        /// <summary>
        /// ID del rol
        /// </summary>
        public int RolId { get; set; }
        public virtual Rol Rol { get; set; } = null!;
    }
}
