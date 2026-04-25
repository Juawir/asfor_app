import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;

  final List<AppUser> _users = [
    // Super Admin
    const AppUser(id: 'SA001', name: 'Administrator', username: 'admin', password: 'admin123', division: 'Semua', role: UserRole.superadmin),

    // Programmer
    const AppUser(id: 'U001', name: 'Ahmad Fauzi', username: 'ahmad.fauzi', password: 'pass123', division: 'Programmer', role: UserRole.user),
    const AppUser(id: 'U002', name: 'Budi Santoso', username: 'budi.santoso', password: 'pass123', division: 'Programmer', role: UserRole.user),
    const AppUser(id: 'U003', name: 'Rina Wati', username: 'rina.wati', password: 'pass123', division: 'Programmer', role: UserRole.user),

    // Hubungan Masyarakat
    const AppUser(id: 'U004', name: 'Siti Aisyah', username: 'siti.aisyah', password: 'pass123', division: 'Hubungan Masyarakat', role: UserRole.user),
    const AppUser(id: 'U005', name: 'Dewi Lestari', username: 'dewi.lestari', password: 'pass123', division: 'Hubungan Masyarakat', role: UserRole.user),

    // IT Support
    const AppUser(id: 'U006', name: 'Reza Pratama', username: 'reza.pratama', password: 'pass123', division: 'IT Support', role: UserRole.user),
    const AppUser(id: 'U007', name: 'Fajar Hidayat', username: 'fajar.hidayat', password: 'pass123', division: 'IT Support', role: UserRole.user),

    // Training
    const AppUser(id: 'U008', name: 'Nadia Putri', username: 'nadia.putri', password: 'pass123', division: 'Training', role: UserRole.user),
    const AppUser(id: 'U009', name: 'Irfan Maulana', username: 'irfan.maulana', password: 'pass123', division: 'Training', role: UserRole.user),

    // Bidang Usaha
    const AppUser(id: 'U010', name: 'Yoga Aditya', username: 'yoga.aditya', password: 'pass123', division: 'Bidang Usaha', role: UserRole.user),
    const AppUser(id: 'U011', name: 'Maya Sari', username: 'maya.sari', password: 'pass123', division: 'Bidang Usaha', role: UserRole.user),
  ];

  List<AppUser> get allUsers => List.unmodifiable(_users);

  String? login(String username, String password) {
    try {
      final user = _users.firstWhere((u) => u.username == username && u.password == password);
      _currentUser = user;
      return null; // success
    } catch (_) {
      return 'Username atau password salah';
    }
  }

  void logout() { _currentUser = null; }

  void addUser(AppUser user) { _users.add(user); }

  void removeUser(String id) { _users.removeWhere((u) => u.id == id && u.role != UserRole.superadmin); }

  void updateCurrentUser({String? name, String? password}) {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, password: password);
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) { _users[idx] = updated; }
    _currentUser = updated;
  }

  String generateUserId() => 'U${(_users.length + 1).toString().padLeft(3, '0')}';
}
