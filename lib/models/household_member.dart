import 'user_profile.dart';

/// Domain Model: HouseholdMember
class HouseholdMember {
  final String id;
  final String householdId;
  final String userId;
  final String role; // 'admin' or 'member'
  final DateTime? joinedAt;
  final UserProfile? profile;

  HouseholdMember({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.role,
    this.joinedAt,
    this.profile,
  });

  bool get isAdmin => role == 'admin';

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String)
          : null,
      profile: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'user_id': userId,
      'role': role,
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    };
  }
}
