/// Modelo para resultados paginados del API
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
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult<T>(
      items: (json['items'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalRecords: json['totalRecords'] ?? json['totalItems'] ?? 0,
      pageNumber: json['pageNumber'] ?? json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }

  // Getter alias para compatibilidad
  int get totalItems => totalRecords;
  bool get hasMore => hasNextPage;

  PagedResult<T> copyWith({
    List<T>? items,
    int? totalRecords,
    int? pageNumber,
    int? pageSize,
    int? totalPages,
    bool? hasPreviousPage,
    bool? hasNextPage,
  }) {
    return PagedResult<T>(
      items: items ?? this.items,
      totalRecords: totalRecords ?? this.totalRecords,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
