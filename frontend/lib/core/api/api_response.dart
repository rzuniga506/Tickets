/// Respuesta estándar de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ErrorDetails? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'] != null
          ? ErrorDetails.fromJson(json['error'])
          : null,
    );
  }
}

/// Detalles del error
class ErrorDetails {
  final String? code;
  final String? message;
  final Map<String, dynamic>? details;

  ErrorDetails({
    this.code,
    this.message,
    this.details,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'],
      message: json['message'],
      details: json['details'],
    );
  }
}

/// Resultado paginado
class PagedResult<T> {
  final List<T> items;
  final int totalRecords;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PagedResult({
    required this.items,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
  })  : totalPages = (totalRecords / pageSize).ceil(),
        hasPreviousPage = pageNumber > 1,
        hasNextPage = pageNumber < (totalRecords / pageSize).ceil();

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult<T>(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalRecords: json['totalRecords'] ?? json['totalItems'] ?? 0,
      pageNumber: json['pageNumber'] ?? json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }

  // Getter aliases para compatibilidad
  int get totalItems => totalRecords;
  bool get hasMore => hasNextPage;

  PagedResult<T> copyWith({
    List<T>? items,
    int? totalRecords,
    int? pageNumber,
    int? pageSize,
  }) {
    return PagedResult<T>(
      items: items ?? this.items,
      totalRecords: totalRecords ?? this.totalRecords,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
