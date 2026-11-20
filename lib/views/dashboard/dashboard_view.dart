import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

/// Screen: DashboardView (Centralized Dashboard - Phase 3 Foundation)
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HomeGuardian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Household & Members',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.household),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Reminders',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.reminders),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: AppColors.sand,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                        size: 32,
                        color: AppColors.terracotta,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Household',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Warm Minimalist Household Management',
                            style: TextStyle(
                              fontSize: 13,
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
            const SizedBox(height: 24),

            // Quick Navigation Hub
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                _buildHubCard(
                  context,
                  title: 'Tasks',
                  subtitle: 'Pending chores',
                  icon: Icons.check_circle_outline,
                  route: AppRoutes.tasks,
                ),
                _buildHubCard(
                  context,
                  title: 'Appliances',
                  subtitle: 'Warranties & specs',
                  icon: Icons.kitchen_outlined,
                  route: AppRoutes.appliances,
                ),
                _buildHubCard(
                  context,
                  title: 'Reminders',
                  subtitle: 'Bills & schedules',
                  icon: Icons.alarm,
                  route: AppRoutes.reminders,
                ),
                _buildHubCard(
                  context,
                  title: 'Members',
                  subtitle: 'Family profiles',
                  icon: Icons.family_restroom,
                  route: AppRoutes.members,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.terracotta, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
