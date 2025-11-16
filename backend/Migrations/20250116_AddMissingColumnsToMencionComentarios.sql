-- =============================================
-- Script: Agregar columnas faltantes a MencionComentarios
-- Descripción: Agrega CreadoPor, ModificadoPor y Eliminado que hereda de BaseEntity
-- Fecha: 2025-01-16
-- =============================================

USE TicketsDB;
GO

-- Agregar columna CreadoPor si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = 'CreadoPor')
BEGIN
    ALTER TABLE [dbo].[MencionComentarios]
    ADD [CreadoPor] NVARCHAR(256) NULL;
    PRINT 'Columna CreadoPor agregada a MencionComentarios';
END
ELSE
BEGIN
    PRINT 'Columna CreadoPor ya existe en MencionComentarios';
END
GO

-- Agregar columna ModificadoPor si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = 'ModificadoPor')
BEGIN
    ALTER TABLE [dbo].[MencionComentarios]
    ADD [ModificadoPor] NVARCHAR(256) NULL;
    PRINT 'Columna ModificadoPor agregada a MencionComentarios';
END
ELSE
BEGIN
    PRINT 'Columna ModificadoPor ya existe en MencionComentarios';
END
GO

-- Agregar columna Eliminado si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = 'Eliminado')
BEGIN
    ALTER TABLE [dbo].[MencionComentarios]
    ADD [Eliminado] BIT NOT NULL DEFAULT 0;
    PRINT 'Columna Eliminado agregada a MencionComentarios';
END
ELSE
BEGIN
    PRINT 'Columna Eliminado ya existe en MencionComentarios';
END
GO

PRINT 'Migración completada: Columnas de auditoría agregadas a MencionComentarios';
GO
