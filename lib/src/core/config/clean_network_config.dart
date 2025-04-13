import 'dart:core';

import 'package:clean_network/clean_network.dart';
import 'package:clean_network/src/core/config/clean_network_injector.dart';
import 'package:clean_network/src/core/container/clean_network_container.dart';
import 'package:clean_network/src/core/exceptions/clean_network_unknow_exception.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class HttpBaseOptions {
  final String baseUrl;
  final Duration? connectTimeout;
  final Duration? receiveTimeout;

  const HttpBaseOptions({
    this.baseUrl = "",
    this.connectTimeout = const Duration(seconds: 5),
    this.receiveTimeout = const Duration(seconds: 3),
  });
}

class InstanceConfig {
  final String connectionName;
  final HttpBaseOptions options;
  final CleanNetworkInterceptor? interceptor;

  const InstanceConfig({
    required this.options,
    this.connectionName = "default",
    this.interceptor = const CleanNetworkInterceptor(),
  });

  CleanNetworkHttpExceptionType getExceptionType(
    DioExceptionType type,
  ) => switch (type) {
    DioExceptionType.badCertificate =>
      CleanNetworkHttpExceptionType.badCertificate,
    DioExceptionType.badResponse => CleanNetworkHttpExceptionType.badResponse,
    DioExceptionType.cancel => CleanNetworkHttpExceptionType.cancel,
    DioExceptionType.connectionError =>
      CleanNetworkHttpExceptionType.connectionError,
    DioExceptionType.connectionTimeout =>
      CleanNetworkHttpExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout => CleanNetworkHttpExceptionType.sendTimeout,
    DioExceptionType.unknown => CleanNetworkHttpExceptionType.unknown,
    DioExceptionType.receiveTimeout =>
      CleanNetworkHttpExceptionType.receiveTimeout,
  };

  void initConfig() {
    try {
      final Dio dio = Dio();
      dio.options = dio.options.copyWith(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            if (interceptor?.before != null) {
              return handler.next(
                interceptor?.before!(options, handler) ?? options,
              );
            }
            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            if (interceptor?.after != null) {
              return handler.next(
                interceptor?.after!(response, handler) ?? response,
              );
            }
            return handler.next(response);
          },
          onError: (e, handler) {
            CleanNetworkHttpException ex = CleanNetworkHttpException(
              message: e.message ?? "",
              stackTrace: e.stackTrace,
              error: e.error,
              response: CleanNetworkHttpExceptionResponse(
                data: e.response?.data,
                extra: e.response?.extra,
                headers: e.response?.headers.map,
                isRedirect: e.response?.isRedirect ?? false,
                statusCode: e.response?.statusCode,
                statusMessage: e.response?.statusMessage,
              ),
              requestInfo: CleanNetworkHttpExceptionData(
                type: getExceptionType(e.type),
                baseUrl: e.requestOptions.baseUrl,
                data: e.requestOptions.data,
                headers: e.requestOptions.headers,
                method: e.requestOptions.method,
                path: e.requestOptions.path,
                queryParams: e.requestOptions.queryParameters,
                uri: e.requestOptions.uri,
              ),
            );
            interceptor?.catchError!(ex, handler);
            return handler.next(e);
          },
        ),
      );
      print(
        "[Http] request calling options: $connectionName -> ${dio.options.baseUrl}",
      );

      GetIt.I.get<CleanNetworkContainer>().setContent(
        '__connection__$connectionName',
        dio,
      );
    } catch (e) {
      throw CleanNetworkUnknowException(message: "$e");
    }
  }
}

class CleanNetworkToolsConfig {
  final List<InstanceConfig>? instanceConfigs;
  final CleanNetworkInjector injector;

  const CleanNetworkToolsConfig({
    this.instanceConfigs = const [],
    this.injector = const CleanNetworkInjector(),
  });
}
