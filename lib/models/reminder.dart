/// Reminder Types supported across HomeGuardian
enum ReminderType {
  task,
  bill,
  maintenance,
  warranty;

  static ReminderType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'task':
        return ReminderType.task;
      case 'bill':
        return ReminderType.bill;
      case 'maintenance':
        return ReminderType.maintenance;
      case 'warranty':
        return ReminderType.warranty;
      default:
        return ReminderType.task;
    }
  }

  String toDbString() => name;
}

/// Domain Model: Reminder
class Reminder {
  final String id;
  final String householdId;
  final String? applianceId;
  final String? taskId;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime reminderDate;
  final bool isDismissed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder({
    required this.id,
    required this.householdId,
    required this.title,
    required this.type,
    DateTime? reminderDate,
    DateTime? dueDate,
    String? applianceId,
    this.taskId,
    String? relatedId,
    this.description,
    this.isDismissed = false,
    this.createdAt,
    this.updatedAt,
  })  : reminderDate = reminderDate ?? dueDate ?? DateTime.now(),
        applianceId = applianceId ?? relatedId;

  /// Compatibility getters
  DateTime get dueDate => reminderDate;
  String? get relatedId => applianceId ?? taskId;
  bool get isOverdue => reminderDate.isBefore(DateTime.now());

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final parsedDate = json['reminder_date'] != null
        ? DateTime.parse(json['reminder_date'] as String)
        : (json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : DateTime.now());

    return Reminder(
      id: json['id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      applianceId: json['appliance_id'] as String?,
      taskId: json['task_id'] as String?,
      title: json['title'] as String? ?? 'Untitled Reminder',
      description: json['description'] as String?,
      type: ReminderType.fromString(
          json['reminder_type'] as String? ?? 'task'),
      reminderDate: parsedDate,
      isDismissed: json['is_dismissed'] as bool? ?? false,
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
      if (applianceId != null) 'appliance_id': applianceId,
      if (taskId != null) 'task_id': taskId,
      'title': title,
      if (description != null) 'description': description,
      'reminder_type': type.toDbString(),
      'reminder_date': reminderDate.toIso8601String(),
      'is_dismissed': isDismissed,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? householdId,
    String? applianceId,
    String? taskId,
    String? relatedId,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? reminderDate,
    DateTime? dueDate,
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      applianceId: applianceId ?? this.applianceId ?? relatedId,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      reminderDate: reminderDate ?? dueDate ?? this.reminderDate,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
