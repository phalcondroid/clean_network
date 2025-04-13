import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Parenthesis implements StatementExpression {
  final StatementExpression expression;
  const Parenthesis(this.expression);

  @override
  String log() => "(${expression.resolve()})";

  @override
  bool resolve() => (expression.resolve());
}
