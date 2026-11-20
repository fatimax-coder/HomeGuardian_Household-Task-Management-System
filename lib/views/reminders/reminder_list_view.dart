import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../factories/reminder_factory.dart';
import '../../models/reminder.dart';
import '../../strategies/reminder_filter_strategy.dart';

/// Screen: ReminderListView
/// Displays reminders, handles Strategy filtering (Active, Urgent, Warranty),
/// dismissals, deletions, and adding reminders via ReminderFactory.
class ReminderListView extends StatefulWidget {
  final bool isTab;

  const ReminderListView({super.key, this.isTab = false});

  @override
  State<ReminderListView> createState() => _ReminderListViewState();
}

class _ReminderListViewState extends State<ReminderListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final household = context.read<HouseholdController>().selectedHousehold;
      if (household != null) {
        context.read<ReminderController>().fetchReminders(household.id);
      }
    });
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    ReminderType selectedType = ReminderType.bill;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_alert, color: AppColors.terracotta, size: 24),
              SizedBox(width: 10),
              Text(
                'Create Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder Category (ReminderFactory)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<ReminderType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, color: AppColors.brown),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: ReminderType.bill, child: Text('Household Bill')),
                    DropdownMenuItem(
                        value: ReminderType.maintenance,
                        child: Text('Maintenance Service')),
                    DropdownMenuItem(
                        value: ReminderType.warranty,
                        child: Text('Warranty Expiry')),
                    DropdownMenuItem(
                        value: ReminderType.task, child: Text('General Task')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Title *',
                    hintText: 'e.g. Electric Bill, HVAC Filter',
                    prefixIcon: Icon(Icons.title, color: AppColors.brown),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g. \$120 due via portal',
                    prefixIcon: Icon(Icons.notes, color: AppColors.brown),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.terracotta,
                              onPrimary: AppColors.white,
                              surface: AppColors.white,
                              onSurface: AppColors.darkBrown,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.sand),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: AppColors.terracotta),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const Spacer(),
                        const Text('Change',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.terracotta)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(ctx);

                final household =
                    context.read<HouseholdController>().selectedHousehold;
                if (household == null) return;

                final reminder = ReminderFactory.create(
                  householdId: household.id,
                  type: selectedType,
                  title: title,
                  reminderDate: selectedDate,
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );

                final success =
                    await context.read<ReminderController>().addReminder(reminder);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder created!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.bill:
        return Icons.receipt_long_outlined;
      case ReminderType.maintenance:
        return Icons.build_outlined;
      case ReminderType.warranty:
        return Icons.verified_user_outlined;
      case ReminderType.task:
        return Icons.task_alt;
    }
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.bill:
        return AppColors.terracotta;
      case ReminderType.maintenance:
        return AppColors.brown;
      case ReminderType.warranty:
        return AppColors.success;
      case ReminderType.task:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderController = context.watch<ReminderController>();
    final householdController = context.watch<HouseholdController>();
    final activeHousehold = householdController.selectedHousehold;
    final reminders = reminderController.reminders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reminders & Alerts'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          if (activeHousehold != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () =>
                  reminderController.fetchReminders(activeHousehold.id),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_alert),
        label: const Text('New Reminder'),
        onPressed: () {
          if (activeHousehold == null) {
            Navigator.pushNamed(context, AppRoutes.household);
          } else {
            _showAddReminderDialog();
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
                    const Icon(Icons.notifications_none,
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
                      'Connect to a household to view and set automated reminders.',
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
          : Column(
              children: [
                // Filter Strategy Tabs (Active, Urgent, Warranty Only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppColors.sand.withValues(alpha: 0.35),
                  child: Row(
                    children: [
                      _buildStrategyTab(
                        label: 'Active (${reminderController.activeCount})',
                        strategyType: ActiveRemindersStrategy,
                        onTap: () => reminderController
                            .setFilterStrategy(ActiveRemindersStrategy()),
                      ),
                      const SizedBox(width: 8),
                      _buildStrategyTab(
                        label: 'Urgent (${reminderController.urgentCount})',
                        strategyType: UrgentRemindersStrategy,
                        onTap: () => reminderController
                            .setFilterStrategy(UrgentRemindersStrategy()),
                      ),
                      const SizedBox(width: 8),
                      _buildStrategyTab(
                        label: 'Warranty',
                        strategyType: WarrantyRemindersStrategy,
                        onTap: () => reminderController
                            .setFilterStrategy(WarrantyRemindersStrategy()),
                      ),
                    ],
                  ),
                ),

                // Reminders List
                Expanded(
                  child: reminderController.isLoading && reminders.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.terracotta))
                      : reminders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.notifications_off_outlined,
                                      size: 56, color: AppColors.sand),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No Reminders in This View',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tap "+ New Reminder" to schedule bills, maintenance or tasks.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: reminders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final reminder = reminders[index];
                                final typeColor = _getTypeColor(reminder.type);
                                final isOverdue = reminder.isOverdue &&
                                    !reminder.isDismissed;

                                return Card(
                                  color: AppColors.white,
                                  elevation: 1.2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: isOverdue
                                          ? AppColors.error.withValues(alpha: 0.6)
                                          : AppColors.sand,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Category Icon Circle
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: typeColor.withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getTypeIcon(reminder.type),
                                            color: typeColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Reminder Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      reminder.title,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: reminder.isDismissed
                                                            ? AppColors.textMuted
                                                            : AppColors.darkBrown,
                                                        decoration: reminder
                                                                .isDismissed
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isOverdue)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error
                                                            .withValues(alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                      ),
                                                      child: const Text(
                                                        'OVERDUE',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors.error,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (reminder.description !=
                                                      null &&
                                                  reminder.description!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 3),
                                                Text(
                                                  reminder.description!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),

                                              // Date row
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 12,
                                                    color: isOverdue
                                                        ? AppColors.error
                                                        : AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${reminder.reminderDate.year}-${reminder.reminderDate.month.toString().padLeft(2, '0')}-${reminder.reminderDate.day.toString().padLeft(2, '0')}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: isOverdue
                                                          ? AppColors.error
                                                          : AppColors
                                                              .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Actions: Dismiss and Delete
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!reminder.isDismissed)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check_circle_outline,
                                                  color: AppColors.success,
                                                  size: 22,
                                                ),
                                                tooltip: 'Dismiss Reminder',
                                                onPressed: () {
                                                  reminderController
                                                      .dismissReminder(
                                                          reminder.id);
                                                },
                                              ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: AppColors.textSecondary,
                                                size: 20,
                                              ),
                                              tooltip: 'Delete Reminder',
                                              onPressed: () {
                                                reminderController
                                                    .deleteReminder(
                                                        reminder.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildStrategyTab({
    required String label,
    required Type strategyType,
    required VoidCallback onTap,
  }) {
    final controller = context.watch<ReminderController>();
    final isSelected = controller.filterStrategy.runtimeType == strategyType;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.sand,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.white : AppColors.darkBrown,
          ),
        ),
      ),
    );
  }
}
