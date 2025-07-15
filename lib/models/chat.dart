class User {
  final int id;
  final String? name;
  final String? photoUrl;

  User({required this.id, this.name, this.photoUrl});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    photoUrl: json['photo_url'] != null
        ? 'http://109.173.168.29:8001${json['photo_url']}'
        : null,
  );
}

class Chat {
  final int id;
  final String name;
  final List<User> users;
  String? lastMessage;
  DateTime? lastMessageTime;
  String? lastSenderName;

  Chat({
    required this.id,
    required this.name,
    this.lastMessage,
    required this.users,
    this.lastMessageTime,
    this.lastSenderName,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'],
    name: json['name'],
    lastMessage: json['last_message'] ?? '',
    users: (json['users'] as List<dynamic>)
        .map((u) => User.fromJson(u))
        .toList(),
  );
}
