import '../models/reminder.dart';

/// Strategy Pattern: Base Strategy for Filtering Reminders
abstract class ReminderFilterStrategy {
  String get name;
  List<Reminder> filter(List<Reminder> reminders);
}

/// Concrete Strategy: Show all active (non-dismissed) reminders
class ActiveRemindersStrategy implements ReminderFilterStrategy {
  @override
  String get name => 'Active';

  @override
  List<Reminder> filter(List<Reminder> reminders) {
    return reminders.where((r) => !r.isDismissed).toList();
  }
}

/// Concrete Strategy: Show overdue or today's urgent reminders
class UrgentRemindersStrategy implements ReminderFilterStrategy {
  @override
  String get name => 'Urgent';

  @override
  List<Reminder> filter(List<Reminder> reminders) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return reminders
        .where((r) => !r.isDismissed && r.dueDate.isBefore(tomorrow))
        .toList();
  }
}

/// Concrete Strategy: Filter by Warranty Expiries only
class WarrantyRemindersStrategy implements ReminderFilterStrategy {
  @override
  String get name => 'Warranty Only';

  @override
  List<Reminder> filter(List<Reminder> reminders) {
    return reminders
        .where((r) => !r.isDismissed && r.type == ReminderType.warranty)
        .toList();
  }
}

