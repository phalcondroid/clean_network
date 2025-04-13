import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class IterableFilter<T> implements Comparison {
  final List<T> items;
  final StatementExpression Function(T item) expr;

  const IterableFilter(this.items, this.expr);

  @override
  String log() {
    return "";
  }

  @override
  bool resolve() => items.any((T i) => expr(i).resolve());
}
