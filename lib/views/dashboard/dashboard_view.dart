import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/household_controller.dart';

/// Screen: DashboardView (Centralized Dashboard)
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().checkAuthStatus();
      context.read<HouseholdController>().fetchHouseholds();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of HomeGuardian?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthController>().signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final householdController = context.watch<HouseholdController>();
    final currentProfile = authController.currentProfile;
    final activeHousehold = householdController.selectedHousehold;

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
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting & Household Status Card
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentProfile != null
                                ? 'Welcome, ${currentProfile.fullName}'
                                : 'My Household',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeHousehold != null
                                ? 'Active Household: ${activeHousehold.name}'
                                : 'No household connected yet',
                            style: const TextStyle(
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
            const SizedBox(height: 20),

            // Setup Household CTA Banner if none active
            if (activeHousehold == null) ...[
              Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.sand, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.terracotta),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Create or join a household to start managing appliances and tasks.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.household),
                        child: const Text('Setup', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

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
                  subtitle: 'Chores & deadlines',
                  icon: Icons.check_circle_outline,
                  route: AppRoutes.tasks,
                ),
                _buildHubCard(
                  context,
                  title: 'Appliances',
                  subtitle: 'Warranties & service',
                  icon: Icons.kitchen_outlined,
                  route: AppRoutes.appliances,
                ),
                _buildHubCard(
                  context,
                  title: 'Reminders',
                  subtitle: 'Bills & alerts',
                  icon: Icons.alarm,
                  route: AppRoutes.reminders,
                ),
                _buildHubCard(
                  context,
                  title: 'Members',
                  subtitle: 'Family & roles',
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
