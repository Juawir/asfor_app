import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const AsforApp());
}

class AsforApp extends StatelessWidget {
  const AsforApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASFOR - Rekap Laporan Divisi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
