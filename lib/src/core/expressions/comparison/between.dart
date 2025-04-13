import 'package:clean_network/src/core/expressions/comparison/greater_than_equal.dart';
import 'package:clean_network/src/core/expressions/comparison/less_than_equal.dart';
import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';
import 'package:clean_network/src/core/expressions/logical/and.dart';

class Between implements Comparison {
  final double value;
  final (double, double) and;

  Between(this.value, {required this.and});

  @override
  String log() => "($value ${and.$1}) and ${and.$2})";

  @override
  bool resolve() =>
      And(Gte(value, gte: and.$1), and: Lte(value, lte: and.$2)).resolve();
}
