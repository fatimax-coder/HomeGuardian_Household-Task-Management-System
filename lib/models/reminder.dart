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
  final String title;
  final ReminderType type;
  final DateTime dueDate;
  final bool isDismissed;
  final String? relatedId;
  final DateTime? createdAt;

  Reminder({
    required this.id,
    required this.householdId,
    required this.title,
    required this.type,
    required this.dueDate,
    this.isDismissed = false,
    this.relatedId,
    this.createdAt,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now());

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String? ?? 'Untitled Reminder',
      type: ReminderType.fromString(json['reminder_type'] as String? ?? 'task'),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      isDismissed: json['is_dismissed'] as bool? ?? false,
      relatedId: json['related_id'] as String?,
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
      'reminder_type': type.toDbString(),
      'due_date': dueDate.toIso8601String(),
      'is_dismissed': isDismissed,
      if (relatedId != null) 'related_id': relatedId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? householdId,
    String? title,
    ReminderType? type,
    DateTime? dueDate,
    bool? isDismissed,
    String? relatedId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      title: title ?? this.title,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      isDismissed: isDismissed ?? this.isDismissed,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

