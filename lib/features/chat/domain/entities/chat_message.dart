import 'package:equatable/equatable.dart';
import 'query_result.dart';

enum MessageRole { user, assistant }

enum MessageStatus { sending, loading, done, error }

class ChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String text;
  final MessageStatus status;
  final QueryResult? result;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.status,
    this.result,
    required this.createdAt,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    QueryResult? result,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      status: status ?? this.status,
      result: result ?? this.result,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, role, text, status, result, createdAt];
}
