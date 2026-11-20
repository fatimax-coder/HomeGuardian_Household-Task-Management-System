import '../models/household.dart';
import '../models/household_member.dart';
import '../services/supabase_service.dart';

abstract class IHouseholdRepository {
  Future<List<Household>> getUserHouseholds();
  Future<Household> createHousehold({required String name});
  Future<Household> joinHousehold({required String inviteCode});
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId);
}

/// Repository Pattern Implementation for Household & Members
class HouseholdRepository implements IHouseholdRepository {
  final SupabaseService _service;

  HouseholdRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  @override
  Future<List<Household>> getUserHouseholds() async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('households')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Household.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Household> createHousehold({required String name}) async {
    final user = _service.client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Generate 6-char alphanumeric invite code
    final inviteCode =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6);

    final response = await _service.client
        .from('households')
        .insert({
          'name': name,
          'invite_code': inviteCode,
          'created_by': user.id,
        })
        .select()
        .single();

    final household = Household.fromJson(response);

    // Automatically add creator as admin
    await _service.client.from('household_members').insert({
      'household_id': household.id,
      'user_id': user.id,
      'role': 'admin',
    });

    return household;
  }

  @override
  Future<Household> joinHousehold({required String inviteCode}) async {
    final user = _service.client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _service.client
        .from('households')
        .select()
        .eq('invite_code', inviteCode.trim().toUpperCase())
        .maybeSingle();

    if (response == null) {
      throw Exception('Household not found with invite code: $inviteCode');
    }

    final household = Household.fromJson(response);

    await _service.client.from('household_members').upsert({
      'household_id': household.id,
      'user_id': user.id,
      'role': 'member',
    });

    return household;
  }

  @override
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId) async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('household_members')
        .select('*, profiles(*)')
        .eq('household_id', householdId);

    return (response as List)
        .map((item) => HouseholdMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
