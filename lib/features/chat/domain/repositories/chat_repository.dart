import '../entities/query_result.dart';

abstract class ChatRepository {
  Future<String> submitQuestion(String question);
  Future<QueryResult?> pollResult(String requestId);
}
