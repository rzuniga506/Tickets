# 🚀 Instrucciones de Configuración Inicial - Sistema Tickets TI

## ⚠️ IMPORTANTE: Ejecutar ANTES de iniciar la aplicación

---

## 1️⃣ CREAR MIGRACIONES DE BASE DE DATOS

La base de datos NO tiene migraciones creadas. Debes ejecutar:

```bash
cd /home/user/Tickets/backend/Tickets.API
dotnet ef migrations add InitialCreate --project ../Tickets.Infrastructure --context ApplicationDbContext --output-dir Data/Migrations
```

### Aplicar Migraciones (crear la base de datos):

```bash
dotnet ef database update --project Tickets.Infrastructure
```

### Verificar que la migración se creó:

Deberías ver un nuevo directorio:
```
/home/user/Tickets/backend/Tickets.Infrastructure/Data/Migrations/
```

---

## 2️⃣ CONFIGURAR CADENA DE CONEXIÓN

Edita `backend/Tickets.API/appsettings.json` y actualiza:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=TU_SERVIDOR;Database=TicketsDB;User Id=TU_USUARIO;Password=TU_CONTRASEÑA;TrustServerCertificate=True;MultipleActiveResultSets=True"
}
```

**Opciones comunes:**
- **SQL Server local**: `Server=localhost;Database=TicketsDB;Integrated Security=True;TrustServerCertificate=True`
- **SQL Server Express**: `Server=localhost\\SQLEXPRESS;Database=TicketsDB;Integrated Security=True;TrustServerCertificate=True`
- **Docker SQL Server**: `Server=localhost,1433;Database=TicketsDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True`

---

## 3️⃣ CONFIGURAR VARIABLES DE ENTORNO (RECOMENDADO)

En producción, NO uses credenciales hardcodeadas en appsettings.json.

### Opción A: User Secrets (Desarrollo)

```bash
cd backend/Tickets.API
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=...;Database=TicketsDB;..."
dotnet user-secrets set "JwtSettings:SecretKey" "TU_CLAVE_SECRETA_MUY_LARGA_Y_SEGURA"
```

### Opción B: Variables de Entorno

Crea `.env` en la raíz del backend (ver `.env.example` como referencia):

```bash
DATABASE_CONNECTION=Server=...
JWT_SECRET=TU_CLAVE_SECRETA
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=tu-email@gmail.com
SMTP_PASSWORD=tu-app-password
```

---

## 4️⃣ RESTAURAR PAQUETES

```bash
# Backend
cd backend/Tickets.API
dotnet restore

# Frontend
cd ../../frontend
flutter pub get
```

---

## 5️⃣ EJECUTAR LA APLICACIÓN

### Backend:

```bash
cd backend/Tickets.API
dotnet run
```

La API estará disponible en: `http://localhost:5000` y `https://localhost:5001`

### Frontend (Web):

```bash
cd frontend
flutter run -d chrome
```

### Frontend (Móvil - Android):

```bash
cd frontend
flutter run -d android
```

---

## 6️⃣ DATOS DE PRUEBA

El sistema crea automáticamente datos iniciales (seed data):

### Usuario Administrador:
- **Email**: `admin@tickets.com`
- **Contraseña**: `Admin123!`

### Roles Predefinidos:
- Administrador
- Técnico
- Usuario Final
- Supervisor

### Permisos:
15 permisos granulares ya configurados.

---

## 7️⃣ VERIFICAR CONFIGURACIÓN

### Health Check:
`GET http://localhost:5000/health`

Debe responder: `Healthy`

### Swagger UI:
`http://localhost:5000/swagger`

### Login Test:
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@tickets.com","password":"Admin123!"}'
```

Deberías recibir un token JWT.

---

## 🔒 SEGURIDAD - CHECKLIST PRODUCCIÓN

Antes de desplegar a producción:

- [ ] Cambiar JWT SecretKey a una clave segura de 64+ caracteres
- [ ] Actualizar contraseñas de base de datos
- [ ] Configurar AllowedOrigins en CORS (quitar AllowAll)
- [ ] Habilitar HTTPS (UseHttpsRedirection siempre activo)
- [ ] Configurar rate limiting
- [ ] Revisar políticas de contraseñas
- [ ] Habilitar logging con Serilog
- [ ] Configurar backup automático de base de datos

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "A network-related or instance-specific error occurred"
**Solución**: Verifica que SQL Server esté ejecutándose y la cadena de conexión sea correcta.

### Error: "Cannot find SqlLocalDB.exe"
**Solución**: Usa SQL Server Express o Docker en lugar de LocalDB.

### Error: "No migrations were applied"
**Solución**: Ejecuta `dotnet ef database update` desde Tickets.API.

### Error: "InvalidOperationException: Unable to resolve service for type 'JwtSettings'"
**Solución**: Ya está resuelto en esta versión. JwtSettings está registrado en DI.

---

## 📖 DOCUMENTACIÓN ADICIONAL

- API Docs: `http://localhost:5000/swagger`
- Architecture: Ver `README.md`
- Endpoints: Ver Swagger UI

---

**Creado**: 2025-01-15
**Versión**: 1.0
**Estado**: Sistema production-ready con mejoras de seguridad y features completas
