using System.Threading.Tasks;

namespace Tickets.Application.Services.Interfaces
{
    /// <summary>
    /// Interfaz del servicio de correo electrónico
    /// </summary>
    public interface IEmailService
    {
        /// <summary>
        /// Envía un correo electrónico
        /// </summary>
        /// <param name="to">Destinatario</param>
        /// <param name="subject">Asunto</param>
        /// <param name="body">Cuerpo del mensaje (HTML)</param>
        /// <param name="isHtml">Indica si el cuerpo es HTML (default: true)</param>
        /// <returns>True si se envió correctamente</returns>
        Task<bool> SendEmailAsync(string to, string subject, string body, bool isHtml = true);

        /// <summary>
        /// Envía un correo electrónico para notificación de mención
        /// </summary>
        /// <param name="toEmail">Email del destinatario</param>
        /// <param name="toName">Nombre del destinatario</param>
        /// <param name="ticketNumber">Número del ticket</param>
        /// <param name="ticketSubject">Asunto del ticket</param>
        /// <param name="ticketId">ID del ticket para generar enlace</param>
        /// <returns>True si se envió correctamente</returns>
        Task<bool> SendMentionNotificationAsync(
            string toEmail,
            string toName,
            string ticketNumber,
            string ticketSubject,
            int ticketId);
    }
}
