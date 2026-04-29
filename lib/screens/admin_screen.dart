import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'main_screen.dart' show mainScaffoldKey;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await UserService().getUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _showAddUser() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? division;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tambah User Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('User baru akan memiliki akses ke divisi yang ditentukan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: division,
              items: AppTheme.divisions.map((d) => DropdownMenuItem(value: d, child: Row(children: [
                Icon(AppColors.getDivisionIcon(d), size: 18, color: AppColors.getDivisionColor(d)),
                const SizedBox(width: 10), Text(d, style: GoogleFonts.inter(fontSize: 14)),
              ]))).toList(),
              onChanged: (v) => setSheetState(() => division = v),
              decoration: const InputDecoration(hintText: 'Pilih Divisi', prefixIcon: Icon(Icons.group_rounded)),
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || division == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
                  return;
                }
                final existing = _users.any((u) => u.email == emailCtrl.text.trim());
                if (existing) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Email sudah digunakan')));
                  return;
                }
                
                final newUser = AppUser(
                  id: '', name: nameCtrl.text.trim(), email: emailCtrl.text.trim(),
                  password: passwordCtrl.text, division: division!, role: UserRole.user,
                );
                
                final success = await UserService().createUser(newUser);
                if (success) {
                  _fetchUsers();
                  if (mounted) Navigator.pop(ctx);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('✅ User berhasil ditambahkan'), backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                } else {
                  if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Gagal menambahkan user')));
                }
              },
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text('Tambah User', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ])),
        );
      }),
    );
  }

  void _confirmDelete(AppUser user) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus User?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Yakin ingin menghapus ${user.name}?', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () async { 
            Navigator.pop(ctx);
            final success = await UserService().deleteUser(user.id);
            if (success) {
              _fetchUsers();
            } else {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus user')));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    }
    
    final users = _users;
    final divGroups = <String, List<AppUser>>{};
    for (final u in users) {
      divGroups.putIfAbsent(u.division, () => []).add(u);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Kelola User', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUser, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded), label: Text('User', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.people_rounded, color: Colors.white, size: 24)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total User', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              Text('${users.length}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
            const Spacer(),
            ...AppTheme.divisions.map((d) {
              final count = users.where((u) => u.division == d).length;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('$count', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              );
            }),
          ]),
        ),
        const SizedBox(height: 20),

        // User list by division
        ...divGroups.entries.map((entry) {
          final div = entry.key;
          final divUsers = entry.value;
          final color = div == 'Semua' ? AppColors.primary : AppColors.getDivisionColor(div);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(div == 'Semua' ? Icons.admin_panel_settings_rounded : AppColors.getDivisionIcon(div), size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Text(div == 'Semua' ? 'Super Admin' : div, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                  child: Text('${divUsers.length}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                ),
              ]),
            ),
            ...divUsers.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                // Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(u.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(u.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (u.isSuperAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text('ADMIN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.warning)),
                      ),
                    ],
                  ]),
                  Text('ID: ${u.id} • ${u.email}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                ])),
                if (!u.isSuperAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                    onPressed: () => _confirmDelete(u),
                  ),
              ]),
            )),
            const SizedBox(height: 12),
          ]);
        }),
        const SizedBox(height: 60),
      ]),
    );
  }
}
