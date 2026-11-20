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
import '../appliances/appliance_form_view.dart';
import '../tasks/task_form_view.dart';

/// Screen: DashboardView
/// Central operational hub featuring key household metrics, quick task toggles, and shortcut actions
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

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final householdController = context.watch<HouseholdController>();
    final taskController = context.watch<TaskController>();
    final applianceController = context.watch<ApplianceController>();
    final reminderController = context.watch<ReminderController>();

    final profile = authController.currentProfile;
    final household = householdController.selectedHousehold;

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Banner
              Card(
                color: AppColors.sand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_outlined,
                          size: 28,
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
                            const SizedBox(height: 3),
                            Text(
                              household != null
                                  ? 'Managing ${household.name} (${householdController.currentUserRole})'
                                  : 'Smart Household Management & Maintenance',
                              style: const TextStyle(
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
              ),
              const SizedBox(height: 16),

              // Active Household Banner or Onboarding CTA
              if (household == null) ...[
                Card(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.sand, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.terracotta, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'No Household Connected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Create your household or join your family using a 6-character invite code.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_home_outlined, size: 18),
                          label: const Text('Create or Join Household'),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.household),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.sand, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
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
                              const SizedBox(height: 2),
                              Text(
                                'Invite Code: ${household.inviteCode}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.terracotta,
                                ),
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
                                content: Text('Invite code copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.people_outline,
                              color: AppColors.brown),
                          tooltip: 'View Members',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.members),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Operational Metrics Grid (2x2)
              const Text(
                'Household Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
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
                    count: applianceController.totalAppliancesCount.toString(),
                    subtitle: 'Registered units',
                    icon: Icons.kitchen_outlined,
                    color: AppColors.brown,
                    onTap: () => _navigateToTab(2, AppRoutes.appliances),
                  ),
                  _buildMetricCard(
                    title: 'Expiring Warranties',
                    count: applianceController.expiringWarrantiesCount.toString(),
                    subtitle: 'Within 30 days',
                    icon: Icons.verified_user_outlined,
                    color: applianceController.expiringWarrantiesCount > 0
                        ? AppColors.error
                        : AppColors.success,
                    onTap: () => _navigateToTab(2, AppRoutes.appliances),
                  ),
                  _buildMetricCard(
                    title: 'Reminders',
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
              const SizedBox(height: 22),

              // Quick Actions Row
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
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
                      label: 'Reminders Hub',
                      onPressed: () => _navigateToTab(3, AppRoutes.reminders),
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
              const SizedBox(height: 24),

              // Priority Household Tasks Preview
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
              const SizedBox(height: 8),

              // Tasks preview list
              if (taskController.tasks.isEmpty) ...[
                Card(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        household == null
                            ? 'Connect to a household to view chores.'
                            : 'All caught up! No active tasks.',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
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
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
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
            ],
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
