import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/lab.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';
import 'lab_detail_screen.dart';
import 'main_screen.dart' show mainScaffoldKey;

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
    _isITSupport = user?.role == 'admin' || user?.division == 'IT Support';
    
    final labs = await InventoryService().getLabs();
    if (mounted) {
      setState(() {
        _labs = labs;
        _isLoading = false;
      });
    }
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
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tugaskan Penanggung Jawab', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                    subtitle: Text(user.division, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
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
                    Navigator.pop(ctx);
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
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Inventaris Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
      ),
      body: _labs.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text('Tidak ada akses ke Lab manapun', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            Text('Anda belum ditetapkan sebagai penanggung jawab lab.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          ]))
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
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.computer_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lab.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('${lab.inventoryItemsCount} Barang', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                      ])),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Penanggung Jawab:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                          Text(picNames.isEmpty ? 'Belum Ada' : picNames, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: picNames.isEmpty ? AppColors.warning : AppColors.textPrimary)),
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
