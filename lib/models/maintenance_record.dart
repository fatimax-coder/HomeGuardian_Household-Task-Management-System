/// Domain Model: MaintenanceRecord
class MaintenanceRecord {
  final String id;
  final String applianceId;
  final DateTime serviceDate;
  final String description;
  final double cost;
  final String? serviceProvider;
  final DateTime? createdAt;

  MaintenanceRecord({
    required this.id,
    required this.applianceId,
    required this.serviceDate,
    required this.description,
    this.cost = 0.0,
    this.serviceProvider,
    this.createdAt,
  });

  /// Compatibility alias for serviceType
  String get serviceType => description;

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] as String? ?? '',
      applianceId: json['appliance_id'] as String? ?? '',
      serviceDate: json['service_date'] != null
          ? DateTime.tryParse(json['service_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] as String? ??
          json['service_type'] as String? ??
          'General Maintenance',
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : 0.0,
      serviceProvider: json['service_provider'] as String?,
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
      'description': description,
      'cost': cost,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  MaintenanceRecord copyWith({
    String? id,
    String? applianceId,
    DateTime? serviceDate,
    String? description,
    String? serviceType,
    double? cost,
    String? serviceProvider,
    DateTime? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      applianceId: applianceId ?? this.applianceId,
      serviceDate: serviceDate ?? this.serviceDate,
      description: description ?? serviceType ?? this.description,
      cost: cost ?? this.cost,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
