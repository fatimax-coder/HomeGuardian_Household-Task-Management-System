import '../models/task.dart';
import '../services/supabase_service.dart';

abstract class ITaskRepository {
  Future<List<Task>> getTasks(String householdId);
  Future<Task> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> toggleTaskStatus(String taskId, bool isCompleted);
  Future<void> deleteTask(String taskId);
}

/// Repository Pattern Implementation for Tasks
class TaskRepository implements ITaskRepository {
  final SupabaseService _service;

  TaskRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  @override
  Future<List<Task>> getTasks(String householdId) async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('tasks')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final response = await _service.client
        .from('tasks')
        .insert(task.toJson())
        .select()
        .single();

    return Task.fromJson(response);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _service.client
        .from('tasks')
        .update(task.toJson())
        .eq('id', task.id);
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    final user = _service.client.auth.currentUser;
    await _service.client.from('tasks').update({
      'is_completed': isCompleted,
      'completed_by': isCompleted ? user?.id : null,
    }).eq('id', taskId);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _service.client.from('tasks').delete().eq('id', taskId);
  }
}

