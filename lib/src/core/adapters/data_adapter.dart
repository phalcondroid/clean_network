import 'package:clean_network/src/core/adapters/data_options.dart';

abstract class DataAdapter {
  Future<List<Map<String, dynamic>>> get(String path, DataOptions options);
  Future<dynamic> getOne(String path, DataOptions options);
  Future<T?> save<T>(
    String path,
    List<Map<String, dynamic>> data, {
    DataOptions? options,
  });
  Future<bool> update(
    String path,
    List<Map<String, dynamic>> data, {
    DataOptions? options,
  });
  Future<bool> remove(String path, {DataOptions? options});
  Future<void> clear(String path);
}
