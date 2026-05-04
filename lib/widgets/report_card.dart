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
      case ReportStatus.draft: return AppColors.textSecondary;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10, offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(children: [
            // Top accent bar
            Container(height: 4, width: double.infinity, color: divColor),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_statusIcon, size: 12, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        report.statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor,
                        ),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Footer
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: divColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(AppColors.getDivisionIcon(report.division), size: 12, color: divColor),
                      const SizedBox(width: 4),
                      Text(
                        report.division,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: divColor),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy', 'id_ID').format(report.date),
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ]),
                
                // Budget (if any)
                if (report.budget > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(children: [
                      Icon(Icons.payments_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Anggaran: ',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        fmt.format(report.budget),
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
