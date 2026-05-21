import 'package:equatable/equatable.dart';

class QueryResult extends Equatable {
  final String requestId;
  final String question;
  final String sqlQuery;
  final String source;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final int rowCount;
  final int executionTimeMs;
  final String naturalLanguageResponse;

  const QueryResult({
    required this.requestId,
    required this.question,
    required this.sqlQuery,
    required this.source,
    required this.columns,
    required this.rows,
    required this.rowCount,
    required this.executionTimeMs,
    required this.naturalLanguageResponse,
  });

  @override
  List<Object> get props => [requestId, question, sqlQuery];
}
