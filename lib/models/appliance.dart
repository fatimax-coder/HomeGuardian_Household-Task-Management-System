/// Domain Model: Appliance
class Appliance {
  final String id;
  final String householdId;
  final String name;
  final String? brand;
  final String? modelNumber;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? warrantyExpiryDate;
  final String? notes;
  final DateTime? createdAt;

  Appliance({
    required this.id,
    required this.householdId,
    required this.name,
    this.brand,
    this.modelNumber,
    this.purchaseDate,
    this.purchasePrice,
    this.warrantyExpiryDate,
    this.notes,
    this.createdAt,
  });

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
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String? ?? 'Unnamed Appliance',
      brand: json['brand'] as String?,
      modelNumber: json['model_number'] as String?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'] as String)
          : null,
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] as num).toDouble()
          : null,
      warrantyExpiryDate: json['warranty_expiry_date'] != null
          ? DateTime.tryParse(json['warranty_expiry_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'household_id': householdId,
      'name': name,
      if (brand != null) 'brand': brand,
      if (modelNumber != null) 'model_number': modelNumber,
      if (purchaseDate != null)
        'purchase_date': purchaseDate!.toIso8601String().split('T').first,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (warrantyExpiryDate != null)
        'warranty_expiry_date':
            warrantyExpiryDate!.toIso8601String().split('T').first,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Appliance copyWith({
    String? id,
    String? householdId,
    String? name,
    String? brand,
    String? modelNumber,
    DateTime? purchaseDate,
    double? purchasePrice,
    DateTime? warrantyExpiryDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appliance(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      warrantyExpiryDate: warrantyExpiryDate ?? this.warrantyExpiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

