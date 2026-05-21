import '../../domain/entities/query_result.dart';

class ChatResultModel extends QueryResult {
  const ChatResultModel({
    required super.requestId,
    required super.question,
    required super.sqlQuery,
    required super.source,
    required super.columns,
    required super.rows,
    required super.rowCount,
    required super.executionTimeMs,
    required super.naturalLanguageResponse,
  });

  factory ChatResultModel.fromJson(String requestId, Map<String, dynamic> data) {
    final rawRows = data['rows'] as List<dynamic>? ?? [];
    return ChatResultModel(
      requestId: requestId,
      question: data['question'] as String? ?? '',
      sqlQuery: data['sql_query'] as String? ?? '',
      source: data['source'] as String? ?? '',
      columns: List<String>.from(data['columns'] as List? ?? []),
      rows: rawRows
          .map((r) => List<dynamic>.from(r as List))
          .toList(),
      rowCount: data['row_count'] as int? ?? 0,
      executionTimeMs: data['execution_time_ms'] as int? ?? 0,
      naturalLanguageResponse: data['natural_language_response'] as String? ?? '',
    );
  }
}
