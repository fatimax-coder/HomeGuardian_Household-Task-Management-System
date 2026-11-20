/// Domain Model: MaintenanceRecord
class MaintenanceRecord {
  final String id;
  final String applianceId;
  final DateTime serviceDate;
  final String serviceType;
  final String? serviceProvider;
  final double cost;
  final String? notes;
  final DateTime? createdAt;

  MaintenanceRecord({
    required this.id,
    required this.applianceId,
    required this.serviceDate,
    required this.serviceType,
    this.serviceProvider,
    this.cost = 0.0,
    this.notes,
    this.createdAt,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] as String,
      applianceId: json['appliance_id'] as String,
      serviceDate: json['service_date'] != null
          ? DateTime.parse(json['service_date'] as String)
          : DateTime.now(),
      serviceType: json['service_type'] as String? ?? 'General Maintenance',
      serviceProvider: json['service_provider'] as String?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : 0.0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'appliance_id': applianceId,
      'service_date': serviceDate.toIso8601String().split('T').first,
      'service_type': serviceType,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      'cost': cost,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

