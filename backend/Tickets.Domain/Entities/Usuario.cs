using System;
using System.Collections.Generic;
using Tickets.Domain.Common;

namespace Tickets.Domain.Entities
{
    /// <summary>
    /// Entidad que representa un usuario del sistema
    /// </summary>
    public class Usuario : BaseEntity
    {
        /// <summary>
        /// Nombre del usuario
        /// </summary>
        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Apellido del usuario
        /// </summary>
        public string Apellido { get; set; } = string.Empty;

        /// <summary>
        /// Correo electrónico (único)
        /// </summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// Hash de la contraseña (BCrypt)
        /// </summary>
        public string PasswordHash { get; set; } = string.Empty;

        /// <summary>
        /// Número de teléfono
        /// </summary>
        public string? Telefono { get; set; }

        /// <summary>
        /// Indica si el usuario está activo
        /// </summary>
        public bool Activo { get; set; }

        /// <summary>
        /// Fecha y hora del último acceso al sistema
        /// </summary>
        public DateTime? UltimoAcceso { get; set; }

        /// <summary>
        /// URL de la foto de perfil
        /// </summary>
        public string? FotoPerfilUrl { get; set; }

        /// <summary>
        /// Departamento al que pertenece el usuario
        /// </summary>
        public int? DepartamentoId { get; set; }
        public virtual Departamento? Departamento { get; set; }

        // Relaciones
        /// <summary>
        /// Roles asignados al usuario
        /// </summary>
        public virtual ICollection<UsuarioRol> UsuarioRoles { get; set; }

        /// <summary>
        /// Tokens de refresco activos del usuario
        /// </summary>
        public virtual ICollection<RefreshToken> RefreshTokens { get; set; }

        /// <summary>
        /// Dispositivos registrados para notificaciones push
        /// </summary>
        public virtual ICollection<DispositivoUsuario> Dispositivos { get; set; }

        /// <summary>
        /// Tickets creados por el usuario (como solicitante)
        /// </summary>
        public virtual ICollection<Ticket> TicketsCreados { get; set; }

        /// <summary>
        /// Tickets asignados al usuario (como técnico)
        /// </summary>
        public virtual ICollection<Ticket> TicketsAsignados { get; set; }

        /// <summary>
        /// Equipos asignados al usuario
        /// </summary>
        public virtual ICollection<Equipo> EquiposAsignados { get; set; }

        /// <summary>
        /// Notificaciones del usuario
        /// </summary>
        public virtual ICollection<Notificacion> Notificaciones { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public Usuario()
        {
            Activo = true;
            UsuarioRoles = new HashSet<UsuarioRol>();
            RefreshTokens = new HashSet<RefreshToken>();
            Dispositivos = new HashSet<DispositivoUsuario>();
            TicketsCreados = new HashSet<Ticket>();
            TicketsAsignados = new HashSet<Ticket>();
            EquiposAsignados = new HashSet<Equipo>();
            Notificaciones = new HashSet<Notificacion>();
        }

        /// <summary>
        /// Obtiene el nombre completo del usuario
        /// </summary>
        public string NombreCompleto => $"{Nombre} {Apellido}";
    }
}
