class CleanNetworkHttpExceptionResponse {
  final int? statusCode;
  final dynamic data;
  final bool isRedirect;
  final String? statusMessage;
  final Map<String, dynamic>? extra;
  final Map<String, dynamic>? headers;

  const CleanNetworkHttpExceptionResponse({
    this.data,
    this.statusCode,
    this.statusMessage,
    this.isRedirect = false,
    this.extra,
    this.headers,
  });
}
