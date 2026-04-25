import '../models/income.dart';

final now = DateTime.now();

final List<Income> dummyIncomes = [
  // === Hari ini ===
  Income(id: 'I001', description: 'Jasa konsultasi IT PT. Maju', amount: 3500000, date: DateTime(now.year, now.month, now.day, 9, 0), category: IncomeCategory.service),
  Income(id: 'I002', description: 'Penjualan modul training', amount: 1200000, date: DateTime(now.year, now.month, now.day, 11, 30), category: IncomeCategory.product),
  Income(id: 'I003', description: 'Maintenance server klien', amount: 800000, date: DateTime(now.year, now.month, now.day, 14, 0), category: IncomeCategory.service),

  // === Kemarin ===
  Income(id: 'I004', description: 'Proyek website CV. Berkah', amount: 7500000, date: DateTime(now.year, now.month, now.day - 1, 10, 0), category: IncomeCategory.project),
  Income(id: 'I005', description: 'Penjualan PC Rakitan', amount: 4200000, date: DateTime(now.year, now.month, now.day - 1, 15, 0), category: IncomeCategory.product),

  // === Minggu ini ===
  Income(id: 'I006', description: 'Jasa instalasi jaringan', amount: 2000000, date: DateTime(now.year, now.month, now.day - 2), category: IncomeCategory.service),
  Income(id: 'I007', description: 'Proyek aplikasi mobile', amount: 15000000, date: DateTime(now.year, now.month, now.day - 3), category: IncomeCategory.project),
  Income(id: 'I008', description: 'Penjualan lisensi software', amount: 3000000, date: DateTime(now.year, now.month, now.day - 4), category: IncomeCategory.product),

  // === Bulan ini (sebelumnya) ===
  Income(id: 'I009', description: 'Proyek sistem kasir Toko ABC', amount: 12000000, date: DateTime(now.year, now.month, 5), category: IncomeCategory.project),
  Income(id: 'I010', description: 'Pelatihan digital marketing', amount: 5000000, date: DateTime(now.year, now.month, 7), category: IncomeCategory.service),
  Income(id: 'I011', description: 'Jasa desain grafis', amount: 1500000, date: DateTime(now.year, now.month, 8), category: IncomeCategory.service),
  Income(id: 'I012', description: 'Penjualan aksesoris komputer', amount: 2800000, date: DateTime(now.year, now.month, 10), category: IncomeCategory.product),
  Income(id: 'I013', description: 'Setup CCTV kantor', amount: 4500000, date: DateTime(now.year, now.month, 12), category: IncomeCategory.service),

  // === Bulan lalu ===
  Income(id: 'I014', description: 'Proyek ERP PT. Sejahtera', amount: 25000000, date: DateTime(now.year, now.month - 1, 3), category: IncomeCategory.project),
  Income(id: 'I015', description: 'Jasa maintenance bulanan', amount: 3000000, date: DateTime(now.year, now.month - 1, 10), category: IncomeCategory.service),
  Income(id: 'I016', description: 'Penjualan printer & toner', amount: 6000000, date: DateTime(now.year, now.month - 1, 15), category: IncomeCategory.product),
  Income(id: 'I017', description: 'Workshop IT untuk UMKM', amount: 4000000, date: DateTime(now.year, now.month - 1, 18), category: IncomeCategory.service),
  Income(id: 'I018', description: 'Proyek website e-commerce', amount: 18000000, date: DateTime(now.year, now.month - 1, 22), category: IncomeCategory.project),
  Income(id: 'I019', description: 'Penjualan laptop 3 unit', amount: 21000000, date: DateTime(now.year, now.month - 1, 25), category: IncomeCategory.product),

  // === 2 bulan lalu ===
  Income(id: 'I020', description: 'Proyek app kasir resto', amount: 10000000, date: DateTime(now.year, now.month - 2, 5), category: IncomeCategory.project),
  Income(id: 'I021', description: 'Pelatihan admin server', amount: 3500000, date: DateTime(now.year, now.month - 2, 12), category: IncomeCategory.service),
  Income(id: 'I022', description: 'Penjualan UPS & stabilizer', amount: 4500000, date: DateTime(now.year, now.month - 2, 20), category: IncomeCategory.product),

  // === 3 bulan lalu ===
  Income(id: 'I023', description: 'Proyek digitalisasi arsip', amount: 8000000, date: DateTime(now.year, now.month - 3, 8), category: IncomeCategory.project),
  Income(id: 'I024', description: 'Jasa data recovery', amount: 2500000, date: DateTime(now.year, now.month - 3, 15), category: IncomeCategory.service),
  Income(id: 'I025', description: 'Penjualan software antivirus', amount: 1800000, date: DateTime(now.year, now.month - 3, 22), category: IncomeCategory.product),

  // === Tahun lalu (beberapa bulan) ===
  Income(id: 'I026', description: 'Proyek besar sistem HR', amount: 35000000, date: DateTime(now.year - 1, 11, 10), category: IncomeCategory.project),
  Income(id: 'I027', description: 'Jasa audit IT perusahaan', amount: 12000000, date: DateTime(now.year - 1, 10, 5), category: IncomeCategory.service),
  Income(id: 'I028', description: 'Proyek marketplace', amount: 28000000, date: DateTime(now.year - 1, 9, 20), category: IncomeCategory.project),
  Income(id: 'I029', description: 'Penjualan server & storage', amount: 45000000, date: DateTime(now.year - 1, 8, 15), category: IncomeCategory.product),
  Income(id: 'I030', description: 'Pelatihan cyber security', amount: 8000000, date: DateTime(now.year - 1, 7, 12), category: IncomeCategory.service),
];
