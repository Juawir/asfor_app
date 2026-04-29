import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../services/task_service.dart';
import '../widgets/stat_card.dart';
import 'main_screen.dart' show mainScaffoldKey;
import 'report_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Report> _reports = [];
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reports = await ReportService().getReports();
    final tasks = await TaskService().getTasks();
    if (mounted) {
      setState(() {
        _reports = reports;
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    }
    
    final auth = AuthService();
    final user = auth.currentUser;
    final isAdmin = auth.isSuperAdmin;
    final userDiv = user?.division ?? '';

    final reports = isAdmin ? _reports : _reports.where((r) => r.division == userDiv).toList();
    final tasks = isAdmin ? _tasks : _tasks.where((t) => t.division == userDiv).toList();
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalBudget = reports.where((r) => r.status == ReportStatus.approved).fold<double>(0, (s, r) => s + r.budget);
    final pending = reports.where((r) => r.status == ReportStatus.pending).length;
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).length;

    final divColor = isAdmin ? AppColors.primary : AppColors.getDivisionColor(userDiv);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 170, floating: false, pinned: true,
          backgroundColor: divColor,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => mainScaffoldKey.currentState?.openDrawer(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [divColor, divColor.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(children: [
                  // User avatar
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white24, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 2.5),
                    ),
                    child: Center(child: Text(user?.name[0].toUpperCase() ?? '?', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Selamat Datang! 👋', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(user?.name ?? 'User', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  ])),
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
                  child: Text(isAdmin ? '⭐ Super Admin — Semua Divisi' : '📋 ${user?.division ?? ''}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ]),
            ),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
            children: [
              StatCard(label: 'Total Laporan', value: '${reports.length}', icon: Icons.description_rounded, color: AppColors.primary),
              if (isAdmin || userDiv == 'Bidang Usaha')
                StatCard(label: 'Total Anggaran', value: fmt.format(totalBudget), icon: Icons.payments_rounded, color: AppColors.success, subtitle: 'Yang disetujui'),
              StatCard(label: 'Menunggu Review', value: '$pending', icon: Icons.schedule_rounded, color: AppColors.warning),
              StatCard(label: 'Task Selesai', value: '$doneTasks/${tasks.length}', icon: Icons.task_alt_rounded, color: AppColors.info),
            ],
          ),
          const SizedBox(height: 20),

          if (isAdmin) ...[
            Text('Laporan per Divisi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...AppTheme.divisions.map((div) {
              final count = _reports.where((r) => r.division == div).length;
              final approved = _reports.where((r) => r.division == div && r.status == ReportStatus.approved).length;
              final color = AppColors.getDivisionColor(div);
              final pct = _reports.isEmpty ? 0.0 : count / _reports.length;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(AppColors.getDivisionIcon(div), color: color, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(div, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('$approved/$count disetujui', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                    ])),
                    Text('$count', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(50), child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color))),
                ]),
              );
            }),
            const SizedBox(height: 20),
          ],

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Laporan Terbaru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 8),
          if (reports.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Center(child: Text('Belum ada laporan', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted))),
            )
          else
            ...reports.take(5).map((r) => _buildRecentItem(context, r)),
          const SizedBox(height: 24),
        ]))),
      ]),
    );
  }

  Widget _buildRecentItem(BuildContext context, Report r) {
    final color = AppColors.getDivisionColor(r.division);
    Color statusColor;
    switch (r.status) {
      case ReportStatus.approved: statusColor = AppColors.success;
      case ReportStatus.pending: statusColor = AppColors.warning;
      case ReportStatus.rejected: statusColor = AppColors.danger;
      case ReportStatus.draft: statusColor = AppColors.textMuted;
    }
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailScreen(report: r))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${r.division} • ${DateFormat('dd MMM', 'id_ID').format(r.date)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}
