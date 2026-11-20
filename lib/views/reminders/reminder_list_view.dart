import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Screen: ReminderListView (Placeholder for Phase 3 Foundation)
class ReminderListView extends StatelessWidget {
  const ReminderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reminders & Alerts'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 56,
              color: AppColors.brown,
            ),
            SizedBox(height: 16),
            Text(
              'Reminders Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tasks, Bills, Maintenance & Expiry Notifications',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
