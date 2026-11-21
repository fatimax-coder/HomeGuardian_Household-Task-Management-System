import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/household.dart';
import '../models/household_member.dart';
import '../services/supabase_service.dart';

abstract class IHouseholdRepository {
  Future<List<Household>> getUserHouseholds();
  Future<Household> createHousehold({required String name});
  Future<Household> joinHousehold({required String inviteCode});
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId);
  Future<HouseholdMember> addMemberByName({
    required String householdId,
    required String name,
  });
  Future<void> removeMember(String memberId);
}

/// Repository Pattern Implementation for Household & Members
class HouseholdRepository implements IHouseholdRepository {
  final SupabaseService _service;

  HouseholdRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  /// Generates a strictly 6-character uppercase alphanumeric code matching ^[A-Z0-9]{6}$
  static String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // exclude ambiguous chars like 0/O, 1/I
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Future<List<Household>> getUserHouseholds() async {
    if (!_service.isInitialized) return [];

    try {
      final user = _service.client.auth.currentUser;
      if (user == null) return [];

      // Query households that the current user belongs to via household_members
      final response = await _service.client
          .from('households')
          .select('*, household_members!inner(user_id)')
          .eq('household_members.user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Household.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback: direct select if RLS handles membership
      final response = await _service.client
          .from('households')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Household.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  Future<Household> createHousehold({required String name}) async {
    final user = _service.client.auth.currentUser;
    if (user == null) {
      throw const AuthException('You must be signed in to create a household.');
    }

    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      throw Exception('Household name must be at least 2 characters long.');
    }

    final inviteCode = generateInviteCode();
    final memberName = user.userMetadata?['full_name'] as String? ?? 'Admin';

    try {
      final response = await _service.client
          .from('households')
          .insert({
            'name': trimmedName,
            'invite_code': inviteCode,
            'created_by': user.id,
          })
          .select()
          .single();

      final household = Household.fromJson(response);

      // Automatically add the creator as admin with their member_name
      await _service.client.from('household_members').insert({
        'household_id': household.id,
        'user_id': user.id,
        'member_name': memberName,
        'role': 'admin',
      });

      return household;
    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate key') || e.code == '23505') {
        throw Exception('A household with similar credentials already exists.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to create household: ${e.toString()}');
    }
  }

  @override
  Future<Household> joinHousehold({required String inviteCode}) async {
    final user = _service.client.auth.currentUser;
    if (user == null) {
      throw const AuthException('You must be signed in to join a household.');
    }

    final cleanCode = inviteCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(cleanCode)) {
      throw Exception('Invite code must be exactly 6 alphanumeric characters.');
    }

    try {
      // Call the secure atomic database RPC function
      final rpcResult = await _service.client.rpc(
        'join_household_by_invite_code',
        params: {'code_input': cleanCode},
      );

      final Map<String, dynamic> data =
          (rpcResult is Map<String, dynamic>) ? rpcResult : {};

      final String householdId = data['household_id'] as String? ?? '';
      if (householdId.isEmpty) {
        throw Exception(data['message'] ?? 'Unable to join household.');
      }

      // Fetch the household details
      final householdResponse = await _service.client
          .from('households')
          .select()
          .eq('id', householdId)
          .single();

      return Household.fromJson(householdResponse);
    } on PostgrestException catch (e) {
      if (e.message.contains('No matching household')) {
        throw Exception('Invalid invite code. No household found with code: $cleanCode');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to join household: ${e.toString()}');
    }
  }

  @override
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId) async {
    if (!_service.isInitialized) return [];

    try {
      final response = await _service.client
          .from('household_members')
          .select('*, profiles(*)')
          .eq('household_id', householdId)
          .order('role', ascending: true); // Admins appear first

      return (response as List)
          .map((item) => HouseholdMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load members: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdMember> addMemberByName({
    required String householdId,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Member name cannot be blank.');
    }

    try {
      final response = await _service.client
          .from('household_members')
          .insert({
            'household_id': householdId,
            'user_id': null, // Family member without account
            'member_name': trimmedName,
            'role': 'member',
          })
          .select()
          .single();

      return HouseholdMember.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add family member: ${e.toString()}');
    }
  }

  @override
  Future<void> removeMember(String memberId) async {
    try {
      await _service.client.from('household_members').delete().eq('id', memberId);
    } catch (e) {
      throw Exception('Failed to remove member: ${e.toString()}');
    }
  }
}
