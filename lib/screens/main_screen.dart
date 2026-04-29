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
import 'login_screen.dart';

// Global key so child screens can open the drawer
final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _auth = AuthService();
  String? _reportDivisionFilter; // for admin division-specific report navigation

  void _navigateTo(int index, {String? divFilter}) {
    setState(() {
      _currentIndex = index;
      _reportDivisionFilter = divFilter;
    });
    Navigator.pop(context); // close drawer
  }

  void _logout() {
    Navigator.pop(context); // close drawer
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Keluar?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Yakin ingin keluar dari akun ini?', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () {
            _auth.logout();
            Navigator.pop(ctx);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
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
      default: return const DashboardScreen();
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isAdmin = _auth.isSuperAdmin;
    final divColor = isAdmin ? AppColors.primary : AppColors.getDivisionColor(user?.division ?? '');

    return Scaffold(
      key: mainScaffoldKey,
      body: _buildCurrentScreen(),

      drawer: Drawer(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(24))),
        child: Column(children: [
          // Drawer Header with user info
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [divColor, divColor.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white24, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 3),
                ),
                child: Center(child: Text(
                  user?.name[0].toUpperCase() ?? '?',
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                )),
              ),
              const SizedBox(height: 14),
              Text(user?.name ?? '', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text('${user?.email ?? ''}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
                  child: Text(user?.roleLabel ?? '', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isAdmin ? Icons.admin_panel_settings_rounded : AppColors.getDivisionIcon(user?.division ?? ''), size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(user?.division ?? '', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ]),
            ]),
          ),

          // Menu items
          Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
            _drawerItem(Icons.dashboard_rounded, 'Dashboard', 0),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.border)),

            // Laporan section
            if (isAdmin) ...[
              // Admin: expandable per division
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(Icons.description_rounded, color: _currentIndex == 1 ? AppColors.primary : AppColors.textMuted, size: 22),
                  title: Text('Laporan', style: GoogleFonts.inter(fontSize: 14, fontWeight: _currentIndex == 1 ? FontWeight.w700 : FontWeight.w500, color: _currentIndex == 1 ? AppColors.primary : AppColors.textPrimary)),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                  childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    _divisionSubItem('Semua Divisi', null),
                    ...AppTheme.divisions.map((d) => _divisionSubItem(d, d)),
                  ],
                ),
              ),
            ] else ...[
              _drawerItem(Icons.description_rounded, 'Laporan', 1),
            ],

            _drawerItem(Icons.add_circle_rounded, 'Buat Laporan', 2),
            _drawerItem(Icons.task_rounded, 'Task Manager', 3),
            _drawerItem(Icons.how_to_vote_rounded, 'Pemilihan', 7, badge: 'VOTE'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.border)),

            if (isAdmin || user?.division == 'Bidang Usaha')
              _drawerItem(Icons.account_balance_wallet_rounded, 'Keuangan', 6, badge: user?.division == 'Bidang Usaha' && !isAdmin ? null : 'FINANCE'),

            if (isAdmin)
              _drawerItem(Icons.person_add_rounded, 'Tambah Pengguna', 4, badge: 'ADMIN'),

            _drawerItem(Icons.settings_rounded, 'Pengaturan Akun', 5),
          ])),

          // Logout
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
              title: Text('Keluar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              onTap: _logout,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ]),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index, {String? badge}) {
    final selected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
        title: Row(children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textPrimary)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.warning)),
            ),
          ],
        ]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        onTap: () => _navigateTo(index),
      ),
    );
  }

  Widget _divisionSubItem(String label, String? divFilter) {
    final color = divFilter != null ? AppColors.getDivisionColor(divFilter) : AppColors.primary;
    final isSelected = _currentIndex == 1 && _reportDivisionFilter == divFilter;
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: divFilter != null
          ? Icon(AppColors.getDivisionIcon(divFilter), size: 18, color: isSelected ? color : AppColors.textMuted)
          : Icon(Icons.list_rounded, size: 18, color: isSelected ? color : AppColors.textMuted),
        title: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? color : AppColors.textSecondary)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () => _navigateTo(1, divFilter: divFilter),
      ),
    );
  }
}
