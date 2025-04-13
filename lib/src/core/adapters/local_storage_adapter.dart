import 'dart:convert';

import 'package:clean_network/src/core/adapters/data_adapter.dart';
import 'package:clean_network/src/core/adapters/local_storage_options.dart';
import 'package:clean_network/src/core/mapper/mapper_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageAdapter extends DataAdapter {
  @override
  Future<List<Map<String, dynamic>>> get(
    String path,
    covariant LocalStorageOptions options,
  ) async {
    var box = await Hive.openBox(path);
    if (!box.isOpen) {
      box = await Hive.openBox(path);
    }
    var hiveResult = box.get(path) ?? [];
    var mapper = MapperHelper(hiveResult);
    var mappedResult = mapper.mapSources(hiveResult);
    var result =
        (mappedResult as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
    print("hive [get]: count: ${result.length}");
    return result;
  }

  @override
  Future<Map<String, dynamic>> getOne(
    String path,
    covariant LocalStorageOptions options,
  ) async {
    var box = await Hive.openBox(path);
    if (!box.isOpen) {
      box = await Hive.openBox(path);
    }
    var rawResult = box.get(path);
    if (rawResult == null) {
      return {};
    }
    List<Map<String, dynamic>> result = rawResult;
    print("hive [get one]: ${result.firstOrNull}");
    if (result.isEmpty) {
      return {};
    }
    return result.first;
  }

  @override
  Future<bool> remove(
    String path, {
    covariant LocalStorageOptions? options,
  }) async {
    var box = await Hive.openBox(path);
    if (!box.isOpen) {
      box = await Hive.openBox(path);
    }
    return true;
  }

  @override
  Future<T> save<T>(
    String path,
    List<Map<String, dynamic>> data, {
    covariant LocalStorageOptions? options,
  }) async {
    var box = await Hive.openBox(path);
    if (!box.isOpen) {
      box = await Hive.openBox(path);
    }
    await box.put(path, data);
    print("hive [save]: $data");
    return {} as T;
  }

  @override
  Future<bool> update(
    String path,
    List<Map<String, dynamic>> data, {
    covariant LocalStorageOptions? options,
  }) async {
    await remove(path, options: options);
    await save(path, data, options: options);
    return true;
  }

  @override
  Future<void> clear(String path) async {
    var box = await Hive.openBox(path);
    if (!box.isOpen) {
      box = await Hive.openBox(path);
    }
    await box.clear();
  }
}
