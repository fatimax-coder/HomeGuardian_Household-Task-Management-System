import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../controllers/appliance_controller.dart';
import '../controllers/reminder_controller.dart';
import '../controllers/task_controller.dart';
import 'appliances/appliance_list_view.dart';
import 'dashboard/dashboard_view.dart';
import 'profile/profile_view.dart';
import 'reminders/reminder_list_view.dart';
import 'tasks/task_list_view.dart';

/// Screen: MainScaffoldView
/// Responsive master navigation frame providing BottomNavigationBar on mobile
/// and NavigationRail on desktop/tablet, preserving active subview states with IndexedStack.
class MainScaffoldView extends StatefulWidget {
  final int initialIndex;

  const MainScaffoldView({super.key, this.initialIndex = 0});

  @override
  State<MainScaffoldView> createState() => _MainScaffoldViewState();
}

class _MainScaffoldViewState extends State<MainScaffoldView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final applianceController = context.watch<ApplianceController>();
    final reminderController = context.watch<ReminderController>();

    final pendingTasks = taskController.pendingTasksCount;
    final expiringWarranties = applianceController.expiringWarrantiesCount;
    final urgentReminders = reminderController.urgentCount;

    final isWide = MediaQuery.of(context).size.width >= 700;

    final pages = [
      DashboardView(isTab: true, onNavigateTab: _onTabSelected),
      const TaskListView(isTab: true),
      const ApplianceListView(isTab: true),
      const ReminderListView(isTab: true),
      const ProfileView(isTab: true),
    ];

    if (isWide) {
      // Desktop / Tablet NavigationRail Layout
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.terracotta,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              selectedIconTheme:
                  const IconThemeData(color: AppColors.terracotta),
              unselectedIconTheme:
                  const IconThemeData(color: AppColors.textSecondary),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.sand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: AppColors.terracotta,
                    size: 28,
                  ),
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: pendingTasks > 0,
                    label: Text(pendingTasks.toString()),
                    backgroundColor: AppColors.terracotta,
                    child: const Icon(Icons.checklist_rtl),
                  ),
                  label: const Text('Tasks'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: expiringWarranties > 0,
                    label: Text(expiringWarranties.toString()),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.kitchen_outlined),
                  ),
                  selectedIcon: const Icon(Icons.kitchen),
                  label: const Text('Appliances'),
                ),
                NavigationRailDestination(
                  icon: Badge(
                    isLabelVisible: urgentReminders > 0,
                    label: Text(urgentReminders.toString()),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.alarm_outlined),
                  ),
                  selectedIcon: const Icon(Icons.alarm),
                  label: const Text('Reminders'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.sand),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile BottomNavigationBar Layout
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.terracotta,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: pendingTasks > 0,
              label: Text(pendingTasks.toString()),
              backgroundColor: AppColors.terracotta,
              child: const Icon(Icons.checklist_rtl),
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: expiringWarranties > 0,
              label: Text(expiringWarranties.toString()),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.kitchen_outlined),
            ),
            activeIcon: const Icon(Icons.kitchen),
            label: 'Appliances',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: urgentReminders > 0,
              label: Text(urgentReminders.toString()),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.alarm_outlined),
            ),
            activeIcon: const Icon(Icons.alarm),
            label: 'Reminders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
