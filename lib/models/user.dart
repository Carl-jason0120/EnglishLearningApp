class AppUser {
  final int id;
  final String email;
  final String password;
  final String displayName;
  final String createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      displayName: map['displayName'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }
}
