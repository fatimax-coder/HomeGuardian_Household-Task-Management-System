import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/appliance_controller.dart';
import 'package:home_guardian/models/appliance.dart';
import 'package:home_guardian/models/maintenance_record.dart';
import 'package:home_guardian/repositories/appliance_repository.dart';

class MockApplianceRepository implements IApplianceRepository {
  final List<Appliance> _appliances = [];
  final Map<String, List<MaintenanceRecord>> _records = {};

  @override
  Future<List<Appliance>> getAppliances(String householdId) async {
    return List.from(_appliances);
  }

  @override
  Future<Appliance> createAppliance(Appliance appliance) async {
    final created = appliance.copyWith(id: 'app-${_appliances.length + 1}');
    _appliances.add(created);
    return created;
  }

  @override
  Future<void> updateAppliance(Appliance appliance) async {
    final idx = _appliances.indexWhere((a) => a.id == appliance.id);
    if (idx != -1) _appliances[idx] = appliance;
  }

  @override
  Future<void> deleteAppliance(String applianceId) async {
    _appliances.removeWhere((a) => a.id == applianceId);
    _records.remove(applianceId);
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords(String applianceId) async {
    return List.from(_records[applianceId] ?? []);
  }

  @override
  Future<MaintenanceRecord> addMaintenanceRecord(MaintenanceRecord record) async {
    final created = record.copyWith(id: 'rec-${DateTime.now().millisecondsSinceEpoch}');
    final list = _records[record.applianceId] ?? [];
    _records[record.applianceId] = [created, ...list];
    return created;
  }
}

void main() {
  group('Appliance & Maintenance Module Flow Tests', () {
    late MockApplianceRepository mockRepo;
    late ApplianceController controller;

    setUp(() {
      mockRepo = MockApplianceRepository();
      controller = ApplianceController(mockRepo);
    });

    test('Appliance Model computes warranty expiry and status correctly', () {
      final now = DateTime.now();
      final activeAppliance = Appliance(
        id: '1',
        householdId: 'h-1',
        name: 'Refrigerator',
        brand: 'Samsung',
        model: 'RT34',
        purchaseDate: now.subtract(const Duration(days: 30)),
        warrantyMonths: 12,
      );

      expect(activeAppliance.isWarrantyActive, isTrue);
      expect(activeAppliance.warrantyStatus, contains('Active'));

      final expiredAppliance = Appliance(
        id: '2',
        householdId: 'h-1',
        name: 'Old Toaster',
        purchaseDate: DateTime(2020, 1, 1),
        warrantyMonths: 12,
      );
      expect(expiredAppliance.isWarrantyActive, isFalse);
      expect(expiredAppliance.warrantyStatus, 'Expired');
    });

    test('ApplianceController registers appliance and detects expiring warranties', () async {
      final now = DateTime.now();
      // Appliance purchased 11 months and 15 days ago with 12 month warranty -> expiring in ~15 days
      final expiringApp = Appliance(
        id: '',
        householdId: 'h-1',
        name: 'Microwave Oven',
        purchaseDate: DateTime(now.year, now.month - 11, now.day - 15),
        warrantyMonths: 12,
      );

      final added = await controller.addAppliance(expiringApp);
      expect(added, isTrue);
      expect(controller.totalAppliancesCount, 1);
      expect(controller.expiringWarrantiesCount, 1);
    });

    test('ApplianceController logs maintenance records and tracks service history', () async {
      final app = await mockRepo.createAppliance(Appliance(
        id: '',
        householdId: 'h-1',
        name: 'Air Conditioner',
      ));

      final record = MaintenanceRecord(
        id: '',
        applianceId: app.id,
        serviceDate: DateTime.now(),
        description: 'Gas refill and coil cleaning',
        cost: 85.50,
        serviceProvider: 'CoolAir Experts',
      );

      final logged = await controller.addMaintenanceRecord(record);
      expect(logged, isTrue);

      final history = controller.getRecords(app.id);
      expect(history.length, 1);
      expect(history.first.description, 'Gas refill and coil cleaning');
      expect(history.first.cost, 85.50);
      expect(history.first.serviceProvider, 'CoolAir Experts');
    });

    test('ApplianceController updates and deletes appliances', () async {
      await controller.addAppliance(Appliance(
        id: '',
        householdId: 'h-1',
        name: 'Dishwasher',
      ));
      final app = controller.appliances.first;

      final updated = await controller.updateAppliance(app.copyWith(name: 'Bosch Dishwasher'));
      expect(updated, isTrue);
      expect(controller.appliances.first.name, 'Bosch Dishwasher');

      final deleted = await controller.deleteAppliance(app.id);
      expect(deleted, isTrue);
      expect(controller.totalAppliancesCount, 0);
    });
  });
}
