class User {
  final int id;
  final String? name;
  final String? photoUrl;

  User({required this.id, this.name, this.photoUrl});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    photoUrl: json['photo_url'] != null
        ? 'http://anonion.nextlayer.site${json['photo_url']}'
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photo_url': photoUrl, // <-- ключ должен совпадать с fromJson
  };
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
    lastMessage: json['last_message'],
    users: (json['users'] as List<dynamic>)
        .map((u) => User.fromJson(u))
        .toList(),
    lastMessageTime: json['last_message_time'] != null
        ? DateTime.parse(json['last_message_time'])
        : null,
    lastSenderName: json['last_sender_name'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'last_message': lastMessage,
    'users': users.map((u) => u.toJson()).toList(),
    'last_message_time': lastMessageTime?.toIso8601String(),
    'last_sender_name': lastSenderName,
  };
}
