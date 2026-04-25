import '../models/income.dart';

/// Helper: Safely subtract days from a date without going out of bounds
DateTime _daysAgo(int days) {
  final d = DateTime.now();
  return DateTime(d.year, d.month, d.day - days);
}

/// Helper: Build a date in a prior month safely
DateTime _monthAgo(int months, int day) {
  final d = DateTime.now();
  // Clamp to end of the target month if day is too large
  final target = DateTime(d.year, d.month - months + 1, 0); // last day of target month
  final safeDay = day > target.day ? target.day : day;
  return DateTime(d.year, d.month - months, safeDay);
}

final List<Income> dummyIncomes = [
  // === Hari ini ===
  Income(id: 'I001', description: 'Jasa konsultasi IT PT. Maju', amount: 3500000,
    date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
    category: IncomeCategory.service),
  Income(id: 'I002', description: 'Penjualan modul training', amount: 1200000,
    date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 30),
    category: IncomeCategory.product),
  Income(id: 'I003', description: 'Maintenance server klien', amount: 800000,
    date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0),
    category: IncomeCategory.service),

  // === Kemarin ===
  Income(id: 'I004', description: 'Proyek website CV. Berkah', amount: 7500000,
    date: _daysAgo(1), category: IncomeCategory.project),
  Income(id: 'I005', description: 'Penjualan PC Rakitan', amount: 4200000,
    date: _daysAgo(1), category: IncomeCategory.product),

  // === 2-4 Hari lalu ===
  Income(id: 'I006', description: 'Jasa instalasi jaringan', amount: 2000000,
    date: _daysAgo(2), category: IncomeCategory.service),
  Income(id: 'I007', description: 'Proyek aplikasi mobile', amount: 15000000,
    date: _daysAgo(3), category: IncomeCategory.project),
  Income(id: 'I008', description: 'Penjualan lisensi software', amount: 3000000,
    date: _daysAgo(4), category: IncomeCategory.product),

  // === Bulan ini (awal bulan) ===
  Income(id: 'I009', description: 'Proyek sistem kasir Toko ABC', amount: 12000000,
    date: _monthAgo(0, 5), category: IncomeCategory.project),
  Income(id: 'I010', description: 'Pelatihan digital marketing', amount: 5000000,
    date: _monthAgo(0, 7), category: IncomeCategory.service),
  Income(id: 'I011', description: 'Jasa desain grafis', amount: 1500000,
    date: _monthAgo(0, 8), category: IncomeCategory.service),
  Income(id: 'I012', description: 'Penjualan aksesoris komputer', amount: 2800000,
    date: _monthAgo(0, 10), category: IncomeCategory.product),

  // === Bulan lalu ===
  Income(id: 'I013', description: 'Proyek ERP PT. Sejahtera', amount: 25000000,
    date: _monthAgo(1, 3), category: IncomeCategory.project),
  Income(id: 'I014', description: 'Jasa maintenance bulanan', amount: 3000000,
    date: _monthAgo(1, 10), category: IncomeCategory.service),
  Income(id: 'I015', description: 'Penjualan printer & toner', amount: 6000000,
    date: _monthAgo(1, 15), category: IncomeCategory.product),
  Income(id: 'I016', description: 'Workshop IT untuk UMKM', amount: 4000000,
    date: _monthAgo(1, 18), category: IncomeCategory.service),
  Income(id: 'I017', description: 'Proyek website e-commerce', amount: 18000000,
    date: _monthAgo(1, 22), category: IncomeCategory.project),
  Income(id: 'I018', description: 'Penjualan laptop 3 unit', amount: 21000000,
    date: _monthAgo(1, 25), category: IncomeCategory.product),

  // === 2 bulan lalu ===
  Income(id: 'I019', description: 'Proyek app kasir resto', amount: 10000000,
    date: _monthAgo(2, 5), category: IncomeCategory.project),
  Income(id: 'I020', description: 'Pelatihan admin server', amount: 3500000,
    date: _monthAgo(2, 12), category: IncomeCategory.service),
  Income(id: 'I021', description: 'Penjualan UPS & stabilizer', amount: 4500000,
    date: _monthAgo(2, 20), category: IncomeCategory.product),

  // === 3 bulan lalu ===
  Income(id: 'I022', description: 'Proyek digitalisasi arsip', amount: 8000000,
    date: _monthAgo(3, 8), category: IncomeCategory.project),
  Income(id: 'I023', description: 'Jasa data recovery', amount: 2500000,
    date: _monthAgo(3, 15), category: IncomeCategory.service),
  Income(id: 'I024', description: 'Penjualan software antivirus', amount: 1800000,
    date: _monthAgo(3, 22), category: IncomeCategory.product),

  // === 4 bulan lalu ===
  Income(id: 'I025', description: 'Proyek sistem absensi', amount: 9000000,
    date: _monthAgo(4, 5), category: IncomeCategory.project),
  Income(id: 'I026', description: 'Jasa konsultasi keamanan', amount: 5000000,
    date: _monthAgo(4, 18), category: IncomeCategory.service),

  // === 5 bulan lalu ===
  Income(id: 'I027', description: 'Proyek migrasi cloud', amount: 20000000,
    date: _monthAgo(5, 10), category: IncomeCategory.project),
  Income(id: 'I028', description: 'Penjualan perangkat jaringan', amount: 7500000,
    date: _monthAgo(5, 20), category: IncomeCategory.product),

  // === Tahun lalu ===
  Income(id: 'I029', description: 'Proyek besar sistem HR', amount: 35000000,
    date: DateTime(DateTime.now().year - 1, 11, 10), category: IncomeCategory.project),
  Income(id: 'I030', description: 'Jasa audit IT perusahaan', amount: 12000000,
    date: DateTime(DateTime.now().year - 1, 10, 5), category: IncomeCategory.service),
  Income(id: 'I031', description: 'Proyek marketplace', amount: 28000000,
    date: DateTime(DateTime.now().year - 1, 9, 20), category: IncomeCategory.project),
  Income(id: 'I032', description: 'Penjualan server & storage', amount: 45000000,
    date: DateTime(DateTime.now().year - 1, 8, 15), category: IncomeCategory.product),
  Income(id: 'I033', description: 'Pelatihan cyber security', amount: 8000000,
    date: DateTime(DateTime.now().year - 1, 7, 12), category: IncomeCategory.service),
];
