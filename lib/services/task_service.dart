import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'api_config.dart';

class TaskService {
  Future<List<Task>> getTasks({String? division, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (division != null && division != 'Semua') queryParams['division'] = division;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/tasks').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await ApiConfig.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List tasks = data['data'] ?? [];
        return tasks.map((e) => Task.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create a new task — requires assigneeId (user ID), not assignee name
  Future<bool> createTask(Task task, {required String assigneeId}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tasks'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'priority': task.priority.name,
          'due_date': task.dueDate.toIso8601String().split('T')[0],
          'division': task.division,
          'assigned_to': assigneeId,
          'status': 'pending',
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Update task status — backend sends notification to assigner if status = done
  Future<bool> updateTaskStatus(String id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/tasks/$id'),
        headers: await ApiConfig.getHeaders(),
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
