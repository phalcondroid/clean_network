import 'package:shared_preferences/shared_preferences.dart';

class CleanNetworkContainer {
  final Map<String, dynamic>? content;

  const CleanNetworkContainer({this.content = const {}});

  T getContent<T>(String key) {
    return content?[key] as T;
  }

  setContent<T>(String key, T val) {
    content?[key] = val;
  }

  bool exist(String key) => content!.containsKey(key);

  bool remove(String key) => content!.remove(key) != null ? true : false;

  Future<bool> isStored(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> removePersistent(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  Future<T?> getPersistent<T>(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? result = prefs.get(key);
    if (result is double) {
      return prefs.getDouble(key) as T;
    } else if (result is String) {
      return prefs.getString(key) as T;
    } else if (result is int) {
      return prefs.getInt(key) as T;
    } else if (result is bool) {
      return prefs.getBool(key) as T;
    }
    return result as T?;
  }

  Future<bool> persist<T>(String key, T value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Type type = T;
      if (type == double) {
        return prefs.setDouble(key, value as double);
      } else if (type == String) {
        return prefs.setString(key, value as String);
      } else if (type == int) {
        return prefs.setInt(key, value as int);
      } else if (type == bool) {
        return prefs.setBool(key, value as bool);
      }
      return await prefs.setString(key, value.toString());
    } catch (e) {
      return false;
    }
  }
}
