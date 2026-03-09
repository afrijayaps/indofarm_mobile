class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode, this.meta});

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
