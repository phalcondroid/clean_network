import 'package:clean_network/src/core/adapters/data_options.dart';

class HttpOptions extends DataOptions {
  final String paths;
  final Map<String, dynamic> queries;
  final Map<String, dynamic> headers;

  const HttpOptions({
    this.paths = "",
    this.queries = const {},
    this.headers = const {},
  });
}
