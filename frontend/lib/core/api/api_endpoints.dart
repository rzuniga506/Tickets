/// Endpoints de la API
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String emailExists = '/auth/email-exists';

  // Usuarios
  static const String usuarios = '/usuarios';
  static String usuarioById(int id) => '/usuarios/$id';
  static String toggleActivo(int id) => '/usuarios/$id/toggle-activo';
  static String asignarRoles(int id) => '/usuarios/$id/asignar-roles';
  static String usuariosByDepartamento(int departamentoId) =>
      '/usuarios/departamento/$departamentoId';
  static String usuariosByRol(int rolId) => '/usuarios/rol/$rolId';
  static const String tecnicos = '/usuarios/tecnicos';

  // Equipos
  static const String equipos = '/equipos';
  static String equipoById(int id) => '/equipos/$id';
  static String equipoByCodigo(String codigo) => '/equipos/codigo/$codigo';
  static String equipoByQR(String qr) => '/equipos/qr/$qr';
  static String asignarEquipo(int equipoId, int usuarioId) =>
      '/equipos/$equipoId/asignar/$usuarioId';
  static String desasignarEquipo(int equipoId) =>
      '/equipos/$equipoId/desasignar';
  static String generarQR(int equipoId) => '/equipos/$equipoId/generar-qr';
  static const String equiposDisponibles = '/equipos/disponibles';
  static String equiposByUsuario(int usuarioId) =>
      '/equipos/usuario/$usuarioId';
  static const String misEquipos = '/equipos/mis-equipos';
  static String equiposByDepartamento(int departamentoId) =>
      '/equipos/departamento/$departamentoId';
  static const String equiposGarantiaProximaVencer =
      '/equipos/garantia-proxima-vencer';
  static String cambiarEstadoEquipo(int equipoId) =>
      '/equipos/$equipoId/cambiar-estado';

  // Tickets
  static const String tickets = '/tickets';
  static String ticketById(int id) => '/tickets/$id';
  static String ticketByNumero(String numero) => '/tickets/numero/$numero';
  static String asignarTicket(int id) => '/tickets/$id/asignar';
  static String iniciarProceso(int id) => '/tickets/$id/iniciar-proceso';
  static String resolverTicket(int id) => '/tickets/$id/resolver';
  static String cerrarTicket(int id) => '/tickets/$id/cerrar';
  static String reabrirTicket(int id) => '/tickets/$id/reabrir';
  static String evaluarTicket(int id) => '/tickets/$id/evaluar';
  static String cambiarPrioridad(int id) => '/tickets/$id/cambiar-prioridad';
  static const String misTickets = '/tickets/mis-tickets';
  static const String ticketsAsignados = '/tickets/asignados';
  static const String ticketsPendientes = '/tickets/pendientes-asignacion';
  static const String ticketsSLA = '/tickets/sla-proximo-vencer';
  static const String ticketsEstadisticas = '/tickets/estadisticas';

  // Comentarios de Tickets
  static const String comentariosTicket = '/comentariosticket';
  static String comentarioById(int id) => '/comentariosticket/$id';
  static String comentariosByTicket(int ticketId) => '/comentariosticket/ticket/$ticketId';

  // Notificaciones
  static const String notificaciones = '/notificaciones';
  static String notificacionById(int id) => '/notificaciones/$id';
  static String marcarLeida(int id) => '/notificaciones/$id/marcar-leida';
  static const String marcarTodasLeidas =
      '/notificaciones/marcar-todas-leidas';
  static const String conteoNoLeidas = '/notificaciones/no-leidas/count';
}
