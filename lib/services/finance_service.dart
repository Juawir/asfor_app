import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/income.dart';
import 'api_config.dart';

class FinanceService {
  Future<List<Income>> getIncomes({String? type}) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/finances').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await ApiConfig.getHeaders());
      
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

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/finances/summary'),
        headers: await ApiConfig.getHeaders(),
      );
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
