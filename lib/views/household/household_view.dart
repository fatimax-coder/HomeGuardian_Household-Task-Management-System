import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

/// Screen: HouseholdView (Placeholder for Phase 3 Foundation)
class HouseholdView extends StatelessWidget {
  const HouseholdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Household Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 56,
              color: AppColors.terracotta,
            ),
            const SizedBox(height: 16),
            const Text(
              'Household Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create, Join via Invite Code & Settings',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.members),
              child: const Text('Manage Family Members'),
            ),
          ],
        ),
      ),
    );
  }
}
