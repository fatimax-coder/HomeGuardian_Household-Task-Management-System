import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/appliance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/reminder.dart';
import '../../widgets/app_illustration.dart';
import '../../widgets/charts/maintenance_expense_chart.dart';
import '../../widgets/charts/task_completion_chart.dart';
import '../../widgets/charts/task_priority_chart.dart';
import '../appliances/appliance_form_view.dart';
import '../tasks/task_form_view.dart';

/// Screen: DashboardView
/// Structured according to Section 5 Dashboard Layout:
/// 1. Welcome section with attractive home illustration.
/// 2. Household name and user role.
/// 3. Quick statistics cards.
/// 4. Task completion chart.
/// 5. Task priority chart.
/// 6. Upcoming reminders.
/// 7. Recent tasks.
/// 8. Household quick actions.
class DashboardView extends StatefulWidget {
  final bool isTab;
  final ValueChanged<int>? onNavigateTab;

  const DashboardView({
    super.key,
    this.isTab = false,
    this.onNavigateTab,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  Future<void> _refreshAllData() async {
    final auth = context.read<AuthController>();
    final householdCtrl = context.read<HouseholdController>();

    if (!auth.isAuthenticated) {
      await auth.checkAuthStatus();
    }
    await householdCtrl.fetchHouseholds();

    final activeHousehold = householdCtrl.selectedHousehold;
    if (activeHousehold != null && mounted) {
      await Future.wait([
        context.read<TaskController>().fetchTasks(activeHousehold.id),
        context.read<ApplianceController>().fetchAppliances(activeHousehold.id),
        context.read<ReminderController>().fetchReminders(activeHousehold.id),
      ]);
    }
  }

  void _navigateToTab(int tabIndex, String routeFallback) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(tabIndex);
    } else {
      Navigator.pushNamed(context, routeFallback);
    }
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.bill:
        return Icons.receipt_long_outlined;
      case ReminderType.maintenance:
        return Icons.build_outlined;
      case ReminderType.warranty:
        return Icons.verified_user_outlined;
      case ReminderType.task:
        return Icons.task_alt;
    }
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.bill:
        return AppColors.terracotta;
      case ReminderType.maintenance:
        return AppColors.brown;
      case ReminderType.warranty:
        return AppColors.success;
      case ReminderType.task:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final householdController = context.watch<HouseholdController>();
    final taskController = context.watch<TaskController>();
    final applianceController = context.watch<ApplianceController>();
    final reminderController = context.watch<ReminderController>();

    final profile = authController.currentProfile;
    final household = householdController.selectedHousehold;
    final activeReminders = reminderController.reminders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HomeGuardian'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Household & Members',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.members),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh All',
            onPressed: _refreshAllData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.terracotta,
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -------------------------------------------------------------
                  // 1. Welcome section with attractive home illustration
                  // -------------------------------------------------------------
                  Card(
                    color: AppColors.white,
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppColors.sand, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppIllustration.homeBanner(height: 125),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.sand,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.waving_hand_outlined,
                                  size: 24,
                                  color: AppColors.terracotta,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile != null
                                          ? 'Welcome back, ${profile.fullName}!'
                                          : 'Welcome to HomeGuardian',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Smart Household Management & Maintenance System',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // -------------------------------------------------------------
                  // 2. Household name and user role
                  // -------------------------------------------------------------
                  if (household == null) ...[
                    Card(
                      color: AppColors.white,
                      elevation: 1.2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.sand, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.sand.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: AppColors.terracotta, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'No Household Connected',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Create a household or join your family via invite code.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.household),
                              child: const Text('Setup'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: AppColors.white,
                      elevation: 1.2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.sand, width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.sand.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.home_work_outlined,
                                color: AppColors.terracotta,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    household.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              householdController.isCurrentAdmin
                                                  ? AppColors.terracotta
                                                  : AppColors.sand,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          householdController.currentUserRole,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: householdController
                                                    .isCurrentAdmin
                                                ? AppColors.white
                                                : AppColors.darkBrown,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Code: ${household.inviteCode}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy,
                                  size: 18, color: AppColors.terracotta),
                              tooltip: 'Copy Invite Code',
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: household.inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invite code copied!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.people_outline,
                                  size: 20, color: AppColors.brown),
                              tooltip: 'Family Members',
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.members),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // -------------------------------------------------------------
                  // 3. Quick statistics cards
                  // -------------------------------------------------------------
                  const Text(
                    'Household Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _buildMetricCard(
                        title: 'Pending Tasks',
                        count: taskController.pendingTasksCount.toString(),
                        subtitle: 'of ${taskController.totalTasksCount} total',
                        icon: Icons.checklist_rtl,
                        color: AppColors.terracotta,
                        onTap: () => _navigateToTab(1, AppRoutes.tasks),
                      ),
                      _buildMetricCard(
                        title: 'Appliances',
                        count:
                            applianceController.totalAppliancesCount.toString(),
                        subtitle: 'Registered units',
                        icon: Icons.kitchen_outlined,
                        color: AppColors.brown,
                        onTap: () => _navigateToTab(2, AppRoutes.appliances),
                      ),
                      _buildMetricCard(
                        title: 'Expiring Warranties',
                        count: applianceController.expiringWarrantiesCount
                            .toString(),
                        subtitle: 'Within 30 days',
                        icon: Icons.verified_user_outlined,
                        color: applianceController.expiringWarrantiesCount > 0
                            ? AppColors.error
                            : AppColors.success,
                        onTap: () => _navigateToTab(2, AppRoutes.appliances),
                      ),
                      _buildMetricCard(
                        title: 'Active Reminders',
                        count: reminderController.activeCount.toString(),
                        subtitle:
                            '${reminderController.urgentCount} urgent alert${reminderController.urgentCount == 1 ? '' : 's'}',
                        icon: Icons.notifications_active_outlined,
                        color: reminderController.urgentCount > 0
                            ? AppColors.error
                            : AppColors.terracotta,
                        onTap: () => _navigateToTab(3, AppRoutes.reminders),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // -------------------------------------------------------------
                  // 4. Task completion chart
                  // -------------------------------------------------------------
                  TaskCompletionChart(taskController: taskController),
                  const SizedBox(height: 16),

                  // -------------------------------------------------------------
                  // 5. Task priority chart & Maintenance expense chart
                  // -------------------------------------------------------------
                  TaskPriorityChart(taskController: taskController),
                  const SizedBox(height: 16),
                  MaintenanceExpenseChart(
                      applianceController: applianceController),
                  const SizedBox(height: 18),

                  // -------------------------------------------------------------
                  // 6. Upcoming reminders
                  // -------------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _navigateToTab(3, AppRoutes.reminders),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (activeReminders.isEmpty) ...[
                    Card(
                      color: AppColors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            AppIllustration.emptyReminders(size: 40),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'No upcoming reminders. All bills and service alerts are clear!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeReminders.take(3).length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final rem = activeReminders[index];
                        final remColor = _getReminderColor(rem.type);
                        final isOverdue = rem.isOverdue && !rem.isDismissed;

                        return Card(
                          color: AppColors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isOverdue
                                  ? AppColors.error.withValues(alpha: 0.6)
                                  : AppColors.sand,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: remColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getReminderIcon(rem.type),
                                color: remColor,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              rem.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            subtitle: Text(
                              'Due: ${rem.reminderDate.year}-${rem.reminderDate.month.toString().padLeft(2, '0')}-${rem.reminderDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                            trailing: isOverdue
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'OVERDUE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 18),

                  // -------------------------------------------------------------
                  // 7. Recent tasks
                  // -------------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Chores & Tasks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToTab(1, AppRoutes.tasks),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (taskController.tasks.isEmpty) ...[
                    Card(
                      color: AppColors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            AppIllustration.emptyTasks(size: 40),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'All caught up! No pending chores right now.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taskController.tasks.take(3).length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = taskController.tasks[index];
                        return Card(
                          color: AppColors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.sand),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Checkbox(
                              activeColor: AppColors.terracotta,
                              value: task.isCompleted,
                              onChanged: (val) {
                                taskController.toggleTaskStatus(
                                  task.id,
                                  val ?? false,
                                );
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? AppColors.textMuted
                                    : AppColors.darkBrown,
                              ),
                            ),
                            subtitle: task.dueDate != null
                                ? Text(
                                    'Due: ${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: task.isOverdue
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                  )
                                : null,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.sand.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brown,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 22),

                  // -------------------------------------------------------------
                  // 8. Household quick actions
                  // -------------------------------------------------------------
                  const Text(
                    'Household Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.add_task,
                          label: 'New Task',
                          onPressed: () {
                            if (household != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TaskFormView()),
                              );
                            } else {
                              Navigator.pushNamed(context, AppRoutes.household);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.kitchen,
                          label: 'Add Appliance',
                          onPressed: () {
                            if (household != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ApplianceFormView()),
                              );
                            } else {
                              Navigator.pushNamed(context, AppRoutes.household);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.alarm_add,
                          label: 'Set Reminder',
                          onPressed: () =>
                              _navigateToTab(3, AppRoutes.reminders),
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.group_add,
                          label: 'Family Members',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.members),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.white,
      elevation: 1.2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.sand, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Icon(icon, size: 20, color: color),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBrown,
        elevation: 0,
        side: const BorderSide(color: AppColors.sand, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18, color: AppColors.terracotta),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onPressed,
    );
  }
}
