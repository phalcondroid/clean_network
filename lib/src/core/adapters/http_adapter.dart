import 'package:dio/dio.dart';
import 'package:clean_network/src/core/adapters/data_adapter.dart';
import 'package:clean_network/src/core/adapters/http_options.dart';

class HttpAdapter implements DataAdapter {
  const HttpAdapter({required this.http});

  final dynamic http;

  @override
  Future<List<Map<String, dynamic>>> get(
    String path,
    covariant HttpOptions options,
  ) async {
    print('---- Dio [RequestType][Many]');
    List<Map<String, dynamic>> response =
        await _callInternalGet<List<Map<String, dynamic>>?>(
          path,
          options,
          "Many",
        ) ??
        [];
    print('---- Dio [RequestType][Many] #2 ${response}');
    return response;
  }

  @override
  Future<dynamic> getOne(String path, covariant HttpOptions options) async {
    Map<String, dynamic> prev = {};
    return await _callInternalGet<Map<String, dynamic>>(
          path,
          options,
          "Single",
        ) ??
        prev;
  }

  Future<T?> _callInternalGet<T>(
    String path,
    HttpOptions options,
    String type,
  ) async {
    String url = http.options.baseUrl + path;
    if (options.paths.isNotEmpty) {
      url += options.paths;
    }
    print('---- Dio [RequestType][$type][URL] $url');
    if (options.headers.isNotEmpty) {
      print(
        '---- Dio [RequestType][GET][$type][OPTIONS]; h: ${options.headers} p: ${options.paths} q: ${options.queries}}',
      );
      Response<T> response = await http.get<T>(
        url,
        queryParameters: options.queries,
        options: Options(headers: options.headers),
      );
      return response.data;
    }
    Response<T> response = await http.get<T>(url);
    return response.data;
  }

  @override
  Future<bool> remove(String path, {covariant HttpOptions? options}) async {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<T?> save<T>(
    String path,
    List<Map<String, dynamic>> data, {
    covariant HttpOptions? options,
  }) async {
    String url = http.options.baseUrl + path;
    print('---- Dio [RequestType][POST][Url]; $url');
    if (options!.headers.isNotEmpty) {
      Map<String, dynamic> headers = {};
      options.headers.forEach((key, value) {
        if (value != null) {
          headers[key] = value;
        }
      });

      Response<T> response = await http.post<T>(
        url,
        data: data.first,
        queryParameters: options.queries,
        options: Options(headers: headers),
      );
      return response.data;
    }
    Response<T> response = await http.post<T>(url, data: data.first);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> saveAndGetList(
    String path,
    List<Map<String, dynamic>> data, {
    covariant HttpOptions? options,
  }) async {
    List<Map<String, dynamic>> response =
        await save<List<Map<String, dynamic>>?>(path, data, options: options) ??
        [];
    return response;
  }

  Future<Map<String, dynamic>> saveAndGetOne(
    String path,
    List<Map<String, dynamic>> data, {
    covariant HttpOptions? options,
  }) async {
    Map<String, dynamic> response =
        await save<Map<String, dynamic>>(path, data, options: options) ?? {};
    return response;
  }

  @override
  Future<bool> update(
    String path,
    List<Map<String, dynamic>> data, {
    covariant HttpOptions? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> clear(String path) {
    throw UnimplementedError();
  }
}
