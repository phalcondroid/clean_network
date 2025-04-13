import 'package:clean_network/src/core/exceptions/clean_network_http_exception_type.dart';

class CleanNetworkHttpExceptionData {
  final String path;
  final String baseUrl;
  final Uri uri;
  final String method;
  final Map<String, dynamic> headers;
  final dynamic data;
  final Map<String, dynamic> queryParams;
  final CleanNetworkHttpExceptionType type;

  const CleanNetworkHttpExceptionData({
    required this.path,
    required this.baseUrl,
    required this.headers,
    required this.data,
    required this.method,
    required this.queryParams,
    required this.uri,
    required this.type,
  });
}
