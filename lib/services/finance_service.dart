import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/income.dart';
import 'api_config.dart';

class FinanceService {
  Future<List<Income>> getIncomes({String? type}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/finances').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: await ApiConfig.getHeaders()).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List incomes = data['data'] ?? [];
        return incomes.map((e) => Income.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createFinance(Income transaction) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/finances'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode(transaction.toJson()),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteFinance(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/finances/$id'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/finances/summary'),
        headers: await ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
