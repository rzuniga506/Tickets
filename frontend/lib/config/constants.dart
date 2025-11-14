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

/// Estados de equipos
enum EstadoEquipo {
  disponible,
  asignado,
  enMantenimiento,
  dadoDeBaja,
  enReparacion
}

/// Condiciones de equipos
enum CondicionEquipo {
  nuevo,
  bueno,
  regular,
  malo
}

/// Estados de tickets
enum EstadoTicket {
  nuevo,
  asignado,
  enProceso,
  resuelto,
  cerrado
}

/// Prioridades de tickets
enum PrioridadTicket {
  baja,
  media,
  alta,
  urgente,
  critica
}

/// Tipos de solución
enum TipoSolucion {
  remota,
  presencial,
  telefonica,
  guiada
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
        return 'Asignado';
      case EstadoEquipo.enMantenimiento:
        return 'En Mantenimiento';
      case EstadoEquipo.dadoDeBaja:
        return 'Dado de Baja';
      case EstadoEquipo.enReparacion:
        return 'En Reparación';
    }
  }
}

extension CondicionEquipoExtension on CondicionEquipo {
  String get displayName {
    switch (this) {
      case CondicionEquipo.nuevo:
        return 'Nuevo';
      case CondicionEquipo.bueno:
        return 'Bueno';
      case CondicionEquipo.regular:
        return 'Regular';
      case CondicionEquipo.malo:
        return 'Malo';
    }
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
      case EstadoTicket.resuelto:
        return 'Resuelto';
      case EstadoTicket.cerrado:
        return 'Cerrado';
    }
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
      case PrioridadTicket.urgente:
        return 'Urgente';
      case PrioridadTicket.critica:
        return 'Crítica';
    }
  }
}
