import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Report _report;
  bool _processing = false;
  final _service = ReportService();

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Future<void> _approve() async {
    setState(() => _processing = true);
    final updated = await _service.approveReport(_report.id);
    setState(() => _processing = false);
    if (updated != null) {
      setState(() => _report = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Laporan berhasil disetujui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyetujui laporan'), backgroundColor: AppColors.danger));
    }
  }

  Future<void> _showRejectDialog() async {
    final reasonCtrl = TextEditingController();
    bool confirming = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Tolak Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Masukkan alasan penolakan:', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Anggaran melebihi batas yang diizinkan...',
                  hintStyle: GoogleFonts.inter(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: confirming ? null : () async {
                if (reasonCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan penolakan wajib diisi'), backgroundColor: AppColors.danger));
                  return;
                }
                setDialog(() => confirming = true);
                final updated = await _service.rejectReport(_report.id, reasonCtrl.text.trim());
                if (mounted) Navigator.pop(ctx);
                if (updated != null) {
                  setState(() => _report = updated);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Laporan ditolak.'),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: Text(confirming ? 'Memproses...' : 'Tolak Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService().isSuperAdmin;
    final divColor = AppColors.getDivisionColor(_report.division);
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    Color statusColor;
    switch (_report.status) {
      case ReportStatus.approved: statusColor = AppColors.success;
      case ReportStatus.pending: statusColor = AppColors.warning;
      case ReportStatus.rejected: statusColor = AppColors.danger;
      case ReportStatus.draft: statusColor = AppColors.textMuted;
    }

    final canApprove = isAdmin && _report.status == ReportStatus.pending;
    final canReject = isAdmin && (_report.status == ReportStatus.pending || _report.status == ReportStatus.approved);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Admin action bar for pending reports
      bottomNavigationBar: canApprove || canReject
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    if (canReject)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _processing ? null : _showRejectDialog,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text('Tolak', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    if (canApprove && canReject) const SizedBox(width: 12),
                    if (canApprove)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _processing ? null : _approve,
                          icon: _processing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(_processing ? 'Memproses...' : 'Setujui Laporan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,

      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 160, pinned: true,
          backgroundColor: divColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context, _report), // return updated report
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [divColor, divColor.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(AppColors.getDivisionIcon(_report.division), size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(_report.division, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(_report.title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          // Status & Budget card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Status', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                  child: Text(_report.statusLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ])),
              Container(width: 1, height: 40, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Anggaran', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(_report.budget > 0 ? fmt.format(_report.budget) : '-', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          // Metadata
          _infoRow(Icons.person_rounded, 'Diajukan oleh', _report.submittedBy),
          _infoRow(Icons.calendar_today_rounded, 'Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(_report.date)),
          if (_report.approvedBy != null) _infoRow(Icons.verified_rounded, 'Disetujui oleh', _report.approvedBy!),
          if (_report.approvedAt != null) _infoRow(Icons.check_circle_outline_rounded, 'Tanggal Approval', DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(_report.approvedAt!)),
          if (_report.rejectionNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.danger.withValues(alpha: 0.2))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_rounded, size: 18, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Alasan Penolakan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger)),
                  const SizedBox(height: 4),
                  Text(_report.rejectionNote!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
                ])),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          // Description
          Text('Deskripsi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Text(_report.description, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          ),
          // Attachments
          if (_report.attachments.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Lampiran', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ..._report.attachments.map((a) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(a, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                const Icon(Icons.download_rounded, size: 20, color: AppColors.textMuted),
              ]),
            )),
          ],
          const SizedBox(height: 40),
        ]))),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
      ]),
    );
  }
}
