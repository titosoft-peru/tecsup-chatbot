import '../../domain/entities/query_result.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;
  ChatRepositoryImpl(this.remoteDatasource);

  @override
  Future<String> submitQuestion(String question) {
    return remoteDatasource.submitQuestion(question);
  }

  @override
  Future<QueryResult?> pollResult(String requestId) {
    return remoteDatasource.pollResult(requestId);
  }
}
