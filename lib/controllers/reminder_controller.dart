import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../strategies/reminder_filter_strategy.dart';
import 'base_controller.dart';

/// MVC Controller for Reminders
/// Utilizes Strategy Pattern for dynamic filtering and Observer for reactive UI
class ReminderController extends BaseController {
  final IReminderRepository _repository;

  List<Reminder> _reminders = [];
  ReminderFilterStrategy _filterStrategy = ActiveRemindersStrategy();
  ReminderType? _typeFilter; // null = all types
  String _searchQuery = '';

  ReminderController([IReminderRepository? repository])
      : _repository = repository ?? ReminderRepository();

  ReminderFilterStrategy get filterStrategy => _filterStrategy;
  ReminderType? get typeFilter => _typeFilter;
  String get searchQuery => _searchQuery;

  /// Returns reminders filtered by active Strategy, category type, and search query
  List<Reminder> get reminders {
    final strategyFiltered = _filterStrategy.filter(_reminders);
    final query = _searchQuery.trim().toLowerCase();

    return strategyFiltered.where((r) {
      final matchesType = _typeFilter == null || r.type == _typeFilter;
      final matchesQuery = query.isEmpty ||
          r.title.toLowerCase().contains(query) ||
          (r.description?.toLowerCase().contains(query) ?? false);
      return matchesType && matchesQuery;
    }).toList();
  }

  List<Reminder> get allRawReminders => List.unmodifiable(_reminders);

  int get totalCount => _reminders.length;

  int get activeCount =>
      _reminders.where((r) => !r.isDismissed).length;

  int get urgentCount =>
      _reminders.where((r) => !r.isDismissed && r.isOverdue).length;

  void setFilterStrategy(ReminderFilterStrategy strategy) {
    _filterStrategy = strategy;
    notifyListeners();
  }

  void setTypeFilter(ReminderType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _typeFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> fetchReminders(String householdId) async {
    setLoading(true);
    try {
      _reminders = await _repository.getReminders(householdId);
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addReminder(Reminder reminder) async {
    setLoading(true);
    try {
      final created = await _repository.createReminder(reminder);
      _reminders.add(created);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> dismissReminder(String reminderId) async {
    try {
      await _repository.dismissReminder(reminderId);
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = _reminders[index].copyWith(isDismissed: true);
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  /// Quick action: dismisses all currently overdue active reminders
  Future<int> dismissAllOverdue() async {
    final overdueIds = _reminders
        .where((r) => !r.isDismissed && r.isOverdue)
        .map((r) => r.id)
        .toList();

    int dismissedCount = 0;
    for (final id in overdueIds) {
      try {
        await _repository.dismissReminder(id);
        final index = _reminders.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reminders[index] = _reminders[index].copyWith(isDismissed: true);
          dismissedCount++;
        }
      } catch (e) {
        setError(e.toString());
      }
    }

    if (dismissedCount > 0) {
      notifyListeners();
    }
    return dismissedCount;
  }

  Future<bool> deleteReminder(String reminderId) async {
    try {
      await _repository.deleteReminder(reminderId);
      _reminders.removeWhere((r) => r.id == reminderId);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}