import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

/// Screen: ApplianceListView (Placeholder for Phase 3 Foundation)
class ApplianceListView extends StatelessWidget {
  const ApplianceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appliances & Warranties'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.kitchen,
              size: 56,
              color: AppColors.terracotta,
            ),
            const SizedBox(height: 16),
            const Text(
              'Appliance Registry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Warranty Status, Models & Maintenance History',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.applianceDetail),
              child: const Text('View Sample Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

