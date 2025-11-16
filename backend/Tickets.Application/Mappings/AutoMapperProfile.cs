using AutoMapper;
using System;
using System.Linq;
using Tickets.Application.DTOs.Auth;
using Tickets.Application.DTOs.Departamentos;
using Tickets.Application.DTOs.Equipos;
using Tickets.Application.DTOs.Notificaciones;
using Tickets.Application.DTOs.Permisos;
using Tickets.Application.DTOs.Roles;
using Tickets.Application.DTOs.Tickets;
using Tickets.Application.DTOs.Usuarios;
using Tickets.Domain.Entities;

namespace Tickets.Application.Mappings
{
    /// <summary>
    /// Perfil de AutoMapper para mapeo de entidades a DTOs
    /// </summary>
    public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            // ============================================================
            // MAPEOS DE USUARIO
            // ============================================================
            CreateMap<Usuario, UsuarioDto>()
                .ForMember(dest => dest.NombreCompleto,
                    opt => opt.MapFrom(src => $"{src.Nombre} {src.Apellido}"))
                .ForMember(dest => dest.DepartamentoNombre,
                    opt => opt.MapFrom(src => src.Departamento != null ? src.Departamento.Nombre : null))
                .ForMember(dest => dest.Roles,
                    opt => opt.MapFrom(src => src.UsuarioRoles.Select(ur => ur.Rol.Nombre).ToList()));

            CreateMap<UsuarioCreateDto, Usuario>()
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioRoles, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            CreateMap<UsuarioUpdateDto, Usuario>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioRoles, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            // ============================================================
            // MAPEOS DE ROL
            // ============================================================
            CreateMap<Rol, RolDto>()
                .ForMember(dest => dest.CantidadUsuarios,
                    opt => opt.MapFrom(src => src.UsuarioRoles.Count))
                .ForMember(dest => dest.Permisos,
                    opt => opt.MapFrom(src => src.RolPermisos.Select(rp => new PermisoDto
                    {
                        Id = rp.Permiso.Id,
                        Codigo = rp.Permiso.Codigo,
                        Nombre = rp.Permiso.Nombre,
                        Modulo = rp.Permiso.Modulo,
                        Descripcion = rp.Permiso.Descripcion
                    }).ToList()));

            CreateMap<RolCreateDto, Rol>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.EsSistema, opt => opt.MapFrom(src => false))
                .ForMember(dest => dest.RolPermisos, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioRoles, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            CreateMap<RolUpdateDto, Rol>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.EsSistema, opt => opt.Ignore())
                .ForMember(dest => dest.RolPermisos, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioRoles, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            // ============================================================
            // MAPEOS DE PERMISO
            // ============================================================
            CreateMap<Permiso, PermisoDto>();

            // ============================================================
            // MAPEOS DE DEPARTAMENTO
            // ============================================================
            CreateMap<Departamento, DepartamentoDto>()
                .ForMember(dest => dest.CantidadUsuarios,
                    opt => opt.MapFrom(src => src.Usuarios.Count))
                .ForMember(dest => dest.CantidadEquipos,
                    opt => opt.MapFrom(src => src.Equipos.Count));

            // ============================================================
            // MAPEOS DE EQUIPO
            // ============================================================
            CreateMap<Equipo, EquipoDto>()
                .ForMember(dest => dest.EstadoNombre,
                    opt => opt.MapFrom(src => src.Estado.ToString()))
                .ForMember(dest => dest.CondicionNombre,
                    opt => opt.MapFrom(src => src.Condicion.ToString()))
                .ForMember(dest => dest.EnGarantia,
                    opt => opt.MapFrom(src => src.FechaFinGarantia.HasValue && src.FechaFinGarantia.Value > DateTime.UtcNow))
                .ForMember(dest => dest.UsuarioAsignadoNombre,
                    opt => opt.MapFrom(src => src.UsuarioAsignado != null ? $"{src.UsuarioAsignado.Nombre} {src.UsuarioAsignado.Apellido}" : null))
                .ForMember(dest => dest.DepartamentoAsignadoNombre,
                    opt => opt.MapFrom(src => src.DepartamentoAsignado != null ? src.DepartamentoAsignado.Nombre : null));

            CreateMap<EquipoCreateDto, Equipo>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.CodigoQR, opt => opt.Ignore())
                .ForMember(dest => dest.FechaAsignacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.DepartamentoAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.Tickets, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            CreateMap<EquipoUpdateDto, Equipo>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.CodigoInterno, opt => opt.Ignore())
                .ForMember(dest => dest.CodigoQR, opt => opt.Ignore())
                .ForMember(dest => dest.FechaAsignacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.DepartamentoAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.Tickets, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            // ============================================================
            // MAPEOS DE TICKET
            // ============================================================
            CreateMap<Ticket, TicketDto>()
                .ForMember(dest => dest.PrioridadNombre,
                    opt => opt.MapFrom(src => src.Prioridad.ToString()))
                .ForMember(dest => dest.EstadoNombre,
                    opt => opt.MapFrom(src => src.Estado.ToString()))
                .ForMember(dest => dest.TipoSolucionNombre,
                    opt => opt.MapFrom(src => src.TipoSolucion.HasValue ? src.TipoSolucion.Value.ToString() : null))
                .ForMember(dest => dest.SolicitanteNombre,
                    opt => opt.MapFrom(src => $"{src.Solicitante.Nombre} {src.Solicitante.Apellido}"))
                .ForMember(dest => dest.SolicitanteEmail,
                    opt => opt.MapFrom(src => src.Solicitante.Email))
                .ForMember(dest => dest.TecnicoAsignadoNombre,
                    opt => opt.MapFrom(src => src.TecnicoAsignado != null ? $"{src.TecnicoAsignado.Nombre} {src.TecnicoAsignado.Apellido}" : null))
                .ForMember(dest => dest.EquipoNombre,
                    opt => opt.MapFrom(src => src.Equipo != null ? src.Equipo.Nombre : null))
                .ForMember(dest => dest.EquipoCodigoInterno,
                    opt => opt.MapFrom(src => src.Equipo != null ? src.Equipo.CodigoInterno : null))
                .ForMember(dest => dest.CategoriaTicketNombre,
                    opt => opt.MapFrom(src => src.CategoriaTicket != null ? src.CategoriaTicket.Nombre : null));

            CreateMap<TicketCreateDto, Ticket>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.NumeroTicket, opt => opt.Ignore())
                .ForMember(dest => dest.Estado, opt => opt.Ignore())
                .ForMember(dest => dest.FechaApertura, opt => opt.Ignore())
                .ForMember(dest => dest.SolicitanteId, opt => opt.Ignore())
                .ForMember(dest => dest.Solicitante, opt => opt.Ignore())
                .ForMember(dest => dest.TecnicoAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.Equipo, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            CreateMap<TicketUpdateDto, Ticket>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.NumeroTicket, opt => opt.Ignore())
                .ForMember(dest => dest.Estado, opt => opt.Ignore())
                .ForMember(dest => dest.FechaApertura, opt => opt.Ignore())
                .ForMember(dest => dest.SolicitanteId, opt => opt.Ignore())
                .ForMember(dest => dest.Solicitante, opt => opt.Ignore())
                .ForMember(dest => dest.TecnicoAsignado, opt => opt.Ignore())
                .ForMember(dest => dest.Equipo, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());

            // ============================================================
            // MAPEOS DE NOTIFICACIÓN
            // ============================================================
            CreateMap<Notificacion, NotificacionDto>()
                .ForMember(dest => dest.TipoNombre,
                    opt => opt.MapFrom(src => src.Tipo.ToString()))
                .ForMember(dest => dest.PrioridadNombre,
                    opt => opt.MapFrom(src => src.Prioridad.ToString()));

            CreateMap<NotificacionCreateDto, Notificacion>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Leida, opt => opt.MapFrom(src => false))
                .ForMember(dest => dest.Enviada, opt => opt.MapFrom(src => false))
                .ForMember(dest => dest.Usuario, opt => opt.Ignore())
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Eliminado, opt => opt.Ignore());
        }
    }
}
