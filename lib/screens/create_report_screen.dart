import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import 'package:file_picker/file_picker.dart';
import 'main_screen.dart' show mainScaffoldKey;

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});
  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  late String? _selectedDivision;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _pickedFilePath;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
    _selectedDivision = _auth.isSuperAdmin ? null : _auth.currentUser?.division;
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _budgetCtrl.dispose(); super.dispose(); }

  void _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2024), lastDate: DateTime(2030));
    if (d != null) setState(() => _selectedDate = d);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDivision == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih divisi terlebih dahulu'))); return; }
    
    final newReport = Report(
      id: '',
      title: _titleCtrl.text,
      description: _descCtrl.text,
      division: _selectedDivision!,
      date: _selectedDate,
      status: ReportStatus.pending,
      budget: double.tryParse(_budgetCtrl.text) ?? 0.0,
      submittedBy: _auth.currentUser?.name ?? '',
    );

    final success = await ReportService().createReport(newReport, filePath: _pickedFilePath);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.white), const SizedBox(width: 8), const Text('Laporan berhasil dibuat!')]),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        _titleCtrl.clear(); _descCtrl.clear(); _budgetCtrl.clear();
        setState(() { _selectedDivision = _auth.isSuperAdmin ? null : _auth.currentUser?.division; _pickedFilePath = null; _pickedFileName = null; });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal membuat laporan'), backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Buat Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.note_add_rounded, color: Colors.white, size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Buat Laporan Baru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Isi formulir untuk membuat laporan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // Judul
          _label('Judul Laporan'),
          TextFormField(controller: _titleCtrl, validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
            decoration: const InputDecoration(hintText: 'Masukkan judul laporan', prefixIcon: Icon(Icons.title_rounded)),
            style: GoogleFonts.inter(fontSize: 14)),
          const SizedBox(height: 16),

          // Divisi
          _label('Divisi'),
          DropdownButtonFormField<String>(
            initialValue: _selectedDivision,
            items: (_auth.isSuperAdmin ? AppTheme.divisions : [_auth.currentUser?.division ?? ''])
                .where((d) => d.isNotEmpty).map((d) => DropdownMenuItem(value: d, child: Row(children: [
              Icon(AppColors.getDivisionIcon(d), size: 18, color: AppColors.getDivisionColor(d)),
              const SizedBox(width: 10), Text(d, style: GoogleFonts.inter(fontSize: 14)),
            ]))).toList(),
            onChanged: _auth.isSuperAdmin ? (v) => setState(() => _selectedDivision = v) : null,
            decoration: const InputDecoration(hintText: 'Pilih divisi', prefixIcon: Icon(Icons.group_rounded)),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Tanggal
          _label('Tanggal'),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                const Spacer(), const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Anggaran
          _label('Anggaran (Rp)'),
          TextFormField(controller: _budgetCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '0', prefixIcon: Icon(Icons.payments_rounded)),
            style: GoogleFonts.inter(fontSize: 14)),
          const SizedBox(height: 16),

          // Deskripsi
          _label('Deskripsi'),
          TextFormField(controller: _descCtrl, maxLines: 5, validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
            decoration: const InputDecoration(hintText: 'Tuliskan deskripsi laporan...', alignLabelWithHint: true),
            style: GoogleFonts.inter(fontSize: 14)),
          const SizedBox(height: 16),

          // Upload
          _label('Lampiran'),
          GestureDetector(
            onTap: () async {
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
              );
              if (result != null) {
                setState(() {
                  _pickedFilePath = result.files.single.path;
                  _pickedFileName = result.files.single.name;
                });
              }
            },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary, style: BorderStyle.solid, width: 1.5), color: AppColors.primary.withValues(alpha: 0.04)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_upload_rounded, size: 32, color: AppColors.primary),
                const SizedBox(height: 8),
                Text('Tap untuk upload dokumen', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                Text('PDF, DOC, XLS, JPG (Max 10MB)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              ]),
            ),
          ),
          if (_pickedFileName != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.insert_drive_file_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_pickedFileName!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary))),
                GestureDetector(onTap: () => setState(() { _pickedFilePath = null; _pickedFileName = null; }),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger)),
              ]),
            ),
          ],
          const SizedBox(height: 28),

          // Submit
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
            onPressed: _submit, icon: const Icon(Icons.send_rounded, size: 18),
            label: Text('Kirim Laporan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
          const SizedBox(height: 32),
        ])),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );
}
