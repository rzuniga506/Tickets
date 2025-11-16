-- =============================================
-- Migración: Agregar campo TipoSoporte a tabla Tickets
-- Fecha: 2025-01-16
-- Descripción: Agregar tipo de soporte (Soporte Técnico, Softland, Dodi, Otro)
-- =============================================

-- Agregar columna TipoSoporte
ALTER TABLE [dbo].[Tickets]
ADD [TipoSoporte] INT NOT NULL DEFAULT 0;

GO

-- Agregar comentario para documentación
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tipo de soporte: 0=Soporte Técnico, 1=Softland, 2=Dodi, 3=Otro',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'Tickets',
    @level2type = N'COLUMN', @level2name = N'TipoSoporte';

GO

-- Crear índice para mejorar consultas por tipo de soporte
CREATE NONCLUSTERED INDEX [IX_Tickets_TipoSoporte]
ON [dbo].[Tickets] ([TipoSoporte] ASC);

GO

PRINT 'Migración completada: Campo TipoSoporte agregado correctamente';
