class CleanNetworkException implements Exception {
  final String? message;
  final StackTrace? stackTrace;
  const CleanNetworkException([
    this.message = "",
    this.stackTrace = StackTrace.empty,
  ]);

  @override
  String toString() =>
      " [ CleanNetworkException ]: $message , StackTrace: $stackTrace";
}
