import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/appliance_controller.dart';
import '../../controllers/household_controller.dart';
import '../../models/appliance.dart';
import '../../widgets/app_illustration.dart';
import 'appliance_detail_view.dart';
import 'appliance_form_view.dart';

/// Screen: ApplianceListView
/// Shows household appliances, warranty statuses, countdown badges, and navigation to details
class ApplianceListView extends StatefulWidget {
  final bool isTab;

  const ApplianceListView({super.key, this.isTab = false});

  @override
  State<ApplianceListView> createState() => _ApplianceListViewState();
}

class _ApplianceListViewState extends State<ApplianceListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final household = context.read<HouseholdController>().selectedHousehold;
      if (household != null) {
        context.read<ApplianceController>().fetchAppliances(household.id);
      }
    });
  }

  Color _getWarrantyBadgeColor(Appliance appliance) {
    if (!appliance.isWarrantyActive) return AppColors.error;
    if (appliance.daysUntilWarrantyExpires <= 30) return AppColors.terracotta;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final applianceController = context.watch<ApplianceController>();
    final householdController = context.watch<HouseholdController>();
    final activeHousehold = householdController.selectedHousehold;
    final appliances = applianceController.appliances;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appliances & Warranties'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          if (activeHousehold != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  applianceController.fetchAppliances(activeHousehold.id),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Appliance'),
        onPressed: () {
          if (activeHousehold == null) {
            Navigator.pushNamed(context, AppRoutes.household);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApplianceFormView()),
            );
          }
        },
      ),
      body: activeHousehold == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.kitchen_outlined,
                        size: 64, color: AppColors.brown),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Household',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect or create a household to register appliances and track warranties.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_home),
                      label: const Text('Setup Household'),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.household),
                    ),
                  ],
                ),
              ),
            )
          : applianceController.isLoading && appliances.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.terracotta))
              : appliances.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIllustration.emptyAppliances(size: 80),
                          const SizedBox(height: 12),
                          const Text(
                            'No Appliances Registered',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Keep warranty info and service logs organized.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Appliance'),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ApplianceFormView()),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: appliances.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final appliance = appliances[index];
                        final badgeColor = _getWarrantyBadgeColor(appliance);

                        return Card(
                          color: AppColors.white,
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                                color: AppColors.sand, width: 1.2),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              applianceController.selectAppliance(appliance);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplianceDetailView(
                                      appliance: appliance),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Appliance Illustration Thumbnail
                                  ApplianceThumbnail(
                                    name: appliance.name,
                                    brand: appliance.brand,
                                    size: 58,
                                  ),
                                  const SizedBox(width: 14),

                                  // Appliance Specs
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appliance.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          [
                                            if (appliance.brand != null)
                                              appliance.brand,
                                            if (appliance.model != null)
                                              'Model: ${appliance.model}',
                                          ].join(' • '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Warranty status badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                badgeColor.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: badgeColor
                                                    .withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            appliance.warrantyStatus,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: badgeColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
