import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_item.dart';
import 'api_config.dart';

class NotificationService {
  Future<({List<AppNotificationItem> items, int unreadCount})> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: await ApiConfig.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final List list = data['notifications'] ?? [];
        return (
          items: list.map((e) => AppNotificationItem.fromJson(e)).toList(),
          unreadCount: (data['unread_count'] as int?) ?? 0,
        );
      }
      return (items: <AppNotificationItem>[], unreadCount: 0);
    } catch (_) {
      return (items: <AppNotificationItem>[], unreadCount: 0);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: await ApiConfig.getHeaders(),
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
        headers: await ApiConfig.getHeaders(),
      );
    } catch (_) {}
  }
}
