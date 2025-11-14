using AutoMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Tickets.Application.DTOs.Auth;
using Tickets.Application.DTOs.Usuarios;
using Tickets.Application.Services.Interfaces;
using Tickets.Domain.Entities;
using Tickets.Domain.Exceptions;
using Tickets.Infrastructure.Repositories.Interfaces;
using Tickets.Infrastructure.Services;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Implementación del servicio de autenticación
    /// </summary>
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IJwtService _jwtService;
        private readonly IMapper _mapper;

        public AuthService(
            IUnitOfWork unitOfWork,
            IJwtService jwtService,
            IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _jwtService = jwtService;
            _mapper = mapper;
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request, string? ipAddress = null)
        {
            // Buscar usuario por email
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                        .ThenInclude(r => r.RolPermisos)
                            .ThenInclude(rp => rp.Permiso)
                .Include(u => u.Departamento)
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (usuario == null)
            {
                throw new UnauthorizedException("Credenciales inválidas");
            }

            // Verificar contraseña
            if (!BCrypt.Net.BCrypt.Verify(request.Password, usuario.PasswordHash))
            {
                throw new UnauthorizedException("Credenciales inválidas");
            }

            // Verificar si el usuario está activo
            if (!usuario.Activo)
            {
                throw new UnauthorizedException("Usuario inactivo. Contacte al administrador.");
            }

            // Obtener roles
            var roles = usuario.UsuarioRoles
                .Select(ur => ur.Rol.Nombre)
                .ToList();

            // Obtener permisos únicos de todos los roles
            var permisos = usuario.UsuarioRoles
                .SelectMany(ur => ur.Rol.RolPermisos)
                .Select(rp => rp.Permiso.Codigo)
                .Distinct()
                .ToList();

            // Generar tokens
            var accessToken = _jwtService.GenerateAccessToken(usuario, roles, permisos);
            var refreshToken = _jwtService.GenerateRefreshToken(
                usuario.Id,
                request.DispositivoInfo,
                ipAddress);

            // Guardar refresh token en base de datos
            _unitOfWork.Repository<RefreshToken>().Add(refreshToken);

            // Actualizar último acceso
            usuario.UltimoAcceso = DateTime.UtcNow;
            _unitOfWork.Repository<Usuario>().Update(usuario);

            await _unitOfWork.SaveChangesAsync();

            // Mapear usuario a DTO
            var usuarioDto = _mapper.Map<UsuarioDto>(usuario);

            return new AuthResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token,
                ExpiresAt = DateTime.UtcNow.AddMinutes(60), // Esto debería venir de settings
                Usuario = usuarioDto,
                Roles = roles,
                Permisos = permisos
            };
        }

        public async Task<AuthResponse> RefreshTokenAsync(string refreshToken, string? ipAddress = null)
        {
            // Buscar el refresh token
            var token = await _unitOfWork.Repository<RefreshToken>()
                .GetQueryable()
                .Include(rt => rt.Usuario)
                    .ThenInclude(u => u.UsuarioRoles)
                        .ThenInclude(ur => ur.Rol)
                            .ThenInclude(r => r.RolPermisos)
                                .ThenInclude(rp => rp.Permiso)
                .Include(rt => rt.Usuario.Departamento)
                .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

            if (token == null || !token.EsActivo)
            {
                throw new UnauthorizedException("Refresh token inválido o expirado");
            }

            var usuario = token.Usuario;

            if (!usuario.Activo)
            {
                throw new UnauthorizedException("Usuario inactivo");
            }

            // Obtener roles y permisos
            var roles = usuario.UsuarioRoles
                .Select(ur => ur.Rol.Nombre)
                .ToList();

            var permisos = usuario.UsuarioRoles
                .SelectMany(ur => ur.Rol.RolPermisos)
                .Select(rp => rp.Permiso.Codigo)
                .Distinct()
                .ToList();

            // Generar nuevo access token
            var accessToken = _jwtService.GenerateAccessToken(usuario, roles, permisos);

            // Generar nuevo refresh token
            var nuevoRefreshToken = _jwtService.GenerateRefreshToken(
                usuario.Id,
                token.DispositivoInfo,
                ipAddress);

            // Revocar el refresh token anterior
            token.Revocado = true;
            token.FechaRevocacion = DateTime.UtcNow;
            _unitOfWork.Repository<RefreshToken>().Update(token);

            // Guardar el nuevo refresh token
            _unitOfWork.Repository<RefreshToken>().Add(nuevoRefreshToken);

            // Actualizar último acceso
            usuario.UltimoAcceso = DateTime.UtcNow;
            _unitOfWork.Repository<Usuario>().Update(usuario);

            await _unitOfWork.SaveChangesAsync();

            var usuarioDto = _mapper.Map<UsuarioDto>(usuario);

            return new AuthResponse
            {
                AccessToken = accessToken,
                RefreshToken = nuevoRefreshToken.Token,
                ExpiresAt = DateTime.UtcNow.AddMinutes(60),
                Usuario = usuarioDto,
                Roles = roles,
                Permisos = permisos
            };
        }

        public async Task LogoutAsync(int usuarioId, string? refreshToken = null)
        {
            if (!string.IsNullOrEmpty(refreshToken))
            {
                // Revocar el refresh token específico
                var token = await _unitOfWork.Repository<RefreshToken>()
                    .FirstOrDefaultAsync(rt => rt.Token == refreshToken && rt.UsuarioId == usuarioId);

                if (token != null && token.EsActivo)
                {
                    token.Revocado = true;
                    token.FechaRevocacion = DateTime.UtcNow;
                    _unitOfWork.Repository<RefreshToken>().Update(token);
                    await _unitOfWork.SaveChangesAsync();
                }
            }
            else
            {
                // Revocar todos los refresh tokens del usuario
                var tokens = await _unitOfWork.Repository<RefreshToken>()
                    .FindAsync(rt => rt.UsuarioId == usuarioId && !rt.Revocado);

                foreach (var token in tokens)
                {
                    token.Revocado = true;
                    token.FechaRevocacion = DateTime.UtcNow;
                }

                if (tokens.Any())
                {
                    _unitOfWork.Repository<RefreshToken>().UpdateRange(tokens);
                    await _unitOfWork.SaveChangesAsync();
                }
            }
        }

        public async Task<UsuarioDto> GetProfileAsync(int usuarioId)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetQueryable()
                .Include(u => u.UsuarioRoles)
                    .ThenInclude(ur => ur.Rol)
                .Include(u => u.Departamento)
                .FirstOrDefaultAsync(u => u.Id == usuarioId);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", usuarioId);
            }

            return _mapper.Map<UsuarioDto>(usuario);
        }

        public async Task ChangePasswordAsync(int usuarioId, ChangePasswordRequest request)
        {
            var usuario = await _unitOfWork.Repository<Usuario>()
                .GetByIdAsync(usuarioId);

            if (usuario == null)
            {
                throw new NotFoundException("Usuario", usuarioId);
            }

            // Verificar contraseña actual
            if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, usuario.PasswordHash))
            {
                throw new ValidationException("La contraseña actual es incorrecta");
            }

            // Verificar que la nueva contraseña sea diferente
            if (BCrypt.Net.BCrypt.Verify(request.NewPassword, usuario.PasswordHash))
            {
                throw new ValidationException("La nueva contraseña debe ser diferente a la actual");
            }

            // Actualizar contraseña
            usuario.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            _unitOfWork.Repository<Usuario>().Update(usuario);

            // Revocar todos los refresh tokens (forzar re-login en todos los dispositivos)
            var tokens = await _unitOfWork.Repository<RefreshToken>()
                .FindAsync(rt => rt.UsuarioId == usuarioId && !rt.Revocado);

            foreach (var token in tokens)
            {
                token.Revocado = true;
                token.FechaRevocacion = DateTime.UtcNow;
            }

            if (tokens.Any())
            {
                _unitOfWork.Repository<RefreshToken>().UpdateRange(tokens);
            }

            await _unitOfWork.SaveChangesAsync();
        }

        public async Task<bool> EmailExistsAsync(string email)
        {
            return await _unitOfWork.Repository<Usuario>()
                .AnyAsync(u => u.Email == email);
        }
    }
}
