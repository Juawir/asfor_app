import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_config.dart';

class UserService {
  Future<List<AppUser>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List users = data['data'] ?? [];
        return users.map((e) => AppUser.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> createUser(AppUser user) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'division': user.division,
          'role': user.role.name,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
