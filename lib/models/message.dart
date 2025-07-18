import '/../models/user.dart';

class Message {
  final int id;
  final int userId;
  final String? content;
  final bool edited;
  final bool deleted;
  final bool isPhoto; // добавь это поле
  final String? imageUrl;
  final DateTime createdAt;
  final User sender;

  Message({
    required this.id,
    required this.userId,
    this.content,
    this.edited = false,
    this.deleted = false,
    this.isPhoto = false, // значение по умолчанию
    required this.createdAt,
    required this.sender,
    this.imageUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    userId: json['user_id'],
    content: json['content'],
    edited: json['edited'] ?? false,
    deleted: json['deleted'] ?? false,
    isPhoto: json['is_photo'] ?? false, // ключ из json
    createdAt: DateTime.parse(json['created_at']),
    imageUrl: json['image_url'],
    sender: User.fromJson(json['sender']),
  );
}
