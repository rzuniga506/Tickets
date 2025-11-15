using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Linq;
using System.Security.Claims;

namespace Tickets.API.Attributes
{
    /// <summary>
    /// Atributo para autorización basada en permisos granulares
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public class AuthorizePermissionAttribute : Attribute, IAuthorizationFilter
    {
        private readonly string[] _permissions;

        /// <summary>
        /// Constructor que acepta uno o más permisos requeridos
        /// </summary>
        /// <param name="permissions">Códigos de permisos requeridos (ej: "usuarios.create", "tickets.view")</param>
        public AuthorizePermissionAttribute(params string[] permissions)
        {
            _permissions = permissions ?? throw new ArgumentNullException(nameof(permissions));
        }

        public void OnAuthorization(AuthorizationFilterContext context)
        {
            // Verificar que el usuario esté autenticado
            var user = context.HttpContext.User;
            if (!user.Identity?.IsAuthenticated ?? true)
            {
                context.Result = new UnauthorizedResult();
                return;
            }

            // Obtener permisos del usuario desde los claims
            var userPermissions = user.Claims
                .Where(c => c.Type == "permission")
                .Select(c => c.Value)
                .ToList();

            // Verificar si el usuario es Administrador (tiene todos los permisos)
            var isAdmin = user.Claims.Any(c => c.Type == ClaimTypes.Role && c.Value == "Administrador");

            if (isAdmin)
            {
                // Los administradores tienen acceso a todo
                return;
            }

            // Verificar si el usuario tiene AL MENOS UNO de los permisos requeridos
            var hasPermission = _permissions.Any(requiredPermission =>
                userPermissions.Contains(requiredPermission, StringComparer.OrdinalIgnoreCase));

            if (!hasPermission)
            {
                context.Result = new ForbidResult();
            }
        }
    }
}
