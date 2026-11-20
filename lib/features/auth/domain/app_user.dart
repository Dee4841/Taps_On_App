class AppUser {
  final String id;
  final String email;
  final String role; // 'student' | 'admin'

  const AppUser({
    required this.id,
    required this.email,
    this.role = 'student',
  });

  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? id,
    String? email,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
