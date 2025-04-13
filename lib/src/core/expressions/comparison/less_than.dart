import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Lt implements Comparison {
  final double v1;
  final double lt;
  const Lt(this.v1, {required this.lt});

  @override
  String log() => "$v1 < $lt";

  @override
  bool resolve() => v1 < lt;
}
