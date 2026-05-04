enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final String division;
  final String assignee;       // name (for display)
  final String? assignedToId;  // user id (for notification)
  final String? assignedBy;    // name of assigner (for display)
  final String? assignedById;  // user id of assigner (for notification)
  final DateTime dueDate;
  final TaskPriority priority;
  TaskStatus status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.division,
    required this.assignee,
    this.assignedToId,
    this.assignedBy,
    this.assignedById,
    required this.dueDate,
    required this.priority,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low: return 'Rendah';
      case TaskPriority.medium: return 'Sedang';
      case TaskPriority.high: return 'Tinggi';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo: return 'To Do';
      case TaskStatus.inProgress: return 'Dikerjakan';
      case TaskStatus.done: return 'Selesai';
    }
  }

  bool get isOverdue =>
      status != TaskStatus.done && dueDate.isBefore(DateTime.now());

  Task copyWith({
    String? id, String? title, String? description, String? division,
    String? assignee, String? assignedToId, String? assignedBy, String? assignedById,
    DateTime? dueDate, TaskPriority? priority, TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id, title: title ?? this.title,
      description: description ?? this.description, division: division ?? this.division,
      assignee: assignee ?? this.assignee, assignedToId: assignedToId ?? this.assignedToId,
      assignedBy: assignedBy ?? this.assignedBy, assignedById: assignedById ?? this.assignedById,
      dueDate: dueDate ?? this.dueDate, priority: priority ?? this.priority,
      status: status ?? this.status, createdAt: createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    TaskPriority getPriority(String? p) {
      if (p == 'high') return TaskPriority.high;
      if (p == 'medium') return TaskPriority.medium;
      return TaskPriority.low;
    }
    TaskStatus getStatus(String? s) {
      if (s == 'done') return TaskStatus.done;
      if (s == 'inProgress' || s == 'in_progress') return TaskStatus.inProgress;
      return TaskStatus.todo;
    }

    // assigned_to can be nested object (from withRelation) or flat field
    final assignedToObj = json['assigned_to'];
    final assignedByObj = json['assigned_by'];

    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      division: json['division'] ?? '',
      assignee: assignedToObj is Map ? (assignedToObj['name'] ?? '') : (json['assignee'] ?? ''),
      assignedToId: assignedToObj is Map ? assignedToObj['id']?.toString() : json['assigned_to_id']?.toString(),
      assignedBy: assignedByObj is Map ? (assignedByObj['name'] ?? '') : (json['assigned_by_name'] ?? ''),
      assignedById: assignedByObj is Map ? assignedByObj['id']?.toString() : json['assigned_by_id']?.toString(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now(),
      priority: getPriority(json['priority']),
      status: getStatus(json['status']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'title': title, 'description': description, 'division': division,
      'assignee': assignee, 'due_date': dueDate.toIso8601String(),
      'priority': priority.name, 'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
