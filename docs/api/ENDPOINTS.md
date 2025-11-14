# 🔌 API Endpoints - Documentación Completa

Base URL: `https://api.empresa.com/api/v1`

## Autenticación

Todos los endpoints (excepto `/auth/login`) requieren autenticación mediante JWT:
```
Authorization: Bearer {token}
```

---

## 🔐 Autenticación

### POST /auth/login
Iniciar sesión

**Body:**
```json
{
  "email": "usuario@empresa.com",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1...",
    "refreshToken": "dGhpcyBpcyBhIHJl...",
    "usuario": {
      "id": 1,
      "nombre": "Juan",
      "apellido": "Pérez",
      "email": "juan@empresa.com"
    },
    "roles": ["Técnico"],
    "permisos": ["tickets.read", "tickets.write"]
  }
}
```

### POST /auth/refresh
Renovar token

**Body:**
```json
{
  "refreshToken": "dGhpcyBpcyBhIHJl..."
}
```

### POST /auth/logout
Cerrar sesión

### GET /auth/profile
Obtener perfil del usuario autenticado

---

## 📦 Inventario - Equipos

### GET /inventario/equipos
Listar equipos (paginado)

**Query Params:**
- `page` (int): Página actual (default: 1)
- `pageSize` (int): Items por página (default: 20)
- `search` (string): Búsqueda por código, nombre, serie
- `tipoEquipoId` (int): Filtrar por tipo
- `estado` (int): 0=Disponible, 1=EnUso, 2=EnMantenimiento, etc.
- `ubicacionId` (int): Filtrar por ubicación
- `usuarioAsignadoId` (int): Filtrar por usuario asignado

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "codigoInterno": "PC-001",
        "nombre": "Laptop Dell Latitude 5420",
        "numeroSerie": "ABC123",
        "estado": 1,
        "estadoNombre": "En Uso",
        "tipoEquipo": {
          "id": 1,
          "nombre": "Laptop"
        },
        "marca": {
          "id": 5,
          "nombre": "Dell"
        },
        "usuarioAsignado": {
          "id": 10,
          "nombre": "Juan Pérez"
        },
        "ubicacion": {
          "id": 3,
          "nombre": "Piso 2 - Área TI"
        }
      }
    ],
    "page": 1,
    "pageSize": 20,
    "totalItems": 150,
    "totalPages": 8
  }
}
```

### GET /inventario/equipos/{id}
Detalle de equipo

### POST /inventario/equipos
Crear equipo

**Permisos:** `inventario.write`

**Body:**
```json
{
  "codigoInterno": "PC-050",
  "nombre": "Laptop HP ProBook",
  "numeroSerie": "XYZ789",
  "tipoEquipoId": 1,
  "marcaId": 3,
  "modelo": "ProBook 450 G8",
  "especificacionesJson": "{\"cpu\":\"Intel i5\",\"ram\":\"16GB\",\"disco\":\"512GB SSD\"}",
  "costoAdquisicion": 15000.00,
  "fechaAdquisicion": "2024-01-15",
  "proveedorId": 2,
  "ubicacionId": 3
}
```

### PUT /inventario/equipos/{id}
Actualizar equipo

### DELETE /inventario/equipos/{id}
Eliminar equipo (soft delete)

### POST /inventario/equipos/{id}/asignar
Asignar equipo a usuario

**Body:**
```json
{
  "usuarioId": 10,
  "ubicacionId": 5,
  "motivo": "Asignación para home office",
  "observaciones": "Equipo nuevo"
}
```

### POST /inventario/equipos/{id}/liberar
Liberar equipo asignado

### GET /inventario/equipos/{id}/historial
Historial de movimientos del equipo

### GET /inventario/equipos/{id}/qr
Obtener imagen QR del equipo (PNG)

### POST /inventario/equipos/{id}/documentos
Subir documento del equipo (multipart/form-data)

### GET /inventario/equipos/estadisticas
Estadísticas del inventario

**Response 200:**
```json
{
  "success": true,
  "data": {
    "totalEquipos": 250,
    "disponibles": 45,
    "enUso": 180,
    "enMantenimiento": 15,
    "valorTotalInventario": 3500000.00,
    "equiposPorTipo": [
      { "tipo": "Laptop", "cantidad": 120 },
      { "tipo": "Desktop", "cantidad": 80 }
    ],
    "equiposProximosAVencerGarantia": 12
  }
}
```

### GET /inventario/equipos/export
Exportar inventario

**Query Params:**
- `format`: excel | pdf | csv

**Response:** Archivo descargable

---

## 💻 Inventario - Software

### GET /inventario/software
Listar software

### POST /inventario/software
Crear software

### PUT /inventario/software/{id}
Actualizar software

### DELETE /inventario/software/{id}
Eliminar software

### GET /inventario/software/{id}/licencias-disponibles
Licencias disponibles

### POST /inventario/software/{id}/asignar-licencia
Asignar licencia

### GET /inventario/software/vencimientos
Software próximo a vencer

**Query Params:**
- `diasProximos` (int): Default 30

---

## 🎫 Tickets

### GET /tickets
Listar tickets (paginado)

**Query Params:**
- `page`, `pageSize`
- `search`: Búsqueda por número, asunto, descripción
- `estado`: 0=Nuevo, 1=Asignado, 2=EnProceso, 3=EnEspera, 4=Resuelto, 5=Cerrado
- `prioridad`: 1=Baja, 2=Media, 3=Alta, 4=Crítica
- `categoriaId`
- `tecnicoId`
- `solicitanteId`
- `fechaDesde`, `fechaHasta`
- `soloVencidos` (bool)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 123,
        "numeroTicket": "TK-2024-00123",
        "asunto": "Error en aplicación de nómina",
        "descripcion": "La aplicación muestra error al intentar...",
        "estado": 2,
        "estadoNombre": "En Proceso",
        "prioridad": 3,
        "prioridadNombre": "Alta",
        "categoria": {
          "id": 2,
          "nombre": "Software"
        },
        "solicitante": {
          "id": 50,
          "nombre": "María González"
        },
        "tecnicoAsignado": {
          "id": 5,
          "nombre": "Pedro Técnico"
        },
        "fechaApertura": "2024-11-14T10:30:00Z",
        "fechaLimiteSLA": "2024-11-14T18:30:00Z",
        "slaVencido": false
      }
    ],
    "page": 1,
    "pageSize": 20,
    "totalItems": 87,
    "totalPages": 5
  }
}
```

### GET /tickets/{id}
Detalle completo del ticket

### POST /tickets
Crear ticket

**Body:**
```json
{
  "asunto": "Impresora no funciona",
  "descripcion": "La impresora del piso 3 no imprime documentos",
  "categoriaId": 1,
  "prioridad": 2,
  "equipoId": 45,
  "ubicacionId": 8
}
```

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": 124,
    "numeroTicket": "TK-2024-00124",
    "estado": 0,
    "fechaLimiteSLA": "2024-11-14T14:30:00Z"
  },
  "message": "Ticket creado exitosamente"
}
```

### PUT /tickets/{id}
Actualizar ticket

### DELETE /tickets/{id}
Eliminar ticket

### POST /tickets/{id}/asignar
Asignar ticket a técnico

**Body:**
```json
{
  "tecnicoId": 5,
  "motivo": "Especialista en hardware",
  "notificar": true
}
```

### POST /tickets/{id}/cambiar-estado
Cambiar estado del ticket

**Body:**
```json
{
  "nuevoEstado": 2,
  "comentario": "Iniciando revisión del equipo"
}
```

### POST /tickets/{id}/cambiar-prioridad
Cambiar prioridad

### POST /tickets/{id}/resolver
Resolver ticket

**Body:**
```json
{
  "solucion": "Se reemplazó el cartucho de tinta y se configuró la red",
  "tipoSolucion": 0,
  "minutosInvertidos": 45
}
```

### POST /tickets/{id}/cerrar
Cerrar ticket

### POST /tickets/{id}/reabrir
Reabrir ticket cerrado

**Body:**
```json
{
  "motivo": "El problema persiste"
}
```

### POST /tickets/{id}/evaluar
Evaluar servicio del ticket

**Body:**
```json
{
  "calificacion": 5,
  "comentario": "Excelente servicio, muy rápido"
}
```

### GET /tickets/{id}/historial
Historial de cambios

### GET /tickets/mis-tickets
Tickets del usuario autenticado

### GET /tickets/asignados-a-mi
Tickets asignados al usuario autenticado (técnicos)

### GET /tickets/estadisticas
Estadísticas de tickets

**Response 200:**
```json
{
  "success": true,
  "data": {
    "totalTickets": 1250,
    "abiertos": 87,
    "nuevos": 12,
    "enProceso": 45,
    "vencidosSLA": 3,
    "resueltosHoy": 8,
    "resueltosEsteMes": 120,
    "promedioResolucionHoras": 4.5,
    "cumplimientoSLA": 92.3
  }
}
```

---

## 💬 Comentarios de Tickets

### GET /tickets/{ticketId}/comentarios
Listar comentarios

### POST /tickets/{ticketId}/comentarios
Agregar comentario

**Body:**
```json
{
  "contenido": "Se realizó revisión inicial, esperando repuesto",
  "esInterno": false
}
```

### PUT /tickets/{ticketId}/comentarios/{id}
Editar comentario

### DELETE /tickets/{ticketId}/comentarios/{id}
Eliminar comentario

---

## 📎 Adjuntos de Tickets

### GET /tickets/{ticketId}/adjuntos
Listar adjuntos

### POST /tickets/{ticketId}/adjuntos
Subir adjunto (multipart/form-data)

**Form Data:**
- `file`: Archivo (max 10MB)

### DELETE /tickets/{ticketId}/adjuntos/{id}
Eliminar adjunto

### GET /tickets/{ticketId}/adjuntos/{id}/download
Descargar adjunto

---

## 📢 Notificaciones

### GET /notificaciones
Listar notificaciones del usuario

**Query Params:**
- `leidas` (bool): Filtrar por leídas/no leídas
- `tipo` (int): Filtrar por tipo
- `page`, `pageSize`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 500,
        "titulo": "Nuevo ticket asignado",
        "mensaje": "Se te asignó el ticket TK-2024-00124",
        "tipo": 1,
        "prioridad": 2,
        "leida": false,
        "fechaCreacion": "2024-11-14T11:00:00Z",
        "urlAccion": "/tickets/124"
      }
    ],
    "totalItems": 45
  }
}
```

### GET /notificaciones/no-leidas/count
Cantidad de notificaciones no leídas

### PUT /notificaciones/{id}/marcar-leida
Marcar como leída

### PUT /notificaciones/marcar-todas-leidas
Marcar todas como leídas

### DELETE /notificaciones/{id}
Eliminar notificación

### POST /notificaciones/registrar-dispositivo
Registrar dispositivo para push notifications

**Body:**
```json
{
  "tokenPush": "firebase_token_here",
  "plataforma": 0,
  "nombreDispositivo": "iPhone 13"
}
```

### GET /notificaciones/preferencias
Obtener preferencias

### PUT /notificaciones/preferencias
Actualizar preferencias

---

## 📍 Ubicaciones

### GET /ubicaciones
Listar ubicaciones

### GET /ubicaciones/jerarquia
Obtener árbol jerárquico

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "México",
      "tipo": 0,
      "hijas": [
        {
          "id": 2,
          "nombre": "Ciudad de México",
          "tipo": 1,
          "hijas": [
            {
              "id": 3,
              "nombre": "Edificio Central",
              "tipo": 2,
              "hijas": []
            }
          ]
        }
      ]
    }
  ]
}
```

### GET /ubicaciones/{id}
Detalle de ubicación

### POST /ubicaciones
Crear ubicación

### PUT /ubicaciones/{id}
Actualizar ubicación

### DELETE /ubicaciones/{id}
Eliminar ubicación

### GET /ubicaciones/{id}/equipos
Equipos en la ubicación

### GET /ubicaciones/{id}/usuarios
Usuarios en la ubicación

### GET /ubicaciones/{id}/estadisticas
Estadísticas de la ubicación

---

## 🏢 Proveedores

### GET /proveedores
Listar proveedores

### POST /proveedores
Crear proveedor

### PUT /proveedores/{id}
Actualizar proveedor

### DELETE /proveedores/{id}
Eliminar proveedor

### GET /proveedores/{id}/contratos
Contratos del proveedor

### POST /proveedores/{id}/contratos
Crear contrato

### PUT /proveedores/contratos/{id}
Actualizar contrato

### GET /proveedores/{id}/evaluaciones
Evaluaciones del proveedor

### POST /proveedores/{id}/evaluar
Evaluar proveedor

**Body:**
```json
{
  "periodo": "Q4 2024",
  "calidadProductos": 5,
  "tiempoEntrega": 4,
  "precios": 4,
  "atencionCliente": 5,
  "soporteTecnico": 4,
  "comentarios": "Excelente servicio",
  "recomendado": true
}
```

### GET /proveedores/contratos/proximos-vencer
Contratos próximos a vencer

**Query Params:**
- `diasProximos` (int): Default 30

---

## 👥 Usuarios y Roles

### GET /usuarios
Listar usuarios

### GET /usuarios/{id}
Detalle de usuario

### POST /usuarios
Crear usuario

### PUT /usuarios/{id}
Actualizar usuario

### DELETE /usuarios/{id}
Eliminar usuario

### POST /usuarios/{id}/cambiar-password
Cambiar contraseña

### GET /roles
Listar roles

### POST /roles
Crear rol

### PUT /roles/{id}
Actualizar rol

---

## 🔍 Auditoría

### GET /auditoria
Logs de auditoría

**Query Params:**
- `usuarioId`
- `modulo`
- `accion`: CREATE, UPDATE, DELETE, READ
- `fechaDesde`, `fechaHasta`
- `page`, `pageSize`

### GET /auditoria/reporte
Generar reporte de auditoría

**Query Params:**
- `formato`: excel | pdf

---

## 📊 Reportes

### GET /reportes/inventario-completo
Reporte completo de inventario

### GET /reportes/tickets-por-periodo
Reporte de tickets por período

### GET /reportes/desempeño-tecnicos
Reporte de desempeño de técnicos

### GET /reportes/cumplimiento-sla
Reporte de cumplimiento SLA

---

## Códigos de Respuesta

| Código | Descripción |
|--------|-------------|
| 200 | OK - Solicitud exitosa |
| 201 | Created - Recurso creado |
| 204 | No Content - Eliminación exitosa |
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - No autenticado |
| 403 | Forbidden - Sin permisos |
| 404 | Not Found - Recurso no encontrado |
| 409 | Conflict - Conflicto (ej: código duplicado) |
| 422 | Unprocessable Entity - Validación fallida |
| 500 | Internal Server Error - Error del servidor |

## Formato de Error

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Datos inválidos",
    "details": [
      {
        "field": "email",
        "message": "El email es requerido"
      }
    ]
  }
}
```

---

**Documentación generada automáticamente con Swagger:** `https://api.empresa.com/swagger`

**Última actualización:** Noviembre 2025
