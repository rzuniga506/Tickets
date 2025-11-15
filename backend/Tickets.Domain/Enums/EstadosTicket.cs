namespace Tickets.Domain.Enums
{
    /// <summary>
    /// Prioridades de un ticket de soporte
    /// </summary>
    public enum PrioridadTicket
    {
        /// <summary>
        /// Prioridad baja - No urgente
        /// </summary>
        Baja = 1,

        /// <summary>
        /// Prioridad media - Importancia moderada
        /// </summary>
        Media = 2,

        /// <summary>
        /// Prioridad alta - Requiere atención pronta
        /// </summary>
        Alta = 3,

        /// <summary>
        /// Prioridad crítica - Requiere atención inmediata
        /// </summary>
        Critica = 4,

        /// <summary>
        /// Prioridad urgente - Alias de Crítica
        /// </summary>
        Urgente = 4
    }

    /// <summary>
    /// Estados del ciclo de vida de un ticket
    /// </summary>
    public enum EstadoTicket
    {
        /// <summary>
        /// Ticket recién creado, sin asignar
        /// </summary>
        Nuevo = 0,

        /// <summary>
        /// Ticket asignado a un técnico
        /// </summary>
        Asignado = 1,

        /// <summary>
        /// Ticket en proceso de resolución
        /// </summary>
        EnProceso = 2,

        /// <summary>
        /// Ticket en espera de información o recursos
        /// </summary>
        EnEspera = 3,

        /// <summary>
        /// Ticket resuelto, pendiente de cierre
        /// </summary>
        Resuelto = 4,

        /// <summary>
        /// Ticket cerrado definitivamente
        /// </summary>
        Cerrado = 5,

        /// <summary>
        /// Ticket cancelado
        /// </summary>
        Cancelado = 6,

        /// <summary>
        /// Ticket reabierto después de haber sido cerrado
        /// </summary>
        Reabierto = 7
    }

    /// <summary>
    /// Tipo de solución aplicada a un ticket
    /// </summary>
    public enum TipoSolucion
    {
        /// <summary>
        /// Problema completamente resuelto
        /// </summary>
        Resuelto = 0,

        /// <summary>
        /// Solución temporal o workaround
        /// </summary>
        Workaround = 1,

        /// <summary>
        /// No se pudo resolver
        /// </summary>
        NoResuelto = 2,

        /// <summary>
        /// Derivado a otra área o proveedor
        /// </summary>
        Derivado = 3
    }

    /// <summary>
    /// Tipo de comentario en un ticket
    /// </summary>
    public enum TipoComentario
    {
        Normal = 0,
        CambioEstado = 1,
        Reasignacion = 2,
        CambioPrioridad = 3,
        Solucion = 4,
        Seguimiento = 5
    }
}
