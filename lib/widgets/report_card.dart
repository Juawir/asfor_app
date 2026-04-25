import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

  Color get _statusColor {
    switch (report.status) {
      case ReportStatus.draft: return AppColors.textMuted;
      case ReportStatus.pending: return AppColors.warning;
      case ReportStatus.approved: return AppColors.success;
      case ReportStatus.rejected: return AppColors.danger;
    }
  }

  IconData get _statusIcon {
    switch (report.status) {
      case ReportStatus.draft: return Icons.edit_note_rounded;
      case ReportStatus.pending: return Icons.schedule_rounded;
      case ReportStatus.approved: return Icons.check_circle_rounded;
      case ReportStatus.rejected: return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final divColor = AppColors.getDivisionColor(report.division);
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Container(height: 4, decoration: BoxDecoration(color: divColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(report.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_statusIcon, size: 12, color: _statusColor),
                  const SizedBox(width: 4),
                  Text(report.statusLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Text(report.description, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: divColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(AppColors.getDivisionIcon(report.division), size: 12, color: divColor),
                  const SizedBox(width: 4),
                  Text(report.division, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: divColor)),
                ]),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(DateFormat('dd MMM yyyy', 'id_ID').format(report.date), style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ]),
            if (report.budget > 0) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.payments_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(fmt.format(report.budget), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
            ],
          ])),
        ]),
      ),
    );
  }
}
