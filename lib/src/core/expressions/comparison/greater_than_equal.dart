import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Gte implements Comparison {
  final double v1;
  final double gte;
  const Gte(this.v1, {required this.gte});

  @override
  String log() => "$v1 >= $gte";

  @override
  bool resolve() => v1 >= gte;
}
