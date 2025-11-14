namespace Tickets.Domain.Enums
{
    /// <summary>
    /// Tipos de notificación del sistema
    /// </summary>
    public enum TipoNotificacion
    {
        Sistema = 0,
        TicketNuevo = 1,
        TicketAsignado = 2,
        TicketActualizado = 3,
        TicketResuelto = 4,
        TicketComentario = 5,
        EquipoAsignado = 6,
        EquipoLiberado = 7,
        SoftwarePorVencer = 8,
        GarantiaPorVencer = 9,
        AlertaSLA = 10,
        Otro = 11
    }

    /// <summary>
    /// Prioridad de una notificación
    /// </summary>
    public enum PrioridadNotificacion
    {
        Baja = 0,
        Normal = 1,
        Alta = 2,
        Urgente = 3
    }

    /// <summary>
    /// Plataformas de dispositivos soportadas
    /// </summary>
    public enum PlataformaDispositivo
    {
        Android = 0,
        iOS = 1,
        Web = 2,
        Windows = 3,
        macOS = 4,
        Linux = 5
    }
}
