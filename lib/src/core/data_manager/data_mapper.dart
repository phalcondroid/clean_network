import 'package:clean_network/src/core/expressions/contracts/expressions_contracts.dart';

class DataMapper<T> {
  const DataMapper(this.data);

  final List<T> data;

  List<T> get(StatementExpression criteria) {
    return [{}] as List<T>;
  }

  T getOne(StatementExpression criteria) {
    return {} as T;
  }
}
