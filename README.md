# ASFOR - Division Management & Finance System

ASFOR adalah aplikasi manajemen internal berbasis mobile (Flutter) yang dirancang untuk mengelola laporan divisi, manajemen tugas (task manager), pelaporan keuangan secara real-time, dan pemilihan ketua. Aplikasi ini memiliki sistem keamanan berbasis peran (**Role-Based Access Control**) yang memastikan setiap user hanya dapat melihat dan mengelola data sesuai dengan divisinya.

---

## 🚀 Fitur Utama

### 1. Sistem Autentikasi & Keamanan (RBAC)
- **Email Login System**: Autentikasi aman menggunakan Email dan Password, terkoneksi dengan API.
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
- **Assignee Dinamis**: Memilih penugasan berdasarkan divisi secara real-time dari API.
- **Priority Indicator**: Label prioritas (Tinggi, Sedang, Rendah) untuk efisiensi kerja.
- **Tab Filter**: Membedakan tugas yang sedang berjalan (To-Do/In-Progress) dan yang sudah selesai.

### 5. Sistem Keuangan (Khusus Bidang Usaha & Admin)
- **Income Tracking**: Pencatatan pemasukan berdasarkan kategori (Proyek, Jasa, Produk).
- **Timeframe Analysis**: Rekap pemasukan Harian, Bulanan, dan Tahunan.
- **Comparison Engine**: Membandingkan pendapatan bulan ini vs bulan lalu dengan indikator persentase naik/turun.
- **Visual Chart**: Bar chart interaktif untuk melihat tren pemasukan 6 bulan terakhir.

### 6. Pemilihan Ketua Aslab (Voting) - *BARU*
- **Live Voting System**: Fitur pemilihan ketua dengan real-time progress untuk Admin.
- **One-Vote Constraint**: Sistem aman di mana setiap user hanya bisa memberikan 1 suara.
- **Winner Reveal**: Penampilan pemenang secara eksklusif setelah pemilihan ditutup.
- **Candidate Management**: Admin dapat membuat pemilihan dan menambah kandidat dari seluruh anggota divisi.

### 7. UI / UX Premium
- **Modern UI**: Menggunakan gradasi warna halus, efek bayangan melayang (3D), dan animasi navigasi.
- **Sidebar Navigation (Drawer)**: Menu navigasi samping yang bersih dengan profil user di bagian header.
- **Material 3 Design**: Dukungan sudut membulat untuk dialog, pop-up, dan notifikasi (snackbar).

---

## 🛠️ Teknologi & Library
- **Framework**: Flutter (Dart)
- **Backend API Integration**: HTTP RESTful API (`https://taskmanage.aslabinf.my.id/api`)
- **Local Storage**: SharedPreferences (digunakan untuk *caching* sesi pemilihan dan otentikasi)
- **Typography**: Google Fonts (Inter)
- **Localization**: Intl (Format Rupiah & Tanggal Indonesia)
- **Android Support**: Kompatibel penuh dengan Android 12+ (SDK 31+).

---

## 📂 Struktur Folder
```text
lib/
├── models/        # Model data (User, Report, Task, Income, Election)
├── screens/       # Semua halaman UI (Dashboard, Login, Finance, Election, dll)
├── services/      # Logika API & Local Storage (Auth, Task, Report, Election)
├── theme/         # Konfigurasi warna (AppColors) & gaya aplikasi (Material 3)
└── widgets/       # Komponen UI reusable (Card, Chips, StatCard)
```

---

## 🔑 Akun Demo (Untuk Pengetesan)

Pastikan aplikasi terhubung ke internet saat mencoba akun ini karena memanggil REST API asli.

| Role | Email | Password | Divisi |
| :--- | :--- | :--- | :--- |
| **Super Admin** | `admin@example.com` | `password` | Semua |
---

## 📝 Catatan Pengembangan
- **API Status**: Saat ini integrasi *Users*, *Tasks*, dan *Auth* sudah menggunakan backend Laravel jarak jauh. 
- **Election Module**: Fitur pemilihan ketua masih menggunakan penyimpanan *Local Storage (SharedPreferences)* dan dapat dialihkan ke API secara mulus jika endpoint `/elections` sudah tersedia di Laravel.

---

© 2026 ASFOR Team - Powerful Management System.
