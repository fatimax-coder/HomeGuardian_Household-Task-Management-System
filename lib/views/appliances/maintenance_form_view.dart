import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/appliance_controller.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../factories/reminder_factory.dart';
import '../../models/appliance.dart';
import '../../models/maintenance_record.dart';

/// Screen: MaintenanceFormView
/// Logs a service or repair record for an appliance
class MaintenanceFormView extends StatefulWidget {
  final Appliance appliance;

  const MaintenanceFormView({super.key, required this.appliance});

  @override
  State<MaintenanceFormView> createState() => _MaintenanceFormViewState();
}

class _MaintenanceFormViewState extends State<MaintenanceFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _providerController = TextEditingController();
  final _costController = TextEditingController(text: '0.00');

  DateTime _serviceDate = DateTime.now();
  bool _scheduleFollowup = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    _providerController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
      setState(() => _serviceDate = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ApplianceController>();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;

    final record = MaintenanceRecord(
      id: '',
      applianceId: widget.appliance.id,
      serviceDate: _serviceDate,
      description: _descriptionController.text.trim(),
      cost: cost,
      serviceProvider: _providerController.text.trim().isEmpty
          ? null
          : _providerController.text.trim(),
    );

    final success = await controller.addMaintenanceRecord(record);

    if (success && _scheduleFollowup && mounted) {
      final activeHousehold =
          context.read<HouseholdController>().selectedHousehold;
      if (activeHousehold != null) {
        final reminderController = context.read<ReminderController>();
        final followUpDate = _serviceDate.add(const Duration(days: 180));
        final reminder = ReminderFactory.createMaintenanceAlert(
          householdId: activeHousehold.id,
          applianceName: widget.appliance.name,
          serviceDate: followUpDate,
          applianceId: widget.appliance.id,
          notes: '6-month periodic follow-up after "${record.description}"',
        );
        await reminderController.addReminder(reminder);
      }
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance record logged successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ApplianceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Maintenance'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.sand, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Appliance info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sand.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.sand),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.build_circle_outlined,
                                color: AppColors.terracotta, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.appliance.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  if (widget.appliance.brand != null ||
                                      widget.appliance.model != null)
                                    Text(
                                      '${widget.appliance.brand ?? ""} ${widget.appliance.model ?? ""}'
                                          .trim(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Service Description
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Service Description *',
                          hintText: 'e.g. Filter cleaning, Compressor repair',
                          prefixIcon:
                              Icon(Icons.description_outlined, color: AppColors.brown),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Please describe the maintenance performed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Service Date Picker
                      InkWell(
                        onTap: _pickServiceDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sand),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_outlined,
                                  color: AppColors.terracotta, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Service Date',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      '${_serviceDate.year}-${_serviceDate.month.toString().padLeft(2, '0')}-${_serviceDate.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: AppColors.brown),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Provider & Cost
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _providerController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Service Provider',
                                hintText: 'e.g. QuickCool Care',
                                prefixIcon: Icon(Icons.storefront_outlined,
                                    color: AppColors.brown),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _costController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Cost (\$)',
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.attach_money,
                                    color: AppColors.brown),
                              ),
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n < 0) {
                                  return 'Valid cost >= 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Checkbox for Follow-up reminder
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _scheduleFollowup,
                        activeColor: AppColors.terracotta,
                        title: const Text(
                          'Schedule 6-month maintenance follow-up alert',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.darkBrown),
                        ),
                        onChanged: (val) {
                          setState(() => _scheduleFollowup = val ?? false);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      ElevatedButton(
                        onPressed: controller.isLoading ? null : _saveRecord,
                        child: controller.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Save Maintenance Log'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
