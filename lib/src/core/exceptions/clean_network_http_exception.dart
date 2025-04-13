import 'package:clean_network/clean_network.dart';

class CleanNetworkHttpException implements CleanNetworkException {
  @override
  final String message;

  @override
  final StackTrace stackTrace;
  final CleanNetworkHttpExceptionData requestInfo;
  final Object? error;
  final CleanNetworkHttpExceptionResponse response;

  const CleanNetworkHttpException({
    this.message = "",
    this.stackTrace = StackTrace.empty,
    this.error,
    required this.requestInfo,
    required this.response,
  });
}
