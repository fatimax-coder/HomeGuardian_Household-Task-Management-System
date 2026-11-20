import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/household_controller.dart';

/// Screen: ProfileView
/// Displays user account info, current household membership details, and logout
class ProfileView extends StatelessWidget {
  final bool isTab;
  const ProfileView({super.key, this.isTab = false});

  Future<void> _handleLogout(BuildContext context) async {
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

    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().signOut();
      if (!context.mounted) return;
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
    final profile = authController.currentProfile;
    final household = householdController.selectedHousehold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User & Household Profile'),
        automaticallyImplyLeading: !isTab,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Profile Header Card
                Card(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.sand,
                          child: Text(
                            profile?.fullName.isNotEmpty == true
                                ? profile!.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.fullName ?? 'Authenticated User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile?.email ?? authController.currentUserEmail ?? 'No email',
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

                // Household Information Card
                const Text(
                  'Active Household',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 10),
                if (household != null) ...[
                  Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.home_work_outlined,
                                  color: AppColors.terracotta, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      household.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Role: ${householdController.currentUserRole}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: householdController.isCurrentAdmin
                                      ? AppColors.terracotta
                                      : AppColors.sand,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  householdController.isCurrentAdmin ? 'Admin' : 'Member',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: householdController.isCurrentAdmin
                                        ? AppColors.white
                                        : AppColors.darkBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.sand),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.vpn_key_outlined,
                                    size: 18, color: AppColors.brown),
                                const SizedBox(width: 8),
                                const Text(
                                  'Invite Code: ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary),
                                ),
                                Text(
                                  household.inviteCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: AppColors.darkBrown,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18, color: AppColors.terracotta),
                                  tooltip: 'Copy Code',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: household.inviteCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Invite code copied!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.people_outline, size: 18),
                                  label: const Text('Members'),
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.members),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.swap_horiz, size: 18),
                                  label: const Text('Switch / Join'),
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.household),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No Household Selected',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Create or join a household to start managing tasks and appliances.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_home_outlined),
                            label: const Text('Setup Household'),
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.household),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Sign Out Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sign Out of HomeGuardian',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
