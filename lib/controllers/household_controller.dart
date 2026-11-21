import '../models/household.dart';
import '../models/household_member.dart';
import '../repositories/household_repository.dart';
import '../observers/app_event_bus.dart';
import '../services/supabase_service.dart';
import 'base_controller.dart';

/// MVC Controller for Household & Member Management
class HouseholdController extends BaseController {
  final IHouseholdRepository _repository;

  List<Household> _households = [];
  Household? _selectedHousehold;
  List<HouseholdMember> _members = [];
  String? _lastCreatedInviteCode;
  String? _successMessage;

  HouseholdController([IHouseholdRepository? repository])
      : _repository = repository ?? HouseholdRepository();

  List<Household> get households => _households;
  Household? get selectedHousehold => _selectedHousehold;
  List<HouseholdMember> get members => _members;
  String? get lastCreatedInviteCode => _lastCreatedInviteCode;
  String? get successMessage => _successMessage;

  String? get currentUserId {
    if (!SupabaseService.instance.isInitialized) return null;
    return SupabaseService.instance.client.auth.currentUser?.id;
  }

  /// Returns whether the current user is an Admin of the selected household
  bool get isCurrentAdmin {
    if (_selectedHousehold == null) return false;
    final uid = currentUserId;
    if (uid == null) {
      // Fallback for testing environments without active Supabase session
      return _members.any((m) => m.isAdmin);
    }

    // Direct creator check or member role check
    if (_selectedHousehold!.createdBy == uid) return true;
    return _members.any((m) => m.userId == uid && m.isAdmin);
  }

  /// Current user's role in the active household
  String get currentUserRole {
    if (_selectedHousehold == null) return 'None';
    return isCurrentAdmin ? 'Admin' : 'Member';
  }

  int get totalMembersCount => _members.length;

  void setSelectedHousehold(Household? household) {
    _selectedHousehold = household;
    notifyListeners();
    if (household != null) {
      fetchMembers(household.id);
      AppEventBus.instance.notify(AppEventType.householdChanged, household);
    }
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> fetchHouseholds() async {
    setLoading(true);
    try {
      _households = await _repository.getUserHouseholds();
      if (_households.isNotEmpty) {
        if (_selectedHousehold == null ||
            !_households.any((h) => h.id == _selectedHousehold!.id)) {
          _selectedHousehold = _households.first;
        }
        await fetchMembers(_selectedHousehold!.id);
      } else {
        _selectedHousehold = null;
        _members = [];
      }
      clearError();
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createHousehold(String name) async {
    setLoading(true);
    clearError();
    _successMessage = null;
    try {
      final newHousehold = await _repository.createHousehold(name: name);
      _households.insert(0, newHousehold);
      _lastCreatedInviteCode = newHousehold.inviteCode;
      _successMessage =
          'Household "${newHousehold.name}" created successfully!';
      setSelectedHousehold(newHousehold);
      await fetchMembers(newHousehold.id);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> joinHousehold(String inviteCode) async {
    setLoading(true);
    clearError();
    _successMessage = null;
    try {
      final household = await _repository.joinHousehold(inviteCode: inviteCode);
      if (!_households.any((h) => h.id == household.id)) {
        _households.add(household);
      }
      _successMessage =
          'Successfully joined "${household.name}" as a member!';
      setSelectedHousehold(household);
      await fetchMembers(household.id);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchMembers(String householdId) async {
    try {
      _members = await _repository.getHouseholdMembers(householdId);
      notifyListeners();
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> addFamilyMember(String name) async {
    if (_selectedHousehold == null) return false;
    if (!isCurrentAdmin) {
      setError('Only household admins can add family members.');
      return false;
    }

    setLoading(true);
    try {
      final newMember = await _repository.addMemberByName(
        householdId: _selectedHousehold!.id,
        name: name,
      );
      _members.add(newMember);
      AppEventBus.instance.notify(AppEventType.memberUpdated, newMember);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> removeMember(String memberId) async {
    if (_selectedHousehold == null) return false;
    final target = _members.firstWhere((m) => m.id == memberId,
        orElse: () => HouseholdMember(
            id: '', householdId: '', memberName: '', role: ''));

    // Check permissions
    final isSelf = target.userId == currentUserId;
    if (!isCurrentAdmin && !isSelf) {
      setError('Only household admins can remove other members.');
      return false;
    }

    setLoading(true);
    try {
      await _repository.removeMember(memberId);
      _members.removeWhere((m) => m.id == memberId);
      if (isSelf) {
        // If user removed themselves, refresh household list
        await fetchHouseholds();
      }
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      setLoading(false);
    }
  }
}
