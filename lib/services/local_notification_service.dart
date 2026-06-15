import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final NotificationService _apiService = NotificationService();
  Timer? _pollTimer;
  String? _lastSeenNotifId;
  bool _initialized = false;

  /// Initialize the local notification plugin — call once from main.dart
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request notification permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Start polling for new notifications (call after login)
  void startPolling() {
    stopPolling();
    // Immediately fetch to set the baseline _lastSeenNotifId
    _checkForNew(isBaseline: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkForNew());
  }

  /// Stop polling (call on logout)
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForNew({bool isBaseline = false}) async {
    try {
      final result = await _apiService.getNotifications();
      if (result.items.isEmpty) return;

      final latestNotif = result.items.first; // already sorted by created_at desc

      if (isBaseline) {
        // First run: just record the latest ID, don't show notification
        _lastSeenNotifId = latestNotif.id;
        return;
      }

      // If there's a new notification we haven't seen yet
      if (_lastSeenNotifId != latestNotif.id && !latestNotif.isRead) {
        // Count how many new unread notifications there are
        final newUnread = <String>[];
        for (final n in result.items) {
          if (n.id == _lastSeenNotifId) break;
          if (!n.isRead) newUnread.add(n.id);
        }

        if (newUnread.isNotEmpty) {
          // Show the latest one as a system notification
          _showNotification(
            id: latestNotif.id.hashCode,
            title: latestNotif.title,
            body: newUnread.length > 1
                ? '${latestNotif.body}\n+${newUnread.length - 1} notifikasi lainnya'
                : latestNotif.body,
          );
        }

        _lastSeenNotifId = latestNotif.id;
      }
    } catch (_) {
      // Silently ignore polling errors
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'asfor_notifications',
      'Notifikasi ASFOR',
      channelDescription: 'Notifikasi aktivitas ASFOR',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  /// Reset baseline (e.g. when user opens notification sheet)
  void resetBaseline(String? latestId) {
    if (latestId != null) _lastSeenNotifId = latestId;
  }
}
