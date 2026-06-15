import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../widgets/report_card.dart';
import '../widgets/division_chip.dart';
import 'main_screen.dart' show buildMenuButton;
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  final String? initialDivisionFilter;
  const ReportListScreen({super.key, this.initialDivisionFilter});
  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late String _selectedDivision;
  String _searchQuery = '';
  final _auth = AuthService();
  List<Report> _allReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDivision = widget.initialDivisionFilter ?? 'Semua';
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final reports = await ReportService().getReports();
    if (mounted) {
      setState(() {
        _allReports = reports;
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(ReportListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDivisionFilter != oldWidget.initialDivisionFilter) {
      setState(() => _selectedDivision = widget.initialDivisionFilter ?? 'Semua');
    }
  }

  List<Report> get _filteredReports {
    final isAdmin = _auth.isSuperAdmin;
    final userDiv = _auth.currentUser?.division ?? '';
    return _allReports.where((r) {
      final matchUserDiv = isAdmin || r.division == userDiv;
      final matchFilter = _selectedDivision == 'Semua' || r.division == _selectedDivision;
      final matchSearch = _searchQuery.isEmpty || r.title.toLowerCase().contains(_searchQuery.toLowerCase()) || r.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchUserDiv && matchFilter && matchSearch;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: AppColors.backgroundOf(context), body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final filtered = _filteredReports;
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        leading: buildMenuButton(context),
        title: Text(_selectedDivision == 'Semua' ? 'Daftar Laporan' : 'Laporan $_selectedDivision', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceOf(context),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Cari laporan...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMutedOf(context)),
              filled: true, fillColor: AppColors.surfaceOf(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderOf(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderOf(context))),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
        // Division filter (only for SuperAdmin)
        if (_auth.isSuperAdmin)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                DivisionChip(label: 'Semua', selected: _selectedDivision == 'Semua', onTap: () => setState(() => _selectedDivision = 'Semua')),
                const SizedBox(width: 8),
                ...AppTheme.divisions.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DivisionChip(label: d, selected: _selectedDivision == d, onTap: () => setState(() => _selectedDivision = d)),
                )),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Text('${filtered.length} laporan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryOf(context))),
            const Spacer(),
            if (_selectedDivision != 'Semua')
              GestureDetector(
                onTap: () => setState(() => _selectedDivision = 'Semua'),
                child: Text('Reset filter', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        // Report list
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_rounded, size: 56, color: AppColors.textMutedOf(context).withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text('Tidak ada laporan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMutedOf(context))),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, i) => ReportCard(
                  report: filtered[i],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailScreen(report: filtered[i]))),
                ),
              ),
        ),
      ]),
    );
  }
}
