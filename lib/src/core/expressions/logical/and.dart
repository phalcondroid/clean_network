import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class And implements Logical {
  final StatementExpression v1;
  final StatementExpression and;
  const And(this.v1, {required this.and});

  @override
  String log() => "(${v1.resolve()} && ${and.resolve()})";

  @override
  bool resolve() => (v1.resolve() && and.resolve());
}
