import 'user_profile.dart';

/// Domain Model: HouseholdMember
/// Supports both:
/// 1. Authenticated users linked to an account (userId != null)
/// 2. Family members added by name without an account (userId == null)
class HouseholdMember {
  final String id;
  final String householdId;
  final String? userId;
  final String memberName;
  final String role; // 'admin' or 'member'
  final DateTime? joinedAt;
  final UserProfile? profile;

  HouseholdMember({
    required this.id,
    required this.householdId,
    this.userId,
    required this.memberName,
    this.role = 'member',
    this.joinedAt,
    this.profile,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get hasAccount => userId != null && userId!.isNotEmpty;

  String get displayName => profile?.fullName ?? memberName;
  String get displayEmail =>
      profile?.email ?? (hasAccount ? '' : 'Family Member (No Account)');

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String?,
      memberName: json['member_name'] as String? ??
          (json['profiles'] != null
              ? (json['profiles']['full_name'] as String? ?? 'Member')
              : 'Member'),
      role: json['role'] as String? ?? 'member',
      joinedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : (json['joined_at'] != null
              ? DateTime.tryParse(json['joined_at'] as String)
              : null),
      profile: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'household_id': householdId,
      if (userId != null) 'user_id': userId,
      'member_name': memberName,
      'role': role,
      if (joinedAt != null) 'created_at': joinedAt!.toIso8601String(),
    };
  }

  HouseholdMember copyWith({
    String? id,
    String? householdId,
    String? userId,
    String? memberName,
    String? role,
    DateTime? joinedAt,
    UserProfile? profile,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      memberName: memberName ?? this.memberName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      profile: profile ?? this.profile,
    );
  }
}
