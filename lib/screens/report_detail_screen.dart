import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final divColor = AppColors.getDivisionColor(report.division);
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    Color statusColor;
    switch (report.status) {
      case ReportStatus.approved: statusColor = AppColors.success;
      case ReportStatus.pending: statusColor = AppColors.warning;
      case ReportStatus.rejected: statusColor = AppColors.danger;
      case ReportStatus.draft: statusColor = AppColors.textMuted;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 160, pinned: true,
          backgroundColor: divColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
                    Icon(AppColors.getDivisionIcon(report.division), size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(report.division, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(report.title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  child: Text(report.statusLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ])),
              Container(width: 1, height: 40, color: AppColors.border),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Anggaran', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(report.budget > 0 ? fmt.format(report.budget) : '-', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          // Metadata
          _infoRow(Icons.person_rounded, 'Diajukan oleh', report.submittedBy),
          _infoRow(Icons.calendar_today_rounded, 'Tanggal', DateFormat('dd MMMM yyyy', 'id_ID').format(report.date)),
          if (report.approvedBy != null) _infoRow(Icons.verified_rounded, 'Disetujui oleh', report.approvedBy!),
          if (report.approvedAt != null) _infoRow(Icons.check_circle_outline_rounded, 'Tanggal Approval', DateFormat('dd MMMM yyyy', 'id_ID').format(report.approvedAt!)),
          if (report.rejectionNote != null) ...[
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
                  Text(report.rejectionNote!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
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
            child: Text(report.description, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          ),
          // Attachments
          if (report.attachments.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Lampiran', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ...report.attachments.map((a) => Container(
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
