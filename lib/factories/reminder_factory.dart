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
    required DateTime dueDate,
    String? relatedId,
  }) {
    String formattedTitle = title.trim();

    switch (type) {
      case ReminderType.warranty:
        if (!formattedTitle.startsWith('Warranty:')) {
          formattedTitle = 'Warranty Alert: $formattedTitle';
        }
        break;
      case ReminderType.maintenance:
        if (!formattedTitle.startsWith('Service:')) {
          formattedTitle = 'Scheduled Service: $formattedTitle';
        }
        break;
      case ReminderType.bill:
        if (!formattedTitle.startsWith('Bill:')) {
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
      title: formattedTitle,
      type: type,
      dueDate: dueDate,
      isDismissed: false,
      relatedId: relatedId,
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
      dueDate: warrantyExpiryDate,
      relatedId: applianceId,
    );
  }

  /// Convenience Factory for Scheduled Appliance Maintenance
  static Reminder createMaintenanceAlert({
    required String householdId,
    required String applianceName,
    required DateTime serviceDate,
    required String applianceId,
  }) {
    return create(
      householdId: householdId,
      type: ReminderType.maintenance,
      title: applianceName,
      dueDate: serviceDate,
      relatedId: applianceId,
    );
  }
}

