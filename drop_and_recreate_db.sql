-- Script para eliminar y recrear la base de datos TicketsDB
USE master;
GO

-- Cerrar todas las conexiones activas a la base de datos
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'TicketsDB')
BEGIN
    ALTER DATABASE TicketsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TicketsDB;
END
GO

-- Crear la base de datos nuevamente
CREATE DATABASE TicketsDB;
GO

PRINT 'Base de datos TicketsDB eliminada y recreada exitosamente';
GO
