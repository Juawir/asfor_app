enum UserRole { user, superadmin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String division;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.division,
    required this.role,
  });

  bool get isSuperAdmin => role == UserRole.superadmin;

  String get roleLabel => isSuperAdmin ? 'Super Admin' : 'User';

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? division,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      division: division ?? this.division,
      role: role ?? this.role,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: '', // Password tidak dikembalikan dari API untuk keamanan
      division: json['division'] ?? '',
      role: json['role'] == 'admin' ? UserRole.superadmin : UserRole.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'division': division,
      'role': isSuperAdmin ? 'admin' : 'user',
    };
  }
}
