/// Domain Model: Task
class Task {
  final String id;
  final String householdId;
  final String title;
  final String? description;
  final String? assignedTo;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final String? completedBy;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    this.assignedTo,
    this.dueDate,
    this.priority = 'medium',
    this.isCompleted = false,
    this.completedBy,
    this.createdAt,
  });

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['is_completed'] as bool? ?? false,
      completedBy: json['completed_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'household_id': householdId,
      'title': title,
      if (description != null) 'description': description,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted,
      if (completedBy != null) 'completed_by': completedBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? householdId,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    String? completedBy,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
