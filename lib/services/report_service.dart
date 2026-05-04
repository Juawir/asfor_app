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

  Future<bool> createReport(Report report, {String? filePath}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/reports'));
      
      final headers = await ApiConfig.getHeaders();
      headers.remove('Content-Type');
      headers.remove('content-type');
      request.headers.addAll(headers);
      
      request.fields['title'] = report.title;
      request.fields['description'] = report.description;
      request.fields['budget'] = report.budget.toString();
      request.fields['division'] = report.division;
      request.fields['date'] = report.date.toIso8601String().split('T')[0];
      
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('attachment', filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Admin: setujui laporan
  Future<Report?> approveReport(String reportId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/reports/$reportId/approve'),
        headers: await ApiConfig.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Report.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Admin: tolak laporan dengan alasan
  Future<Report?> rejectReport(String reportId, String reason) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/reports/$reportId/reject'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({'rejection_note': reason}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Report.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
