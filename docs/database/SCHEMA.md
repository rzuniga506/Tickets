# 🗄️ Esquema de Base de Datos

## Índice
1. [Diagrama ER General](#diagrama-er-general)
2. [Tablas por Módulo](#tablas-por-módulo)
3. [Scripts SQL](#scripts-sql)
4. [Relaciones](#relaciones)
5. [Índices](#índices)
6. [Vistas](#vistas)
7. [Stored Procedures](#stored-procedures)

---

## Diagrama ER General

```
┌─────────────────────────────────────────────────────────────┐
│                   MÓDULO DE AUTENTICACIÓN                    │
├─────────────────────────────────────────────────────────────┤
│ Usuarios ─┬─ UsuarioRoles ─── Roles ─── RolPermisos ─── Permisos
│           ├─ RefreshTokens                                   │
│           ├─ DispositivosUsuario                             │
│           └─ PreferenciasNotificacion                        │
│                                                              │
│ Departamentos ──< Usuarios                                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   MÓDULO DE INVENTARIOS                      │
├─────────────────────────────────────────────────────────────┤
│ TiposEquipo ──< Equipos >── Marcas                          │
│                  ├── HistorialMovimientos                    │
│                  ├── DocumentosEquipo                        │
│                  ├── MantenimientosEquipo                    │
│                  ├── EquipoSoftware >── Software             │
│                  └── Tickets                                 │
│                                                              │
│ Ubicaciones ──< Equipos                                      │
│ Proveedores ──< Equipos                                      │
│             └─< Software                                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   MÓDULO DE TICKETS                          │
├─────────────────────────────────────────────────────────────┤
│ CategoriasTicket ──< Tickets >── Usuarios (Solicitante)     │
│                      ├── Usuarios (Técnico)                  │
│                      ├── ComentariosTicket                   │
│                      ├── AdjuntosTicket                      │
│                      ├── HistorialEstadosTicket              │
│                      └── Equipos                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   MÓDULOS ADICIONALES                        │
├─────────────────────────────────────────────────────────────┤
│ Notificaciones ──> Usuarios                                  │
│ Ubicaciones (jerarquía)                                      │
│ Proveedores ─┬─ ContratosProveedor                          │
│              └─ EvaluacionesProveedor                        │
│ LogsAuditoria                                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Tablas por Módulo

### AUTENTICACIÓN Y USUARIOS

#### Usuarios
```sql
CREATE TABLE Usuarios (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(500) NOT NULL,
    Telefono NVARCHAR(20),
    Activo BIT NOT NULL DEFAULT 1,
    UltimoAcceso DATETIME2,

    DepartamentoId INT,

    -- Auditoría
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Usuarios_Departamentos FOREIGN KEY (DepartamentoId)
        REFERENCES Departamentos(Id)
);

CREATE INDEX IX_Usuarios_Email ON Usuarios(Email);
CREATE INDEX IX_Usuarios_Activo ON Usuarios(Activo);
```

#### Roles
```sql
CREATE TABLE Roles (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(500),
    EsSistema BIT NOT NULL DEFAULT 0, -- No se puede eliminar

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);
```

#### Permisos
```sql
CREATE TABLE Permisos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo NVARCHAR(100) NOT NULL UNIQUE,  -- 'inventario.read'
    Nombre NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(500),
    Modulo NVARCHAR(50) NOT NULL,          -- 'Inventario', 'Tickets', etc.

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);

CREATE INDEX IX_Permisos_Modulo ON Permisos(Modulo);
```

#### UsuarioRoles (Tabla Intermedia)
```sql
CREATE TABLE UsuarioRoles (
    UsuarioId INT NOT NULL,
    RolId INT NOT NULL,

    PRIMARY KEY (UsuarioId, RolId),

    CONSTRAINT FK_UsuarioRoles_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioRoles_Roles FOREIGN KEY (RolId)
        REFERENCES Roles(Id) ON DELETE CASCADE
);
```

#### RolPermisos (Tabla Intermedia)
```sql
CREATE TABLE RolPermisos (
    RolId INT NOT NULL,
    PermisoId INT NOT NULL,

    PRIMARY KEY (RolId, PermisoId),

    CONSTRAINT FK_RolPermisos_Roles FOREIGN KEY (RolId)
        REFERENCES Roles(Id) ON DELETE CASCADE,
    CONSTRAINT FK_RolPermisos_Permisos FOREIGN KEY (PermisoId)
        REFERENCES Permisos(Id) ON DELETE CASCADE
);
```

#### RefreshTokens
```sql
CREATE TABLE RefreshTokens (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Token NVARCHAR(500) NOT NULL UNIQUE,
    Expiracion DATETIME2 NOT NULL,
    Revocado BIT NOT NULL DEFAULT 0,
    FechaRevocacion DATETIME2,
    DispositivoInfo NVARCHAR(500),

    UsuarioId INT NOT NULL,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_RefreshTokens_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id) ON DELETE CASCADE
);

CREATE INDEX IX_RefreshTokens_Token ON RefreshTokens(Token);
CREATE INDEX IX_RefreshTokens_Usuario_Expiracion
    ON RefreshTokens(UsuarioId, Expiracion);
```

#### Departamentos
```sql
CREATE TABLE Departamentos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(500),
    Codigo NVARCHAR(20) UNIQUE,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);
```

---

### INVENTARIOS

#### TiposEquipo
```sql
CREATE TABLE TiposEquipo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    Icono NVARCHAR(100),
    Categoria INT NOT NULL,  -- 0=Computadoras, 1=Servidores, etc.
    PlantillaEspecificaciones NVARCHAR(MAX), -- JSON Schema

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);
```

#### Marcas
```sql
CREATE TABLE Marcas (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(500),
    PaisOrigen NVARCHAR(100),
    SitioWeb NVARCHAR(200),
    LogoUrl NVARCHAR(500),

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);
```

#### Equipos
```sql
CREATE TABLE Equipos (
    Id INT PRIMARY KEY IDENTITY(1,1),

    -- Identificación
    CodigoInterno NVARCHAR(50) NOT NULL UNIQUE,
    NumeroSerie NVARCHAR(100),
    Nombre NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(1000),
    CodigoQR NVARCHAR(100) UNIQUE,

    -- Clasificación
    TipoEquipoId INT NOT NULL,
    MarcaId INT,
    Modelo NVARCHAR(150),
    EspecificacionesJson NVARCHAR(MAX), -- JSON flexible

    -- Estado
    Estado INT NOT NULL DEFAULT 0, -- 0=Disponible, 1=EnUso, 2=EnMantenimiento, etc.
    Condicion INT NOT NULL DEFAULT 1, -- 0=Nuevo, 1=Excelente, 2=Bueno, etc.

    -- Financiero
    CostoAdquisicion DECIMAL(18,2),
    FechaAdquisicion DATE,
    VidaUtilMeses INT DEFAULT 36,
    ValorResidual DECIMAL(18,2),

    -- Garantía
    FechaInicioGarantia DATE,
    FechaFinGarantia DATE,
    ProveedorId INT,

    -- Ubicación
    UbicacionId INT,

    -- Asignación
    UsuarioAsignadoId INT,
    FechaAsignacion DATETIME2,
    DepartamentoAsignadoId INT,

    Observaciones NVARCHAR(2000),

    -- Auditoría
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Equipos_TiposEquipo FOREIGN KEY (TipoEquipoId)
        REFERENCES TiposEquipo(Id),
    CONSTRAINT FK_Equipos_Marcas FOREIGN KEY (MarcaId)
        REFERENCES Marcas(Id),
    CONSTRAINT FK_Equipos_Proveedores FOREIGN KEY (ProveedorId)
        REFERENCES Proveedores(Id),
    CONSTRAINT FK_Equipos_Ubicaciones FOREIGN KEY (UbicacionId)
        REFERENCES Ubicaciones(Id),
    CONSTRAINT FK_Equipos_UsuariosAsignados FOREIGN KEY (UsuarioAsignadoId)
        REFERENCES Usuarios(Id),
    CONSTRAINT FK_Equipos_Departamentos FOREIGN KEY (DepartamentoAsignadoId)
        REFERENCES Departamentos(Id)
);

CREATE INDEX IX_Equipos_CodigoInterno ON Equipos(CodigoInterno);
CREATE INDEX IX_Equipos_Estado_TipoEquipo ON Equipos(Estado, TipoEquipoId);
CREATE INDEX IX_Equipos_UsuarioAsignado ON Equipos(UsuarioAsignadoId)
    WHERE UsuarioAsignadoId IS NOT NULL;
CREATE INDEX IX_Equipos_Ubicacion ON Equipos(UbicacionId)
    WHERE UbicacionId IS NOT NULL;
CREATE INDEX IX_Equipos_CodigoQR ON Equipos(CodigoQR);
```

#### Software
```sql
CREATE TABLE Software (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(200) NOT NULL,
    Version NVARCHAR(50),
    Fabricante NVARCHAR(150),
    Tipo INT NOT NULL, -- 0=SistemaOperativo, 1=Aplicacion, etc.
    TipoLicencia INT NOT NULL, -- 0=Perpetua, 1=Suscripcion, etc.
    Descripcion NVARCHAR(1000),

    -- Licenciamiento
    CantidadLicencias INT,
    LicenciasEnUso INT DEFAULT 0,
    CostoLicencia DECIMAL(18,2),
    FechaCompra DATE,
    FechaVencimiento DATE,
    AlertarVencimiento BIT DEFAULT 1,
    DiasAntesAlertar INT DEFAULT 30,

    ClaveProducto NVARCHAR(500), -- Encriptada
    Observaciones NVARCHAR(2000),

    ProveedorId INT,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Software_Proveedores FOREIGN KEY (ProveedorId)
        REFERENCES Proveedores(Id)
);

CREATE INDEX IX_Software_FechaVencimiento ON Software(FechaVencimiento)
    WHERE FechaVencimiento IS NOT NULL;
```

#### EquipoSoftware (Tabla Intermedia)
```sql
CREATE TABLE EquipoSoftware (
    Id INT PRIMARY KEY IDENTITY(1,1),
    EquipoId INT NOT NULL,
    SoftwareId INT NOT NULL,
    FechaInstalacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    VersionInstalada NVARCHAR(50),
    ClaveActivacion NVARCHAR(500),
    Observaciones NVARCHAR(1000),

    CONSTRAINT FK_EquipoSoftware_Equipos FOREIGN KEY (EquipoId)
        REFERENCES Equipos(Id) ON DELETE CASCADE,
    CONSTRAINT FK_EquipoSoftware_Software FOREIGN KEY (SoftwareId)
        REFERENCES Software(Id) ON DELETE CASCADE
);

CREATE INDEX IX_EquipoSoftware_Equipo ON EquipoSoftware(EquipoId);
CREATE INDEX IX_EquipoSoftware_Software ON EquipoSoftware(SoftwareId);
```

#### HistorialMovimientos
```sql
CREATE TABLE HistorialMovimientos (
    Id INT PRIMARY KEY IDENTITY(1,1),
    EquipoId INT NOT NULL,
    Tipo INT NOT NULL, -- 0=Asignacion, 1=Reasignacion, etc.

    -- Estado anterior
    EstadoAnterior INT,
    UbicacionAnteriorId INT,
    UsuarioAnteriorId INT,

    -- Estado nuevo
    EstadoNuevo INT,
    UbicacionNuevaId INT,
    UsuarioNuevoId INT,

    Motivo NVARCHAR(500),
    Observaciones NVARCHAR(2000),
    FechaMovimiento DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    RegistradoPorId INT NOT NULL,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_HistorialMovimientos_Equipos FOREIGN KEY (EquipoId)
        REFERENCES Equipos(Id) ON DELETE CASCADE,
    CONSTRAINT FK_HistorialMovimientos_RegistradoPor FOREIGN KEY (RegistradoPorId)
        REFERENCES Usuarios(Id)
);

CREATE INDEX IX_HistorialMovimientos_Equipo_Fecha
    ON HistorialMovimientos(EquipoId, FechaMovimiento DESC);
```

#### DocumentosEquipo
```sql
CREATE TABLE DocumentosEquipo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    EquipoId INT NOT NULL,
    Nombre NVARCHAR(200) NOT NULL,
    Tipo INT NOT NULL, -- 0=Factura, 1=Garantia, 2=Manual, etc.
    RutaArchivo NVARCHAR(500) NOT NULL,
    Extension NVARCHAR(10),
    TamanoBytes BIGINT,
    Descripcion NVARCHAR(1000),

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_DocumentosEquipo_Equipos FOREIGN KEY (EquipoId)
        REFERENCES Equipos(Id) ON DELETE CASCADE
);
```

---

### TICKETS

#### CategoriasTicket
```sql
CREATE TABLE CategoriasTicket (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    Icono NVARCHAR(100),
    Color NVARCHAR(20),

    -- SLA
    TiempoRespuestaMinutos INT DEFAULT 60,
    TiempoResolucionMinutos INT DEFAULT 480,

    -- Asignación automática
    AsignacionAutomatica BIT DEFAULT 0,
    GrupoTecnicosId INT,

    Activa BIT NOT NULL DEFAULT 1,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);
```

#### Tickets
```sql
CREATE TABLE Tickets (
    Id INT PRIMARY KEY IDENTITY(1,1),

    -- Identificación
    NumeroTicket NVARCHAR(50) NOT NULL UNIQUE,
    Asunto NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,

    -- Clasificación
    CategoriaId INT NOT NULL,
    Prioridad INT NOT NULL, -- 1=Baja, 2=Media, 3=Alta, 4=Critica
    Estado INT NOT NULL DEFAULT 0, -- 0=Nuevo, 1=Asignado, etc.

    -- Solicitante
    SolicitanteId INT NOT NULL,

    -- Asignación
    TecnicoAsignadoId INT,
    FechaAsignacion DATETIME2,

    -- Fechas
    FechaApertura DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaInicioProceso DATETIME2,
    FechaResolucion DATETIME2,
    FechaCierre DATETIME2,
    MinutosInvertidos INT,

    -- SLA
    FechaLimiteSLA DATETIME2,
    SLACumplido BIT DEFAULT 0,
    MinutosRestantesSLA INT,

    -- Equipo relacionado
    EquipoId INT,

    -- Ubicación
    UbicacionId INT,

    -- Evaluación
    CalificacionServicio INT, -- 1-5
    ComentarioEvaluacion NVARCHAR(1000),
    FechaEvaluacion DATETIME2,

    -- Solución
    Solucion NVARCHAR(MAX),
    TipoSolucion INT, -- 0=Resuelto, 1=Workaround, etc.

    -- Reaperturas
    FueReabierto BIT DEFAULT 0,
    CantidadReaberturas INT DEFAULT 0,

    -- Auditoría
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Tickets_Categorias FOREIGN KEY (CategoriaId)
        REFERENCES CategoriasTicket(Id),
    CONSTRAINT FK_Tickets_Solicitantes FOREIGN KEY (SolicitanteId)
        REFERENCES Usuarios(Id),
    CONSTRAINT FK_Tickets_Tecnicos FOREIGN KEY (TecnicoAsignadoId)
        REFERENCES Usuarios(Id),
    CONSTRAINT FK_Tickets_Equipos FOREIGN KEY (EquipoId)
        REFERENCES Equipos(Id),
    CONSTRAINT FK_Tickets_Ubicaciones FOREIGN KEY (UbicacionId)
        REFERENCES Ubicaciones(Id)
);

CREATE INDEX IX_Tickets_NumeroTicket ON Tickets(NumeroTicket);
CREATE INDEX IX_Tickets_Estado_FechaApertura
    ON Tickets(Estado, FechaApertura DESC)
    INCLUDE (NumeroTicket, Asunto, Prioridad);
CREATE INDEX IX_Tickets_TecnicoAsignado_Estado
    ON Tickets(TecnicoAsignadoId, Estado);
CREATE INDEX IX_Tickets_Solicitante ON Tickets(SolicitanteId);
CREATE INDEX IX_Tickets_FechaLimiteSLA
    ON Tickets(FechaLimiteSLA)
    WHERE FechaLimiteSLA IS NOT NULL AND Estado NOT IN (4, 5); -- No cerrados
```

#### ComentariosTicket
```sql
CREATE TABLE ComentariosTicket (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL,
    AutorId INT NOT NULL,
    Contenido NVARCHAR(MAX) NOT NULL,
    EsInterno BIT DEFAULT 0,
    FechaComentario DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Tipo INT NOT NULL DEFAULT 0, -- 0=Normal, 1=CambioEstado, etc.

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_ComentariosTicket_Tickets FOREIGN KEY (TicketId)
        REFERENCES Tickets(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ComentariosTicket_Autores FOREIGN KEY (AutorId)
        REFERENCES Usuarios(Id)
);

CREATE INDEX IX_ComentariosTicket_Ticket_Fecha
    ON ComentariosTicket(TicketId, FechaComentario);
```

#### AdjuntosTicket
```sql
CREATE TABLE AdjuntosTicket (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL,
    NombreArchivo NVARCHAR(200) NOT NULL,
    RutaArchivo NVARCHAR(500) NOT NULL,
    Extension NVARCHAR(10),
    TamanoBytes BIGINT,
    TipoMime NVARCHAR(100),
    SubidoPorId INT NOT NULL,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_AdjuntosTicket_Tickets FOREIGN KEY (TicketId)
        REFERENCES Tickets(Id) ON DELETE CASCADE,
    CONSTRAINT FK_AdjuntosTicket_Usuarios FOREIGN KEY (SubidoPorId)
        REFERENCES Usuarios(Id)
);
```

#### HistorialEstadosTicket
```sql
CREATE TABLE HistorialEstadosTicket (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL,

    EstadoAnterior INT,
    EstadoNuevo INT,
    PrioridadAnterior INT,
    PrioridadNueva INT,
    TecnicoAnteriorId INT,
    TecnicoNuevoId INT,

    Motivo NVARCHAR(500),
    FechaCambio DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    ModificadoPorId INT NOT NULL,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_HistorialEstadosTicket_Tickets FOREIGN KEY (TicketId)
        REFERENCES Tickets(Id) ON DELETE CASCADE,
    CONSTRAINT FK_HistorialEstadosTicket_Modificadores FOREIGN KEY (ModificadoPorId)
        REFERENCES Usuarios(Id)
);

CREATE INDEX IX_HistorialEstadosTicket_Ticket_Fecha
    ON HistorialEstadosTicket(TicketId, FechaCambio DESC);
```

---

### MÓDULOS ADICIONALES

#### Ubicaciones
```sql
CREATE TABLE Ubicaciones (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(150) NOT NULL,
    Codigo NVARCHAR(50) UNIQUE,
    Descripcion NVARCHAR(500),
    Tipo INT NOT NULL, -- 0=Pais, 1=Ciudad, 2=Edificio, etc.

    -- Jerarquía
    UbicacionPadreId INT,

    -- Información adicional
    Direccion NVARCHAR(300),
    Ciudad NVARCHAR(100),
    Pais NVARCHAR(100),
    CodigoPostal NVARCHAR(20),

    -- Coordenadas
    Latitud DECIMAL(10,8),
    Longitud DECIMAL(11,8),

    -- Contacto
    TelefonoContacto NVARCHAR(20),
    EmailContacto NVARCHAR(150),
    ResponsableId INT,

    -- Capacidad
    CapacidadPersonas INT,
    CapacidadEquipos INT,

    Activa BIT NOT NULL DEFAULT 1,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Ubicaciones_UbicacionPadre FOREIGN KEY (UbicacionPadreId)
        REFERENCES Ubicaciones(Id),
    CONSTRAINT FK_Ubicaciones_Responsables FOREIGN KEY (ResponsableId)
        REFERENCES Usuarios(Id)
);

CREATE INDEX IX_Ubicaciones_Codigo ON Ubicaciones(Codigo);
CREATE INDEX IX_Ubicaciones_Padre ON Ubicaciones(UbicacionPadreId);
```

#### Proveedores
```sql
CREATE TABLE Proveedores (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(200) NOT NULL,
    RazonSocial NVARCHAR(300),
    RFC NVARCHAR(20),
    Tipo INT NOT NULL, -- 0=Hardware, 1=Software, etc.

    -- Contacto
    Direccion NVARCHAR(300),
    Ciudad NVARCHAR(100),
    Pais NVARCHAR(100),
    CodigoPostal NVARCHAR(20),
    Telefono NVARCHAR(20),
    Email NVARCHAR(150),
    SitioWeb NVARCHAR(200),

    NombreContactoPrincipal NVARCHAR(150),
    TelefonoContacto NVARCHAR(20),
    EmailContacto NVARCHAR(150),

    -- Información comercial
    NumeroProveedor NVARCHAR(50) UNIQUE,
    CondicionesPago NVARCHAR(500),
    DiasPago INT DEFAULT 30,
    RequiereOrdenCompra BIT DEFAULT 0,

    -- Evaluación
    CalificacionPromedio DECIMAL(3,2),
    CantidadEvaluaciones INT DEFAULT 0,

    Activo BIT NOT NULL DEFAULT 1,
    Preferente BIT DEFAULT 0,
    Observaciones NVARCHAR(2000),

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0
);

CREATE INDEX IX_Proveedores_Nombre ON Proveedores(Nombre);
CREATE INDEX IX_Proveedores_RFC ON Proveedores(RFC);
```

#### Notificaciones
```sql
CREATE TABLE Notificaciones (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Titulo NVARCHAR(200) NOT NULL,
    Mensaje NVARCHAR(1000) NOT NULL,
    Tipo INT NOT NULL,
    Prioridad INT NOT NULL DEFAULT 1,

    UsuarioId INT NOT NULL,

    -- Estado
    Leida BIT DEFAULT 0,
    FechaLeida DATETIME2,
    Enviada BIT DEFAULT 0,
    FechaEnvio DATETIME2,

    -- Metadata
    EntidadTipo NVARCHAR(50),
    EntidadId INT,
    Accion NVARCHAR(50),
    DatosJson NVARCHAR(MAX),
    UrlAccion NVARCHAR(500),
    IconoUrl NVARCHAR(500),

    -- Canales
    EnviarPush BIT DEFAULT 1,
    EnviarEmail BIT DEFAULT 0,
    MostrarInApp BIT DEFAULT 1,

    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FechaModificacion DATETIME2,
    CreadoPor NVARCHAR(150),
    ModificadoPor NVARCHAR(150),
    Eliminado BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Notificaciones_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id) ON DELETE CASCADE
);

CREATE INDEX IX_Notificaciones_Usuario_Leida
    ON Notificaciones(UsuarioId, Leida)
    INCLUDE (Titulo, FechaCreacion);
CREATE INDEX IX_Notificaciones_FechaCreacion
    ON Notificaciones(FechaCreacion DESC);
```

#### LogsAuditoria
```sql
CREATE TABLE LogsAuditoria (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Accion NVARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE, READ
    Modulo NVARCHAR(50) NOT NULL,
    EntidadTipo NVARCHAR(100),
    EntidadId INT,

    ValoresAnteriores NVARCHAR(MAX),
    ValoresNuevos NVARCHAR(MAX),

    FechaHora DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    DireccionIP NVARCHAR(50),
    UserAgent NVARCHAR(500),
    Exitoso BIT DEFAULT 1,
    MensajeError NVARCHAR(1000),

    CONSTRAINT FK_LogsAuditoria_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id)
);

CREATE INDEX IX_LogsAuditoria_FechaHora ON LogsAuditoria(FechaHora DESC);
CREATE INDEX IX_LogsAuditoria_Usuario_Fecha ON LogsAuditoria(UsuarioId, FechaHora DESC);
CREATE INDEX IX_LogsAuditoria_Modulo_Accion ON LogsAuditoria(Modulo, Accion);
```

---

## Vistas Útiles

### Vista de Equipos Completos
```sql
CREATE VIEW vw_EquiposCompletos AS
SELECT
    e.Id,
    e.CodigoInterno,
    e.Nombre,
    e.NumeroSerie,
    e.Estado,
    e.Condicion,
    te.Nombre AS TipoEquipo,
    m.Nombre AS Marca,
    e.Modelo,
    u.Nombre AS UsuarioAsignado,
    u.Email AS EmailUsuario,
    ub.Nombre AS Ubicacion,
    ub.Codigo AS CodigoUbicacion,
    p.Nombre AS Proveedor,
    e.FechaAdquisicion,
    e.CostoAdquisicion,
    e.FechaFinGarantia,
    DATEDIFF(DAY, GETUTCDATE(), e.FechaFinGarantia) AS DiasRestantesGarantia
FROM Equipos e
INNER JOIN TiposEquipo te ON e.TipoEquipoId = te.Id
LEFT JOIN Marcas m ON e.MarcaId = m.Id
LEFT JOIN Usuarios u ON e.UsuarioAsignadoId = u.Id
LEFT JOIN Ubicaciones ub ON e.UbicacionId = ub.Id
LEFT JOIN Proveedores p ON e.ProveedorId = p.Id
WHERE e.Eliminado = 0;
```

### Vista de Tickets Dashboard
```sql
CREATE VIEW vw_TicketsDashboard AS
SELECT
    t.Id,
    t.NumeroTicket,
    t.Asunto,
    t.Estado,
    t.Prioridad,
    c.Nombre AS Categoria,
    s.Nombre AS Solicitante,
    s.Email AS EmailSolicitante,
    tec.Nombre AS Tecnico,
    tec.Email AS EmailTecnico,
    t.FechaApertura,
    t.FechaLimiteSLA,
    CASE
        WHEN t.FechaLimiteSLA < GETUTCDATE() AND t.Estado NOT IN (4,5) THEN 1
        ELSE 0
    END AS SLAVencido,
    t.CalificacionServicio
FROM Tickets t
INNER JOIN CategoriasTicket c ON t.CategoriaId = c.Id
INNER JOIN Usuarios s ON t.SolicitanteId = s.Id
LEFT JOIN Usuarios tec ON t.TecnicoAsignadoId = tec.Id
WHERE t.Eliminado = 0;
```

---

## Stored Procedures Útiles

### sp_ObtenerEstadisticasInventario
```sql
CREATE PROCEDURE sp_ObtenerEstadisticasInventario
AS
BEGIN
    SELECT
        COUNT(*) AS TotalEquipos,
        SUM(CASE WHEN Estado = 0 THEN 1 ELSE 0 END) AS Disponibles,
        SUM(CASE WHEN Estado = 1 THEN 1 ELSE 0 END) AS EnUso,
        SUM(CASE WHEN Estado = 2 THEN 1 ELSE 0 END) AS EnMantenimiento,
        SUM(CASE WHEN Estado = 4 THEN 1 ELSE 0 END) AS DadosDeBaja,
        SUM(CostoAdquisicion) AS ValorTotalInventario,
        AVG(DATEDIFF(MONTH, FechaAdquisicion, GETUTCDATE())) AS EdadPromedioMeses
    FROM Equipos
    WHERE Eliminado = 0;

    SELECT
        te.Nombre AS TipoEquipo,
        COUNT(*) AS Cantidad
    FROM Equipos e
    INNER JOIN TiposEquipo te ON e.TipoEquipoId = te.Id
    WHERE e.Eliminado = 0
    GROUP BY te.Nombre
    ORDER BY Cantidad DESC;
END
```

---

**Total de tablas:** 35+
**Total de índices:** 50+
**Total de relaciones:** 40+

---

**Última actualización:** Noviembre 2025
