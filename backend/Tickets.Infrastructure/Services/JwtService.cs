using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Tickets.Application.DTOs.Common;
using Tickets.Domain.Entities;

namespace Tickets.Infrastructure.Services
{
    /// <summary>
    /// Interfaz del servicio JWT
    /// </summary>
    public interface IJwtService
    {
        /// <summary>
        /// Genera un access token JWT
        /// </summary>
        string GenerateAccessToken(Usuario usuario, List<string> roles, List<string> permisos);

        /// <summary>
        /// Genera un refresh token
        /// </summary>
        RefreshToken GenerateRefreshToken(int usuarioId, string? dispositivoInfo = null, string? direccionIp = null);

        /// <summary>
        /// Valida un token JWT
        /// </summary>
        ClaimsPrincipal? ValidateToken(string token);

        /// <summary>
        /// Obtiene el ID del usuario desde un token
        /// </summary>
        int? GetUserIdFromToken(string token);
    }

    /// <summary>
    /// Implementación del servicio JWT
    /// </summary>
    public class JwtService : IJwtService
    {
        private readonly JwtSettings _jwtSettings;
        private readonly JwtSecurityTokenHandler _tokenHandler;

        public JwtService(IOptions<JwtSettings> jwtSettings)
        {
            _jwtSettings = jwtSettings.Value;
            _tokenHandler = new JwtSecurityTokenHandler();
        }

        public string GenerateAccessToken(Usuario usuario, List<string> roles, List<string> permisos)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
                new Claim(ClaimTypes.Email, usuario.Email),
                new Claim(ClaimTypes.Name, usuario.NombreCompleto),
                new Claim(ClaimTypes.GivenName, usuario.Nombre),
                new Claim(ClaimTypes.Surname, usuario.Apellido),
                new Claim("activo", usuario.Activo.ToString())
            };

            // Agregar roles
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            // Agregar permisos
            foreach (var permiso in permisos)
            {
                claims.Add(new Claim("permission", permiso));
            }

            // Agregar departamento si existe
            if (usuario.DepartamentoId.HasValue)
            {
                claims.Add(new Claim("departamento", usuario.DepartamentoId.Value.ToString()));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes),
                signingCredentials: credentials,
                notBefore: DateTime.UtcNow
            );

            return _tokenHandler.WriteToken(token);
        }

        public RefreshToken GenerateRefreshToken(int usuarioId, string? dispositivoInfo = null, string? direccionIp = null)
        {
            var randomBytes = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);

            return new RefreshToken
            {
                Token = Convert.ToBase64String(randomBytes),
                UsuarioId = usuarioId,
                Expiracion = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays),
                DispositivoInfo = dispositivoInfo,
                DireccionIP = direccionIp,
                FechaCreacion = DateTime.UtcNow,
                Revocado = false
            };
        }

        public ClaimsPrincipal? ValidateToken(string token)
        {
            try
            {
                var tokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(_jwtSettings.SecretKey)),
                    ValidateIssuer = true,
                    ValidIssuer = _jwtSettings.Issuer,
                    ValidateAudience = true,
                    ValidAudience = _jwtSettings.Audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero // No dar tiempo extra de gracia
                };

                var principal = _tokenHandler.ValidateToken(
                    token,
                    tokenValidationParameters,
                    out SecurityToken validatedToken);

                // Verificar que sea un JWT válido
                if (validatedToken is not JwtSecurityToken jwtToken ||
                    !jwtToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256,
                        StringComparison.InvariantCultureIgnoreCase))
                {
                    return null;
                }

                return principal;
            }
            catch
            {
                return null;
            }
        }

        public int? GetUserIdFromToken(string token)
        {
            var principal = ValidateToken(token);
            if (principal == null)
                return null;

            var userIdClaim = principal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                return userId;
            }

            return null;
        }
    }
}
