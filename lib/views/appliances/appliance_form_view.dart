import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/appliance_controller.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/reminder_controller.dart';
import '../../factories/reminder_factory.dart';
import '../../models/appliance.dart';

/// Screen: ApplianceFormView
/// Handles adding or editing an appliance with warranty duration
class ApplianceFormView extends StatefulWidget {
  final Appliance? existingAppliance;

  const ApplianceFormView({super.key, this.existingAppliance});

  @override
  State<ApplianceFormView> createState() => _ApplianceFormViewState();
}

class _ApplianceFormViewState extends State<ApplianceFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _warrantyMonthsController;

  DateTime _purchaseDate = DateTime.now();
  bool _createWarrantyAlert = true;

  @override
  void initState() {
    super.initState();
    final app = widget.existingAppliance;
    _nameController = TextEditingController(text: app?.name ?? '');
    _brandController = TextEditingController(text: app?.brand ?? '');
    _modelController = TextEditingController(text: app?.model ?? '');
    _warrantyMonthsController =
        TextEditingController(text: (app?.warrantyMonths ?? 12).toString());
    if (app?.purchaseDate != null) {
      _purchaseDate = app!.purchaseDate!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _warrantyMonthsController.dispose();
    super.dispose();
  }

  DateTime get _calculatedExpiryDate {
    final months = int.tryParse(_warrantyMonthsController.text.trim()) ?? 12;
    return DateTime(
      _purchaseDate.year,
      _purchaseDate.month + months,
      _purchaseDate.day,
    );
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _saveAppliance() async {
    if (!_formKey.currentState!.validate()) return;

    final householdController = context.read<HouseholdController>();
    final activeHousehold = householdController.selectedHousehold;
    if (activeHousehold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or create a household first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final applianceController = context.read<ApplianceController>();
    final months = int.tryParse(_warrantyMonthsController.text.trim()) ?? 12;

    final appliance = Appliance(
      id: widget.existingAppliance?.id ?? '',
      householdId: activeHousehold.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      purchaseDate: _purchaseDate,
      warrantyMonths: months,
    );

    bool success;
    if (widget.existingAppliance != null) {
      success = await applianceController.updateAppliance(appliance);
    } else {
      success = await applianceController.addAppliance(appliance);

      // Create automatic warranty reminder if requested
      if (success && _createWarrantyAlert && mounted) {
        final reminderController = context.read<ReminderController>();
        final reminder = ReminderFactory.createWarrantyAlert(
          householdId: activeHousehold.id,
          applianceName: appliance.name,
          warrantyExpiryDate: _calculatedExpiryDate,
          applianceId: appliance.id,
        );
        await reminderController.addReminder(reminder);
      }
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingAppliance != null
              ? 'Appliance updated successfully!'
              : 'Appliance added to household!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (applianceController.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(applianceController.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAppliance != null;
    final applianceController = context.watch<ApplianceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Appliance' : 'Add Appliance'),
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
                      Text(
                        isEditing ? 'Update Appliance Specs' : 'Register New Household Appliance',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track model specs, warranties, and maintenance logs in one place.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Appliance Name *',
                          hintText: 'e.g. Refrigerator, Washing Machine',
                          prefixIcon: Icon(Icons.kitchen_outlined, color: AppColors.brown),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Brand & Model Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                hintText: 'e.g. Samsung, LG',
                                prefixIcon: Icon(Icons.branding_watermark_outlined, color: AppColors.brown),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Model / Serial #',
                                hintText: 'e.g. RT34M',
                                prefixIcon: Icon(Icons.tag, color: AppColors.brown),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Purchase Date Picker Tile
                      InkWell(
                        onTap: _pickPurchaseDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sand),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppColors.terracotta, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Purchase Date',
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.brown),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Warranty Duration in Months
                      TextFormField(
                        controller: _warrantyMonthsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Warranty Period (Months)',
                          hintText: 'e.g. 12, 24, 36',
                          prefixIcon: Icon(Icons.verified_user_outlined, color: AppColors.brown),
                          suffixText: 'months',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 0) {
                            return 'Enter a valid number of months (>= 0)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Warranty Preview Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sand.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.sand),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: AppColors.terracotta),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Warranty expires on: ${_calculatedExpiryDate.year}-${_calculatedExpiryDate.month.toString().padLeft(2, '0')}-${_calculatedExpiryDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Checkbox for automatic reminder
                      if (!isEditing)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _createWarrantyAlert,
                          activeColor: AppColors.terracotta,
                          title: const Text(
                            'Create automatic warranty reminder alert',
                            style: TextStyle(fontSize: 13, color: AppColors.darkBrown),
                          ),
                          onChanged: (val) {
                            setState(() => _createWarrantyAlert = val ?? false);
                          },
                        ),
                      const SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: applianceController.isLoading ? null : _saveAppliance,
                        child: applianceController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(isEditing ? 'Save Changes' : 'Save Appliance'),
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
