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

  factory Report.fromJson(Map<String, dynamic> json) {
    ReportStatus getStatus(String? s) {
      if (s == 'pending') return ReportStatus.pending;
      if (s == 'approved') return ReportStatus.approved;
      if (s == 'rejected') return ReportStatus.rejected;
      return ReportStatus.draft;
    }
    
    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      division: json['division'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: getStatus(json['status']),
      budget: json['budget'] != null ? double.parse(json['budget'].toString()) : 0.0,
      submittedBy: json['submitted_by'] ?? '',
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      rejectionNote: json['rejection_note'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'division': division,
      'date': date.toIso8601String(),
      'status': status.name,
      'budget': budget,
      'submitted_by': submittedBy,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_note': rejectionNote,
      'attachments': attachments,
    };
  }
}
