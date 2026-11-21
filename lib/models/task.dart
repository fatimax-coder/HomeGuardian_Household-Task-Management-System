/// Domain Model: Task
class Task {
  final String id;
  final String householdId;
  final String? assignedMemberId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String status;   // 'pending', 'in_progress', 'completed'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    String? assignedMemberId,
    String? assignedTo,
    this.dueDate,
    this.priority = 'medium',
    String? status,
    bool? isCompleted,
    this.createdAt,
    this.updatedAt,
  })  : assignedMemberId = assignedMemberId ?? assignedTo,
        status = status ?? ((isCompleted ?? false) ? 'completed' : 'pending');

  bool get isCompleted => status == 'completed';

  String? get assignedTo => assignedMemberId;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] as String? ??
        ((json['is_completed'] as bool? ?? false) ? 'completed' : 'pending');

    return Task(
      id: json['id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Chore',
      description: json['description'] as String?,
      assignedMemberId:
          json['assigned_member_id'] as String? ?? json['assigned_to'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      priority: json['priority'] as String? ?? 'medium',
      status: statusVal,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'household_id': householdId,
      'title': title,
      if (description != null) 'description': description,
      if (assignedMemberId != null) 'assigned_member_id': assignedMemberId,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      'priority': priority.toLowerCase(),
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? householdId,
    String? assignedMemberId,
    String? assignedTo,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? status,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newStatus = status ??
        (isCompleted != null
            ? (isCompleted ? 'completed' : 'pending')
            : this.status);

    return Task(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      assignedMemberId:
          assignedMemberId ?? assignedTo ?? this.assignedMemberId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: newStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
