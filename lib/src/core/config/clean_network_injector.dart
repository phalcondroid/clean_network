import 'package:get_it/get_it.dart';

class CleanNetworkInjector {
  final Future<void> Function(GetIt injector)? inject;

  const CleanNetworkInjector({this.inject});
}
