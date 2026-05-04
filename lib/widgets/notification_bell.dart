import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  final Color iconColor;
  final Function(int) onNavigate;

  const NotificationBell({super.key, required this.iconColor, required this.onNavigate});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  List<AppNotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final result = await NotificationService().getNotifications();
    if (mounted) setState(() {
      _notifications = result.items;
      _unreadCount = result.unreadCount;
    });
  }

  void _showNotifSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifikasi', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: () async {
                        await NotificationService().markAllRead();
                        _fetchNotifications();
                        setSheet(() {
                          _unreadCount = 0;
                        });
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: Text('Tandai Dibaca', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.border),
                            const SizedBox(height: 16),
                            Text('Belum ada notifikasi', style: GoogleFonts.inter(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (ctx, index) {
                          final notif = _notifications[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: notif.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
                              border: Border.all(color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: _getNotifColor(notif.type).withValues(alpha: 0.15),
                                child: Icon(_getNotifIcon(notif.type), color: _getNotifColor(notif.type), size: 20),
                              ),
                              title: Text(notif.title, style: GoogleFonts.inter(fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700, fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(notif.body, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                              ),
                              onTap: () async {
                                if (!notif.isRead) {
                                  await NotificationService().markRead(notif.id);
                                  _fetchNotifications();
                                  setSheet(() => _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0);
                                }
                                if (mounted) Navigator.pop(ctx);
                                
                                if (notif.type == 'task' || notif.type == 'task_status') widget.onNavigate(3);
                                else if (notif.type == 'lab_assignment') widget.onNavigate(8);
                                else if (notif.type == 'event') widget.onNavigate(9);
                                else if (notif.type == 'report' || notif.type == 'report_division' || notif.type == 'report_approved' || notif.type == 'report_rejected') widget.onNavigate(1);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'task': return Icons.task_rounded;
      case 'task_status': return Icons.update_rounded;
      case 'lab_assignment': return Icons.science_rounded;
      case 'event': return Icons.event_rounded;
      case 'report': return Icons.description_rounded;
      case 'report_division': return Icons.group_rounded;
      case 'report_approved': return Icons.check_circle_rounded;
      case 'report_rejected': return Icons.cancel_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'task': return AppColors.warning;
      case 'task_status': return const Color(0xFFF59E0B);
      case 'lab_assignment': return AppColors.primary;
      case 'event': return AppColors.success;
      case 'report': return const Color(0xFF6366F1);
      case 'report_division': return const Color(0xFF0EA5E9);
      case 'report_approved': return AppColors.success;
      case 'report_rejected': return AppColors.danger;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_rounded, color: widget.iconColor),
          onPressed: _showNotifSheet,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
