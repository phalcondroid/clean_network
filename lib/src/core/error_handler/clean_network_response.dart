import 'dart:convert';
import 'package:dio/dio.dart';

class CleanNetworkResponse<T> {
  CleanNetworkResponse({
    this.data,
    required this.requestOptions,
    this.statusCode,
    this.statusMessage,
    this.isRedirect = false,
    this.redirects = const [],
    Map<String, dynamic>? extra,
    dynamic? headers,
  }) : headers =
           headers ??
           Headers(preserveHeaderCase: requestOptions.preserveHeaderCase),
       extra = extra ?? <String, dynamic>{};

  T? data;
  dynamic requestOptions;
  int? statusCode;
  String? statusMessage;
  dynamic headers;
  bool isRedirect;
  List<RedirectRecord> redirects;
  Uri get realUri =>
      redirects.isNotEmpty ? redirects.last.location : requestOptions.uri;
  Map<String, dynamic> extra;

  @override
  String toString() {
    if (data is Map) {
      return jsonEncode(data);
    }
    return data.toString();
  }
}
