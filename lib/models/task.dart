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
}
