import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/reminder_controller.dart';
import 'package:home_guardian/factories/reminder_factory.dart';
import 'package:home_guardian/models/reminder.dart';
import 'package:home_guardian/repositories/reminder_repository.dart';
import 'package:home_guardian/strategies/reminder_filter_strategy.dart';

class MockReminderRepository implements IReminderRepository {
  final List<Reminder> _reminders = [];

  @override
  Future<List<Reminder>> getReminders(String householdId) async {
    return List.from(_reminders);
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final created = reminder.copyWith(id: 'rem-${_reminders.length + 1}');
    _reminders.add(created);
    return created;
  }

  @override
  Future<void> dismissReminder(String reminderId) async {
    final idx = _reminders.indexWhere((r) => r.id == reminderId);
    if (idx != -1) {
      _reminders[idx] = _reminders[idx].copyWith(isDismissed: true);
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    _reminders.removeWhere((r) => r.id == reminderId);
  }
}

void main() {
  group('Reminders Module & Strategy Flow Tests', () {
    late MockReminderRepository mockRepo;
    late ReminderController controller;

    setUp(() {
      mockRepo = MockReminderRepository();
      controller = ReminderController(mockRepo);
    });

    test('ReminderFactory generates typed alerts with standard conventions', () {
      final bill = ReminderFactory.create(
        householdId: 'h-1',
        type: ReminderType.bill,
        title: 'Electricity Bill',
        reminderDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(bill.title, contains('Bill Due: Electricity Bill'));
      expect(bill.type, ReminderType.bill);

      final warrantyAlert = ReminderFactory.createWarrantyAlert(
        householdId: 'h-1',
        applianceName: 'LG Refrigerator',
        warrantyExpiryDate: DateTime.now().add(const Duration(days: 20)),
        applianceId: 'app-1',
      );
      expect(warrantyAlert.type, ReminderType.warranty);
      expect(warrantyAlert.title, contains('Warranty Alert: LG Refrigerator'));
      expect(warrantyAlert.applianceId, 'app-1');

      final serviceAlert = ReminderFactory.createMaintenanceAlert(
        householdId: 'h-1',
        applianceName: 'Water Heater',
        serviceDate: DateTime.now().add(const Duration(days: 60)),
        applianceId: 'app-2',
      );
      expect(serviceAlert.type, ReminderType.maintenance);
      expect(serviceAlert.title, contains('Scheduled Service: Water Heater'));
    });

    test('ReminderController creates, dismisses, and filters active reminders', () async {
      final r1 = ReminderFactory.create(
        householdId: 'h-1',
        type: ReminderType.bill,
        title: 'Water Bill',
        reminderDate: DateTime.now().add(const Duration(days: 2)),
      );
      await controller.addReminder(r1);

      expect(controller.totalCount, 1);
      expect(controller.activeCount, 1);

      final id = controller.reminders.first.id;
      await controller.dismissReminder(id);

      expect(controller.activeCount, 0);
      expect(controller.reminders.isEmpty, isTrue); // Active strategy excludes dismissed
    });

    test('ReminderFilterStrategy filters urgent and warranty reminders', () async {
      // Urgent reminder (due today/overdue)
      await controller.addReminder(Reminder(
        id: '',
        householdId: 'h-1',
        title: 'Overdue Electricity',
        type: ReminderType.bill,
        reminderDate: DateTime.now().subtract(const Duration(hours: 2)),
      ));

      // Warranty reminder (due in 10 days)
      await controller.addReminder(Reminder(
        id: '',
        householdId: 'h-1',
        title: 'Warranty Alert: Microwave',
        type: ReminderType.warranty,
        reminderDate: DateTime.now().add(const Duration(days: 10)),
      ));

      // Test Urgent Strategy
      controller.setFilterStrategy(UrgentRemindersStrategy());
      expect(controller.reminders.length, 1);
      expect(controller.reminders.first.title, contains('Overdue'));

      // Test Warranty Strategy
      controller.setFilterStrategy(WarrantyRemindersStrategy());
      expect(controller.reminders.length, 1);
      expect(controller.reminders.first.type, ReminderType.warranty);
    });

    test('ReminderController deletes reminder', () async {
      await controller.addReminder(Reminder(
        id: '',
        householdId: 'h-1',
        title: 'Temporary Reminder',
        type: ReminderType.task,
        reminderDate: DateTime.now().add(const Duration(days: 1)),
      ));
      expect(controller.totalCount, 1);

      final id = controller.reminders.first.id;
      final deleted = await controller.deleteReminder(id);
      expect(deleted, isTrue);
      expect(controller.totalCount, 0);
    });
  });
}

