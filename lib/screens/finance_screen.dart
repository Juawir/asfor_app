import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/income.dart';
import '../services/finance_service.dart';
import 'main_screen.dart' show mainScaffoldKey;

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  List<Income> _allIncomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    final incomes = await FinanceService().getIncomes();
    if (mounted) {
      setState(() {
        _allIncomes = incomes;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  // === Calculation helpers ===
  DateTime get _today => DateTime.now();
  DateTime get _startOfToday => DateTime(_today.year, _today.month, _today.day);
  DateTime get _startOfMonth => DateTime(_today.year, _today.month, 1);
  DateTime get _startOfYear => DateTime(_today.year, 1, 1);
  DateTime get _startOfLastMonth => DateTime(_today.year, _today.month - 1, 1);
  DateTime get _endOfLastMonth => DateTime(_today.year, _today.month, 0, 23, 59, 59);
  DateTime get _startOfLastYear => DateTime(_today.year - 1, 1, 1);
  DateTime get _endOfLastYear => DateTime(_today.year - 1, 12, 31, 23, 59, 59);

  double _sumInRange(DateTime start, DateTime end) => _allIncomes
    .where((i) => !i.date.isBefore(start) && !i.date.isAfter(end))
    .fold(0.0, (s, i) => s + i.amount);

  List<Income> _inRange(DateTime start, DateTime end) => _allIncomes
    .where((i) => !i.date.isBefore(start) && !i.date.isAfter(end))
    .toList()..sort((a, b) => b.date.compareTo(a.date));

  double get todayIncome => _sumInRange(_startOfToday, _today);
  double get monthIncome => _sumInRange(_startOfMonth, _today);
  double get yearIncome => _sumInRange(_startOfYear, _today);
  double get lastMonthIncome => _sumInRange(_startOfLastMonth, _endOfLastMonth);
  double get lastYearIncome => _sumInRange(_startOfLastYear, _endOfLastYear);

  double _pctChange(double current, double previous) =>
    previous == 0 ? (current > 0 ? 100 : 0) : ((current - previous) / previous * 100);

  // Category breakdown for current month
  Map<IncomeCategory, double> get _categoryBreakdown {
    final items = _inRange(_startOfMonth, _today);
    final map = <IncomeCategory, double>{};
    for (final cat in IncomeCategory.values) {
      map[cat] = items.where((i) => i.category == cat).fold(0.0, (s, i) => s + i.amount);
    }
    return map;
  }

  // Monthly totals for bar chart (last 6 months)
  List<MapEntry<String, double>> get _monthlyTotals {
    final result = <MapEntry<String, double>>[];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      // Dart handles month underflow correctly: DateTime(2025, -1, 1) → Nov 2024
      final m = DateTime(now.year, now.month - i, 1);
      final mEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
      final label = DateFormat('MMM', 'id_ID').format(m);
      result.add(MapEntry(label, _sumInRange(m, mEnd)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    }
    
    final monthPct = _pctChange(monthIncome, lastMonthIncome);
    final yearPct = _pctChange(yearIncome, lastYearIncome);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Keuangan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelColor: AppColors.textMuted, labelColor: AppColors.primary,
          indicatorColor: AppColors.primary, indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Ringkasan'), Tab(text: 'Transaksi'), Tab(text: 'Perbandingan')],
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _buildSummary(monthPct, yearPct),
        _buildTransactions(),
        _buildComparison(monthPct, yearPct),
      ]),
    );
  }

  // ==================== TAB 1: RINGKASAN ====================
  Widget _buildSummary(double monthPct, double yearPct) {
    final categories = _categoryBreakdown;
    final maxCat = categories.values.fold(0.0, (a, b) => a > b ? a : b);

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Income summary cards
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF7043)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
              child: Text('Bidang Usaha', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
          ]),
          const SizedBox(height: 16),
          Text('Pemasukan Hari Ini', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(fmt.format(todayIncome), style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 12),

      // Month & Year row
      Row(children: [
        Expanded(child: _miniCard('Bulan Ini', monthIncome, monthPct, Icons.calendar_month_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _miniCard('Tahun Ini', yearIncome, yearPct, Icons.date_range_rounded)),
      ]),
      const SizedBox(height: 20),

      // Monthly bar chart
      Text('Pemasukan 6 Bulan Terakhir', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: _buildBarChart(),
      ),
      const SizedBox(height: 20),

      // Category breakdown
      Text('Kategori Bulan Ini', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      ...categories.entries.map((e) {
        final color = _catColor(e.key);
        final pct = maxCat > 0 ? e.value / maxCat : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(_catIcon(e.key), size: 18, color: color)),
              const SizedBox(width: 12),
              Expanded(child: Text(e.key.categoryLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              Text(fmt.format(e.value), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(50), child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color))),
          ]),
        );
      }),
      const SizedBox(height: 20),
    ]);
  }

  // ==================== TAB 2: TRANSAKSI ====================
  Widget _buildTransactions() {
    final allItems = List<Income>.from(_allIncomes)..sort((a, b) => b.date.compareTo(a.date));
    if (allItems.isEmpty) {
      return Center(child: Text('Belum ada transaksi', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)));
    }

    // Group by date
    final grouped = <String, List<Income>>{};
    for (final item in allItems) {
      final key = DateFormat('dd MMMM yyyy', 'id_ID').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      ...grouped.entries.map((entry) {
        final dateTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Text(entry.key, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const Spacer(),
              Text(fmt.format(dateTotal), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
            ]),
          ),
          ...entry.value.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _catColor(item.category).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(_catIcon(item.category), size: 18, color: _catColor(item.category)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.description, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item.categoryLabel, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              ])),
              Text(fmt.format(item.amount), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
            ]),
          )),
        ]);
      }),
      const SizedBox(height: 20),
    ]);
  }

  // ==================== TAB 3: PERBANDINGAN ====================
  Widget _buildComparison(double monthPct, double yearPct) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Month comparison
      Text('Perbandingan Bulanan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      _comparisonCard(
        label1: 'Bulan Ini', value1: monthIncome,
        label2: 'Bulan Lalu', value2: lastMonthIncome,
        pctChange: monthPct, icon: Icons.calendar_month_rounded,
      ),
      const SizedBox(height: 20),

      // Year comparison
      Text('Perbandingan Tahunan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      _comparisonCard(
        label1: 'Tahun Ini', value1: yearIncome,
        label2: 'Tahun Lalu', value2: lastYearIncome,
        pctChange: yearPct, icon: Icons.date_range_rounded,
      ),
      const SizedBox(height: 20),

      // Category comparison this month vs last month
      Text('Perbandingan Kategori', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('Bulan ini vs bulan lalu', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
      const SizedBox(height: 12),
      ...IncomeCategory.values.map((cat) {
        final thisMonth = _inRange(_startOfMonth, _today).where((i) => i.category == cat).fold(0.0, (s, i) => s + i.amount);
        final lastMonth = _inRange(_startOfLastMonth, _endOfLastMonth).where((i) => i.category == cat).fold(0.0, (s, i) => s + i.amount);
        final pct = _pctChange(thisMonth, lastMonth);
        final color = _catColor(cat);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(_catIcon(cat), size: 18, color: color)),
              const SizedBox(width: 12),
              Expanded(child: Text(cat.categoryLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              _pctBadge(pct),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bulan ini', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                Text(fmt.format(thisMonth), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ])),
              Container(width: 1, height: 30, color: AppColors.border),
              Expanded(child: Padding(padding: const EdgeInsets.only(left: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bulan lalu', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                Text(fmt.format(lastMonth), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ]))),
            ]),
          ]),
        );
      }),
      const SizedBox(height: 20),
    ]);
  }

  // ==================== SHARED WIDGETS ====================

  Widget _miniCard(String label, double value, double pct, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const Spacer(),
          _pctBadge(pct),
        ]),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(fmt.format(value), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _pctBadge(double pct) {
    final isUp = pct >= 0;
    final color = isUp ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: color),
        const SizedBox(width: 2),
        Text('${pct.abs().toStringAsFixed(1)}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _comparisonCard({required String label1, required double value1, required String label2, required double value2, required double pctChange, required IconData icon}) {
    final isUp = pctChange >= 0;
    final diff = value1 - value2;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(children: [
          Expanded(child: _compCol(label1, value1, AppColors.primary)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(children: [
              Icon(Icons.compare_arrows_rounded, size: 24, color: AppColors.textMuted),
              const SizedBox(height: 4),
              _pctBadge(pctChange),
            ]),
          ),
          Expanded(child: _compCol(label2, value2, AppColors.textSecondary)),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: (isUp ? AppColors.success : AppColors.danger).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 18, color: isUp ? AppColors.success : AppColors.danger),
            const SizedBox(width: 8),
            Text('Selisih: ${isUp ? '+' : ''}${fmt.format(diff)}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isUp ? AppColors.success : AppColors.danger)),
          ]),
        ),
      ]),
    );
  }

  Widget _compCol(String label, double value, Color color) {
    return Column(children: [
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
      const SizedBox(height: 6),
      Text(fmt.format(value), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    ]);
  }

  Widget _buildBarChart() {
    final data = _monthlyTotals;
    final maxVal = data.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: data.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final h = maxVal > 0 ? (e.value / maxVal * 120) : 0.0;
        final isLast = i == data.length - 1;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(fmt.format(e.value).replaceAll('Rp ', '').replaceAll('.000', 'K').replaceAll('.', ''),
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Container(
              height: h, width: double.infinity,
              decoration: BoxDecoration(
                color: isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Text(e.key, style: GoogleFonts.inter(fontSize: 11, fontWeight: isLast ? FontWeight.w700 : FontWeight.w500, color: isLast ? AppColors.primary : AppColors.textMuted)),
          ]),
        ));
      }).toList()),
    );
  }

  Color _catColor(IncomeCategory cat) {
    switch (cat) {
      case IncomeCategory.project: return AppColors.primary;
      case IncomeCategory.service: return AppColors.info;
      case IncomeCategory.product: return AppColors.success;
      case IncomeCategory.other: return AppColors.warning;
    }
  }

  IconData _catIcon(IncomeCategory cat) {
    switch (cat) {
      case IncomeCategory.project: return Icons.work_rounded;
      case IncomeCategory.service: return Icons.handyman_rounded;
      case IncomeCategory.product: return Icons.inventory_2_rounded;
      case IncomeCategory.other: return Icons.more_horiz_rounded;
    }
  }
}
