import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Eq implements Comparison {
  final dynamic v1;
  final dynamic eq;
  const Eq(this.v1, {required this.eq});

  @override
  String log() => "$v1 == $eq";

  @override
  bool resolve() => v1 == eq;
}
