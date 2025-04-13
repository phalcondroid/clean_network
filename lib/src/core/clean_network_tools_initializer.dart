import 'package:clean_network/src/core/container/clean_network_container.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_network/clean_network.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CleanNetworkToolsInitializer {
  final CleanNetworkToolsConfig config;

  const CleanNetworkToolsInitializer({required this.config});

  Future<void> init() async {
    print("CleanNetwork tools is initializing....");
    await initLocalStorage();
    GetIt.instance.registerSingleton<Dio>(Dio());
    GetIt.instance.registerSingleton<CleanNetworkContainer>(
      CleanNetworkContainer(content: {}),
    );
    GetIt.instance.registerSingleton<LocalStorageAdapter>(
      LocalStorageAdapter(),
    );
    if (config.injector.inject != null) {
      await config.injector.inject!(GetIt.I);
    }
    if (config.instanceConfigs!.isEmpty) {
      throw CleanNetworkException(
        "CleanNetwork instance config must be configured!",
      );
    }
    config.instanceConfigs?.forEach((instanceConfig) {
      instanceConfig.initConfig();
    });
    GetIt.instance.registerSingleton<CleanNetworkToolsConfig>(config);
  }

  Future<void> initLocalStorage() async {
    await Hive.initFlutter();
  }
}
