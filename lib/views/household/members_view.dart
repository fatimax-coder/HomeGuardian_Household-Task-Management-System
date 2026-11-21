import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/household_controller.dart';
import '../../models/household_member.dart';

/// Screen: MembersView
/// Lists all household members, displays roles, and provides Admin-only management
class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_outlined,
                color: AppColors.terracotta, size: 26),
            SizedBox(width: 10),
            Text(
              'Add Family Member',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a family member by name (e.g. child, elderly relative) who does not have an account.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Member Name',
                hintText: 'e.g. Grandma Rose, Billy',
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.brown),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              final controller = context.read<HouseholdController>();
              final success = await controller.addFamilyMember(name);
              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "$name" to household members.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (controller.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveMember(HouseholdMember member) async {
    final controller = context.read<HouseholdController>();
    final isSelf = member.userId == controller.currentUserId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isSelf ? 'Leave Household' : 'Remove Member',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: Text(
          isSelf
              ? 'Are you sure you want to leave "${controller.selectedHousehold?.name}"?'
              : 'Are you sure you want to remove "${member.displayName}" from this household?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isSelf ? 'Leave' : 'Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await controller.removeMember(member.id);
      if (!mounted) return;

      if (success) {
        if (isSelf) {
          Navigator.pop(context); // return to dashboard
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSelf
                ? 'You have left the household.'
                : 'Removed ${member.displayName}.'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (controller.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HouseholdController>();
    final members = controller.members;
    final isAdmin = controller.isCurrentAdmin;
    final currentUid = controller.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family Members'),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Family Member'),
              onPressed: _showAddMemberDialog,
            )
          : null,
      body: members.isEmpty
          ? const Center(
              child: Text(
                'No members found in this household.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = members[index];
                final isSelf = member.userId == currentUid;

                return Card(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Avatar Circle with Initials
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: member.isAdmin
                              ? AppColors.terracotta
                              : AppColors.sand,
                          child: Text(
                            member.displayName.isNotEmpty
                                ? member.displayName[0].toUpperCase()
                                : 'M',
                            style: TextStyle(
                              color: member.isAdmin
                                  ? AppColors.white
                                  : AppColors.darkBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name & Email / Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      member.displayName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                  ),
                                  if (isSelf) ...[
                                    const SizedBox(width: 6),
                                    const Text(
                                      '(You)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                member.displayEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.isAdmin
                                ? AppColors.terracotta.withValues(alpha: 0.15)
                                : AppColors.sand.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: member.isAdmin
                                  ? AppColors.terracotta
                                  : AppColors.sand,
                            ),
                          ),
                          child: Text(
                            member.isAdmin ? 'Admin' : 'Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: member.isAdmin
                                  ? AppColors.terracotta
                                  : AppColors.brown,
                            ),
                          ),
                        ),

                        // Delete button (visible if user is admin OR member is self)
                        if (isAdmin || isSelf) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(
                              isSelf ? Icons.exit_to_app : Icons.delete_outline,
                              color: AppColors.error.withValues(alpha: 0.8),
                              size: 20,
                            ),
                            tooltip: isSelf ? 'Leave Household' : 'Remove Member',
                            onPressed: () => _handleRemoveMember(member),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
