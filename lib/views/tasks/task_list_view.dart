import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../strategies/task_sort_strategy.dart';
import '../../widgets/app_illustration.dart';
import 'task_form_view.dart';

/// Screen: TaskListView
/// Displays tasks, supports search, status & priority filtering, Strategy sorting, and CRUD
class TaskListView extends StatefulWidget {
  final bool isTab;

  const TaskListView({super.key, this.isTab = false});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskController = context.read<TaskController>();
      _searchController.text = taskController.searchQuery;
      final household = context.read<HouseholdController>().selectedHousehold;
      if (household != null) {
        taskController.fetchTasks(household.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortMenu(BuildContext context) {
    final controller = context.read<TaskController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Sort Tasks By (Strategy Pattern)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.terracotta),
              title: const Text('Due Date (Earliest First)'),
              trailing: controller.sortStrategy is SortByDueDateStrategy
                  ? const Icon(Icons.check, color: AppColors.terracotta)
                  : null,
              onTap: () {
                controller.setSortStrategy(SortByDueDateStrategy());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: AppColors.terracotta),
              title: const Text('Priority (High to Low)'),
              trailing: controller.sortStrategy is SortByPriorityStrategy
                  ? const Icon(Icons.check, color: AppColors.terracotta)
                  : null,
              onTap: () {
                controller.setSortStrategy(SortByPriorityStrategy());
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: AppColors.terracotta),
              title: const Text('Alphabetical (Title A-Z)'),
              trailing: controller.sortStrategy is SortByTitleStrategy
                  ? const Icon(Icons.check, color: AppColors.terracotta)
                  : null,
              onTap: () {
                controller.setSortStrategy(SortByTitleStrategy());
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown),
        ),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TaskController>().deleteTask(task.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('clean') ||
        t.contains('sweep') ||
        t.contains('mop') ||
        t.contains('wash') ||
        t.contains('dust')) {
      return Icons.cleaning_services_outlined;
    } else if (t.contains('cook') ||
        t.contains('meal') ||
        t.contains('kitchen') ||
        t.contains('dish')) {
      return Icons.soup_kitchen_outlined;
    } else if (t.contains('buy') ||
        t.contains('shop') ||
        t.contains('grocery') ||
        t.contains('market')) {
      return Icons.shopping_bag_outlined;
    } else if (t.contains('fix') ||
        t.contains('repair') ||
        t.contains('filter') ||
        t.contains('service')) {
      return Icons.build_outlined;
    }
    return Icons.task_alt;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.terracotta;
      case 'low':
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final householdController = context.watch<HouseholdController>();
    final activeHousehold = householdController.selectedHousehold;
    final tasks = taskController.tasks;
    final membersMap = {for (var m in householdController.members) m.id: m.displayName};
    final hasActiveFilters = taskController.statusFilter != 'all' ||
        taskController.priorityFilter != 'all' ||
        taskController.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Household Tasks'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Options (${taskController.sortStrategy.name})',
            onPressed: () => _showSortMenu(context),
          ),
          if (activeHousehold != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => taskController.fetchTasks(activeHousehold.id),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        onPressed: () {
          if (activeHousehold == null) {
            Navigator.pushNamed(context, AppRoutes.household);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskFormView()),
            );
          }
        },
      ),
      body: activeHousehold == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_work_outlined,
                        size: 64, color: AppColors.brown),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Household',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect or create a household to organize chores and tasks.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_home),
                      label: const Text('Setup Household'),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.household),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Search & Filter Controls Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  color: AppColors.sand.withValues(alpha: 0.35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live Search Input
                      TextField(
                        controller: _searchController,
                        onChanged: taskController.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search tasks by title or description...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.brown,
                          ),
                          suffixIcon: taskController.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    taskController.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.sand),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.sand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.terracotta),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Filter Tabs (All, Pending, Done)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'All (${taskController.totalTasksCount})',
                              filter: 'all',
                              current: taskController.statusFilter,
                              onTap: () => taskController.setStatusFilter('all'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Pending (${taskController.pendingTasksCount})',
                              filter: 'pending',
                              current: taskController.statusFilter,
                              onTap: () =>
                                  taskController.setStatusFilter('pending'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Done (${taskController.completedTasksCount})',
                              filter: 'completed',
                              current: taskController.statusFilter,
                              onTap: () =>
                                  taskController.setStatusFilter('completed'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Priority Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPriorityChip(
                              label: 'All Priorities',
                              priority: 'all',
                              current: taskController.priorityFilter,
                              onTap: () =>
                                  taskController.setPriorityFilter('all'),
                            ),
                            const SizedBox(width: 6),
                            _buildPriorityChip(
                              label: 'High (${taskController.highPriorityCount})',
                              priority: 'high',
                              current: taskController.priorityFilter,
                              activeColor: AppColors.error,
                              onTap: () =>
                                  taskController.setPriorityFilter('high'),
                            ),
                            const SizedBox(width: 6),
                            _buildPriorityChip(
                              label:
                                  'Medium (${taskController.mediumPriorityCount})',
                              priority: 'medium',
                              current: taskController.priorityFilter,
                              activeColor: AppColors.terracotta,
                              onTap: () =>
                                  taskController.setPriorityFilter('medium'),
                            ),
                            const SizedBox(width: 6),
                            _buildPriorityChip(
                              label: 'Low (${taskController.lowPriorityCount})',
                              priority: 'low',
                              current: taskController.priorityFilter,
                              activeColor: AppColors.brown,
                              onTap: () =>
                                  taskController.setPriorityFilter('low'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tasks List View
                Expanded(
                  child: taskController.isLoading && tasks.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.terracotta))
                      : tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppIllustration.emptyTasks(size: 80),
                                  const SizedBox(height: 12),
                                  Text(
                                    hasActiveFilters
                                        ? 'No matching tasks found.'
                                        : 'No tasks scheduled!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (hasActiveFilters)
                                    TextButton.icon(
                                      icon: const Icon(Icons.filter_alt_off,
                                          size: 18),
                                      label: const Text('Clear Filters'),
                                      onPressed: () {
                                        _searchController.clear();
                                        taskController.clearFilters();
                                      },
                                    )
                                  else
                                    const Text(
                                      'Tap "+ New Task" below to assign chores.',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: tasks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                final assignedName = task.assignedMemberId != null
                                    ? membersMap[task.assignedMemberId]
                                    : null;

                                return Card(
                                  color: AppColors.white,
                                  elevation: task.isCompleted ? 0.5 : 1.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: task.isCompleted
                                          ? AppColors.sand.withValues(alpha: 0.5)
                                          : AppColors.sand,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Status Toggle Checkbox
                                        Checkbox(
                                          activeColor: AppColors.terracotta,
                                          value: task.isCompleted,
                                          onChanged: (val) {
                                            taskController.toggleTaskStatus(
                                              task.id,
                                              val ?? false,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),

                                        // Task Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.sand
                                                          .withValues(
                                                              alpha: 0.35),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                      _getCategoryIcon(
                                                          task.title),
                                                      size: 14,
                                                      color:
                                                          AppColors.terracotta,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      task.title,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: task.isCompleted
                                                            ? AppColors
                                                                .textMuted
                                                            : AppColors
                                                                .darkBrown,
                                                        decoration:
                                                            task.isCompleted
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (task.description != null &&
                                                  task.description!.isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  task.description!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: task.isCompleted
                                                        ? AppColors.textMuted
                                                        : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),

                                              // Metadata chips (Priority, Due Date, Assigned Member)
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: [
                                                  // Priority Chip
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getPriorityColor(
                                                              task.priority)
                                                          .withValues(
                                                              alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      task.priority.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _getPriorityColor(
                                                            task.priority),
                                                      ),
                                                    ),
                                                  ),

                                                  // Due Date Chip
                                                  if (task.dueDate != null)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: task.isOverdue
                                                            ? AppColors.error
                                                                .withValues(
                                                                    alpha: 0.12)
                                                            : AppColors.sand
                                                                .withValues(
                                                                    alpha: 0.5),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.schedule,
                                                            size: 11,
                                                            color: task.isOverdue
                                                                ? AppColors.error
                                                                : AppColors
                                                                    .darkBrown,
                                                          ),
                                                          const SizedBox(width: 3),
                                                          Text(
                                                            '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}${task.isOverdue ? " (Overdue)" : ""}',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: task.isOverdue
                                                                  ? AppColors.error
                                                                  : AppColors
                                                                      .darkBrown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  // Assigned Member Chip
                                                  if (assignedName != null)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.sand
                                                            .withValues(
                                                                alpha: 0.5),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                              Icons.person,
                                                              size: 11,
                                                              color: AppColors
                                                                  .brown),
                                                          const SizedBox(width: 3),
                                                          Text(
                                                            assignedName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .brown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Actions Popup Menu (Edit / Delete)
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              size: 18,
                                              color: AppColors.textSecondary),
                                          onSelected: (val) {
                                            if (val == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => TaskFormView(
                                                      existingTask: task),
                                                ),
                                              );
                                            } else if (val == 'delete') {
                                              _handleDeleteTask(task);
                                            }
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined,
                                                      size: 18,
                                                      color: AppColors.brown),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline,
                                                      size: 18,
                                                      color: AppColors.error),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.error)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String filter,
    required String current,
    required VoidCallback onTap,
  }) {
    final isSelected = filter == current;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.sand,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.white : AppColors.darkBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip({
    required String label,
    required String priority,
    required String current,
    required VoidCallback onTap,
    Color activeColor = AppColors.brown,
  }) {
    final isSelected = priority == current;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.sand,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}