import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class Or implements Logical {
  final StatementExpression v1;
  final StatementExpression or;
  const Or(this.v1, {required this.or});

  @override
  String log() => "(${v1.resolve()} || ${or.resolve()})";

  @override
  bool resolve() => (v1.resolve() || or.resolve());
}
