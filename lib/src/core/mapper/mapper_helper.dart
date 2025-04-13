import 'dart:convert';

class MapperHelper {

  final dynamic data;
  
  const MapperHelper(this.data);

  dynamic mapSources(dynamic item) {
    String type = item.runtimeType.toString();
    // print("----> di type [$type]");
    if (type.startsWith("_List") || type.startsWith("List")) {
      var s = item.map((element) => mapSources(element)).toList();
      // print("when is a list $s");
      return s;
    }
    if (type.startsWith("_Map") || type.startsWith("Map") || type.startsWith("MappedListIterable")) {
      Map<String, dynamic> auxMap = {};
      item.forEach((k, v) {
        auxMap.addAll({ k.toString(): mapSources(v) });
      });
      // print("whens map ${item} :${auxMap}");
      return auxMap;
    }
    if (type.startsWith("bool")) {
      return item as bool;
    }
    if (type.startsWith("double")) {
      return item as double;
    }
    if (type.startsWith("int")) {
      return item as int;
    }
    if (type.startsWith("String")) {
      return item as String;
    }
    return item;
  }

  get2() {
    return mapSources(data);
  }

  T get<T>() {
    return mapSources(data);
  }
}