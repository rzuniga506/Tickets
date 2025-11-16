-- ================================================
-- Script de Optimización de Base de Datos TicketsDB
-- Incluye: Índices, Stored Procedures y Vistas
-- ================================================

USE TicketsDB;
GO

-- Configurar opciones necesarias para índices filtrados
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT 'Creando Índices adicionales para optimización...';
GO

-- Índices para tabla Usuarios
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_Email_Activo' AND object_id = OBJECT_ID('Usuarios'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Usuarios_Email_Activo
    ON Usuarios(Email, Activo)
    INCLUDE (Nombre, Apellido);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_Activo_Departamento' AND object_id = OBJECT_ID('Usuarios'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Usuarios_Activo_Departamento
    ON Usuarios(Activo, DepartamentoId)
    WHERE Activo = 1;
END
GO

-- Índices para tabla Tickets (adicionales a los ya definidos en TicketConfiguration)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Tickets_CategoriaTicketId_Estado' AND object_id = OBJECT_ID('Tickets'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Tickets_CategoriaTicketId_Estado
    ON Tickets(CategoriaTicketId, Estado)
    INCLUDE (NumeroTicket, Asunto, Prioridad, FechaApertura);
END
GO

-- Índices para tabla Equipos
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_Estado_Tipo' AND object_id = OBJECT_ID('Equipos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Equipos_Estado_Tipo
    ON Equipos(Estado, Tipo)
    INCLUDE (CodigoInterno, Nombre, Modelo);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_FechaFinGarantia' AND object_id = OBJECT_ID('Equipos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Equipos_FechaFinGarantia
    ON Equipos(FechaFinGarantia)
    WHERE FechaFinGarantia IS NOT NULL AND Eliminado = 0;
END
GO

-- Índices para tabla Notificaciones
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Notificaciones_Usuario_Leida' AND object_id = OBJECT_ID('Notificaciones'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Notificaciones_Usuario_Leida
    ON Notificaciones(UsuarioId, Leida, FechaCreacion DESC)
    WHERE Leida = 0;
END
GO

-- Índices para tabla ComentariosTicket
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ComentariosTicket_Ticket_Fecha' AND object_id = OBJECT_ID('ComentariosTicket'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_ComentariosTicket_Ticket_Fecha
    ON ComentariosTicket(TicketId, FechaCreacion DESC);
END
GO

-- Índices para tabla HistorialEstadosTicket
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HistorialEstadosTicket_Ticket_Fecha' AND object_id = OBJECT_ID('HistorialEstadosTicket'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_HistorialEstadosTicket_Ticket_Fecha
    ON HistorialEstadosTicket(TicketId, FechaCreacion DESC);
END
GO

PRINT 'Índices adicionales creados exitosamente.';
GO

-- ================================================
-- STORED PROCEDURES
-- ================================================

PRINT 'Creando Stored Procedures...';
GO

-- SP 1: Dashboard - Estadísticas Generales
IF OBJECT_ID('SP_Dashboard_EstadisticasGenerales', 'P') IS NOT NULL
    DROP PROCEDURE SP_Dashboard_EstadisticasGenerales;
GO

CREATE PROCEDURE SP_Dashboard_EstadisticasGenerales
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Tickets
        (SELECT COUNT(*) FROM Tickets WHERE Eliminado = 0) AS TotalTickets,
        (SELECT COUNT(*) FROM Tickets WHERE Estado IN (0, 1, 2, 3, 7) AND Eliminado = 0) AS TicketsAbiertos,
        (SELECT COUNT(*) FROM Tickets WHERE Estado = 4 AND Eliminado = 0) AS TicketsResueltos,
        (SELECT COUNT(*) FROM Tickets WHERE FechaLimiteSLA IS NOT NULL
            AND FechaLimiteSLA < GETUTCDATE() AND Estado NOT IN (4, 5) AND Eliminado = 0) AS TicketsVencidos,

        -- Equipos
        (SELECT COUNT(*) FROM Equipos WHERE Eliminado = 0) AS TotalEquipos,
        (SELECT COUNT(*) FROM Equipos WHERE Estado = 0 AND Eliminado = 0) AS EquiposDisponibles,
        (SELECT COUNT(*) FROM Equipos WHERE Estado = 1 AND Eliminado = 0) AS EquiposAsignados,
        (SELECT COUNT(*) FROM Equipos WHERE Estado = 2 AND Eliminado = 0) AS EquiposEnMantenimiento,

        -- Usuarios
        (SELECT COUNT(*) FROM Usuarios WHERE Activo = 1 AND Eliminado = 0) AS UsuariosActivos,
        (SELECT COUNT(*) FROM Usuarios WHERE Eliminado = 0) AS TotalUsuarios;
END
GO

-- SP 2: Tickets por Técnico
IF OBJECT_ID('SP_Tickets_PorTecnico', 'P') IS NOT NULL
    DROP PROCEDURE SP_Tickets_PorTecnico;
GO

CREATE PROCEDURE SP_Tickets_PorTecnico
    @TecnicoId INT = NULL,
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.Nombre + ' ' + u.Apellido AS NombreTecnico,
        COUNT(t.Id) AS TotalTickets,
        SUM(CASE WHEN t.Estado IN (0, 1, 2, 3, 7) THEN 1 ELSE 0 END) AS TicketsAbiertos,
        SUM(CASE WHEN t.Estado = 4 THEN 1 ELSE 0 END) AS TicketsResueltos,
        SUM(CASE WHEN t.SLACumplido = 1 THEN 1 ELSE 0 END) AS TicketsConSLACumplido,
        AVG(CASE WHEN t.Estado = 4 AND t.FechaCierre IS NOT NULL
            THEN DATEDIFF(HOUR, t.FechaApertura, t.FechaCierre)
            ELSE NULL END) AS PromedioHorasResolucion
    FROM Usuarios u
    LEFT JOIN Tickets t ON u.Id = t.TecnicoAsignadoId
        AND t.Eliminado = 0
        AND (@FechaInicio IS NULL OR t.FechaApertura >= @FechaInicio)
        AND (@FechaFin IS NULL OR t.FechaApertura <= @FechaFin)
    WHERE u.Eliminado = 0
        AND (@TecnicoId IS NULL OR u.Id = @TecnicoId)
    GROUP BY u.Id, u.Nombre, u.Apellido
    ORDER BY TotalTickets DESC;
END
GO

-- SP 3: Tickets Próximos a Vencer SLA
IF OBJECT_ID('SP_Tickets_ProximosVencerSLA', 'P') IS NOT NULL
    DROP PROCEDURE SP_Tickets_ProximosVencerSLA;
GO

CREATE PROCEDURE SP_Tickets_ProximosVencerSLA
    @HorasAnticipacion INT = 24
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Id,
        t.NumeroTicket,
        t.Asunto,
        t.Prioridad,
        t.Estado,
        t.FechaApertura,
        t.FechaLimiteSLA,
        DATEDIFF(HOUR, GETUTCDATE(), t.FechaLimiteSLA) AS HorasRestantes,
        s.Nombre + ' ' + s.Apellido AS Solicitante,
        ISNULL(tec.Nombre + ' ' + tec.Apellido, 'Sin asignar') AS TecnicoAsignado,
        c.Nombre AS Categoria
    FROM Tickets t
    INNER JOIN Usuarios s ON t.SolicitanteId = s.Id
    LEFT JOIN Usuarios tec ON t.TecnicoAsignadoId = tec.Id
    LEFT JOIN CategoriasTicket c ON t.CategoriaTicketId = c.Id
    WHERE t.Eliminado = 0
        AND t.Estado NOT IN (4, 5) -- No incluir Resueltos ni Cerrados
        AND t.FechaLimiteSLA IS NOT NULL
        AND t.FechaLimiteSLA > GETUTCDATE()
        AND DATEDIFF(HOUR, GETUTCDATE(), t.FechaLimiteSLA) <= @HorasAnticipacion
    ORDER BY t.FechaLimiteSLA ASC;
END
GO

-- SP 4: Reporte de Productividad de Técnicos
IF OBJECT_ID('SP_Reporte_ProductividadTecnicos', 'P') IS NOT NULL
    DROP PROCEDURE SP_Reporte_ProductividadTecnicos;
GO

CREATE PROCEDURE SP_Reporte_ProductividadTecnicos
    @FechaInicio DATETIME,
    @FechaFin DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id AS TecnicoId,
        u.Nombre + ' ' + u.Apellido AS Tecnico,
        COUNT(t.Id) AS TotalTicketsAsignados,
        SUM(CASE WHEN t.Estado = 4 THEN 1 ELSE 0 END) AS TicketsResueltos,
        SUM(CASE WHEN t.Estado IN (0, 1, 2, 3, 7) THEN 1 ELSE 0 END) AS TicketsPendientes,
        SUM(CASE WHEN t.SLACumplido = 1 THEN 1 ELSE 0 END) AS TicketsConSLACumplido,
        CAST(SUM(CASE WHEN t.SLACumplido = 1 THEN 1 ELSE 0 END) * 100.0 /
            NULLIF(SUM(CASE WHEN t.FechaCierre IS NOT NULL THEN 1 ELSE 0 END), 0) AS DECIMAL(5,2)) AS PorcentajeSLACumplido,
        AVG(CASE WHEN t.FechaCierre IS NOT NULL
            THEN DATEDIFF(MINUTE, t.FechaApertura, t.FechaCierre)
            ELSE NULL END) AS PromedioMinutosResolucion,
        SUM(CASE WHEN t.FueReabierto = 1 THEN 1 ELSE 0 END) AS TicketsReabiertos
    FROM Usuarios u
    LEFT JOIN Tickets t ON u.Id = t.TecnicoAsignadoId
        AND t.Eliminado = 0
        AND t.FechaApertura >= @FechaInicio
        AND t.FechaApertura <= @FechaFin
    WHERE u.Eliminado = 0
    GROUP BY u.Id, u.Nombre, u.Apellido
    HAVING COUNT(t.Id) > 0
    ORDER BY TicketsResueltos DESC;
END
GO

-- SP 5: Reporte de Tickets por Categoría
IF OBJECT_ID('SP_Reporte_TicketsPorCategoria', 'P') IS NOT NULL
    DROP PROCEDURE SP_Reporte_TicketsPorCategoria;
GO

CREATE PROCEDURE SP_Reporte_TicketsPorCategoria
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.Id,
        c.Nombre AS Categoria,
        c.Color,
        c.Icono,
        COUNT(t.Id) AS TotalTickets,
        SUM(CASE WHEN t.Estado IN (0, 1, 2, 3, 7) THEN 1 ELSE 0 END) AS TicketsAbiertos,
        SUM(CASE WHEN t.Estado = 4 THEN 1 ELSE 0 END) AS TicketsResueltos,
        AVG(CASE WHEN t.FechaCierre IS NOT NULL
            THEN DATEDIFF(HOUR, t.FechaApertura, t.FechaCierre)
            ELSE NULL END) AS PromedioHorasResolucion,
        SUM(CASE WHEN t.Prioridad = 3 THEN 1 ELSE 0 END) AS TicketsUrgentes
    FROM CategoriasTicket c
    LEFT JOIN Tickets t ON c.Id = t.CategoriaTicketId
        AND t.Eliminado = 0
        AND (@FechaInicio IS NULL OR t.FechaApertura >= @FechaInicio)
        AND (@FechaFin IS NULL OR t.FechaApertura <= @FechaFin)
    WHERE c.Eliminado = 0 AND c.Activo = 1
    GROUP BY c.Id, c.Nombre, c.Color, c.Icono, c.Orden
    ORDER BY c.Orden, TotalTickets DESC;
END
GO

-- SP 6: Inventario - Resumen de Equipos
IF OBJECT_ID('SP_Inventario_ResumenEquipos', 'P') IS NOT NULL
    DROP PROCEDURE SP_Inventario_ResumenEquipos;
GO

CREATE PROCEDURE SP_Inventario_ResumenEquipos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Tipo,
        COUNT(*) AS TotalEquipos,
        SUM(CASE WHEN Estado = 0 THEN 1 ELSE 0 END) AS Disponibles,
        SUM(CASE WHEN Estado = 1 THEN 1 ELSE 0 END) AS Asignados,
        SUM(CASE WHEN Estado = 2 THEN 1 ELSE 0 END) AS EnMantenimiento,
        SUM(CASE WHEN Estado = 3 THEN 1 ELSE 0 END) AS Retirados,
        SUM(CASE WHEN CostoAdquisicion IS NOT NULL THEN CostoAdquisicion ELSE 0 END) AS ValorTotalAdquisicion,
        AVG(CASE WHEN FechaAdquisicion IS NOT NULL
            THEN DATEDIFF(MONTH, FechaAdquisicion, GETUTCDATE())
            ELSE NULL END) AS PromedioMesesUso
    FROM Equipos
    WHERE Eliminado = 0
    GROUP BY Tipo
    ORDER BY Tipo;
END
GO

-- SP 7: Equipos con Garantía Próxima a Vencer
IF OBJECT_ID('SP_Equipos_GarantiaProximaVencer', 'P') IS NOT NULL
    DROP PROCEDURE SP_Equipos_GarantiaProximaVencer;
GO

CREATE PROCEDURE SP_Equipos_GarantiaProximaVencer
    @DiasAnticipacion INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.CodigoInterno,
        e.Nombre,
        e.Modelo,
        e.Tipo,
        e.FechaInicioGarantia,
        e.FechaFinGarantia,
        DATEDIFF(DAY, GETUTCDATE(), e.FechaFinGarantia) AS DiasRestantes,
        ISNULL(u.Nombre + ' ' + u.Apellido, 'Sin asignar') AS UsuarioAsignado,
        d.Nombre AS Departamento
    FROM Equipos e
    LEFT JOIN Usuarios u ON e.UsuarioAsignadoId = u.Id
    LEFT JOIN Departamentos d ON e.DepartamentoAsignadoId = d.Id
    WHERE e.Eliminado = 0
        AND e.FechaFinGarantia IS NOT NULL
        AND e.FechaFinGarantia > GETUTCDATE()
        AND DATEDIFF(DAY, GETUTCDATE(), e.FechaFinGarantia) <= @DiasAnticipacion
    ORDER BY e.FechaFinGarantia ASC;
END
GO

-- SP 8: Historial Completo de un Ticket
IF OBJECT_ID('SP_Ticket_HistorialCompleto', 'P') IS NOT NULL
    DROP PROCEDURE SP_Ticket_HistorialCompleto;
GO

CREATE PROCEDURE SP_Ticket_HistorialCompleto
    @TicketId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Información del ticket
    SELECT
        t.*,
        s.Nombre + ' ' + s.Apellido AS NombreSolicitante,
        s.Email AS EmailSolicitante,
        ISNULL(tec.Nombre + ' ' + tec.Apellido, 'Sin asignar') AS NombreTecnico,
        c.Nombre AS NombreCategoria,
        c.Color AS ColorCategoria,
        e.CodigoInterno AS CodigoEquipo,
        e.Nombre AS NombreEquipo
    FROM Tickets t
    INNER JOIN Usuarios s ON t.SolicitanteId = s.Id
    LEFT JOIN Usuarios tec ON t.TecnicoAsignadoId = tec.Id
    LEFT JOIN CategoriasTicket c ON t.CategoriaTicketId = c.Id
    LEFT JOIN Equipos e ON t.EquipoId = e.Id
    WHERE t.Id = @TicketId AND t.Eliminado = 0;

    -- Historial de estados
    SELECT
        h.*,
        u.Nombre + ' ' + u.Apellido AS NombreUsuario
    FROM HistorialEstadosTicket h
    INNER JOIN Usuarios u ON h.UsuarioId = u.Id
    WHERE h.TicketId = @TicketId AND h.Eliminado = 0
    ORDER BY h.FechaCreacion DESC;

    -- Comentarios
    SELECT
        c.*,
        u.Nombre + ' ' + u.Apellido AS NombreUsuario
    FROM ComentariosTicket c
    INNER JOIN Usuarios u ON c.UsuarioId = u.Id
    WHERE c.TicketId = @TicketId AND c.Eliminado = 0
    ORDER BY c.FechaCreacion ASC;

    -- Adjuntos
    SELECT
        a.*,
        u.Nombre + ' ' + u.Apellido AS NombreUsuario
    FROM AdjuntosTicket a
    INNER JOIN Usuarios u ON a.UsuarioId = u.Id
    WHERE a.TicketId = @TicketId AND a.Eliminado = 0
    ORDER BY a.FechaCreacion DESC;
END
GO

-- SP 9: Notificaciones No Leídas
IF OBJECT_ID('SP_Notificaciones_NoLeidas', 'P') IS NOT NULL
    DROP PROCEDURE SP_Notificaciones_NoLeidas;
GO

CREATE PROCEDURE SP_Notificaciones_NoLeidas
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        n.*,
        t.NumeroTicket,
        t.Asunto AS AsuntoTicket
    FROM Notificaciones n
    LEFT JOIN Tickets t ON n.EntidadId = t.Id AND n.EntidadTipo = 'Ticket'
    WHERE n.UsuarioId = @UsuarioId
        AND n.Leida = 0
        AND n.Eliminado = 0
    ORDER BY n.FechaCreacion DESC;
END
GO

PRINT 'Stored Procedures creados exitosamente.';
GO

-- ================================================
-- VISTAS
-- ================================================

PRINT 'Creando Vistas...';
GO

-- Vista: Tickets Activos con Información Completa
IF OBJECT_ID('VW_TicketsActivos', 'V') IS NOT NULL
    DROP VIEW VW_TicketsActivos;
GO

CREATE VIEW VW_TicketsActivos
AS
SELECT
    t.Id,
    t.NumeroTicket,
    t.Asunto,
    t.Descripcion,
    t.Prioridad,
    t.Estado,
    t.FechaApertura,
    t.FechaLimiteSLA,
    t.FechaCierre,
    t.SLACumplido,
    t.FueReabierto,
    t.CantidadReaberturas,

    -- Solicitante
    t.SolicitanteId,
    s.Nombre + ' ' + s.Apellido AS NombreSolicitante,
    s.Email AS EmailSolicitante,

    -- Técnico
    t.TecnicoAsignadoId,
    ISNULL(tec.Nombre + ' ' + tec.Apellido, 'Sin asignar') AS NombreTecnico,

    -- Categoría
    t.CategoriaTicketId,
    c.Nombre AS NombreCategoria,
    c.Color AS ColorCategoria,
    c.Icono AS IconoCategoria,

    -- Equipo
    t.EquipoId,
    e.CodigoInterno AS CodigoEquipo,
    e.Nombre AS NombreEquipo,
    e.Modelo AS ModeloEquipo,

    -- Cálculos
    CASE
        WHEN t.FechaLimiteSLA IS NOT NULL AND t.FechaLimiteSLA < GETUTCDATE() AND t.Estado NOT IN (4, 5)
        THEN 1
        ELSE 0
    END AS EstaVencido,

    CASE
        WHEN t.FechaCierre IS NOT NULL
        THEN DATEDIFF(HOUR, t.FechaApertura, t.FechaCierre)
        ELSE DATEDIFF(HOUR, t.FechaApertura, GETUTCDATE())
    END AS HorasTranscurridas,

    t.FechaCreacion,
    t.FechaModificacion
FROM Tickets t
INNER JOIN Usuarios s ON t.SolicitanteId = s.Id
LEFT JOIN Usuarios tec ON t.TecnicoAsignadoId = tec.Id
LEFT JOIN CategoriasTicket c ON t.CategoriaTicketId = c.Id
LEFT JOIN Equipos e ON t.EquipoId = e.Id
WHERE t.Eliminado = 0
    AND t.Estado NOT IN (5); -- Excluir Cerrados
GO

PRINT 'Vistas creadas exitosamente.';
GO

-- ================================================
-- Resumen final
-- ================================================

PRINT '================================================';
PRINT 'Base de datos optimizada completamente!';
PRINT 'Índices adicionales: 8';
PRINT 'Stored Procedures: 9';
PRINT 'Vistas: 1';
PRINT '================================================';
GO
