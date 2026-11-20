import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/household_controller.dart';
import '../../widgets/app_illustration.dart';

/// Screen: HouseholdView
/// Handles Household Onboarding (Create / Join) and Active Household Details
class HouseholdView extends StatefulWidget {
  const HouseholdView({super.key});

  @override
  State<HouseholdView> createState() => _HouseholdViewState();
}

class _HouseholdViewState extends State<HouseholdView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_createFormKey.currentState!.validate()) return;
    final controller = context.read<HouseholdController>();
    final success = await controller.createHousehold(_nameController.text.trim());

    if (!mounted) return;
    if (success) {
      _nameController.clear();
      _showSuccessDialog(
        title: 'Household Created!',
        content:
            'Your household has been created.\n\nShare this 6-character invite code with your family members to let them join:\n\n${controller.lastCreatedInviteCode ?? ""}',
        inviteCode: controller.lastCreatedInviteCode,
      );
    } else if (controller.hasError) {
      _showErrorSnackBar(controller.errorMessage!);
    }
  }

  Future<void> _handleJoin() async {
    if (!_joinFormKey.currentState!.validate()) return;
    final controller = context.read<HouseholdController>();
    final success =
        await controller.joinHousehold(_inviteCodeController.text.trim());

    if (!mounted) return;
    if (success) {
      _inviteCodeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.successMessage ?? 'Joined successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (controller.hasError) {
      _showErrorSnackBar(controller.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog({
    required String title,
    required String content,
    String? inviteCode,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (inviteCode != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.sand.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sand),
                ),
                child: Center(
                  child: Text(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (inviteCode != null)
            TextButton.icon(
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy Code'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite code copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HouseholdController>();
    final household = controller.selectedHousehold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Household Profile'),
      ),
      body: controller.isLoading && household == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // If active household exists, show Details & Management
                  if (household != null) ...[
                    _buildActiveHouseholdCard(controller, household),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.sand, thickness: 1),
                    const SizedBox(height: 16),
                    const Text(
                      'Household Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Onboarding Tabs (Create / Join)
                  Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: AppIllustration.family(size: 68),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: AppColors.terracotta,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelColor: AppColors.white,
                              unselectedLabelColor: AppColors.textSecondary,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Create Household'),
                                Tab(text: 'Join with Code'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildCreateTab(controller),
                                _buildJoinTab(controller),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveHouseholdCard(
      HouseholdController controller, dynamic household) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.sand, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppIllustration.family(size: 54),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        household.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: controller.isCurrentAdmin
                                  ? AppColors.terracotta
                                  : AppColors.sand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              controller.isCurrentAdmin ? 'Admin' : 'Member',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: controller.isCurrentAdmin
                                    ? AppColors.white
                                    : AppColors.darkBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.totalMembersCount} member${controller.totalMembersCount == 1 ? '' : 's'}',
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
              ],
            ),
            const SizedBox(height: 20),

            // Invite Code Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sand),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vpn_key_outlined,
                      color: AppColors.brown, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Household Invite Code',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        household.inviteCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.terracotta),
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
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Manage Members Navigation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.people_outline, size: 20),
                label: const Text('Manage Family Members'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.members),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab(HouseholdController controller) {
    return Form(
      key: _createFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Name your household (e.g., Baker Residence, The Loft)',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Household Name',
              hintText: 'e.g. Sunnydale Cottage',
              prefixIcon:
                  Icon(Icons.home_outlined, color: AppColors.brown),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: controller.isLoading ? null : _handleCreate,
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : const Text('Create Household'),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTab(HouseholdController controller) {
    return Form(
      key: _joinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter the 6-character alphanumeric code provided by an admin.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
            decoration: const InputDecoration(
              labelText: '6-Digit Code',
              hintText: 'e.g. A9B2X7',
              counterText: '',
              prefixIcon:
                  Icon(Icons.tag, color: AppColors.brown),
            ),
            validator: (v) {
              if (v == null || v.trim().length != 6) {
                return 'Please enter a 6-character code';
              }
              return null;
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: controller.isLoading ? null : _handleJoin,
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : const Text('Join Household'),
          ),
        ],
      ),
    );
  }
}
