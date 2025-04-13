import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

class UuidPrimaryKey implements JsonConverter<String, String> {
  const UuidPrimaryKey();

  @override
  String fromJson(String uuid) {
    if (uuid.isEmpty) {
      return const Uuid().v1();
    }
    return uuid;
  }

  @override
  String toJson(String uuid) {
    if (uuid.isEmpty) {
      return const Uuid().v1();
    }
    return uuid;
  }
}