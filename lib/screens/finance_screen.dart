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
  String _txFilter = 'all'; // all, income, expense

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

  double _sumByType(DateTime start, DateTime end, FinanceType type) => _allIncomes
    .where((i) => i.type == type && !i.date.isBefore(start) && !i.date.isAfter(end))
    .fold(0.0, (s, i) => s + i.amount);

  List<Income> _inRange(DateTime start, DateTime end) => _allIncomes
    .where((i) => !i.date.isBefore(start) && !i.date.isAfter(end))
    .toList()..sort((a, b) => b.date.compareTo(a.date));

  double get todayIncome => _sumByType(_startOfToday, _today, FinanceType.income);
  double get todayExpense => _sumByType(_startOfToday, _today, FinanceType.expense);
  double get monthIncome => _sumByType(_startOfMonth, _today, FinanceType.income);
  double get monthExpense => _sumByType(_startOfMonth, _today, FinanceType.expense);
  double get yearIncome => _sumByType(_startOfYear, _today, FinanceType.income);
  double get yearExpense => _sumByType(_startOfYear, _today, FinanceType.expense);
  double get lastMonthIncome => _sumByType(_startOfLastMonth, _endOfLastMonth, FinanceType.income);
  double get lastMonthExpense => _sumByType(_startOfLastMonth, _endOfLastMonth, FinanceType.expense);
  double get lastYearIncome => _sumByType(_startOfLastYear, _endOfLastYear, FinanceType.income);

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
      result.add(MapEntry(label, _sumByType(m, mEnd, FinanceType.income) - _sumByType(m, mEnd, FinanceType.expense)));
    }
    return result;
  }

  void _showAddTransaction() {
    FinanceType txType = FinanceType.income;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    IncomeCategory category = IncomeCategory.project;
    DateTime selectedDate = DateTime.now();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        final isIncome = txType == FinanceType.income;
        final accentColor = isIncome ? AppColors.success : AppColors.danger;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tambah Transaksi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Type toggle
            Container(
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: FinanceType.values.map((t) {
                final sel = txType == t;
                final c = t == FinanceType.income ? AppColors.success : AppColors.danger;
                return Expanded(child: GestureDetector(
                  onTap: () => setSheetState(() => txType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: sel ? c.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(t == FinanceType.income ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 16, color: sel ? c : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(t.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? c : AppColors.textMuted)),
                    ]),
                  ),
                ));
              }).toList()),
            ),
            const SizedBox(height: 16),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, enabled: !isSubmitting,
              decoration: InputDecoration(hintText: 'Jumlah (Rp)', prefixIcon: Icon(Icons.payments_rounded, color: accentColor)),
              style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<IncomeCategory>(
              value: category,
              items: IncomeCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.categoryLabel, style: GoogleFonts.inter(fontSize: 14)))).toList(),
              onChanged: isSubmitting ? null : (v) => setSheetState(() => category = v!),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded)),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2024), lastDate: DateTime.now());
                if (d != null) setSheetState(() => selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate), style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                  const Spacer(), const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, enabled: !isSubmitting,
              decoration: const InputDecoration(hintText: 'Deskripsi', prefixIcon: Icon(Icons.description_rounded)),
              style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : () async {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0 || descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: const Text('Jumlah dan deskripsi wajib diisi'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  return;
                }
                setSheetState(() => isSubmitting = true);
                final tx = Income(id: '', description: descCtrl.text.trim(), amount: amount, date: selectedDate, category: category, type: txType);
                final ok = await FinanceService().createFinance(tx);
                if (ok) {
                  _fetchIncomes();
                  if (mounted) Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ ${txType.label} berhasil ditambahkan'), backgroundColor: accentColor,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                } else {
                  setSheetState(() => isSubmitting = false);
                  if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: const Text('Gagal menyimpan'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                }
              },
              icon: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded, size: 18),
              label: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
          ])),
        );
      }),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaction,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
      // Saldo hero card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
              child: Text('Hari Ini', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
          ]),
          const SizedBox(height: 16),
          Text('Saldo Hari Ini', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(fmt.format(todayIncome - todayExpense), style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.greenAccent),
                const SizedBox(width: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Masuk', style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
                  Text(fmt.format(todayIncome), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.greenAccent)),
                ]),
              ]),
            )),
            const SizedBox(width: 8),
            Expanded(child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.red[200]),
                const SizedBox(width: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Keluar', style: GoogleFonts.inter(fontSize: 10, color: Colors.white60)),
                  Text(fmt.format(todayExpense), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red[200])),
                ]),
              ]),
            )),
          ]),
        ]),
      ),
      const SizedBox(height: 12),

      // Month & Year row
      Row(children: [
        Expanded(child: _miniCard('Pemasukan Bulan', monthIncome, monthPct, Icons.arrow_downward_rounded, color: AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _miniCard('Pengeluaran Bulan', monthExpense, _pctChange(monthExpense, lastMonthExpense), Icons.arrow_upward_rounded, color: AppColors.danger)),
      ]),
      const SizedBox(height: 20),

      // Monthly bar chart
      Text('Saldo 6 Bulan Terakhir', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
    // Filter items
    var filtered = List<Income>.from(_allIncomes);
    if (_txFilter == 'income') filtered = filtered.where((i) => i.isIncome).toList();
    if (_txFilter == 'expense') filtered = filtered.where((i) => i.isExpense).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // Group by date
    final grouped = <String, List<Income>>{};
    for (final item in filtered) {
      final key = DateFormat('dd MMMM yyyy', 'id_ID').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return StatefulBuilder(builder: (ctx, setSt) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        // Filter chips
        Row(children: [
          _filterChip('Semua', 'all', setSt),
          const SizedBox(width: 8),
          _filterChip('Pemasukan', 'income', setSt),
          const SizedBox(width: 8),
          _filterChip('Pengeluaran', 'expense', setSt),
        ]),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text('Belum ada transaksi', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)))),
        ...grouped.entries.map((entry) {
          final dayIncome = entry.value.where((i) => i.isIncome).fold(0.0, (s, i) => s + i.amount);
          final dayExpense = entry.value.where((i) => i.isExpense).fold(0.0, (s, i) => s + i.amount);
          final dayNet = dayIncome - dayExpense;
          final netColor = dayNet >= 0 ? AppColors.success : AppColors.danger;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Text(entry.key, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const Spacer(),
                Text('${dayNet >= 0 ? '+' : ''}${fmt.format(dayNet)}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: netColor)),
              ]),
            ),
            ...entry.value.map((item) {
              final txColor = item.isIncome ? AppColors.success : AppColors.danger;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: txColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 18, color: txColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.description, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${item.categoryLabel} • ${item.type.label}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                  ])),
                  Text('${item.isExpense ? '-' : '+'}${fmt.format(item.amount)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: txColor)),
                ]),
              );
            }),
          ]);
        }),
        const SizedBox(height: 80),
      ]);
    });
  }

  Widget _filterChip(String label, String value, void Function(void Function()) setSt) {
    final sel = _txFilter == value;
    return GestureDetector(
      onTap: () { setState(() => _txFilter = value); setSt(() {}); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? AppColors.primary : AppColors.textMuted)),
      ),
    );
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

  Widget _miniCard(String label, double value, double pct, IconData icon, {Color? color}) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: c),
          const Spacer(),
          _pctBadge(pct),
        ]),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(fmt.format(value), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
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
