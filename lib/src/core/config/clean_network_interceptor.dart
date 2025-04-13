import 'package:clean_network/clean_network.dart';
import 'package:dio/dio.dart';

class CleanNetworkInterceptor {
  final RequestOptions Function(
    RequestOptions options,
    RequestInterceptorHandler handler,
  )?
  before;
  final Response Function(
    Response response,
    ResponseInterceptorHandler handler,
  )?
  after;
  final void Function(
    CleanNetworkHttpException e,
    ErrorInterceptorHandler handler,
  )?
  catchError;

  const CleanNetworkInterceptor({this.before, this.after, this.catchError});
}
