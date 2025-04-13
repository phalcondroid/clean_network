import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

enum LikeOperator { startsWith, wholeContent, endsWith }

class Like implements Comparison {
  final String v1;
  final String criteria;
  final LikeOperator operator;
  const Like(
    this.v1, {
    required this.criteria,
    this.operator = LikeOperator.wholeContent,
  });

  @override
  String log() => "$v1.contains($criteria)";

  @override
  bool resolve() => switch (operator) {
    LikeOperator.wholeContent => v1.contains(criteria),
    LikeOperator.startsWith => v1.startsWith(criteria),
    LikeOperator.endsWith => v1.endsWith(criteria),
  };
}
