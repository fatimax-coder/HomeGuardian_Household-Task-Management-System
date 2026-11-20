import '../models/task.dart';

/// Factory Pattern Implementation: TaskFactory
/// Generates common recurring household maintenance and inspection task templates
class TaskFactory {
  TaskFactory._();

  /// Creates a standard task with customized parameters
  static Task createCustom({
    required String householdId,
    required String title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String priority = 'medium',
  }) {
    return Task(
      id: '',
      householdId: householdId,
      title: title.trim(),
      description: description?.trim(),
      assignedTo: assignedTo,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 3)),
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  /// Template Factory: HVAC / AC Filter Replacement
  static Task createACFilterCheck(String householdId) {
    return createCustom(
      householdId: householdId,
      title: 'Inspect & Clean AC Filters',
      description: 'Check air filters in living room and bedrooms. Wash or replace as required.',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      priority: 'medium',
    );
  }

  /// Template Factory: Smoke Detector Battery Check
  static Task createSmokeDetectorCheck(String householdId) {
    return createCustom(
      householdId: householdId,
      title: 'Smoke Detector Safety Test',
      description: 'Press test button on all household smoke alarms and verify battery level.',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      priority: 'high',
    );
  }

  /// Template Factory: Deep Kitchen Appliance Clean
  static Task createKitchenClean(String householdId) {
    return createCustom(
      householdId: householdId,
      title: 'Kitchen Deep Clean & Degrease',
      description: 'Clean range hood filters, wipe oven interior, and defrost freezer if needed.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: 'medium',
    );
  }
}
