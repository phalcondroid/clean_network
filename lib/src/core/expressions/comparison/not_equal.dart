import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class NotEq implements Comparison {
  final dynamic v1;
  final dynamic notEq;
  const NotEq(this.v1, {required this.notEq});

  @override
  String log() => "$v1 != $notEq";

  @override
  bool resolve() => v1 != notEq;
}
