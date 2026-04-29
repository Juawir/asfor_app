import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'api_config.dart';

class ReportService {
  Future<List<Report>> getReports({String? division, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (division != null && division != 'Semua') queryParams['division'] = division;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/reports').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await ApiConfig.getHeaders());
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List reports = data['data'] ?? [];
        return reports.map((e) => Report.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createReport(Report report) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reports'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'title': report.title,
          'description': report.description,
          'budget': report.budget,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
