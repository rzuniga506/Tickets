using System;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Tickets.Application.Services.Interfaces;

namespace Tickets.Application.Services.Implementation
{
    /// <summary>
    /// Servicio de correo electrónico usando SMTP
    /// </summary>
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;
        private readonly string _smtpServer;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;

            // Cargar configuración SMTP
            _smtpServer = _configuration["EmailSettings:SmtpServer"] ?? throw new InvalidOperationException("SmtpServer no configurado");
            _smtpPort = int.Parse(_configuration["EmailSettings:SmtpPort"] ?? "587");
            _smtpUsername = _configuration["EmailSettings:SmtpUsername"] ?? throw new InvalidOperationException("SmtpUsername no configurado");
            _smtpPassword = _configuration["EmailSettings:SmtpPassword"] ?? throw new InvalidOperationException("SmtpPassword no configurado");
            _fromEmail = _configuration["EmailSettings:FromEmail"] ?? throw new InvalidOperationException("FromEmail no configurado");
            _fromName = _configuration["EmailSettings:FromName"] ?? "Sistema de Tickets";
        }

        public async Task<bool> SendEmailAsync(string to, string subject, string body, bool isHtml = true)
        {
            try
            {
                using var smtpClient = new SmtpClient(_smtpServer, _smtpPort)
                {
                    Credentials = new NetworkCredential(_smtpUsername, _smtpPassword),
                    EnableSsl = true,
                    Timeout = 20000 // 20 segundos
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(_fromEmail, _fromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = isHtml,
                    BodyEncoding = Encoding.UTF8,
                    SubjectEncoding = Encoding.UTF8
                };

                mailMessage.To.Add(new MailAddress(to));

                await smtpClient.SendMailAsync(mailMessage);

                _logger.LogInformation("Email enviado correctamente a {To} con asunto: {Subject}", to, subject);
                return true;
            }
            catch (SmtpException ex)
            {
                _logger.LogError(ex, "Error SMTP al enviar email a {To}: {Message}", to, ex.Message);
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado al enviar email a {To}: {Message}", to, ex.Message);
                return false;
            }
        }

        public async Task<bool> SendMentionNotificationAsync(
            string toEmail,
            string toName,
            string ticketNumber,
            string ticketSubject,
            int ticketId)
        {
            try
            {
                // TODO: Obtener la URL base desde configuración
                var baseUrl = _configuration["AppSettings:BaseUrl"] ?? "http://localhost:5000";
                var ticketUrl = $"{baseUrl}/tickets/{ticketId}";

                var subject = $"Te mencionaron en el ticket #{ticketNumber}";

                var body = GenerateMentionEmailTemplate(toName, ticketNumber, ticketSubject, ticketUrl);

                return await SendEmailAsync(toEmail, subject, body, isHtml: true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar notificación de mención a {Email}", toEmail);
                return false;
            }
        }

        private string GenerateMentionEmailTemplate(string userName, string ticketNumber, string ticketSubject, string ticketUrl)
        {
            return $@"
<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Mención en Ticket</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            background-color: #ffffff;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: #ffffff;
            padding: 25px;
            border-radius: 12px 12px 0 0;
            text-align: center;
            margin: -30px -30px 30px -30px;
        }}
        .header h1 {{
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }}
        .content {{
            margin: 20px 0;
        }}
        .ticket-info {{
            background-color: #f8f9fa;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }}
        .ticket-info strong {{
            color: #2196F3;
        }}
        .button {{
            display: inline-block;
            padding: 12px 30px;
            background-color: #2196F3;
            color: #ffffff !important;
            text-decoration: none;
            border-radius: 6px;
            margin: 20px 0;
            font-weight: 600;
            text-align: center;
        }}
        .button:hover {{
            background-color: #1976D2;
        }}
        .footer {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            text-align: center;
            color: #757575;
            font-size: 12px;
        }}
        .icon {{
            font-size: 48px;
            margin-bottom: 10px;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <div class='icon'>&#128276;</div>
            <h1>Te mencionaron en un comentario</h1>
        </div>

        <div class='content'>
            <p>Hola <strong>{userName}</strong>,</p>

            <p>Fuiste mencionado en un comentario del siguiente ticket:</p>

            <div class='ticket-info'>
                <p><strong>Ticket:</strong> #{ticketNumber}</p>
                <p><strong>Asunto:</strong> {ticketSubject}</p>
            </div>

            <p>Haz clic en el botón de abajo para ver el ticket y leer el comentario completo:</p>

            <div style='text-align: center;'>
                <a href='{ticketUrl}' class='button'>Ver Ticket</a>
            </div>

            <p style='color: #757575; font-size: 14px; margin-top: 20px;'>
                Si el botón no funciona, copia y pega este enlace en tu navegador:<br>
                <a href='{ticketUrl}' style='color: #2196F3;'>{ticketUrl}</a>
            </p>
        </div>

        <div class='footer'>
            <p>Este es un correo automático del Sistema de Tickets TI.</p>
            <p>Por favor, no respondas a este correo.</p>
        </div>
    </div>
</body>
</html>";
        }
    }
}
