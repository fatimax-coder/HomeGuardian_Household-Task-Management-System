import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../strategies/task_sort_strategy.dart';
import '../observers/app_event_bus.dart';
import 'base_controller.dart';

/// MVC Controller for Tasks
/// Uses Strategy Pattern for sorting and Observer Pattern for cross-module notifications
class TaskController extends BaseController {
  final ITaskRepository _repository;

  List<Task> _tasks = [];
  TaskSortStrategy _sortStrategy = SortByDueDateStrategy();
  String _statusFilter = 'all'; // 'all', 'pending', 'completed'
  String _priorityFilter = 'all'; // 'all', 'high', 'medium', 'low'
  String _searchQuery = '';

  TaskController([ITaskRepository? repository])
      : _repository = repository ?? TaskRepository();

  TaskSortStrategy get sortStrategy => _sortStrategy;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get searchQuery => _searchQuery;

  /// Returns tasks filtered by status, priority, and search query, sorted by active Strategy
  List<Task> get tasks {
    List<Task> filtered = _tasks.where((t) {
      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'pending' && !t.isCompleted) ||
          (_statusFilter == 'completed' && t.isCompleted);

      final matchesPriority = _priorityFilter == 'all' ||
          t.priority.toLowerCase() == _priorityFilter;

      final query = _searchQuery.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          (t.description?.toLowerCase().contains(query) ?? false);

      return matchesStatus && matchesPriority && matchesQuery;
    }).toList();

    return _sortStrategy.sort(filtered);
  }

  List<Task> get allRawTasks => List.unmodifiable(_tasks);

  int get totalTasksCount => _tasks.length;

  int get pendingTasksCount =>
      _tasks.where((t) => !t.isCompleted).length;

  int get inProgressTasksCount =>
      _tasks.where((t) => t.status == 'in_progress').length;

  int get completedTasksCount =>
      _tasks.where((t) => t.isCompleted).length;

  int get highPriorityCount =>
      _tasks.where((t) => t.priority.toLowerCase() == 'high').length;

  int get mediumPriorityCount =>
      _tasks.where((t) => t.priority.toLowerCase() == 'medium').length;

  int get lowPriorityCount =>
      _tasks.where((t) => t.priority.toLowerCase() == 'low').length;

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(String priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = 'all';
    _priorityFilter = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  /// Sets a new sorting strategy and triggers UI update
  void setSortStrategy(TaskSortStrategy strategy) {
    _sortStrategy = strategy;
    notifyListeners();
  }

  Future<void> fetchTasks(String householdId) async {
    setLoading(true);
    try {
      _tasks = await _repository.getTasks(householdId);
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addTask(Task task) async {
    setLoading(true);
    try {
      final created = await _repository.createTask(task);
      _tasks.insert(0, created);
      AppEventBus.instance.notify(AppEventType.taskCreated, created);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateTask(Task task) async {
    setLoading(true);
    try {
      await _repository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        AppEventBus.instance.notify(AppEventType.taskUpdated, task);
      }
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _repository.toggleTaskStatus(taskId, isCompleted);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
        AppEventBus.instance.notify(
          isCompleted ? AppEventType.taskCompleted : AppEventType.taskUpdated,
          _tasks[index],
        );
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      AppEventBus.instance.notify(AppEventType.taskDeleted, taskId);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}