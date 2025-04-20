import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_network/src/helpers/metadata_extractor.dart';
import 'package:clean_network_annotations/clean_network_annotations.dart';
import 'package:source_gen/source_gen.dart';
import '../visitor/model_visitor.dart';

class RestRepositoryGenerator extends GeneratorForAnnotation<RestRepository> {
  String url = '';
  String connection = '';
  bool localMethods = false;

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();

    element.visitChildren(
      visitor,
    ); // Visits all the children of element in no particular order.

    final className = visitor.className; // EX: 'ModelGen' for 'Model'.

    final classBuffer = StringBuffer();

    url = annotation.peek('path')?.stringValue ?? '';
    connection = annotation.peek('connection')?.stringValue ?? '';

    classBuffer.writeln('class _$className implements $className  {');
    resolveMethods(classBuffer, visitor.methods);
    classBuffer.writeln('}');

    return classBuffer.toString();
  }

  (bool, String) checkSimpleReturn(String modelName) {
    bool simpleReturn = false;
    if (modelName.contains("bool")) {
      modelName = "return true;";
      simpleReturn = true;
    }
    if (modelName.contains("String")) {
      modelName = "return '';";
      simpleReturn = true;
    }
    if (modelName.contains("double")) {
      modelName = "return 1.0;";
      simpleReturn = true;
    }
    if (modelName.contains("int")) {
      modelName = "return 1;";
      simpleReturn = true;
    }
    if (modelName.contains("void")) {
      modelName = "";
      simpleReturn = true;
    }
    return (simpleReturn, modelName);
  }

  void resolveMethods(
    StringBuffer classBuffer,
    Map<String, Map<String, dynamic>> methods,
  ) {
    try {
      methods.forEach((methodName, methodData) {
        methodData["url"] = url + methodData["url"];

        classBuffer.writeln("@override");
        List<String> methodParams = [];
        methodData["params"].forEach(
          (key, value) => methodParams.add(value["raw"].toString()),
        );
        classBuffer.writeln(
          "${methodData["return"]} $methodName(${methodParams.join(",")}) async {",
        );

        classBuffer.writeln("\t try {");

        classBuffer.writeln(
          "\t var container = GetIt.I<CleanNetworkContainer>();",
        );

        bool asList = methodData["return"].toString().contains("List<");

        if (methodData["type"] == "get") {
          printForGetMethod(classBuffer, asList, methodData);
        }

        print("===>>>> method type ${methodData["type"]}");
        if (methodData["type"] == "post") {
          printForPostMethod(classBuffer, asList, methodData);
        }

        if (methodData["type"] == "getLocalStorage") {
          printGetLocalStorage(classBuffer, asList, methodData);
        }

        if (methodData["type"] == "saveLocalStorage") {
          printSaveLocalStorage(classBuffer, asList, methodData);
        }

        if (methodData["type"] == "deleteLocalStorage") {
          printDeleteLocalStorage(classBuffer, asList, methodData);
        }

        if (methodData["type"] == "purgeLocalStorage") {
          printPurgeLocalStorage(classBuffer, asList, methodData);
        }

        /*classBuffer
            .writeln("\t } on dynamic catch (e) { throw CleanNetworkException(\"\$e\"); }");*/
        classBuffer.writeln(
          "\t } on dynamic catch (e, s) { "
          "throw CleanNetworkHttpException("
          "message: e,"
          "stackTrace: s,"
          "error: e?.error,"
          "response: CleanNetworkHttpExceptionResponse("
          "    data: e?.response?.data,"
          "    extra: e?.response?.extra,"
          "    headers: e?.response?.headers?.map,"
          "    isRedirect: e?.response?.isRedirect ?? false,"
          "    statusCode: e?.response?.statusCode,"
          "    statusMessage: e?.response?.statusMessage),"
          "requestInfo: CleanNetworkHttpExceptionData("
          "    type: getExceptionType(e?.type),"
          "    baseUrl: e?.requestOptions.baseUrl,"
          "    data: e?.requestOptions?.data,"
          "    headers: e?.requestOptions?.headers,"
          "    method: e?.requestOptions?.method,"
          "    path: e?.requestOptions?.path,"
          "    queryParams: e?.requestOptions?.queryParameters,"
          "    uri: e?.requestOptions?.uri)); }",
        );
        classBuffer.writeln("}");
      });
    } catch (e, s) {
      print("Generator ---->>>>>>: $e, stackTrace: $s");
    }
  }

  void printPurgeLocalStorage(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    List<String> methodParams = [];
    methodData["params"].forEach(
      (key, value) => methodParams.add(value["raw"].toString()),
    );
    String dataType = methodParams.join().split(" ").first;
    String dataType2 = methodParams.join().split(" ")[1];
    asList = dataType.toLowerCase().contains("list");
    if (asList) {
      classBuffer.writeln(
        "throw CleanNetworkException('List params are not allowed in purge method!');",
      );
      return;
    }
    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    bool simpleReturn = false;
    String modelName = MedatadaExtractor.cleanModelName(dataType);
    (simpleReturn, modelName) = checkSimpleReturn(modelName);
    classBuffer.writeln("await localAdapter.clear('$modelName');");
  }

  void printDeleteLocalStorage(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    List<String> methodParams = [];
    methodData["params"].forEach(
      (key, value) => methodParams.add(value["raw"].toString()),
    );
    String dataType = methodParams.join().split(" ").first;
    String strParam = methodParams.join().split(" ")[1];
    asList = dataType.toLowerCase().contains("list");
    String modelName = MedatadaExtractor.cleanModelName(dataType);

    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    classBuffer.writeln(
      "List<Map<String, dynamic>> originalDataList = await localAdapter.get('$modelName', const LocalStorageOptions());",
    );
    String keyModelItem =
        '${"${modelName[0].toLowerCase()}${modelName.substring(1)}"}PkUuid';

    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value['raw'].toString().contains("List<"))) {
        classBuffer.writeln(
          "for(var m in $strParam) { originalDataList.removeWhere((e) => m.$keyModelItem == e['$keyModelItem']); }",
        );
      } else {
        classBuffer.writeln(
          "originalDataList.removeWhere((e) => $strParam.$keyModelItem == e['$keyModelItem']);",
        );
      }
      classBuffer.writeln("await localAdapter.clear('$modelName');");
      classBuffer.writeln(
        "await localAdapter.save('$modelName', originalDataList);",
      );
    });
    bool simpleReturn = false;
    (simpleReturn, modelName) = checkSimpleReturn(dataType);
    // classBuffer.writeln(modelName);
  }

  void printSaveLocalStorage(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    List<String> methodParams = [];
    methodData["params"].forEach(
      (key, value) => methodParams.add(value["raw"].toString()),
    );
    String dataType = methodParams.join().split(" ").first;
    String strParam = methodParams.join().split(" ")[1];
    asList = dataType.toLowerCase().contains("list");
    String modelName = MedatadaExtractor.cleanModelName(dataType);
    String startList = asList ? "List<" : "";
    String endList = asList ? ">" : "";
    String addFilter = '';
    bool simpleReturn = false;
    (simpleReturn, modelName) = checkSimpleReturn(modelName);

    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    classBuffer.writeln(
      "List<Map<String, dynamic>> originalDataList = await localAdapter.get('$modelName', const LocalStorageOptions());",
    );
    String keyModelItem =
        '${"${modelName[0].toLowerCase()}${modelName.substring(1)}"}PkUuid';

    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value['type'] == "where")) {
        addFilter = ".where(${value['name']}).toList()";
      }
      classBuffer.writeln("List<Map<String, dynamic>> preparedList = [];");
      classBuffer.writeln("if (originalDataList.isNotEmpty) {");
      if ((value['raw'].toString().contains("List<"))) {
        classBuffer.writeln("preparedList = originalDataList.map((m) {");
        classBuffer.writeln("if (m.containsKey('$keyModelItem')) {");
        classBuffer.writeln(
          "var modelFound = $strParam.where((e) => e.$keyModelItem == m['$keyModelItem']).firstOrNull;",
        );
        classBuffer.writeln("if (modelFound != null) {");
        classBuffer.writeln(
          "$strParam.removeWhere((e) => e.$keyModelItem == m['$keyModelItem']);",
        );
        classBuffer.writeln("return modelFound.toJson();");
        classBuffer.writeln("}}");
        classBuffer.writeln("return m;");
        classBuffer.writeln("}).toList();");
        classBuffer.writeln("if ($strParam.isNotEmpty) {");
        classBuffer.writeln(
          "preparedList.addAll($strParam.map((e) => e.toJson()).toList());",
        );
        classBuffer.writeln("}");
        classBuffer.writeln(
          "} else { preparedList.addAll($strParam.map((e) => e.toJson()).toList()); }",
        );
      } else {
        classBuffer.writeln(
          "var modelFound = originalDataList.where((m) => $strParam.$keyModelItem == m['$keyModelItem']).firstOrNull;",
        );
        classBuffer.writeln("preparedList = originalDataList.map((m) {");
        classBuffer.writeln(
          "if ($strParam.$keyModelItem == m['$keyModelItem']) {",
        );
        classBuffer.writeln("return $strParam.toJson();");
        classBuffer.writeln("}");
        classBuffer.writeln("return m;");
        classBuffer.writeln("}).toList();");
        classBuffer.writeln("if (modelFound == null || modelFound!.isEmpty) {");
        classBuffer.writeln("preparedList.addAll([$strParam.toJson()]);");
        classBuffer.writeln("}");
        classBuffer.writeln(
          "} else { preparedList.addAll([$strParam.toJson()]); }",
        );
      }
      classBuffer.writeln("await localAdapter.clear('$modelName');");
      classBuffer.writeln(
        "await localAdapter.save('$modelName', preparedList);",
      );
      startList = asList ? "preparedList.map((item) => " : "";
      endList = asList ? ").toList()$addFilter" : "";
      String listValue = asList ? "item" : "$strParam.toJson()";
      String fromExtension = "";
      String genericModelName = MedatadaExtractor.getGenericClassName(
        methodData["return"],
      );
      if (modelName.contains("BaseSingleResponse") ||
          modelName.contains("BaseListResponse") &&
              genericModelName.isNotEmpty) {
        fromExtension =
            ",(Object? raw) { return $genericModelName.fromJson(raw as Map<String, Object?>);}";
      }
      if (!simpleReturn) {
        classBuffer.writeln(
          "return $startList$modelName.fromJson($listValue$fromExtension)$endList;",
        );
      }
    });
  }

  printPurgeDataModel() {}

  void printGetLocalStorage(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    String modelName = MedatadaExtractor.cleanModelName(methodData["return"]);
    bool simpleReturn = false;
    (simpleReturn, modelName) = checkSimpleReturn(modelName);
    bool notStartOne = asList;

    String addFilter = "";
    bool thereIsListener = false;
    bool isWhere = false;
    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value['type'] == "where")) {
        addFilter = ".where(${value['name']}).toList()";
        isWhere = true;
        asList = true;
      }
      if ((value['type'] == "storageListener")) {
        thereIsListener = true;
      }
    });
    String startList = asList ? "List<" : "";
    String endList = asList ? ">" : "";
    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    classBuffer.writeln(
      "${startList}Map<String, dynamic>$endList rawResponse = ${asList ? "[]" : "{}"};",
    );
    String adapterMethod = asList ? "get" : "getOne";
    adapterMethod = isWhere ? "get" : adapterMethod;
    if (!simpleReturn) {
      classBuffer.writeln(
        "rawResponse = await localAdapter.$adapterMethod('${modelName + (methodData["cache"] ?? "")}', const LocalStorageOptions());",
      );
    }
    startList = asList ? "rawResponse.map((item) => " : "";
    endList = asList ? ").toList()$addFilter" : "";
    String fromExtension = "";
    String genericModelName = MedatadaExtractor.getGenericClassName(
      methodData["return"],
    );
    if (modelName.contains("BaseSingleResponse") ||
        modelName.contains("BaseListResponse") && genericModelName.isNotEmpty) {
      fromExtension =
          ",(Object? raw) { return $genericModelName.fromJson(raw as Map<String, Object?>);}";
    }
    String listValue = asList ? "item" : "rawResponse";
    String returnData =
        "$startList$modelName.fromJson($listValue$fromExtension)$endList";
    if (thereIsListener) {
      classBuffer.writeln(
        "await listener($returnData, '$modelName', localAdapter);",
      );
      if (!simpleReturn) {
        classBuffer.writeln(
          "rawResponse = await localAdapter.$adapterMethod('${modelName + (methodData["cache"] ?? "")}', const LocalStorageOptions());",
        );
      }
    }
    if (isWhere && !notStartOne) {
      classBuffer.writeln(
        "return rawResponse.map((e)=> $modelName.fromJson(e$fromExtension)).toList()$addFilter.firstOrNull;",
      );
      return;
    }
    String modelReturn = "return $returnData;";
    classBuffer.writeln(simpleReturn ? modelName : modelReturn);
  }

  ///
  /// Print for post http method
  ///
  void printForPostMethod(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    classBuffer.writeln(
      "\t var adapter = HttpAdapter(http: container.getContent('__connection__$connection'));",
    );
    String modelName = MedatadaExtractor.cleanModelName(methodData["return"]);
    bool simpleReturn = false;
    (simpleReturn, modelName) = checkSimpleReturn(modelName);

    var addFilter = "";
    String startList = asList ? "List<" : "";
    String endList = asList ? ">" : "";
    String adapterMethod = asList ? "saveAndGetList" : "saveAndGetOne";
    bool isList = false;
    String genericListModelName = MedatadaExtractor.getGenericListClassName(
      methodData["return"],
    );
    if (modelName.contains("BaseListResponse") ||
        modelName.contains("BaseSingleResponse") &&
            genericListModelName.isNotEmpty) {
      isList = true;
    }

    var queryParamsMap = {};
    bool thereIsListener = false;
    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value["type"] == "query")) {
        queryParamsMap.addAll(value["query"]);
      }
      if (value.containsKey("path")) {
        methodData["url"] += "/\$" + value["name"] + "";
      }
      if ((value['type'] == "where")) {
        addFilter = ".where(${value['name']}).toList()";
      }
      if ((value['type'] == "storageListener")) {
        thereIsListener = true;
      }
    });

    List<String> httpOptionsParams = [];
    if (queryParamsMap.isNotEmpty) {
      httpOptionsParams.add('queries: $queryParamsMap');
    }
    if (methodData.containsKey("headers") &&
        methodData["headers"].toString().isNotEmpty) {
      httpOptionsParams.add('headers: ${methodData["headers"]}');
    }

    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    classBuffer.writeln(
      "${startList}Map<String, dynamic>$endList rawResponse = ${asList ? "[]" : "{}"};",
    );

    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value.containsKey("postRequestModel"))) {
        String header = "";
        if (methodData.containsKey("headers") &&
            methodData["headers"].toString().isNotEmpty) {
          header = 'headers: ${methodData["headers"]}';
        }
        classBuffer.writeln(
          "rawResponse = await adapter.$adapterMethod('${methodData["url"]}', [ " +
              "${value["name"]}.toJson() ], options: HttpOptions(${httpOptionsParams.join(', ')}));",
        );
      }
    });
    if (!simpleReturn) {
      classBuffer.writeln("await localAdapter.clear('$modelName');");
    }
    startList = asList ? "rawResponse.map((item) => " : "";
    endList = asList ? ").toList()$addFilter" : "";
    String fromExtension = "";
    String genericModelName = MedatadaExtractor.getGenericClassName(
      methodData["return"],
    );
    if (modelName.contains("BaseSingleResponse") ||
        modelName.contains("BaseResponse") && genericModelName.isNotEmpty) {
      fromExtension =
          ",(Object? raw) { return $genericModelName.fromJson(raw as Map<String, Object?>);}";
    }

    if (modelName.contains("BaseListResponse") ||
        modelName.contains("BaseResponse") && genericListModelName.isNotEmpty) {
      fromExtension =
          ",(Object? raw) { return $genericListModelName.fromJson(raw as Map<String, Object?>);}";
    }

    String listValue = asList ? "item" : "rawResponse";
    String returnData =
        "$startList$modelName.fromJson($listValue$fromExtension)$endList";
    if (thereIsListener) {
      classBuffer.writeln(
        "await listener($returnData, '$modelName', localAdapter);",
      );
      if (!simpleReturn) {
        classBuffer.writeln(
          "rawResponse = await localAdapter.$adapterMethod('$modelName', const LocalStorageOptions());",
        );
      }
    }
    String modelReturn = "return $returnData;";
    classBuffer.writeln(simpleReturn ? modelName : modelReturn);
  }

  ///
  /// Print for http GET
  ///
  void printForGetMethod(
    StringBuffer classBuffer,
    bool asList,
    Map<String, dynamic> methodData,
  ) {
    classBuffer.writeln(
      "\t var adapter = HttpAdapter(http: container.getContent('__connection__$connection'));",
    );
    String modelName = MedatadaExtractor.cleanModelName(methodData["return"]);
    var httpOptionsMethodName = "HttpOptions";
    var addFilter = "";
    String startList = asList ? "List<" : "";
    String endList = asList ? ">" : "";
    String adapterMethod = asList ? "get" : "getOne";
    bool thereIsListener = false;
    bool isList = false;
    String genericModelName = MedatadaExtractor.getGenericClassName(
      methodData["return"],
    );
    String genericListModelName = MedatadaExtractor.getGenericListClassName(
      methodData["return"],
    );
    if (modelName.contains("BaseListResponse") ||
        modelName.contains("BaseSingleResponse") &&
            genericListModelName.isNotEmpty) {
      isList = true;
    }

    var queryParamsMap = {};
    httpOptionsMethodName = "HttpOptions";
    methodData["params"].forEach((key, Map<String, dynamic> value) {
      if ((value.containsKey("query"))) {
        queryParamsMap.addAll(value["query"]);
      }
      if (value.containsKey("path")) {
        methodData["url"] += "/\$" + value["name"] + "";
      }
      if ((value.containsKey("where"))) {
        addFilter = ".where(${value['name']}).toList()";
      }
      if (value.containsKey('storageListener')) {
        thereIsListener = true;
      }
    });

    List<String> httpOptionsParams = [];
    if (queryParamsMap.isNotEmpty) {
      httpOptionsParams.add('queries: $queryParamsMap');
    }
    if (methodData.containsKey("headers") &&
        methodData["headers"].toString().isNotEmpty) {
      httpOptionsParams.add('headers: ${methodData["headers"]}');
    }

    classBuffer.writeln(
      "LocalStorageAdapter localAdapter = GetIt.I<LocalStorageAdapter>();",
    );
    classBuffer.writeln(
      "${startList}Map<String, dynamic>$endList rawResponse = ${isList ? "{};" : "await localAdapter.$adapterMethod('${modelName + (methodData["cache"] ?? "")}', const LocalStorageOptions());"}",
    );
    classBuffer.writeln("if (rawResponse.isEmpty) {");
    classBuffer.writeln("rawResponse = await adapter.$adapterMethod(");
    classBuffer.writeln("'${methodData["url"]}',");
    classBuffer.writeln(
      "$httpOptionsMethodName(${httpOptionsParams.join(",")})",
    );
    classBuffer.writeln(");");
    classBuffer.writeln(
      isList
          ? ""
          : "await localAdapter.save('${modelName + (methodData["cache"] ?? "")}', ${asList ? 'rawResponse' : '[rawResponse]'},"
              " options: const LocalStorageOptions());",
    );
    classBuffer.writeln("}");
    startList = asList ? "rawResponse.map((item) => " : "";
    endList = asList ? ").toList()$addFilter" : "";
    String listValue = asList ? "item" : "rawResponse";
    String fromExtension = "";

    if (modelName.contains("BaseSingleResponse") ||
        modelName.contains("BaseResponse") && genericModelName.isNotEmpty) {
      fromExtension =
          ",(Object? raw) { return $genericModelName.fromJson(raw as Map<String, Object?>);}";
    }

    if (modelName.contains("BaseListResponse") ||
        modelName.contains("BaseResponse") && genericListModelName.isNotEmpty) {
      fromExtension =
          ",(Object? raw) { return $genericListModelName.fromJson(raw as Map<String, Object?>);}";
    }

    print("${startList} $modelName $fromExtension");

    String modelReturn =
        "$startList$modelName.fromJson($listValue$fromExtension)$endList";
    if (thereIsListener) {
      classBuffer.writeln(
        "await listener($modelReturn, '$modelName', localAdapter);",
      );
      classBuffer.writeln(
        "rawResponse = await localAdapter.$adapterMethod('${modelName + (methodData["cache"] ?? "")}', const LocalStorageOptions());",
      );
    }
    classBuffer.writeln("return $modelReturn;");
  }
}
