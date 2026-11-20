import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      body: RefreshIndicator(
        color: AppColors.terracotta,
        onRefresh: () async {
          await householdController.fetchHouseholds();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Banner
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
                          size: 30,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentProfile != null
                                  ? 'Welcome, ${currentProfile.fullName}'
                                  : 'Welcome to HomeGuardian',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              currentProfile?.email ??
                                  'Smart Household Management',
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
              const SizedBox(height: 18),

              // Active Household Status or Onboarding Call-to-Action
              if (activeHousehold == null) ...[
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
                                color: AppColors.terracotta, size: 24),
                            SizedBox(width: 10),
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
                        const SizedBox(height: 8),
                        const Text(
                          'Create your household or join your family using a 6-character invite code.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
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
                    side: const BorderSide(color: AppColors.sand, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeHousehold.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
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
                                            fontSize: 11,
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
                                        '${householdController.totalMembersCount} member${householdController.totalMembersCount == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Quick copy invite code button
                            IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: AppColors.terracotta),
                              tooltip: 'Share Invite Code',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: activeHousehold.inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Invite code (${activeHousehold.inviteCode}) copied to clipboard!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
