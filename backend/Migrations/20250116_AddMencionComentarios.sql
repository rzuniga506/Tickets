-- =============================================
-- Script: Agregar sistema de menciones en comentarios
-- Descripción: Crea tabla MencionComentarios para tracking de @menciones
-- Fecha: 2025-01-16
-- =============================================

-- Crear tabla MencionComentarios
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[MencionComentarios](
        [Id] INT IDENTITY(1,1) NOT NULL,
        [ComentarioTicketId] INT NOT NULL,
        [UsuarioMencionadoId] INT NOT NULL,
        [Leida] BIT NOT NULL DEFAULT 0,
        [FechaLeida] DATETIME2(7) NULL,
        [FechaCreacion] DATETIME2(7) NOT NULL DEFAULT GETDATE(),
        [FechaModificacion] DATETIME2(7) NULL,
        CONSTRAINT [PK_MencionComentarios] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
END
GO

-- Agregar foreign keys
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MencionComentarios_ComentariosTicket_ComentarioTicketId]') AND parent_object_id = OBJECT_ID(N'[dbo].[MencionComentarios]'))
BEGIN
    ALTER TABLE [dbo].[MencionComentarios] WITH CHECK ADD CONSTRAINT [FK_MencionComentarios_ComentariosTicket_ComentarioTicketId]
    FOREIGN KEY([ComentarioTicketId])
    REFERENCES [dbo].[ComentariosTicket] ([Id])
    ON DELETE CASCADE
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_MencionComentarios_Usuarios_UsuarioMencionadoId]') AND parent_object_id = OBJECT_ID(N'[dbo].[MencionComentarios]'))
BEGIN
    ALTER TABLE [dbo].[MencionComentarios] WITH CHECK ADD CONSTRAINT [FK_MencionComentarios_Usuarios_UsuarioMencionadoId]
    FOREIGN KEY([UsuarioMencionadoId])
    REFERENCES [dbo].[Usuarios] ([Id])
    ON DELETE NO ACTION
END
GO

-- Crear índices para optimizar consultas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = N'IX_MencionComentarios_ComentarioTicketId')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MencionComentarios_ComentarioTicketId] ON [dbo].[MencionComentarios]
    (
        [ComentarioTicketId] ASC
    )
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = N'IX_MencionComentarios_UsuarioMencionadoId')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MencionComentarios_UsuarioMencionadoId] ON [dbo].[MencionComentarios]
    (
        [UsuarioMencionadoId] ASC
    )
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MencionComentarios]') AND name = N'IX_MencionComentarios_Leida')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_MencionComentarios_Leida] ON [dbo].[MencionComentarios]
    (
        [Leida] ASC
    )
    INCLUDE([UsuarioMencionadoId], [FechaCreacion])
END
GO

PRINT 'Migración completada: Tabla MencionComentarios creada con índices'
GO
