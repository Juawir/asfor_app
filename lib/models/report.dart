enum ReportStatus { draft, pending, approved, rejected }

class Report {
  final String id;
  final String title;
  final String description;
  final String division;
  final DateTime date;
  final ReportStatus status;
  final double budget;
  final String submittedBy;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionNote;
  final List<String> attachments;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.division,
    required this.date,
    required this.status,
    required this.budget,
    required this.submittedBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectionNote,
    this.attachments = const [],
  });

  String get statusLabel {
    switch (status) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.approved:
        return 'Disetujui';
      case ReportStatus.rejected:
        return 'Ditolak';
    }
  }

  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? division,
    DateTime? date,
    ReportStatus? status,
    double? budget,
    String? submittedBy,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionNote,
    List<String>? attachments,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      division: division ?? this.division,
      date: date ?? this.date,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      submittedBy: submittedBy ?? this.submittedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionNote: rejectionNote ?? this.rejectionNote,
      attachments: attachments ?? this.attachments,
    );
  }
}
