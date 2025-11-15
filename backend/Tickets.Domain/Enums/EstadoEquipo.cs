namespace Tickets.Domain.Enums
{
    /// <summary>
    /// Estados posibles de un equipo de inventario
    /// </summary>
    public enum EstadoEquipo
    {
        /// <summary>
        /// Equipo disponible para asignación
        /// </summary>
        Disponible = 0,

        /// <summary>
        /// Equipo asignado a un usuario
        /// </summary>
        Asignado = 1,

        /// <summary>
        /// Equipo actualmente en uso (alias de Asignado)
        /// </summary>
        EnUso = 1,

        /// <summary>
        /// Equipo en mantenimiento preventivo o correctivo
        /// </summary>
        EnMantenimiento = 2,

        /// <summary>
        /// Equipo en proceso de reparación
        /// </summary>
        EnReparacion = 3,

        /// <summary>
        /// Equipo dado de baja permanentemente
        /// </summary>
        DadoDeBaja = 4,

        /// <summary>
        /// Equipo reportado como perdido
        /// </summary>
        Perdido = 5,

        /// <summary>
        /// Equipo reportado como robado
        /// </summary>
        Robado = 6
    }

    /// <summary>
    /// Condición física del equipo
    /// </summary>
    public enum CondicionEquipo
    {
        /// <summary>
        /// Equipo nuevo sin uso
        /// </summary>
        Nuevo = 0,

        /// <summary>
        /// Equipo en excelente condición
        /// </summary>
        Excelente = 1,

        /// <summary>
        /// Equipo en buena condición
        /// </summary>
        Bueno = 2,

        /// <summary>
        /// Equipo en condición regular
        /// </summary>
        Regular = 3,

        /// <summary>
        /// Equipo en mala condición
        /// </summary>
        Malo = 4,

        /// <summary>
        /// Equipo no funcional
        /// </summary>
        NoFuncional = 5
    }

    /// <summary>
    /// Categorías de equipos
    /// </summary>
    public enum CategoriaEquipo
    {
        Computadoras = 0,
        Servidores = 1,
        Impresoras = 2,
        DispositivosRed = 3,
        Perifericos = 4,
        Componentes = 5,
        MovilesTablets = 6,
        Otros = 7
    }

    /// <summary>
    /// Alias de CategoriaEquipo para compatibilidad
    /// </summary>
    public enum TipoEquipo
    {
        Computadora = 0,
        Laptop = 1,
        Servidor = 2,
        Impresora = 3,
        Scanner = 4,
        Router = 5,
        Switch = 6,
        Firewall = 7,
        Monitor = 8,
        Teclado = 9,
        Mouse = 10,
        Telefono = 11,
        Tablet = 12,
        Otro = 99
    }
}
