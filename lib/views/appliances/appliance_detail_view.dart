import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/appliance_controller.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../factories/reminder_factory.dart';
import '../../models/appliance.dart';
import 'appliance_form_view.dart';
import 'maintenance_form_view.dart';

/// Screen: ApplianceDetailView
/// Shows detailed appliance specifications, warranty countdown, maintenance logs, and actions
class ApplianceDetailView extends StatefulWidget {
  final Appliance? appliance;

  const ApplianceDetailView({super.key, this.appliance});

  @override
  State<ApplianceDetailView> createState() => _ApplianceDetailViewState();
}

class _ApplianceDetailViewState extends State<ApplianceDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = widget.appliance ??
          context.read<ApplianceController>().selectedAppliance;
      if (app != null) {
        context.read<ApplianceController>().fetchMaintenanceRecords(app.id);
      }
    });
  }

  Future<void> _handleDelete(Appliance appliance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Appliance',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown),
        ),
        content: Text(
          'Are you sure you want to delete "${appliance.name}" and all its maintenance records?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<ApplianceController>().deleteAppliance(appliance.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appliance deleted successfully'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleCreateWarrantyReminder(Appliance appliance) async {
    if (appliance.warrantyExpiryDate == null) return;
    final household = context.read<HouseholdController>().selectedHousehold;
    if (household == null) return;

    final reminder = ReminderFactory.createWarrantyAlert(
      householdId: household.id,
      applianceName: appliance.name,
      warrantyExpiryDate: appliance.warrantyExpiryDate!,
      applianceId: appliance.id,
    );

    final success = await context.read<ReminderController>().addReminder(reminder);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warranty reminder alert created!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final applianceController = context.watch<ApplianceController>();
    final appliance = widget.appliance ?? applianceController.selectedAppliance;

    if (appliance == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Appliance Details')),
        body: const Center(child: Text('No appliance selected')),
      );
    }

    final records = applianceController.getRecords(appliance.id);
    final days = appliance.daysUntilWarrantyExpires;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(appliance.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Appliance',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplianceFormView(existingAppliance: appliance),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Appliance',
            onPressed: () => _handleDelete(appliance),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warranty Overview Card
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.sand.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_user_outlined,
                                  color: AppColors.terracotta, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appliance.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${appliance.brand ?? "Unknown Brand"} • ${appliance.model ?? "No Model #"}',
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
                        const SizedBox(height: 18),
                        const Divider(color: AppColors.sand, height: 1),
                        const SizedBox(height: 14),

                        // Specs Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecTile(
                                label: 'Purchase Date',
                                value: appliance.purchaseDate != null
                                    ? '${appliance.purchaseDate!.year}-${appliance.purchaseDate!.month.toString().padLeft(2, '0')}-${appliance.purchaseDate!.day.toString().padLeft(2, '0')}'
                                    : 'Not recorded',
                              ),
                            ),
                            Expanded(
                              child: _buildSpecTile(
                                label: 'Warranty Period',
                                value: '${appliance.warrantyMonths} Months',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecTile(
                                label: 'Expiry Date',
                                value: appliance.warrantyExpiryDate != null
                                    ? '${appliance.warrantyExpiryDate!.year}-${appliance.warrantyExpiryDate!.month.toString().padLeft(2, '0')}-${appliance.warrantyExpiryDate!.day.toString().padLeft(2, '0')}'
                                    : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _buildSpecTile(
                                label: 'Status',
                                value: appliance.warrantyStatus,
                                color: appliance.isWarrantyActive
                                    ? (days <= 30
                                        ? AppColors.terracotta
                                        : AppColors.success)
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action: Schedule Warranty Alert
                        if (appliance.warrantyExpiryDate != null)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.alarm_add, size: 18),
                            label: const Text('Add Warranty Alert Reminder'),
                            onPressed: () =>
                                _handleCreateWarrantyReminder(appliance),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Maintenance Records Header & Add Log Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Maintenance Records',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Log Service'),
                      onPressed: () async {
                        final added = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MaintenanceFormView(appliance: appliance),
                          ),
                        );
                        if (added == true && mounted) {
                          applianceController
                              .fetchMaintenanceRecords(appliance.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Maintenance Records List
                if (records.isEmpty) ...[
                  Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.build_outlined,
                              size: 40, color: AppColors.sand),
                          const SizedBox(height: 10),
                          const Text(
                            'No maintenance logged yet.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Log repairs, filter changes, and inspections to track appliance upkeep.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final rec = records[index];
                      return Card(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.sand),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rec.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  Text(
                                    '\$${rec.cost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.terracotta,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event,
                                      size: 13,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rec.serviceDate.year}-${rec.serviceDate.month.toString().padLeft(2, '0')}-${rec.serviceDate.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (rec.serviceProvider != null) ...[
                                    const SizedBox(width: 10),
                                    Icon(Icons.storefront,
                                        size: 13,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      rec.serviceProvider!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecTile({
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.darkBrown,
          ),
        ),
      ],
    );
  }
}
