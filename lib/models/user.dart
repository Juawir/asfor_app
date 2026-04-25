enum UserRole { user, superadmin }

class AppUser {
  final String id;
  final String name;
  final String username;
  final String password;
  final String division;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.division,
    required this.role,
  });

  bool get isSuperAdmin => role == UserRole.superadmin;

  String get roleLabel => isSuperAdmin ? 'Super Admin' : 'User';

  AppUser copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? division,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      division: division ?? this.division,
      role: role ?? this.role,
    );
  }
}
