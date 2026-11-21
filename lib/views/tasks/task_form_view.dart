import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../controllers/household_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';

/// Screen: TaskFormView
/// Handles creating or updating a household chore/task
class TaskFormView extends StatefulWidget {
  final Task? existingTask;

  const TaskFormView({super.key, this.existingTask});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String _priority = 'medium';
  DateTime? _dueDate;
  String? _assignedMemberId;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'medium';
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _assignedMemberId = task?.assignedMemberId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
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
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
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

    final taskController = context.read<TaskController>();

    final task = Task(
      id: widget.existingTask?.id ?? '',
      householdId: activeHousehold.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      assignedMemberId: _assignedMemberId,
      status: widget.existingTask?.status ?? 'pending',
    );

    bool success;
    if (widget.existingTask != null) {
      success = await taskController.updateTask(task);
    } else {
      success = await taskController.addTask(task);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingTask != null
              ? 'Task updated successfully!'
              : 'New task created!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (taskController.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskController.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    final taskController = context.watch<TaskController>();
    final householdController = context.watch<HouseholdController>();
    final members = householdController.members;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Household Task'),
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
                        isEditing ? 'Update Task Details' : 'Create a Chore or Task',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Assign chores to family members with priority and deadlines.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),

                      // Task Title
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Task Title *',
                          hintText: 'e.g. Clean kitchen counters, Take out recycling',
                          prefixIcon: Icon(Icons.task_alt, color: AppColors.brown),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Title must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add instructions, frequency or reminders...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Dropdown & Member Assignment Row
                      DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority Level',
                          prefixIcon: Icon(Icons.flag_outlined, color: AppColors.brown),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low Priority')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                          DropdownMenuItem(value: 'high', child: Text('High Priority')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Member Assignment Dropdown
                      DropdownButtonFormField<String?>(
                        initialValue: _assignedMemberId,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Family Member',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.brown),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Unassigned (Anyone)'),
                          ),
                          ...members.map((m) => DropdownMenuItem<String?>(
                                value: m.id,
                                child: Text(m.displayName),
                              )),
                        ],
                        onChanged: (val) {
                          setState(() => _assignedMemberId = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due Date Picker
                      InkWell(
                        onTap: _pickDueDate,
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
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppColors.terracotta, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Due Date',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      _dueDate != null
                                          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                                          : 'No Due Date Selected',
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
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: taskController.isLoading ? null : _saveTask,
                        child: taskController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(isEditing ? 'Save Changes' : 'Create Task'),
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
