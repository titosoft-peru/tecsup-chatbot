import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_result_model.dart';

abstract class ChatRemoteDatasource {
  Future<String> submitQuestion(String question);
  Future<ChatResultModel?> pollResult(String requestId);
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final ApiClient apiClient;
  ChatRemoteDatasourceImpl(this.apiClient);

  @override
  Future<String> submitQuestion(String question) async {
    final data = await apiClient.post(
      ApiConstants.process,
      {'question': question},
    );
    return data['request_id'] as String;
  }

  @override
  Future<ChatResultModel?> pollResult(String requestId) async {
    final data = await apiClient.get(ApiConstants.result(requestId));
    final status = data['status'] as String?;

    // El backend devuelve 'failed' con el mensaje de error en el nivel raíz
    if (status == 'failed') {
      final msg = data['message'] as String? ?? 'El servidor no pudo procesar la consulta.';
      throw Exception(msg);
    }

    if (status != 'completed') return null; // 'processing' → seguir polling

    final resultData = data['data'] as Map<String, dynamic>?;
    if (resultData == null) return null;

    return ChatResultModel.fromJson(requestId, resultData);
  }
}
