class User {
  final int id;
  final String? name;

  User({
    required this.id,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
  );
}

class Chat {
  final int id;
  final String name;
  final String? lastMessage;
  final List<User> users;

  Chat({
    required this.id,
    required this.name,
    this.lastMessage,
    required this.users,
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