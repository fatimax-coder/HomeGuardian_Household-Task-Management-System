import '../models/appliance.dart';
import '../models/maintenance_record.dart';
import '../repositories/appliance_repository.dart';
import '../observers/app_event_bus.dart';
import 'base_controller.dart';

/// MVC Controller for Appliances & Maintenance Records
class ApplianceController extends BaseController {
  final IApplianceRepository _repository;

  List<Appliance> _appliances = [];
  Appliance? _selectedAppliance;
  final Map<String, List<MaintenanceRecord>> _recordsByAppliance = {};

  ApplianceController([IApplianceRepository? repository])
      : _repository = repository ?? ApplianceRepository();

  List<Appliance> get appliances => _appliances;

  Appliance? get selectedAppliance => _selectedAppliance;

  int get totalAppliancesCount => _appliances.length;

  List<MaintenanceRecord> getRecords(String applianceId) =>
      _recordsByAppliance[applianceId] ?? [];

  int get expiringWarrantiesCount =>
      _appliances.where((a) => a.isWarrantyActive && a.daysUntilWarrantyExpires <= 30).length;

  void selectAppliance(Appliance? appliance) {
    _selectedAppliance = appliance;
    notifyListeners();
  }

  Future<void> fetchAppliances(String householdId) async {
    setLoading(true);
    try {
      _appliances = await _repository.getAppliances(householdId);
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addAppliance(Appliance appliance) async {
    setLoading(true);
    try {
      final created = await _repository.createAppliance(appliance);
      _appliances.add(created);
      AppEventBus.instance.notify(AppEventType.applianceCreated, created);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateAppliance(Appliance appliance) async {
    setLoading(true);
    try {
      await _repository.updateAppliance(appliance);
      final index = _appliances.indexWhere((a) => a.id == appliance.id);
      if (index != -1) {
        _appliances[index] = appliance;
      }
      if (_selectedAppliance?.id == appliance.id) {
        _selectedAppliance = appliance;
      }
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteAppliance(String applianceId) async {
    setLoading(true);
    try {
      await _repository.deleteAppliance(applianceId);
      _appliances.removeWhere((a) => a.id == applianceId);
      _recordsByAppliance.remove(applianceId);
      if (_selectedAppliance?.id == applianceId) {
        _selectedAppliance = null;
      }
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchMaintenanceRecords(String applianceId) async {
    try {
      final records = await _repository.getMaintenanceRecords(applianceId);
      _recordsByAppliance[applianceId] = records;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<bool> addMaintenanceRecord(MaintenanceRecord record) async {
    setLoading(true);
    try {
      final created = await _repository.addMaintenanceRecord(record);
      final currentList = _recordsByAppliance[record.applianceId] ?? [];
      _recordsByAppliance[record.applianceId] = [created, ...currentList];
      AppEventBus.instance.notify(AppEventType.maintenanceLogged, created);
      clearError();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
