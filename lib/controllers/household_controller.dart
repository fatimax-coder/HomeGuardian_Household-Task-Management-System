import '../models/household.dart';
import '../models/household_member.dart';
import '../repositories/household_repository.dart';
import '../observers/app_event_bus.dart';
import 'base_controller.dart';

/// MVC Controller for Household & Member Management
class HouseholdController extends BaseController {
  final IHouseholdRepository _repository;

  List<Household> _households = [];
  Household? _selectedHousehold;
  List<HouseholdMember> _members = [];

  HouseholdController([IHouseholdRepository? repository])
      : _repository = repository ?? HouseholdRepository();

  List<Household> get households => _households;
  Household? get selectedHousehold => _selectedHousehold;
  List<HouseholdMember> get members => _members;

  void setSelectedHousehold(Household? household) {
    _selectedHousehold = household;
    notifyListeners();
    if (household != null) {
      fetchMembers(household.id);
      AppEventBus.instance.notify(AppEventType.householdChanged, household);
    }
  }

  Future<void> fetchHouseholds() async {
    setLoading(true);
    try {
      _households = await _repository.getUserHouseholds();
      if (_households.isNotEmpty && _selectedHousehold == null) {
        _selectedHousehold = _households.first;
        await fetchMembers(_selectedHousehold!.id);
      }
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createHousehold(String name) async {
    setLoading(true);
    try {
      final newHousehold = await _repository.createHousehold(name: name);
      _households.insert(0, newHousehold);
      setSelectedHousehold(newHousehold);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> joinHousehold(String inviteCode) async {
    setLoading(true);
    try {
      final household = await _repository.joinHousehold(inviteCode: inviteCode);
      _households.add(household);
      setSelectedHousehold(household);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
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
      setError(e.toString());
    }
  }
}

