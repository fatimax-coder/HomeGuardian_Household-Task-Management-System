/// Domain Model: Appliance
class Appliance {
  final String id;
  final String householdId;
  final String name;
  final String? brand;
  final String? model;
  final DateTime? purchaseDate;
  final int warrantyMonths;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appliance({
    required this.id,
    required this.householdId,
    required this.name,
    this.brand,
    this.model,
    this.purchaseDate,
    this.warrantyMonths = 12,
    this.createdAt,
    this.updatedAt,
  });

  /// Alias for backwards compatibility
  String? get modelNumber => model;

  /// Computed warranty expiry date from purchase date and warranty months
  DateTime? get warrantyExpiryDate {
    if (purchaseDate == null) return null;
    return DateTime(
      purchaseDate!.year,
      purchaseDate!.month + warrantyMonths,
      purchaseDate!.day,
    );
  }

  /// Warranty status checks
  bool get isWarrantyActive {
    if (warrantyExpiryDate == null) return false;
    return warrantyExpiryDate!.isAfter(DateTime.now());
  }

  int get daysUntilWarrantyExpires {
    if (warrantyExpiryDate == null) return 0;
    return warrantyExpiryDate!.difference(DateTime.now()).inDays;
  }

  String get warrantyStatus {
    if (warrantyExpiryDate == null) return 'No Warranty';
    final days = daysUntilWarrantyExpires;
    if (days < 0) return 'Expired';
    if (days <= 30) return 'Expiring Soon ($days d)';
    return 'Active ($days d left)';
  }

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      id: json['id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Appliance',
      brand: json['brand'] as String?,
      model: json['model'] as String? ?? json['model_number'] as String?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'] as String)
          : null,
      warrantyMonths: json['warranty_months'] as int? ?? 12,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'household_id': householdId,
      'name': name,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T').first,
      'warranty_months': warrantyMonths,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Appliance copyWith({
    String? id,
    String? householdId,
    String? name,
    String? brand,
    String? model,
    String? modelNumber,
    DateTime? purchaseDate,
    int? warrantyMonths,
    DateTime? warrantyExpiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    int calculatedMonths = warrantyMonths ?? this.warrantyMonths;
    if (warrantyExpiryDate != null && purchaseDate != null) {
      calculatedMonths = ((warrantyExpiryDate.difference(purchaseDate).inDays) / 30).round();
    }

    return Appliance(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? modelNumber ?? this.model,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyMonths: calculatedMonths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
