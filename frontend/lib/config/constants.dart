/// Constantes globales de la aplicación
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const String apiBaseUrlProd = 'https://api.tickets.com/api';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // App Info
  static const String appName = 'Tickets TI';
  static const String appVersion = '1.0.0';

  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedFileExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx'
  ];

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce Delays
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Refresh Intervals
  static const Duration notificationRefresh = Duration(minutes: 1);
  static const Duration ticketRefresh = Duration(minutes: 2);
}

/// Estados de equipos (alineado con EstadoEquipo.cs del backend)
enum EstadoEquipo {
  disponible,      // 0
  asignado,        // 1
  enUso,           // 1 (alias de asignado)
  enMantenimiento, // 2
  enReparacion,    // 3
  dadoDeBaja,      // 4
  perdido,         // 5
  robado           // 6
}

/// Tipos de equipo (alineado con TipoEquipo.cs del backend)
enum TipoEquipo {
  computadora,  // 0
  laptop,       // 1
  servidor,     // 2
  impresora,    // 3
  scanner,      // 4
  router,       // 5
  switch_,      // 6 (switch es palabra reservada)
  firewall,     // 7
  monitor,      // 8
  teclado,      // 9
  mouse,        // 10
  telefono,     // 11
  tablet,       // 12
  otro          // 99
}

/// Condiciones de equipos (alineado con CondicionEquipo.cs del backend)
enum CondicionEquipo {
  nuevo,        // 0
  excelente,    // 1
  bueno,        // 2
  regular,      // 3
  malo,         // 4
  noFuncional   // 5
}

/// Estados de tickets (alineado con EstadoTicket.cs del backend)
enum EstadoTicket {
  nuevo,       // 0
  asignado,    // 1
  enProceso,   // 2
  enEspera,    // 3
  resuelto,    // 4
  cerrado,     // 5
  cancelado,   // 6
  reabierto    // 7
}

/// Prioridades de tickets (alineado con PrioridadTicket.cs del backend)
/// IMPORTANTE: Backend usa valores 1-4, no 0-3
enum PrioridadTicket {
  baja,     // backend: 1
  media,    // backend: 2
  alta,     // backend: 3
  critica   // backend: 4
}

/// Tipos de solución (alineado con TipoSolucion.cs del backend)
/// IMPORTANTE: Clasifica el RESULTADO de la solución, no el método de atención
enum TipoSolucion {
  resuelto,    // 0 - Problema completamente resuelto
  workaround,  // 1 - Solución temporal
  noResuelto,  // 2 - No se pudo resolver
  derivado     // 3 - Derivado a otra área
}

/// Tipos de notificación
enum TipoNotificacion {
  ticketNuevo,
  ticketAsignado,
  ticketEnProceso,
  ticketResuelto,
  ticketCerrado,
  ticketActualizado,
  equipoAsignado,
  equipoDesasignado,
  slaProximoVencer,
  slaCumplido,
  slaIncumplido,
  general
}

/// Prioridades de notificación
enum PrioridadNotificacion {
  baja,
  normal,
  alta,
  urgente
}

/// Extensiones para enums

extension EstadoEquipoExtension on EstadoEquipo {
  String get displayName {
    switch (this) {
      case EstadoEquipo.disponible:
        return 'Disponible';
      case EstadoEquipo.asignado:
      case EstadoEquipo.enUso:
        return 'En Uso';
      case EstadoEquipo.enMantenimiento:
        return 'En Mantenimiento';
      case EstadoEquipo.enReparacion:
        return 'En Reparación';
      case EstadoEquipo.dadoDeBaja:
        return 'Dado de Baja';
      case EstadoEquipo.perdido:
        return 'Perdido';
      case EstadoEquipo.robado:
        return 'Robado';
    }
  }

  /// Convierte el enum a valor entero para el backend (0-6)
  int toJson() => index;

  /// Crea un EstadoEquipo desde valor entero del backend
  static EstadoEquipo fromJson(int value) {
    return EstadoEquipo.values[value];
  }
}

extension CondicionEquipoExtension on CondicionEquipo {
  String get displayName {
    switch (this) {
      case CondicionEquipo.nuevo:
        return 'Nuevo';
      case CondicionEquipo.excelente:
        return 'Excelente';
      case CondicionEquipo.bueno:
        return 'Bueno';
      case CondicionEquipo.regular:
        return 'Regular';
      case CondicionEquipo.malo:
        return 'Malo';
      case CondicionEquipo.noFuncional:
        return 'No Funcional';
    }
  }

  /// Convierte el enum a valor entero para el backend (0-5)
  int toJson() => index;

  /// Crea un CondicionEquipo desde valor entero del backend
  static CondicionEquipo fromJson(int value) {
    return CondicionEquipo.values[value];
  }
}

extension TipoEquipoExtension on TipoEquipo {
  String get displayName {
    switch (this) {
      case TipoEquipo.computadora:
        return 'Computadora';
      case TipoEquipo.laptop:
        return 'Laptop';
      case TipoEquipo.servidor:
        return 'Servidor';
      case TipoEquipo.impresora:
        return 'Impresora';
      case TipoEquipo.scanner:
        return 'Scanner';
      case TipoEquipo.router:
        return 'Router';
      case TipoEquipo.switch_:
        return 'Switch';
      case TipoEquipo.firewall:
        return 'Firewall';
      case TipoEquipo.monitor:
        return 'Monitor';
      case TipoEquipo.teclado:
        return 'Teclado';
      case TipoEquipo.mouse:
        return 'Mouse';
      case TipoEquipo.telefono:
        return 'Teléfono';
      case TipoEquipo.tablet:
        return 'Tablet';
      case TipoEquipo.otro:
        return 'Otro';
    }
  }

  /// Convierte el enum a valor entero para el backend
  int toJson() {
    if (this == TipoEquipo.otro) return 99;
    return index;
  }

  /// Crea un TipoEquipo desde valor entero del backend
  static TipoEquipo fromJson(int value) {
    if (value == 99) return TipoEquipo.otro;
    return TipoEquipo.values[value];
  }
}

extension EstadoTicketExtension on EstadoTicket {
  String get displayName {
    switch (this) {
      case EstadoTicket.nuevo:
        return 'Nuevo';
      case EstadoTicket.asignado:
        return 'Asignado';
      case EstadoTicket.enProceso:
        return 'En Proceso';
      case EstadoTicket.enEspera:
        return 'En Espera';
      case EstadoTicket.resuelto:
        return 'Resuelto';
      case EstadoTicket.cerrado:
        return 'Cerrado';
      case EstadoTicket.cancelado:
        return 'Cancelado';
      case EstadoTicket.reabierto:
        return 'Reabierto';
    }
  }

  /// Convierte el enum a valor entero para el backend (0-4)
  int toJson() => index;

  /// Crea un EstadoTicket desde valor entero del backend
  static EstadoTicket fromJson(int value) {
    return EstadoTicket.values[value];
  }
}

extension PrioridadTicketExtension on PrioridadTicket {
  String get displayName {
    switch (this) {
      case PrioridadTicket.baja:
        return 'Baja';
      case PrioridadTicket.media:
        return 'Media';
      case PrioridadTicket.alta:
        return 'Alta';
      case PrioridadTicket.critica:
        return 'Crítica';
    }
  }

  /// Convierte el enum a valor entero para el backend (1-4, no 0-3!)
  int toJson() => index + 1;

  /// Crea un PrioridadTicket desde valor entero del backend (1-4)
  static PrioridadTicket fromJson(int value) {
    return PrioridadTicket.values[value - 1];
  }
}

extension TipoSolucionExtension on TipoSolucion {
  String get displayName {
    switch (this) {
      case TipoSolucion.resuelto:
        return 'Resuelto';
      case TipoSolucion.workaround:
        return 'Solución Temporal';
      case TipoSolucion.noResuelto:
        return 'No Resuelto';
      case TipoSolucion.derivado:
        return 'Derivado';
    }
  }

  /// Convierte el enum a valor entero para el backend (0-3)
  int toJson() => index;

  /// Crea un TipoSolucion desde valor entero del backend
  static TipoSolucion fromJson(int value) {
    return TipoSolucion.values[value];
  }
}

extension TipoNotificacionExtension on TipoNotificacion {
  String get displayName {
    switch (this) {
      case TipoNotificacion.ticketNuevo:
        return 'Ticket Nuevo';
      case TipoNotificacion.ticketAsignado:
        return 'Ticket Asignado';
      case TipoNotificacion.ticketEnProceso:
        return 'Ticket en Proceso';
      case TipoNotificacion.ticketResuelto:
        return 'Ticket Resuelto';
      case TipoNotificacion.ticketCerrado:
        return 'Ticket Cerrado';
      case TipoNotificacion.ticketActualizado:
        return 'Ticket Actualizado';
      case TipoNotificacion.equipoAsignado:
        return 'Equipo Asignado';
      case TipoNotificacion.equipoDesasignado:
        return 'Equipo Desasignado';
      case TipoNotificacion.slaProximoVencer:
        return 'SLA Próximo a Vencer';
      case TipoNotificacion.slaCumplido:
        return 'SLA Cumplido';
      case TipoNotificacion.slaIncumplido:
        return 'SLA Incumplido';
      case TipoNotificacion.general:
        return 'General';
    }
  }
}

extension PrioridadNotificacionExtension on PrioridadNotificacion {
  String get displayName {
    switch (this) {
      case PrioridadNotificacion.baja:
        return 'Baja';
      case PrioridadNotificacion.normal:
        return 'Normal';
      case PrioridadNotificacion.alta:
        return 'Alta';
      case PrioridadNotificacion.urgente:
        return 'Urgente';
    }
  }
}
