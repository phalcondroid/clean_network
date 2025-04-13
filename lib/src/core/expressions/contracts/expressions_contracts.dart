abstract interface class StatementExpression {
  bool resolve();
  String log();
}

abstract interface class Logical implements StatementExpression {
  @override
  bool resolve();
}

abstract interface class Comparison implements StatementExpression {
  @override
  bool resolve();
}