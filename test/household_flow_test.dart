import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/household_controller.dart';
import 'package:home_guardian/models/household.dart';
import 'package:home_guardian/models/household_member.dart';
import 'package:home_guardian/repositories/household_repository.dart';

class MockHouseholdRepository implements IHouseholdRepository {
  final List<Household> _households = [];
  final Map<String, List<HouseholdMember>> _members = {};
  bool shouldFail = false;

  @override
  Future<List<Household>> getUserHouseholds() async {
    if (shouldFail) throw Exception('Network error');
    return List.from(_households);
  }

  @override
  Future<Household> createHousehold({required String name}) async {
    if (shouldFail) throw Exception('Database error');
    if (name.trim().length < 2) {
      throw Exception('Household name must be at least 2 characters long.');
    }

    final household = Household(
      id: 'h-${_households.length + 1}',
      name: name.trim(),
      inviteCode: 'TEST${_households.length + 1}X',
      createdBy: 'u-admin-1',
      createdAt: DateTime.now(),
    );

    _households.insert(0, household);
    _members[household.id] = [
      HouseholdMember(
        id: 'm-admin',
        householdId: household.id,
        userId: 'u-admin-1',
        memberName: 'Admin User',
        role: 'admin',
      ),
    ];
    return household;
  }

  @override
  Future<Household> joinHousehold({required String inviteCode}) async {
    if (shouldFail) throw Exception('RPC Error');
    final clean = inviteCode.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(clean)) {
      throw Exception('Invite code must be exactly 6 alphanumeric characters.');
    }

    final household = _households.firstWhere(
      (h) => h.inviteCode == clean,
      orElse: () => throw Exception('Invalid invite code. No household found with code: $clean'),
    );

    final currentMembers = _members[household.id] ?? [];
    if (currentMembers.any((m) => m.userId == 'u-joining-user')) {
      throw Exception('Already a member of this household.');
    }

    currentMembers.add(
      HouseholdMember(
        id: 'm-joined',
        householdId: household.id,
        userId: 'u-joining-user',
        memberName: 'New Member',
        role: 'member', // Strictly member role
      ),
    );
    _members[household.id] = currentMembers;
    return household;
  }

  @override
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId) async {
    if (shouldFail) throw Exception('Load error');
    return List.from(_members[householdId] ?? []);
  }

  @override
  Future<HouseholdMember> addMemberByName({
    required String householdId,
    required String name,
  }) async {
    final member = HouseholdMember(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      householdId: householdId,
      userId: null,
      memberName: name,
      role: 'member',
    );
    _members[householdId] = [...(_members[householdId] ?? []), member];
    return member;
  }

  @override
  Future<void> removeMember(String memberId) async {
    for (final key in _members.keys) {
      _members[key]?.removeWhere((m) => m.id == memberId);
    }
  }
}

void main() {
  group('Phase 4C: Household Management & Member Flow Tests', () {
    late MockHouseholdRepository mockRepo;
    late HouseholdController controller;

    setUp(() {
      mockRepo = MockHouseholdRepository();
      controller = HouseholdController(mockRepo);
    });

    test('Household Model serialization and copyWith', () {
      final json = {
        'id': 'h-100',
        'name': 'Pine Ridge Home',
        'invite_code': 'PR100X',
        'created_by': 'u-1',
        'created_at': '2026-11-20T10:00:00Z',
      };

      final household = Household.fromJson(json);
      expect(household.id, 'h-100');
      expect(household.name, 'Pine Ridge Home');
      expect(household.inviteCode, 'PR100X');

      final copy = household.copyWith(name: 'Updated Home');
      expect(copy.name, 'Updated Home');
      expect(copy.inviteCode, 'PR100X');

      final serialized = copy.toJson();
      expect(serialized['name'], 'Updated Home');
      expect(serialized['invite_code'], 'PR100X');
    });

    test('HouseholdMember Model correctly identifies admin vs member and account status', () {
      final admin = HouseholdMember(
        id: '1',
        householdId: 'h-1',
        userId: 'u-1',
        memberName: 'Alice',
        role: 'admin',
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.hasAccount, isTrue);
      expect(admin.displayName, 'Alice');

      final familyMember = HouseholdMember(
        id: '2',
        householdId: 'h-1',
        userId: null,
        memberName: 'Baby Bob',
        role: 'member',
      );
      expect(familyMember.isAdmin, isFalse);
      expect(familyMember.hasAccount, isFalse);
      expect(familyMember.displayEmail, contains('Family Member (No Account)'));
    });

    test('Invite code generator produces valid 6-char alphanumeric strings', () {
      final code = HouseholdRepository.generateInviteCode();
      expect(code.length, 6);
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(code), isTrue);
    });

    test('Household creation adds household and assigns admin role', () async {
      final success = await controller.createHousehold('Sunny Haven');

      expect(success, isTrue);
      expect(controller.selectedHousehold, isNotNull);
      expect(controller.selectedHousehold?.name, 'Sunny Haven');
      expect(controller.lastCreatedInviteCode, isNotNull);
      expect(controller.members.length, 1);
      expect(controller.members.first.role, 'admin');
    });

    test('Joining household with valid invite code succeeds and sets member role', () async {
      // First create household
      await controller.createHousehold('Family Residence');
      final inviteCode = controller.lastCreatedInviteCode!;

      // Second user joins
      final joinController = HouseholdController(mockRepo);
      final success = await joinController.joinHousehold(inviteCode);

      expect(success, isTrue);
      expect(joinController.selectedHousehold?.name, 'Family Residence');
      expect(joinController.members.any((m) => m.role == 'member'), isTrue);
    });

    test('Joining household with invalid format or unknown code throws error', () async {
      // Invalid length
      var success = await controller.joinHousehold('ABC');
      expect(success, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, contains('must be exactly 6 alphanumeric characters'));

      // Unknown 6-digit code
      success = await controller.joinHousehold('XYZ999');
      expect(success, isFalse);
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, contains('Invalid invite code'));
    });

    test('Joining duplicate household is prevented', () async {
      await controller.createHousehold('Cozy Nest');
      final code = controller.lastCreatedInviteCode!;

      final joinController = HouseholdController(mockRepo);
      await joinController.joinHousehold(code);

      // Attempt second join
      final duplicateJoin = await joinController.joinHousehold(code);
      expect(duplicateJoin, isFalse);
      expect(joinController.hasError, isTrue);
      expect(joinController.errorMessage, contains('Already a member'));
    });

    test('Admin can add family members without accounts', () async {
      await controller.createHousehold('Stark Manor');

      // Add unregistered member
      final added = await controller.addFamilyMember('Bran Stark');
      expect(added, isTrue);
      expect(controller.members.any((m) => m.memberName == 'Bran Stark' && !m.hasAccount), isTrue);
    });

    test('Member removal operations update member list', () async {
      await controller.createHousehold('Wayne Manor');
      await controller.addFamilyMember('Alfred');
      expect(controller.members.length, 2);

      final alfred = controller.members.firstWhere((m) => m.memberName == 'Alfred');
      final removed = await controller.removeMember(alfred.id);

      expect(removed, isTrue);
      expect(controller.members.length, 1);
    });
  });
}

