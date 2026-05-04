import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import 'api_config.dart';

class EventService {
  Future<List<AppEvent>> getEvents({int? month, int? year, String? search}) async {
    try {
      final params = <String, String>{};
      if (month != null) params['month'] = month.toString();
      if (year != null) params['year'] = year.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse('${ApiConfig.baseUrl}/events').replace(queryParameters: params);
      final response = await http.get(uri, headers: await ApiConfig.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.map((e) => AppEvent.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<AppEvent?> createEvent(AppEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/events'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode(event.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppEvent.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateEvent(String id, AppEvent event) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/events/$id'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode(event.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/events/$id'),
        headers: await ApiConfig.getHeaders(),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
