# ASFOR - Division Management & Finance System

ASFOR adalah aplikasi manajemen internal berbasis mobile (Flutter) yang dirancang untuk mengelola laporan divisi, manajemen tugas (task manager), dan pelaporan keuangan secara real-time. Aplikasi ini memiliki sistem keamanan berbasis peran (**Role-Based Access Control**) yang memastikan setiap user hanya dapat melihat dan mengelola data sesuai dengan divisinya.

---

## 🚀 Fitur Utama

### 1. Sistem Autentikasi & Keamanan (RBAC)
- **Login System**: Setiap user memiliki ID unik dan password.
- **Role Isolation**: 
  - **User**: Hanya dapat melihat data (Laporan & Task) milik divisinya sendiri.
  - **Super Admin**: Memiliki kontrol penuh atas semua divisi, dapat mengelola user, dan melihat semua laporan.
- **Division Tags**: Identitas divisi yang melekat pada profil (Programmer, Humas, IT Support, Training, Bidang Usaha).

### 2. Dashboard Pintar
- **Personalized Greeting**: Menyapa user secara personal berdasarkan nama.
- **Real-time Stats**: Menampilkan jumlah laporan, task selesai, dan review tertunda.
- **Conditional Visibility**: Kartu "Total Anggaran" hanya muncul untuk divisi **Bidang Usaha** dan **Administrator**.

### 3. Manajemen Laporan
- **Filter Divisi**: Laporan terfilter otomatis sesuai divisi login.
- **Approval System**: Status laporan (Pending, Approved, Rejected) dengan indikator warna.
- **Detail View**: Informasi lengkap anggaran, tanggal, dan deskripsi laporan.

### 4. Task Manager (Tugas)
- **Priority Indicator**: Label prioritas (Tinggi, Sedang, Rendah) untuk efisiensi kerja.
- **FAB (Floating Action Button)**: Tombol melayang global untuk menambah tugas dengan cepat dari halaman manapun.
- **Tab Filter**: Membedakan tugas yang sedang berjalan (To-Do/In-Progress) dan yang sudah selesai.

### 5. Sistem Keuangan (Khusus Bidang Usaha & Admin)
- **Income Tracking**: Pencatatan pemasukan berdasarkan kategori (Proyek, Jasa, Produk).
- **Timeframe Analysis**: Rekap pemasukan Harian, Bulanan, dan Tahunan.
- **Comparison Engine**: Membandingkan pendapatan bulan ini vs bulan lalu dengan indikator persentase naik/turun.
- **Visual Chart**: Bar chart interaktif untuk melihat tren pemasukan 6 bulan terakhir.

### 6. Sidebar Navigation (Drawer)
- **Modern UI**: Menu navigasi samping yang bersih dengan profil user di bagian header.
- **Quick Settings**: Halaman pengaturan akun untuk mengubah nama dan password.

---

## 🛠️ Teknologi & Library
- **Framework**: Flutter (Dart)
- **State Management**: AuthService (Singleton Pattern)
- **Typography**: Google Fonts (Inter)
- **Localization**: Intl (Format Rupiah & Tanggal Indonesia)

---

## 📂 Struktur Folder
```text
lib/
├── data/          # Dummy data & data statis
├── models/        # Model data (User, Report, Task, Income)
├── screens/       # Semua halaman UI
├── services/      # Logika bisnis (Auth, dll)
├── theme/         # Konfigurasi warna & gaya aplikasi
└── widgets/       # Komponen UI reusable (Card, Chips, dll)
```

---

## 🔑 Akun Demo (Untuk Pengetesan)

| Role | Email | Password | Divisi |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `admin@example.com` | `admin123` | Semua |
| **Bidang Usaha** | `yoga@example.com` | `pass123` | Bidang Usaha |
| **Programmer** | `ahmad@example.com` | `pass123` | Programmer |

---

## 📝 Catatan Pengembangan
- **Persistence**: Saat ini data bersifat *in-memory* (hilang saat aplikasi dihapus dari RAM). Disarankan integrasi `shared_preferences` atau `database SQLite` untuk penggunaan jangka panjang.
- **Backend**: Aplikasi siap dihubungkan dengan REST API melalui `http` package di folder `services/`.

---

© 2026 ASFOR Team - Powerful Management System.
