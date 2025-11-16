-- =============================================
-- Migración: Agregar campos de inventario detallado a Equipos
-- Fecha: 2025-01-16
-- Descripción: Agrega campos específicos para gestión profesional de inventario IT
-- =============================================

-- Verificar que la tabla existe
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND type in (N'U'))
BEGIN
    RAISERROR ('La tabla Equipos no existe', 16, 1)
    RETURN
END
GO

-- =============================================
-- CAMPOS COMUNES (Todos los tipos de equipo)
-- =============================================

-- Información del fabricante y proveedor
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'Marca')
    ALTER TABLE [dbo].[Equipos] ADD [Marca] NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'Proveedor')
    ALTER TABLE [dbo].[Equipos] ADD [Proveedor] NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'SKU')
    ALTER TABLE [dbo].[Equipos] ADD [SKU] NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'NumeroOrdenCompra')
    ALTER TABLE [dbo].[Equipos] ADD [NumeroOrdenCompra] NVARCHAR(50) NULL;

-- Ubicación física
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'UbicacionFisica')
    ALTER TABLE [dbo].[Equipos] ADD [UbicacionFisica] NVARCHAR(200) NULL;

-- =============================================
-- CAMPOS ESPECÍFICOS - COMPUTADORAS/LAPTOPS
-- =============================================

-- Hardware - Procesador
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'Procesador')
    ALTER TABLE [dbo].[Equipos] ADD [Procesador] NVARCHAR(150) NULL;

-- Hardware - RAM
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'RamGB')
    ALTER TABLE [dbo].[Equipos] ADD [RamGB] INT NULL;

-- Hardware - Almacenamiento
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'DiscoDuroCapacidadGB')
    ALTER TABLE [dbo].[Equipos] ADD [DiscoDuroCapacidadGB] INT NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'TipoAlmacenamiento')
    ALTER TABLE [dbo].[Equipos] ADD [TipoAlmacenamiento] NVARCHAR(50) NULL; -- SSD, HDD, NVMe

-- Red
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'MacAddress')
    ALTER TABLE [dbo].[Equipos] ADD [MacAddress] NVARCHAR(17) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'DireccionIP')
    ALTER TABLE [dbo].[Equipos] ADD [DireccionIP] NVARCHAR(45) NULL; -- IPv4 o IPv6

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'Hostname')
    ALTER TABLE [dbo].[Equipos] ADD [Hostname] NVARCHAR(100) NULL;

-- Sistema Operativo
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'SistemaOperativo')
    ALTER TABLE [dbo].[Equipos] ADD [SistemaOperativo] NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'VersionSO')
    ALTER TABLE [dbo].[Equipos] ADD [VersionSO] NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Equipos]') AND name = 'LicenciaSO')
    ALTER TABLE [dbo].[Equipos] ADD [LicenciaSO] NVARCHAR(200) NULL;

-- =============================================
-- ÍNDICES para mejorar rendimiento de búsquedas
-- =============================================

-- Índice por Marca (búsquedas frecuentes)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_Marca' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_Marca] ON [dbo].[Equipos]([Marca]) WHERE [Marca] IS NOT NULL;

-- Índice por MAC Address (búsquedas de red)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_MacAddress' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_MacAddress] ON [dbo].[Equipos]([MacAddress]) WHERE [MacAddress] IS NOT NULL;

-- Índice por IP (búsquedas de red)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_DireccionIP' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_DireccionIP] ON [dbo].[Equipos]([DireccionIP]) WHERE [DireccionIP] IS NOT NULL;

-- Índice por Hostname
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_Hostname' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_Hostname] ON [dbo].[Equipos]([Hostname]) WHERE [Hostname] IS NOT NULL;

-- Índice por SKU
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_SKU' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_SKU] ON [dbo].[Equipos]([SKU]) WHERE [SKU] IS NOT NULL;

-- Índice compuesto para reportes de inventario por tipo y marca
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Equipos_Tipo_Marca' AND object_id = OBJECT_ID(N'[dbo].[Equipos]'))
    CREATE NONCLUSTERED INDEX [IX_Equipos_Tipo_Marca] ON [dbo].[Equipos]([Tipo], [Marca]) INCLUDE ([RamGB], [DiscoDuroCapacidadGB]);

GO

PRINT 'Migración completada exitosamente: Campos de inventario agregados a tabla Equipos';
GO
