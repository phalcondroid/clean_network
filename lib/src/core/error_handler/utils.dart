import 'package:clean_network/clean_network.dart';
import 'package:dio/dio.dart';

CleanNetworkHttpExceptionType getExceptionType(DioExceptionType type) =>
    switch (type) {
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
