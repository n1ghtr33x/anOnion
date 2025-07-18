class User {
  final int id;
  final String username;
  final String email;
  final String name;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    name: json['name'],
  );
}
