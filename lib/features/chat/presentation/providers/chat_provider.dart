import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/process_question_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';

class ChatProvider extends ChangeNotifier {
  final ProcessQuestionUseCase _processQuestion;
  final ApiClient _apiClient;

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  AuthProvider? _authProvider;
  bool _wasAuthenticated = false;

  ChatProvider({
    required ProcessQuestionUseCase processQuestion,
    required ApiClient apiClient,
  })  : _processQuestion = processQuestion,
        _apiClient = apiClient;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  void updateAuth(AuthProvider auth) {
    final isNowAuthenticated = auth.isAuthenticated;
    final sessionChanged = _wasAuthenticated != isNowAuthenticated;

    _wasAuthenticated = isNowAuthenticated;
    _authProvider = auth;
    _apiClient.setToken(auth.token?.accessToken);
    _apiClient.onUnauthorized = () => _authProvider?.forceLogout();

    if (sessionChanged) {
      _messages.clear();
      notifyListeners();
    }
  }

  static const _destructivePattern =
      r'\b(elimina[r]?|borra[r]?|suprime[r]?|elimine|borre|suprima|'
      r'actualiza[r]?|modifica[r]?|edita[r]?|actualice|modifique|cambia[r]?|cambie|'
      r'inserta[r]?|agrega[r]?|crea[r]?|añade[r]?|inserte|agregue|cree|añada|'
      r'drop|trunca[r]?|truncate|delete|update|insert|alter)\b';

  static const _readonlyNotice =
      'Solo puedo consultar información. No puedo eliminar, modificar ni insertar datos. '
      'Prueba con una pregunta como: "¿Cuál es el último cliente registrado?"';

  Future<void> sendMessage(String question) async {
    if (_isSending || question.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: question.trim(),
      status: MessageStatus.done,
      createdAt: DateTime.now(),
    );

    _messages.add(userMsg);

    if (_isDestructive(question)) {
      _messages.add(ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_bot',
        role: MessageRole.assistant,
        text: _readonlyNotice,
        status: MessageStatus.error,
        createdAt: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    final botMsgId = '${DateTime.now().millisecondsSinceEpoch}_bot';
    _messages.add(ChatMessage(
      id: botMsgId,
      role: MessageRole.assistant,
      text: '',
      status: MessageStatus.loading,
      createdAt: DateTime.now(),
    ));
    _isSending = true;
    notifyListeners();

    try {
      final result = await _processQuestion(question.trim());
      _updateMessage(
        botMsgId,
        text: result.naturalLanguageResponse,
        status: MessageStatus.done,
        result: result,
      );
    } on AuthFailure {
      // Token expirado: forceLogout ya fue llamado desde onUnauthorized.
      // Eliminamos la burbuja de carga silenciosamente; _AuthGate redirige al login.
      _messages.removeWhere((m) => m.id == botMsgId);
    } catch (e) {
      _updateMessage(
        botMsgId,
        text: e.toString().replaceFirst('Exception: ', ''),
        status: MessageStatus.error,
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  bool _isDestructive(String question) =>
      RegExp(_destructivePattern, caseSensitive: false)
          .hasMatch(question.toLowerCase());

  void _updateMessage(
    String id, {
    required String text,
    required MessageStatus status,
    dynamic result,
  }) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    _messages[idx] = _messages[idx].copyWith(
      text: text,
      status: status,
      result: result,
    );
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
