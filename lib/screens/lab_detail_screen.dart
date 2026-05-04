import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/lab.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';

class LabDetailScreen extends StatefulWidget {
  final Lab lab;
  const LabDetailScreen({super.key, required this.lab});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> {
  bool _isLoading = true;
  Lab? _lab;
  List<InventoryItem> _items = [];
  bool _isITSupport = false;
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _isITSupport = user?.role == 'admin' || user?.division == 'IT Support';
    _canEdit = _isITSupport || widget.lab.pics.any((pic) => pic.id == user?.id);
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final res = await InventoryService().getLabDetails(widget.lab.id);
    if (mounted) {
      setState(() {
        _lab = res['lab'];
        _items = res['items'] ?? [];
        _isLoading = false;
      });
    }
  }

  void _showItemDialog([InventoryItem? item]) {
    final isEdit = item != null;
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(text: item?.quantity.toString() ?? '1');
    final notesCtrl = TextEditingController(text: item?.notes ?? '');
    String condition = item?.condition ?? 'Baik';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Text(isEdit ? 'Edit Barang' : 'Tambah Barang', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, enabled: !isSubmitting, decoration: const InputDecoration(hintText: 'Nama Barang', prefixIcon: Icon(Icons.inventory_2_rounded)), style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 12),
              TextField(controller: qtyCtrl, enabled: !isSubmitting, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Jumlah', prefixIcon: Icon(Icons.numbers_rounded)), style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: condition,
                items: ['Baik', 'Rusak Ringan', 'Rusak Berat'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 14)))).toList(),
                onChanged: isSubmitting ? null : (v) => setSheetState(() => condition = v!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.health_and_safety_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, enabled: !isSubmitting, maxLines: 2, decoration: const InputDecoration(hintText: 'Catatan', prefixIcon: Icon(Icons.notes_rounded)), style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  setSheetState(() => isSubmitting = true);
                  final newItem = InventoryItem(id: item?.id ?? '', labId: widget.lab.id, name: nameCtrl.text.trim(), quantity: int.tryParse(qtyCtrl.text) ?? 1, condition: condition, notes: notesCtrl.text.trim());
                  
                  bool success;
                  if (isEdit) {
                    success = await InventoryService().updateItem(widget.lab.id, item.id, newItem);
                  } else {
                    success = await InventoryService().createItem(widget.lab.id, newItem);
                  }

                  if (mounted) {
                    if (success) {
                      _fetchDetails();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan barang'), backgroundColor: AppColors.success));
                    } else {
                      setSheetState(() => isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan barang'), backgroundColor: AppColors.danger));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(isSubmitting ? 'Menyimpan...' : 'Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              )),
            ]),
          ),
        );
      }),
    );
  }

  void _deleteItem(InventoryItem item) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Barang?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Yakin ingin menghapus ${item.name}?', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await InventoryService().deleteItem(widget.lab.id, item.id);
            if (ok) {
              _fetchDetails();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barang dihapus'), backgroundColor: AppColors.success));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  Color _getConditionColor(String cond) {
    if (cond == 'Baik') return AppColors.success;
    if (cond == 'Rusak Ringan') return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text(_lab?.name ?? widget.lab.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: _canEdit ? FloatingActionButton.extended(
        onPressed: _showItemDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
      ) : null,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // PIC Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Detail Lab', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(_lab?.description ?? widget.lab.description, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Penanggung Jawab:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted))),
                  ]),
                  const SizedBox(height: 8),
                  if (_lab != null && _lab!.pics.isNotEmpty)
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _lab!.pics.map((pic) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
                        child: Text(pic.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      )).toList(),
                    )
                  else
                    Text('Belum ada PIC', style: GoogleFonts.inter(fontSize: 12, color: AppColors.warning)),
                ]),
              ),
              const SizedBox(height: 20),
              Text('Daftar Barang', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (_items.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Text('Belum ada barang di lab ini', style: GoogleFonts.inter(color: AppColors.textMuted))))
              else
                ..._items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.devices_rounded, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('Jumlah: ${item.quantity}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                      if (item.notes.isNotEmpty) Text(item.notes, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: _getConditionColor(item.condition).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(item.condition, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _getConditionColor(item.condition))),
                      ),
                      if (_canEdit) ...[
                        const SizedBox(height: 8),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(onTap: () => _showItemDialog(item), child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          GestureDetector(onTap: () => _deleteItem(item), child: const Icon(Icons.delete_rounded, size: 16, color: AppColors.danger)),
                        ])
                      ]
                    ]),
                  ]),
                ))
            ],
          ),
    );
  }
}
