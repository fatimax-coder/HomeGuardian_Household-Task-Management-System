import '../models/reminder.dart';

/// Factory Pattern Implementation: ReminderFactory
/// Encapsulates instantiating specific reminder categories (Warranty, Service, Bills, Tasks)
/// with standard formatting and rules without cluttering UI forms.
class ReminderFactory {
  ReminderFactory._();

  /// Creates a typed reminder with domain-specific naming rules
  static Reminder create({
    required String householdId,
    required ReminderType type,
    required String title,
    required DateTime reminderDate,
    String? applianceId,
    String? taskId,
    String? description,
    String? relatedId,
  }) {
    String formattedTitle = title.trim();

    switch (type) {
      case ReminderType.warranty:
        if (!formattedTitle.toLowerCase().startsWith('warranty')) {
          formattedTitle = 'Warranty Alert: $formattedTitle';
        }
        break;
      case ReminderType.maintenance:
        if (!formattedTitle.toLowerCase().startsWith('service') &&
            !formattedTitle.toLowerCase().startsWith('maintenance')) {
          formattedTitle = 'Scheduled Service: $formattedTitle';
        }
        break;
      case ReminderType.bill:
        if (!formattedTitle.toLowerCase().startsWith('bill')) {
          formattedTitle = 'Bill Due: $formattedTitle';
        }
        break;
      case ReminderType.task:
        // Tasks retain their action title
        break;
    }

    return Reminder(
      id: '',
      householdId: householdId,
      applianceId: applianceId ?? relatedId,
      taskId: taskId,
      title: formattedTitle,
      description: description,
      type: type,
      reminderDate: reminderDate,
      isDismissed: false,
      createdAt: DateTime.now(),
    );
  }

  /// Convenience Factory for Appliance Warranty Alerts
  static Reminder createWarrantyAlert({
    required String householdId,
    required String applianceName,
    required DateTime warrantyExpiryDate,
    required String applianceId,
  }) {
    return create(
      householdId: householdId,
      type: ReminderType.warranty,
      title: applianceName,
      reminderDate: warrantyExpiryDate,
      applianceId: applianceId,
      description: 'Warranty for $applianceName expires soon.',
    );
  }

  /// Convenience Factory for Scheduled Appliance Maintenance
  static Reminder createMaintenanceAlert({
    required String householdId,
    required String applianceName,
    required DateTime serviceDate,
    required String applianceId,
    String? notes,
  }) {
    return create(
      householdId: householdId,
      type: ReminderType.maintenance,
      title: applianceName,
      reminderDate: serviceDate,
      applianceId: applianceId,
      description: notes ?? 'Scheduled maintenance service for $applianceName.',
    );
  }
}
