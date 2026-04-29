enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final String division;
  final String assignee;
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
    required this.dueDate,
    required this.priority,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Rendah';
      case TaskPriority.medium:
        return 'Sedang';
      case TaskPriority.high:
        return 'Tinggi';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'Dikerjakan';
      case TaskStatus.done:
        return 'Selesai';
    }
  }

  bool get isOverdue =>
      status != TaskStatus.done && dueDate.isBefore(DateTime.now());

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? division,
    String? assignee,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      division: division ?? this.division,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
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
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      division: json['division'] ?? '',
      assignee: json['assignee'] ?? '',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now(),
      priority: getPriority(json['priority']),
      status: getStatus(json['status']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'division': division,
      'assignee': assignee,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
