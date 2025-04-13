import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Gt implements Comparison {
  final double v1;
  final double gt;
  const Gt(this.v1, {required this.gt});

  @override
  String log() => "$v1 > $gt";

  @override
  bool resolve() => v1 > gt;
}
