import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/lab.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';
import 'lab_detail_screen.dart';
import 'main_screen.dart' show buildMenuButton;

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  bool _isLoading = true;
  List<Lab> _labs = [];
  bool _isITSupport = false;

  @override
  void initState() {
    super.initState();
    _checkAccessAndFetch();
  }

  Future<void> _checkAccessAndFetch() async {
    final user = AuthService().currentUser;
    _isITSupport = user?.isSuperAdmin == true || user?.division == 'IT Support';
    
    final labs = await InventoryService().getLabs();
    if (mounted) {
      setState(() {
        _labs = labs;
        _isLoading = false;
      });
    }
  }

  void _showAddLabDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(color: AppColors.surfaceOf(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderOf(context), borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_home_work_rounded, color: AppColors.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tambah Lab Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context))),
                Text('Isi informasi laboratorium', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context))),
              ])),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              enabled: !saving,
              decoration: const InputDecoration(hintText: 'Nama Lab (cth: Lab Komputer A)', prefixIcon: Icon(Icons.computer_rounded)),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              enabled: !saving,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Deskripsi lab...', prefixIcon: Icon(Icons.notes_rounded)),
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: saving ? null : () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama lab wajib diisi'), backgroundColor: AppColors.danger));
                  return;
                }
                setSheet(() => saving = true);
                final lab = await InventoryService().createLab(nameCtrl.text.trim(), descCtrl.text.trim());
                if (mounted) {
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (lab != null) {
                    _checkAccessAndFetch();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('✅ Lab berhasil ditambahkan'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Gagal menambahkan lab'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  }
                }
              },
              icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add_rounded, size: 18),
              label: Text(saving ? 'Menyimpan...' : 'Tambah Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
          ])),
        );
      }),
    );
  }

  void _confirmDeleteLab(Lab lab) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Lab?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Lab "${lab.name}" beserta semua inventarisnya akan dihapus permanen.', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await InventoryService().deleteLab(lab.id);
            if (mounted) {
              if (ok) {
                _checkAccessAndFetch();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Lab dihapus'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Gagal menghapus lab'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  void _showAssignDialog(Lab lab) async {
    final users = await InventoryService().getInventoryUsers();
    if (!mounted) return;

    List<String> selectedIds = lab.pics.map((e) => e.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surfaceOf(context), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderOf(context), borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tugaskan Penanggung Jawab', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context))),
            Text(lab.name, style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isSelected = selectedIds.contains(user.id);
                  return CheckboxListTile(
                    title: Text(user.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text(user.division, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context))),
                    value: isSelected,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setSheetState(() {
                        if (val == true) {
                          selectedIds.add(user.id);
                        } else {
                          selectedIds.remove(user.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await InventoryService().assignPics(lab.id, selectedIds);
                  if (mounted) {
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (success) {
                      _checkAccessAndFetch();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penanggung Jawab berhasil diperbarui'), backgroundColor: AppColors.success));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui Penanggung Jawab'), backgroundColor: AppColors.danger));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            )
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: AppColors.backgroundOf(context), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        leading: buildMenuButton(context),
        title: Text('Inventaris Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceOf(context), surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: _isITSupport ? FloatingActionButton.extended(
        onPressed: _showAddLabDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_work_rounded),
        label: Text('Tambah Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ) : null,
      body: _labs.isEmpty
        ? Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: Icon(Icons.inventory_2_outlined, size: 52, color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 20),
              Text(
                _isITSupport ? 'Belum Ada Lab' : 'Tidak Ada Akses Lab',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context)),
              ),
              const SizedBox(height: 8),
              Text(
                _isITSupport
                  ? 'Tap tombol "Tambah Lab" di bawah untuk menambahkan laboratorium baru.'
                  : 'Anda belum ditetapkan sebagai penanggung jawab lab manapun.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMutedOf(context), height: 1.5),
              ),
            ]),
          ))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _labs.length,
            itemBuilder: (context, index) {
              final lab = _labs[index];
              final picNames = lab.pics.map((e) => e.name).join(', ');
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LabDetailScreen(lab: lab))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surfaceOf(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderOf(context))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.computer_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lab.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context))),
                        const SizedBox(height: 4),
                        Text('${lab.inventoryItemsCount} Barang', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context))),
                      ])),
                      if (_isITSupport)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                          tooltip: 'Hapus Lab',
                          onPressed: () => _confirmDeleteLab(lab),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.backgroundOf(context), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Icon(Icons.person_pin_rounded, size: 18, color: AppColors.textMutedOf(context)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Penanggung Jawab:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMutedOf(context))),
                          Text(picNames.isEmpty ? 'Belum Ada' : picNames, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: picNames.isEmpty ? AppColors.warning : AppColors.textPrimaryOf(context))),
                        ])),
                        if (_isITSupport)
                          TextButton(
                            onPressed: () => _showAssignDialog(lab),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text('Ubah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
    );
  }
}
