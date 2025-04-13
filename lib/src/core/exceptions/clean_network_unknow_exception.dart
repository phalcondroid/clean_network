import 'package:clean_network/clean_network.dart';

class CleanNetworkUnknowException implements CleanNetworkException {
  @override
  final String message;

  @override
  final StackTrace stackTrace;

  const CleanNetworkUnknowException({
    this.message = "",
    this.stackTrace = StackTrace.empty,
  });
}
