import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

import 'dashboard_screen.dart';
import 'report_list_screen.dart';
import 'create_report_screen.dart';
import 'task_screen.dart';
import 'admin_screen.dart';
import 'settings_screen.dart';
import 'finance_screen.dart';
import 'election_screen.dart';
import 'inventory_list_screen.dart';
import 'events_screen.dart';
import 'login_screen.dart';
import '../widgets/notification_bell.dart';

final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _auth = AuthService();
  String? _reportDivisionFilter;

  void _navigateTo(int index, {String? divFilter}) {
    setState(() {
      _currentIndex = index;
      _reportDivisionFilter = divFilter;
    });
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _logout() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keluar?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin keluar dari akun ini?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              _auth.logout();
              Navigator.pop(ctx);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0: return const DashboardScreen();
      case 1: return ReportListScreen(initialDivisionFilter: _reportDivisionFilter);
      case 2: return const CreateReportScreen();
      case 3: return const TaskScreen();
      case 4: return const AdminScreen();
      case 5: return const SettingsScreen();
      case 6: return const FinanceScreen();
      case 7: return const ElectionScreen();
      case 8: return const InventoryListScreen();
      case 9: return const EventsScreen();
      default: return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user    = _auth.currentUser;
    final isAdmin = _auth.isSuperAdmin;
    final divColor = isAdmin ? AppColors.primary : AppColors.getDivisionColor(user?.division ?? '');
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      key: mainScaffoldKey,
      body: Stack(
        children: [
          _buildCurrentScreen(),
          // Notification bell — floats on top-right
          Positioned(
            top: padding.top + 4,
            right: 8,
            child: NotificationBell(
              iconColor: _currentIndex == 0 ? Colors.white : AppColors.textPrimary,
              onNavigate: _navigateTo,
            ),
          ),
        ],
      ),

      // ── Drawer ──────────────────────────────────────────────────────────────
      drawer: Drawer(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, padding.top + 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [divColor, divColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar ring
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(child: Text(
                  user?.name[0].toUpperCase() ?? '?',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                )),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? '', style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3,
              )),
              const SizedBox(height: 2),
              Text(user?.email ?? '', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
              const SizedBox(height: 10),
              // Chips
              Wrap(spacing: 6, children: [
                _headerChip(user?.roleLabel ?? ''),
                if ((user?.division ?? '').isNotEmpty)
                  _headerChip(user!.division, icon: AppColors.getDivisionIcon(user.division)),
              ]),
            ]),
          ),

          // Menu list
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 8), children: [
              _item(Icons.dashboard_rounded, 'Dashboard', 0),
              const SizedBox(height: 4),
              const _SectionDivider(label: 'Laporan'),
              if (isAdmin) ...[
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: _ExpansionItem(
                    icon: Icons.description_rounded,
                    label: 'Laporan',
                    selected: _currentIndex == 1,
                    children: [
                      _subItem('Semua Divisi', null, Icons.grid_view_rounded),
                      ...AppTheme.divisions.map((d) => _subItem(d, d, AppColors.getDivisionIcon(d))),
                    ],
                    onNavigate: _navigateTo,
                  ),
                ),
              ] else
                _item(Icons.description_rounded, 'Laporan', 1),
              _item(Icons.add_circle_outline_rounded, 'Buat Laporan', 2),
              const SizedBox(height: 4),
              const _SectionDivider(label: 'Kerja'),
              _item(Icons.task_alt_rounded, 'Task Manager', 3),
              _item(Icons.calendar_month_rounded, 'Kegiatan', 9),
              _item(Icons.inventory_2_rounded, 'Inventaris', 8),
              const SizedBox(height: 4),
              const _SectionDivider(label: 'Lainnya'),
              _item(Icons.how_to_vote_rounded, 'Pemilihan', 7, badge: 'VOTE'),
              if (isAdmin || user?.division == 'Bidang Usaha')
                _item(Icons.account_balance_wallet_rounded, 'Keuangan', 6),
              if (isAdmin)
                _item(Icons.manage_accounts_rounded, 'Kelola Pengguna', 4, badge: 'ADMIN'),
              _item(Icons.tune_rounded, 'Pengaturan', 5),
            ]),
          ),

          // Logout
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, padding.bottom + 12),
            child: Material(
              color: AppColors.danger.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _logout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 14),
                    Text('Keluar', style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger,
                    )),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _headerChip(String label, {IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 11, color: Colors.white), const SizedBox(width: 4)],
      Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  );

  Widget _item(IconData icon, String label, int index, {String? badge}) {
    final sel = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: sel ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: sel ? AppColors.primary : AppColors.textMuted),
        title: Row(children: [
          Text(label, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? AppColors.primary : AppColors.textPrimary,
          )),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.warning)),
            ),
          ],
        ]),
        trailing: sel ? Container(
          width: 4, height: 20,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ) : null,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () => _navigateTo(index),
      ),
    );
  }

  Widget _subItem(String label, String? divFilter, IconData icon) {
    final color = divFilter != null ? AppColors.getDivisionColor(divFilter) : AppColors.primary;
    final sel = _currentIndex == 1 && _reportDivisionFilter == divFilter;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: sel ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 17, color: sel ? color : AppColors.textMuted),
        title: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          color: sel ? color : AppColors.textSecondary,
        )),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        onTap: () => _navigateTo(1, divFilter: divFilter),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
    child: Text(label.toUpperCase(), style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: AppColors.textMuted, letterSpacing: 1.2,
    )),
  );
}

class _ExpansionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final List<Widget> children;
  final void Function(int, {String? divFilter}) onNavigate;

  const _ExpansionItem({
    required this.icon, required this.label, required this.selected,
    required this.children, required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) => ExpansionTile(
    leading: Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textMuted),
    title: Text(label, style: GoogleFonts.inter(
      fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? AppColors.primary : AppColors.textPrimary,
    )),
    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
    childrenPadding: const EdgeInsets.only(left: 12),
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
