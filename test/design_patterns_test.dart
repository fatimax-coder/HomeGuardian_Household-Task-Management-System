import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/factories/reminder_factory.dart';
import 'package:home_guardian/factories/task_factory.dart';
import 'package:home_guardian/models/reminder.dart';
import 'package:home_guardian/models/task.dart';
import 'package:home_guardian/observers/app_event_bus.dart';
import 'package:home_guardian/observers/household_observer.dart';
import 'package:home_guardian/services/notification_service.dart';
import 'package:home_guardian/services/supabase_service.dart';
import 'package:home_guardian/strategies/reminder_filter_strategy.dart';
import 'package:home_guardian/strategies/task_sort_strategy.dart';

void main() {
  group('Design Patterns Foundation Verification', () {
    test('Singleton Pattern: SupabaseService and NotificationService preserve identity', () {
      final s1 = SupabaseService.instance;
      final s2 = SupabaseService.instance;
      expect(identical(s1, s2), isTrue);

      final n1 = NotificationService.instance;
      final n2 = NotificationService.instance;
      expect(identical(n1, n2), isTrue);
    });

    test('Factory Pattern: ReminderFactory instantiates correctly formatted warranty reminders', () {
      final reminder = ReminderFactory.createWarrantyAlert(
        householdId: 'h-1',
        applianceName: 'LG Refrigerator',
        warrantyExpiryDate: DateTime(2027, 5, 20),
        applianceId: 'a-1',
      );

      expect(reminder.title, 'Warranty Alert: LG Refrigerator');
      expect(reminder.type, ReminderType.warranty);
      expect(reminder.relatedId, 'a-1');
      expect(reminder.isDismissed, isFalse);
    });

    test('Factory Pattern: TaskFactory creates routine template tasks', () {
      final task = TaskFactory.createACFilterCheck('h-1');
      expect(task.title, 'Inspect & Clean AC Filters');
      expect(task.priority, 'medium');
      expect(task.isCompleted, isFalse);
    });

    test('Strategy Pattern: TaskSortStrategy sorts tasks by priority', () {
      final low = Task(id: '1', householdId: 'h-1', title: 'Low Task', priority: 'low');
      final high = Task(id: '2', householdId: 'h-1', title: 'High Task', priority: 'high');
      final medium = Task(id: '3', householdId: 'h-1', title: 'Med Task', priority: 'medium');

      final strategy = SortByPriorityStrategy();
      final sorted = strategy.sort([low, medium, high]);

      expect(sorted[0].priority, 'high');
      expect(sorted[1].priority, 'medium');
      expect(sorted[2].priority, 'low');
    });

    test('Strategy Pattern: ReminderFilterStrategy filters active reminders', () {
      final r1 = Reminder(
        id: '1',
        householdId: 'h-1',
        title: 'Active Alert',
        type: ReminderType.task,
        dueDate: DateTime.now(),
        isDismissed: false,
      );
      final r2 = Reminder(
        id: '2',
        householdId: 'h-1',
        title: 'Dismissed Alert',
        type: ReminderType.task,
        dueDate: DateTime.now(),
        isDismissed: true,
      );

      final strategy = ActiveRemindersStrategy();
      final filtered = strategy.filter([r1, r2]);

      expect(filtered.length, 1);
      expect(filtered.first.id, '1');
    });

    test('Observer Pattern: AppEventBus notifies registered observers', () {
      final bus = AppEventBus.instance;
      AppEventType? receivedEvent;
      dynamic receivedPayload;

      final observer = HouseholdObserver(
        onEventReceived: (event, payload) {
          receivedEvent = event;
          receivedPayload = payload;
        },
      );

      bus.subscribe(observer);
      bus.notify(AppEventType.taskCreated, 'test-task-payload');

      expect(receivedEvent, AppEventType.taskCreated);
      expect(receivedPayload, 'test-task-payload');

      bus.unsubscribe(observer);
    });
  });
}
