import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/task_controller.dart';
import 'package:home_guardian/models/task.dart';
import 'package:home_guardian/repositories/task_repository.dart';
import 'package:home_guardian/strategies/task_sort_strategy.dart';

class MockTaskRepository implements ITaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks(String householdId) async {
    return List.from(_tasks);
  }

  @override
  Future<Task> createTask(Task task) async {
    final created = task.copyWith(id: 't-${_tasks.length + 1}');
    _tasks.insert(0, created);
    return created;
  }

  @override
  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: isCompleted);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }
}

void main() {
  group('Task Module & Controller Flow Tests', () {
    late MockTaskRepository mockRepo;
    late TaskController controller;

    setUp(() {
      mockRepo = MockTaskRepository();
      controller = TaskController(mockRepo);
    });

    test('Task Model serialization and status computation', () {
      final json = {
        'id': 't-1',
        'household_id': 'h-1',
        'title': 'Wash Dishes',
        'priority': 'high',
        'status': 'pending',
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      };

      final task = Task.fromJson(json);
      expect(task.title, 'Wash Dishes');
      expect(task.priority, 'high');
      expect(task.isCompleted, isFalse);
      expect(task.isOverdue, isFalse);

      final completedTask = task.copyWith(isCompleted: true);
      expect(completedTask.isCompleted, isTrue);
      expect(completedTask.status, 'completed');
    });

    test('TaskController creates and toggles task status', () async {
      final task = Task(
        id: '',
        householdId: 'h-1',
        title: 'Clean Windows',
        priority: 'low',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      final added = await controller.addTask(task);
      expect(added, isTrue);
      expect(controller.totalTasksCount, 1);
      expect(controller.pendingTasksCount, 1);
      expect(controller.completedTasksCount, 0);

      final taskId = controller.tasks.first.id;
      await controller.toggleTaskStatus(taskId, true);
      expect(controller.completedTasksCount, 1);
      expect(controller.pendingTasksCount, 0);

      await controller.toggleTaskStatus(taskId, false);
      expect(controller.completedTasksCount, 0);
      expect(controller.pendingTasksCount, 1);
    });

    test('TaskController filters tasks by status tab', () async {
      await controller.addTask(Task(
        id: '',
        householdId: 'h-1',
        title: 'Task A',
        status: 'pending',
      ));
      await controller.addTask(Task(
        id: '',
        householdId: 'h-1',
        title: 'Task B',
        status: 'completed',
      ));

      controller.setStatusFilter('all');
      expect(controller.tasks.length, 2);

      controller.setStatusFilter('pending');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Task A');

      controller.setStatusFilter('completed');
      expect(controller.tasks.length, 1);
      expect(controller.tasks.first.title, 'Task B');
    });

    test('TaskController sorts tasks using Strategy Pattern', () async {
      final now = DateTime.now();
      await controller.addTask(Task(
        id: '',
        householdId: 'h-1',
        title: 'Bravo Task',
        priority: 'low',
        dueDate: now.add(const Duration(days: 5)),
      ));
      await controller.addTask(Task(
        id: '',
        householdId: 'h-1',
        title: 'Alpha Task',
        priority: 'high',
        dueDate: now.add(const Duration(days: 1)),
      ));

      // Strategy: Sort by Priority
      controller.setSortStrategy(SortByPriorityStrategy());
      expect(controller.tasks.first.priority, 'high');

      // Strategy: Sort by Title (Alphabetical)
      controller.setSortStrategy(SortByTitleStrategy());
      expect(controller.tasks.first.title, 'Alpha Task');

      // Strategy: Sort by Due Date
      controller.setSortStrategy(SortByDueDateStrategy());
      expect(controller.tasks.first.title, 'Alpha Task');
    });

    test('TaskController deletes task', () async {
      await controller.addTask(Task(
        id: '',
        householdId: 'h-1',
        title: 'Temp Task',
      ));
      expect(controller.totalTasksCount, 1);

      final id = controller.tasks.first.id;
      final deleted = await controller.deleteTask(id);
      expect(deleted, isTrue);
      expect(controller.totalTasksCount, 0);
    });
  });
}
