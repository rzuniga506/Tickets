using System.Collections.Generic;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un departamento de la organización
    /// </summary>
    public class Departamento : BaseEntity
    {
        /// <summary>
        /// Nombre del departamento
        /// </summary>
        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Descripción del departamento
        /// </summary>
        public string? Descripcion { get; set; }

        /// <summary>
        /// Código único del departamento
        /// </summary>
        public string? Codigo { get; set; }

        /// <summary>
        /// Indica si el departamento está activo
        /// </summary>
        public bool Activo { get; set; }

        // Relaciones
        /// <summary>
        /// Usuarios que pertenecen a este departamento
        /// </summary>
        public virtual ICollection<Usuario> Usuarios { get; set; }

        /// <summary>
        /// Equipos asignados a este departamento
        /// </summary>
        public virtual ICollection<Equipo> Equipos { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Departamento()
        {
            Activo = true;
            Usuarios = new HashSet<Usuario>();
            Equipos = new HashSet<Equipo>();
        }
    }
}
