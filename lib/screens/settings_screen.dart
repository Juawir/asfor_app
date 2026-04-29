import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'main_screen.dart' show mainScaffoldKey;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthService();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  bool _editingName = false;
  bool _changingPassword = false;
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _auth.currentUser?.name ?? '');
    _emailCtrl = TextEditingController(text: _auth.currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _saveName() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    
    // Tampilkan loading (opsional bisa pakai showDialog atau state)
    final error = await _auth.updateProfile(_nameCtrl.text.trim());
    if (!mounted) return;
    
    if (error == null) {
      setState(() => _editingName = false);
      _showSnack('✅ Nama berhasil diperbarui');
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _changePassword() async {
    if (_oldPassCtrl.text.isEmpty) {
      _showSnack('Password lama wajib diisi', isError: true);
      return;
    }
    if (_newPassCtrl.text.length < 4) {
      _showSnack('Password baru minimal 4 karakter', isError: true);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _showSnack('Konfirmasi password tidak cocok', isError: true);
      return;
    }
    
    final error = await _auth.changePassword(_oldPassCtrl.text, _newPassCtrl.text);
    if (!mounted) return;

    if (error == null) {
      setState(() => _changingPassword = false);
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      _showSnack('✅ Password berhasil diubah');
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();
    final divColor = user.isSuperAdmin ? AppColors.primary : AppColors.getDivisionColor(user.division);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Pengaturan Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Profile card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [divColor, divColor.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.white24, shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 3),
              ),
              child: Center(child: Text(user.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 12),
            Text(user.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text('${user.email}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
              child: Text('${user.roleLabel} • ${user.division}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // Account info section
        _sectionTitle('Informasi Akun'),
        const SizedBox(height: 8),
        _infoCard([
          _infoTile('ID Anggota', user.id, Icons.badge_rounded),
          const Divider(height: 1, color: AppColors.border),
          _infoTile('Divisi', user.division, Icons.group_rounded),
          const Divider(height: 1, color: AppColors.border),
          _infoTile('Role', user.roleLabel, Icons.shield_rounded),
        ]),
        const SizedBox(height: 20),

        // Edit name
        _sectionTitle('Ubah Nama'),
        const SizedBox(height: 8),
        _infoCard([
          Padding(
            padding: const EdgeInsets.all(14),
            child: _editingName
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Nama lengkap', prefixIcon: Icon(Icons.person_rounded)), style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => setState(() => _editingName = false), child: const Text('Batal'))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: _saveName, child: const Text('Simpan'))),
                  ]),
                ])
              : Row(children: [
                  const Icon(Icons.person_rounded, size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Expanded(child: Text(user.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                  TextButton(onPressed: () => setState(() => _editingName = true), child: Text('Edit', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                ]),
          ),
        ]),
        const SizedBox(height: 20),

        // Change password
        _sectionTitle('Ubah Password'),
        const SizedBox(height: 8),
        _infoCard([
          Padding(
            padding: const EdgeInsets.all(14),
            child: _changingPassword
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextField(controller: _oldPassCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password lama', prefixIcon: Icon(Icons.lock_outline_rounded)), style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(controller: _newPassCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password baru', prefixIcon: Icon(Icons.lock_rounded)), style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(controller: _confirmPassCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Konfirmasi password baru', prefixIcon: Icon(Icons.lock_rounded)), style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () => setState(() => _changingPassword = false), child: const Text('Batal'))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: _changePassword, child: const Text('Simpan'))),
                  ]),
                ])
              : Row(children: [
                  const Icon(Icons.lock_rounded, size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Expanded(child: Text('••••••••', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary))),
                  TextButton(onPressed: () => setState(() => _changingPassword = true), child: Text('Ubah', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                ]),
          ),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary));

  Widget _infoCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
    child: Column(children: children),
  );

  Widget _infoTile(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [
      Icon(icon, size: 20, color: AppColors.textMuted),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ])),
    ]),
  );
}
