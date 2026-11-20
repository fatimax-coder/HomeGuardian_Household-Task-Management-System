import '../models/appliance.dart';
import '../models/maintenance_record.dart';
import '../services/supabase_service.dart';

abstract class IApplianceRepository {
  Future<List<Appliance>> getAppliances(String householdId);
  Future<Appliance> createAppliance(Appliance appliance);
  Future<void> updateAppliance(Appliance appliance);
  Future<void> deleteAppliance(String applianceId);
  Future<List<MaintenanceRecord>> getMaintenanceRecords(String applianceId);
  Future<MaintenanceRecord> addMaintenanceRecord(MaintenanceRecord record);
}

/// Repository Pattern Implementation for Appliances & Maintenance Records
class ApplianceRepository implements IApplianceRepository {
  final SupabaseService _service;

  ApplianceRepository([SupabaseService? service])
      : _service = service ?? SupabaseService.instance;

  @override
  Future<List<Appliance>> getAppliances(String householdId) async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('appliances')
        .select()
        .eq('household_id', householdId)
        .order('name');

    return (response as List)
        .map((item) => Appliance.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Appliance> createAppliance(Appliance appliance) async {
    final response = await _service.client
        .from('appliances')
        .insert(appliance.toJson())
        .select()
        .single();

    return Appliance.fromJson(response);
  }

  @override
  Future<void> updateAppliance(Appliance appliance) async {
    await _service.client
        .from('appliances')
        .update(appliance.toJson())
        .eq('id', appliance.id);
  }

  @override
  Future<void> deleteAppliance(String applianceId) async {
    await _service.client.from('appliances').delete().eq('id', applianceId);
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords(String applianceId) async {
    if (!_service.isInitialized) return [];

    final response = await _service.client
        .from('maintenance_records')
        .select()
        .eq('appliance_id', applianceId)
        .order('service_date', ascending: false);

    return (response as List)
        .map((item) => MaintenanceRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MaintenanceRecord> addMaintenanceRecord(MaintenanceRecord record) async {
    final response = await _service.client
        .from('maintenance_records')
        .insert(record.toJson())
        .select()
        .single();

    return MaintenanceRecord.fromJson(response);
  }
}
