import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../models/task.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../services/task_service.dart';
import '../services/event_service.dart';
import '../widgets/stat_card.dart';
import 'main_screen.dart' show buildMenuButton;
import 'report_detail_screen.dart';
import 'events_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Report> _reports = [];
  List<Task> _tasks = [];
  List<AppEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reports = await ReportService().getReports();
    final tasks = await TaskService().getTasks();
    final events = await EventService().getEvents();
    if (mounted) {
      setState(() {
        _reports = reports;
        _tasks = tasks;
        _events = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundOf(context),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
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

    final upcomingEvents = _events.where((e) => !e.isPast || e.isToday).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final displayEvents = upcomingEvents.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: CustomScrollView(slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 180, floating: false, pinned: true,
            backgroundColor: divColor,
            leading: buildMenuButton(context, color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [divColor, divColor.withValues(alpha: 0.7), AppColors.accent.withValues(alpha: 0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(top: -40, right: -30, child: _decorCircle(140, 0.08)),
                    Positioned(bottom: -20, left: -20, child: _decorCircle(100, 0.06)),
                    Positioned(top: 40, right: 60, child: _decorCircle(50, 0.05)),
                    // Content
                    Positioned(
                      left: 20, right: 20, bottom: 20,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                            ),
                            child: Center(child: Text(
                              user?.name[0].toUpperCase() ?? '?',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                            )),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Selamat Datang! 👋', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(user?.name ?? 'User', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                          ])),
                        ]),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            isAdmin ? '⭐ Super Admin — Semua Divisi' : '📋 ${user?.division ?? ''}',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
            // Stat cards
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
            const SizedBox(height: 24),

            // Division breakdown (admin only)
            if (isAdmin) ...[
              _sectionTitle(context, 'Laporan per Divisi'),
              const SizedBox(height: 12),
              ...AppTheme.divisions.map((div) => _buildDivisionCard(context, div)),
              const SizedBox(height: 24),
            ],

            // Upcoming events
            if (displayEvents.isNotEmpty) ...[
              _sectionTitle(context, 'Kegiatan Mendatang'),
              const SizedBox(height: 10),
              ...displayEvents.map((e) => _buildEventCard(context, e)),
              const SizedBox(height: 24),
            ],

            // Recent reports
            _sectionTitle(context, 'Laporan Terbaru'),
            const SizedBox(height: 10),
            if (reports.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLightOf(context)),
                ),
                child: Center(child: Column(children: [
                  Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMutedOf(context).withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text('Belum ada laporan', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context))),
                ])),
              )
            else
              ...reports.take(5).map((r) => _buildRecentItem(context, r)),
            const SizedBox(height: 24),
          ]))),
        ]),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: opacity)),
  );

  Widget _sectionTitle(BuildContext context, String text) => Text(
    text,
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context)),
  );

  Widget _buildDivisionCard(BuildContext context, String div) {
    final count = _reports.where((r) => r.division == div).length;
    final approved = _reports.where((r) => r.division == div && r.status == ReportStatus.approved).length;
    final color = AppColors.getDivisionColor(div);
    final pct = _reports.isEmpty ? 0.0 : count / _reports.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLightOf(context)),
        boxShadow: [BoxShadow(color: AppColors.cardShadowOf(context), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(AppColors.getDivisionIcon(div), color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(div, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryOf(context))),
            Text('$approved/$count disetujui', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryOf(context))),
          ])),
          Text('$count', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: pct, minHeight: 6,
            backgroundColor: AppColors.borderLightOf(context),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
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
      case ReportStatus.draft: statusColor = AppColors.textMutedOf(context);
    }
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailScreen(report: r))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLightOf(context)),
          boxShadow: [BoxShadow(color: AppColors.cardShadowOf(context), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryOf(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${r.division} • ${DateFormat('dd MMM', 'id_ID').format(r.date)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryOf(context))),
          ])),
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: statusColor, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 4)],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, AppEvent event) {
    final divColor = AppColors.getDivisionColor(event.division);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLightOf(context)),
          boxShadow: [BoxShadow(color: AppColors.cardShadowOf(context), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.04)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${event.eventDate.day}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Text(DateFormat('MMM', 'id_ID').format(event.eventDate), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: divColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                    child: Text(event.division, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: divColor)),
                  ),
                  if (event.isToday) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)]),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text('HARI INI', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ]),
                const SizedBox(height: 6),
                Text(event.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryOf(context))),
                if (event.eventTime != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMutedOf(context)),
                    const SizedBox(width: 4),
                    Text(event.eventTime!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context))),
                  ]),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
