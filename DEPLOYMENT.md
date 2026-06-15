# 🚀 Panduan Deployment ASFOR App (Flutter)

Dokumen ini menjelaskan langkah-langkah untuk melakukan build aplikasi ASFOR untuk produksi.

## 📱 Build untuk Android (APK)

Untuk menghasilkan file APK yang siap diinstal:

1.  **Persiapan Environment**:
    Pastikan file `.env` sudah dikonfigurasi dengan URL API produksi:
    ```env
    API_BASE_URL=https://taskmanage.aslabinf.my.id/api
    ```

2.  **Bersihkan Cache**:
    ```bash
    flutter clean
    flutter pub get
    ```

3.  **Build APK**:
    ```bash
    flutter build apk --release
    ```
    File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`.

4.  **Build App Bundle (Untuk Play Store)**:
    ```bash
    flutter build appbundle --release
    ```

---

## 🌐 Build untuk Web

Jika aplikasi ingin di-deploy sebagai website:

1.  **Build Web**:
    ```bash
    flutter build web --release
    ```

2.  **Deployment**:
    Upload isi dari folder `build/web` ke hosting atau layanan seperti Firebase Hosting, Netlify, atau Vercel.

---

## 🔑 Penandatanganan Aplikasi (App Signing)

Untuk rilis resmi ke Play Store, Anda perlu melakukan *Code Signing*. 
Ikuti panduan resmi Flutter: [Deployment to Android](https://docs.flutter.dev/deployment/android#signing-the-app)

---

## 📝 Catatan Penting
- Pastikan koneksi internet stabil saat melakukan build karena Flutter akan mendownload dependencies.
- Periksa `android/app/build.gradle` untuk memastikan `versionCode` dan `versionName` sudah sesuai sebelum rilis baru.
