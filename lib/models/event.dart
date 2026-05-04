class AppEvent {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String? eventTime;
  final String? location;
  final String division;
  final String createdBy;
  final String? creatorName;

  const AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    this.eventTime,
    this.location,
    required this.division,
    required this.createdBy,
    this.creatorName,
  });

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDate: DateTime.parse(json['event_date']),
      eventTime: json['event_time'],
      location: json['location'],
      division: json['division'] ?? 'Semua',
      createdBy: json['created_by']?.toString() ?? '',
      creatorName: json['creator']?['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'event_date': '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
    'event_time': eventTime,
    'location': location,
    'division': division,
  };

  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year && eventDate.month == now.month && eventDate.day == now.day;
  }

  bool get isPast => eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
}
