import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Lte implements Comparison {
  final double v1;
  final double lte;
  const Lte(this.v1, {required this.lte});

  @override
  String log() => "$v1 <= $lte";

  @override
  bool resolve() => v1 <= lte;
}
