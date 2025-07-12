import 'package:flutter_messenger/models/user.dart';

class Message {
  final int id;
  final int chatId;
  final int userId;
  final String? content;
  final DateTime createdAt;
  final bool edited;
  final bool deleted;
  final User sender;

  Message({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.sender,
    this.edited = false,
    this.deleted = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      edited: json['edited'] ?? false,
      deleted: json['deleted'] ?? false,
      sender: User.fromJson(json['sender']),
    );
  }
}
