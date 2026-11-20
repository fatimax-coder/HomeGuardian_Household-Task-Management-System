import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

/// Screen: TaskListView (Placeholder for Phase 3 Foundation)
class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Household Tasks'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_alt,
              size: 56,
              color: AppColors.brown,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tasks Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CRUD, Priority Sort Strategy & Assignments',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('New Task'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.taskForm),
            ),
          ],
        ),
      ),
    );
  }
}

