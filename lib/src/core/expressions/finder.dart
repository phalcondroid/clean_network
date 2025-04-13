import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Finder {
  final StatementExpression where;
  const Finder({required this.where});
  bool resolve() => where.resolve();
}
