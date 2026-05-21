import 'dart:async';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/query_result.dart';
import '../repositories/chat_repository.dart';

class ProcessQuestionUseCase {
  final ChatRepository repository;
  ProcessQuestionUseCase(this.repository);

  Future<QueryResult> call(String question) async {
    final requestId = await repository.submitQuestion(question);
    final deadline = DateTime.now().add(ApiConstants.pollTimeout);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(ApiConstants.pollInterval);
      final result = await repository.pollResult(requestId);
      if (result != null) return result;
    }

    throw const TimeoutFailure();
  }
}
