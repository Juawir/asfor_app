import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lab.dart';
import 'api_config.dart';

class InventoryService {
  Future<List<Lab>> getLabs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/labs'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List labs = data['data'] ?? [];
        return labs.map((e) => Lab.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getLabDetails(String labId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/labs/$labId'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final lab = Lab.fromJson(data);
        final items = (data['inventory_items'] as List?)?.map((e) => InventoryItem.fromJson(e)).toList() ?? [];
        return {'lab': lab, 'items': items};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<UserBasic>> getInventoryUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/inventory-users'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List users = data['data'] ?? [];
        return users.map((e) => UserBasic.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> assignPics(String labId, List<String> userIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/labs/$labId/assign-pics'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({'user_ids': userIds}),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createItem(String labId, InventoryItem item) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/labs/$labId/items'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItem(String labId, String itemId, InventoryItem item) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/labs/$labId/items/$itemId'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(String labId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/labs/$labId/items/$itemId'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
