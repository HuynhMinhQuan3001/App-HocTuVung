class UserModel {
  final String name;
  final String email;
  final String avatarUrl;
  final int streak;

  UserModel({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.streak,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'streak': streak,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      streak: map['streak'] ?? 0,
    );
  }
}
