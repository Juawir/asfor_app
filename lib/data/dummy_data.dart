import '../models/report.dart';
import '../models/task.dart';

final List<Report> dummyReports = [
  // Programmer
  Report(id: 'R001', title: 'Pengembangan Sistem E-Learning', description: 'Laporan progress pengembangan platform e-learning berbasis web untuk internal organisasi. Meliputi fitur manajemen kursus, quiz interaktif, dan tracking progress peserta.', division: 'Programmer', date: DateTime(2026, 4, 20), status: ReportStatus.approved, budget: 24500000, submittedBy: 'Ahmad Fauzi', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 22), attachments: ['proposal_elearning.pdf', 'wireframe_v2.fig']),
  Report(id: 'R002', title: 'Maintenance Server Bulanan', description: 'Laporan maintenance server bulanan April 2026. Termasuk update keamanan, optimasi database, dan backup rutin.', division: 'Programmer', date: DateTime(2026, 4, 15), status: ReportStatus.approved, budget: 3500000, submittedBy: 'Budi Santoso', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 16)),
  Report(id: 'R003', title: 'Integrasi API Payment Gateway', description: 'Laporan integrasi sistem pembayaran dengan Midtrans untuk platform donasi organisasi.', division: 'Programmer', date: DateTime(2026, 4, 23), status: ReportStatus.pending, budget: 8000000, submittedBy: 'Ahmad Fauzi'),
  Report(id: 'R004', title: 'Bug Fixing Aplikasi Mobile', description: 'Perbaikan bug kritis pada aplikasi mobile versi 2.1: crash saat upload foto dan lag pada halaman dashboard.', division: 'Programmer', date: DateTime(2026, 4, 10), status: ReportStatus.approved, budget: 2000000, submittedBy: 'Rina Wati', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 12)),
  Report(id: 'R005', title: 'Redesign Database Schema', description: 'Rancangan ulang struktur database untuk mengakomodasi fitur multi-tenant.', division: 'Programmer', date: DateTime(2026, 4, 24), status: ReportStatus.draft, budget: 5000000, submittedBy: 'Budi Santoso'),

  // Hubungan Masyarakat
  Report(id: 'R006', title: 'Kegiatan Bakti Sosial Ramadhan', description: 'Laporan pelaksanaan bakti sosial bulan Ramadhan di 3 panti asuhan wilayah Bandung. Total 150 paket sembako terdistribusi.', division: 'Hubungan Masyarakat', date: DateTime(2026, 4, 5), status: ReportStatus.approved, budget: 15000000, submittedBy: 'Siti Aisyah', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 7), attachments: ['dokumentasi_baksos.zip']),
  Report(id: 'R007', title: 'Kerjasama Media Partnership', description: 'Proposal kerjasama media partnership dengan 5 portal berita lokal untuk publikasi kegiatan organisasi.', division: 'Hubungan Masyarakat', date: DateTime(2026, 4, 18), status: ReportStatus.pending, budget: 12000000, submittedBy: 'Dewi Lestari'),
  Report(id: 'R008', title: 'Seminar Publik: Literasi Digital', description: 'Laporan pelaksanaan seminar literasi digital untuk mahasiswa. Peserta 200 orang.', division: 'Hubungan Masyarakat', date: DateTime(2026, 4, 12), status: ReportStatus.approved, budget: 8500000, submittedBy: 'Siti Aisyah', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 14)),
  Report(id: 'R009', title: 'Pengelolaan Media Sosial Q1', description: 'Rekap pengelolaan akun Instagram, TikTok, dan YouTube organisasi kuartal pertama 2026.', division: 'Hubungan Masyarakat', date: DateTime(2026, 4, 1), status: ReportStatus.approved, budget: 4000000, submittedBy: 'Dewi Lestari', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 3)),
  Report(id: 'R010', title: 'Event Buka Puasa Bersama', description: 'Proposal kegiatan buka puasa bersama dengan stakeholder dan mitra.', division: 'Hubungan Masyarakat', date: DateTime(2026, 4, 22), status: ReportStatus.rejected, budget: 20000000, submittedBy: 'Siti Aisyah', rejectionNote: 'Anggaran terlalu besar, harap direvisi dan ajukan ulang.'),

  // IT Support
  Report(id: 'R011', title: 'Pengadaan Perangkat Komputer', description: 'Laporan pengadaan 10 unit komputer baru untuk Lab IT. Termasuk spesifikasi dan vendor terpilih.', division: 'IT Support', date: DateTime(2026, 4, 8), status: ReportStatus.approved, budget: 85000000, submittedBy: 'Reza Pratama', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 10), attachments: ['quotation_vendor.pdf']),
  Report(id: 'R012', title: 'Setup Jaringan WiFi Gedung B', description: 'Instalasi 15 access point dan konfigurasi jaringan baru untuk Gedung B lantai 1-3.', division: 'IT Support', date: DateTime(2026, 4, 14), status: ReportStatus.approved, budget: 25000000, submittedBy: 'Fajar Hidayat', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 16)),
  Report(id: 'R013', title: 'Migrasi Email ke Google Workspace', description: 'Rencana migrasi email organisasi dari server lokal ke Google Workspace.', division: 'IT Support', date: DateTime(2026, 4, 21), status: ReportStatus.pending, budget: 15000000, submittedBy: 'Reza Pratama'),
  Report(id: 'R014', title: 'Troubleshooting Printer Lantai 2', description: 'Laporan penanganan masalah printer jaringan yang tidak bisa diakses dari divisi Humas.', division: 'IT Support', date: DateTime(2026, 4, 19), status: ReportStatus.approved, budget: 500000, submittedBy: 'Fajar Hidayat', approvedBy: 'Reza Pratama', approvedAt: DateTime(2026, 4, 19)),

  // Training
  Report(id: 'R015', title: 'Workshop Flutter Development', description: 'Pelaksanaan workshop Flutter selama 3 hari untuk anggota divisi Programmer. Materi: Dart basics, Widget, State Management.', division: 'Training', date: DateTime(2026, 4, 3), status: ReportStatus.approved, budget: 12000000, submittedBy: 'Nadia Putri', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 5), attachments: ['materi_flutter.pdf', 'sertifikat_template.docx']),
  Report(id: 'R016', title: 'Pelatihan Public Speaking', description: 'Program pelatihan public speaking 2 sesi untuk seluruh anggota organisasi.', division: 'Training', date: DateTime(2026, 4, 10), status: ReportStatus.approved, budget: 7500000, submittedBy: 'Irfan Maulana', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 12)),
  Report(id: 'R017', title: 'Bootcamp UI/UX Design', description: 'Proposal bootcamp UI/UX Design intensif 5 hari dengan mentor dari industri.', division: 'Training', date: DateTime(2026, 4, 23), status: ReportStatus.pending, budget: 18000000, submittedBy: 'Nadia Putri'),
  Report(id: 'R018', title: 'Sertifikasi AWS Cloud', description: 'Program persiapan dan ujian sertifikasi AWS Cloud Practitioner untuk 5 anggota.', division: 'Training', date: DateTime(2026, 4, 17), status: ReportStatus.draft, budget: 25000000, submittedBy: 'Irfan Maulana'),

  // Bidang Usaha
  Report(id: 'R019', title: 'Penjualan Merchandise Q1', description: 'Rekap penjualan merchandise organisasi kuartal pertama: kaos, hoodie, stiker, dan tote bag.', division: 'Bidang Usaha', date: DateTime(2026, 4, 2), status: ReportStatus.approved, budget: 30000000, submittedBy: 'Yoga Aditya', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 4), attachments: ['laporan_penjualan_q1.xlsx']),
  Report(id: 'R020', title: 'Kerjasama Sponsor Event', description: 'Negosiasi dan MoU dengan 3 sponsor untuk event tahunan organisasi.', division: 'Bidang Usaha', date: DateTime(2026, 4, 15), status: ReportStatus.approved, budget: 50000000, submittedBy: 'Maya Sari', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 17)),
  Report(id: 'R021', title: 'Proposal Usaha Jasa Desain', description: 'Proposal pembukaan lini usaha jasa desain grafis untuk klien eksternal.', division: 'Bidang Usaha', date: DateTime(2026, 4, 20), status: ReportStatus.pending, budget: 10000000, submittedBy: 'Yoga Aditya'),
  Report(id: 'R022', title: 'Laporan Keuangan Usaha Maret', description: 'Rekap pemasukan dan pengeluaran seluruh unit usaha bulan Maret 2026.', division: 'Bidang Usaha', date: DateTime(2026, 4, 5), status: ReportStatus.approved, budget: 0, submittedBy: 'Maya Sari', approvedBy: 'Ketua Umum', approvedAt: DateTime(2026, 4, 7)),
];

final List<Task> dummyTasks = [
  // Programmer
  Task(id: 'T001', title: 'Develop login page', description: 'Buat halaman login dengan autentikasi JWT', division: 'Programmer', assignee: 'Ahmad Fauzi', dueDate: DateTime(2026, 4, 28), priority: TaskPriority.high, status: TaskStatus.inProgress),
  Task(id: 'T002', title: 'API endpoint CRUD laporan', description: 'Buat REST API untuk create, read, update, delete laporan', division: 'Programmer', assignee: 'Budi Santoso', dueDate: DateTime(2026, 4, 30), priority: TaskPriority.high, status: TaskStatus.todo),
  Task(id: 'T003', title: 'Unit testing modul auth', description: 'Tulis unit test untuk modul autentikasi', division: 'Programmer', assignee: 'Rina Wati', dueDate: DateTime(2026, 5, 2), priority: TaskPriority.medium, status: TaskStatus.todo),
  Task(id: 'T004', title: 'Optimasi query database', description: 'Perbaiki slow query pada tabel transaksi', division: 'Programmer', assignee: 'Ahmad Fauzi', dueDate: DateTime(2026, 4, 20), priority: TaskPriority.medium, status: TaskStatus.done),
  Task(id: 'T005', title: 'Setup CI/CD pipeline', description: 'Konfigurasi GitHub Actions untuk auto deploy', division: 'Programmer', assignee: 'Budi Santoso', dueDate: DateTime(2026, 5, 5), priority: TaskPriority.low, status: TaskStatus.todo),

  // Hubungan Masyarakat
  Task(id: 'T006', title: 'Desain poster event Mei', description: 'Buat desain poster untuk event seminar bulan Mei', division: 'Hubungan Masyarakat', assignee: 'Siti Aisyah', dueDate: DateTime(2026, 4, 27), priority: TaskPriority.high, status: TaskStatus.inProgress),
  Task(id: 'T007', title: 'Konten Instagram minggu ini', description: 'Siapkan 5 konten feed dan 3 story untuk minggu ini', division: 'Hubungan Masyarakat', assignee: 'Dewi Lestari', dueDate: DateTime(2026, 4, 26), priority: TaskPriority.medium, status: TaskStatus.inProgress),
  Task(id: 'T008', title: 'Press release kegiatan baksos', description: 'Tulis dan distribusikan press release ke media lokal', division: 'Hubungan Masyarakat', assignee: 'Siti Aisyah', dueDate: DateTime(2026, 4, 22), priority: TaskPriority.high, status: TaskStatus.done),
  Task(id: 'T009', title: 'Update website berita terbaru', description: 'Publish 3 artikel berita terbaru di website organisasi', division: 'Hubungan Masyarakat', assignee: 'Dewi Lestari', dueDate: DateTime(2026, 4, 29), priority: TaskPriority.low, status: TaskStatus.todo),

  // IT Support
  Task(id: 'T010', title: 'Install OS di PC baru', description: 'Setup Windows 11 dan software standar di 10 PC baru', division: 'IT Support', assignee: 'Reza Pratama', dueDate: DateTime(2026, 4, 26), priority: TaskPriority.high, status: TaskStatus.inProgress),
  Task(id: 'T011', title: 'Backup data server', description: 'Lakukan full backup semua data server ke NAS', division: 'IT Support', assignee: 'Fajar Hidayat', dueDate: DateTime(2026, 4, 25), priority: TaskPriority.high, status: TaskStatus.todo),
  Task(id: 'T012', title: 'Perbaiki AC ruang server', description: 'Koordinasi dengan teknisi AC untuk perbaikan unit di ruang server', division: 'IT Support', assignee: 'Reza Pratama', dueDate: DateTime(2026, 4, 28), priority: TaskPriority.medium, status: TaskStatus.todo),
  Task(id: 'T013', title: 'Update antivirus seluruh PC', description: 'Update definisi antivirus di semua workstation', division: 'IT Support', assignee: 'Fajar Hidayat', dueDate: DateTime(2026, 4, 18), priority: TaskPriority.low, status: TaskStatus.done),

  // Training
  Task(id: 'T014', title: 'Siapkan materi React.js', description: 'Buat slide presentasi dan hands-on lab untuk workshop React.js', division: 'Training', assignee: 'Nadia Putri', dueDate: DateTime(2026, 5, 1), priority: TaskPriority.high, status: TaskStatus.inProgress),
  Task(id: 'T015', title: 'Rekrut mentor bootcamp', description: 'Cari dan konfirmasi 2 mentor industri untuk bootcamp UI/UX', division: 'Training', assignee: 'Irfan Maulana', dueDate: DateTime(2026, 4, 28), priority: TaskPriority.high, status: TaskStatus.todo),
  Task(id: 'T016', title: 'Evaluasi peserta workshop', description: 'Rekap nilai dan feedback dari peserta workshop Flutter', division: 'Training', assignee: 'Nadia Putri', dueDate: DateTime(2026, 4, 15), priority: TaskPriority.medium, status: TaskStatus.done),
  Task(id: 'T017', title: 'Buat jadwal training Q2', description: 'Susun jadwal program pelatihan kuartal 2', division: 'Training', assignee: 'Irfan Maulana', dueDate: DateTime(2026, 5, 3), priority: TaskPriority.low, status: TaskStatus.todo),

  // Bidang Usaha
  Task(id: 'T018', title: 'Desain merchandise baru', description: 'Buat desain untuk koleksi merchandise edisi Ramadhan', division: 'Bidang Usaha', assignee: 'Yoga Aditya', dueDate: DateTime(2026, 4, 27), priority: TaskPriority.high, status: TaskStatus.inProgress),
  Task(id: 'T019', title: 'Follow up invoice sponsor', description: 'Kirim invoice dan follow up pembayaran 3 sponsor', division: 'Bidang Usaha', assignee: 'Maya Sari', dueDate: DateTime(2026, 4, 25), priority: TaskPriority.high, status: TaskStatus.todo),
  Task(id: 'T020', title: 'Riset harga cetak kaos', description: 'Bandingkan harga dari 5 vendor percetakan kaos', division: 'Bidang Usaha', assignee: 'Yoga Aditya', dueDate: DateTime(2026, 4, 20), priority: TaskPriority.medium, status: TaskStatus.done),
  Task(id: 'T021', title: 'Laporan stok merchandise', description: 'Hitung dan catat stok merchandise yang tersisa', division: 'Bidang Usaha', assignee: 'Maya Sari', dueDate: DateTime(2026, 5, 1), priority: TaskPriority.low, status: TaskStatus.todo),
];
