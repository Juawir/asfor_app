import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        _currentUser = AppUser.fromJson(data['data']['user']);
        return null; // success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Email atau password salah';
      }
    } catch (e) {
      return 'Terjadi kesalahan koneksi. Pastikan API menyala dan VPN terhubung (error: $e).';
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: await ApiConfig.getHeaders(),
      );
    } catch (_) {}
    
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: await ApiConfig.getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = AppUser.fromJson(data['data']);
        return true;
      }
    } catch (_) {}
    
    await prefs.remove('token');
    return false;
  }

  Future<String?> updateProfile(String name) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentUser = AppUser.fromJson(data['data']);
        return null;
      }
      return jsonDecode(response.body)['message'] ?? 'Gagal update profile';
    } catch (e) {
      return 'Koneksi error: $e';
    }
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile/password'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      return jsonDecode(response.body)['message'] ?? 'Gagal ubah password';
    } catch (e) {
      return 'Koneksi error: $e';
    }
  }
}
