import '../models/reminder.dart';
import '../services/supabase_service.dart';

abstract class IReminderRepository {
  Future<List<Reminder>> getReminders(String householdId);
  Future<Reminder> createReminder(Reminder reminder);
  Future<void> dismissReminder(String reminderId);
  Future<void> deleteReminder(String reminderId);
}

/// Repository Pattern Implementation for Reminders
class ReminderRepository implements IReminderRepository {
  final SupabaseService _service;

  ReminderRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  @override
  Future<List<Reminder>> getReminders(String householdId) async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('reminders')
        .select()
        .eq('household_id', householdId)
        .order('reminder_date', ascending: true);

    return (response as List)
        .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final response = await _service.client
        .from('reminders')
        .insert(reminder.toJson())
        .select()
        .single();

    return Reminder.fromJson(response);
  }

  @override
  Future<void> dismissReminder(String reminderId) async {
    await _service.client
        .from('reminders')
        .update({
          'is_dismissed': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reminderId);
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    await _service.client.from('reminders').delete().eq('id', reminderId);
  }
}
