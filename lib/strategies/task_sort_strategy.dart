import '../models/task.dart';

/// Strategy Pattern: Base Strategy for Sorting Tasks
abstract class TaskSortStrategy {
  String get name;
  List<Task> sort(List<Task> tasks);
}

/// Concrete Strategy: Sort by Due Date (Earliest to Latest)
class SortByDueDateStrategy implements TaskSortStrategy {
  @override
  String get name => 'Due Date';

  @override
  List<Task> sort(List<Task> tasks) {
    final list = List<Task>.from(tasks);
    list.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return list;
  }
}

/// Concrete Strategy: Sort by Priority (High -> Medium -> Low)
class SortByPriorityStrategy implements TaskSortStrategy {
  @override
  String get name => 'Priority';

  static const _weights = {'high': 3, 'medium': 2, 'low': 1};

  @override
  List<Task> sort(List<Task> tasks) {
    final list = List<Task>.from(tasks);
    list.sort((a, b) {
      final weightA = _weights[a.priority.toLowerCase()] ?? 0;
      final weightB = _weights[b.priority.toLowerCase()] ?? 0;
      return weightB.compareTo(weightA);
    });
    return list;
  }
}

/// Concrete Strategy: Sort by Task Title (Alphabetical)
class SortByTitleStrategy implements TaskSortStrategy {
  @override
  String get name => 'Alphabetical';

  @override
  List<Task> sort(List<Task> tasks) {
    final list = List<Task>.from(tasks);
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }
}
