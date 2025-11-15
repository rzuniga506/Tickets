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
        TicketEnProceso = 3,
        TicketActualizado = 4,
        TicketResuelto = 5,
        TicketComentario = 6,
        EquipoAsignado = 7,
        EquipoLiberado = 8,
        SoftwarePorVencer = 9,
        GarantiaPorVencer = 10,
        AlertaSLA = 11,
        SLAProximoVencer = 12,
        Otro = 99
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
