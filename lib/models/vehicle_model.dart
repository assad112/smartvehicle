class VehicleModel {
  final String id;
  final String plateNumber;
  final String model;
  final int year;
  final String? brand;
  final String? color;
  final double? currentMileage;
  final DateTime? lastMaintenanceDate;
  final double? lastMaintenanceMileage;
  final DateTime createdAt;
  final String? ownerId; // User ID who owns this vehicle

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.year,
    this.brand,
    this.color,
    this.currentMileage,
    this.lastMaintenanceDate,
    this.lastMaintenanceMileage,
    required this.createdAt,
    this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'model': model,
      'year': year,
      'brand': brand,
      'color': color,
      'currentMileage': currentMileage,
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'lastMaintenanceMileage': lastMaintenanceMileage,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      brand: map['brand'],
      color: map['color'],
      currentMileage: map['currentMileage']?.toDouble(),
      lastMaintenanceDate: map['lastMaintenanceDate'] != null
          ? DateTime.parse(map['lastMaintenanceDate'])
          : null,
      lastMaintenanceMileage: map['lastMaintenanceMileage']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      ownerId: map['ownerId'],
    );
  }

  VehicleModel copyWith({
    String? id,
    String? plateNumber,
    String? model,
    int? year,
    String? brand,
    String? color,
    double? currentMileage,
    DateTime? lastMaintenanceDate,
    double? lastMaintenanceMileage,
    DateTime? createdAt,
    String? ownerId,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      model: model ?? this.model,
      year: year ?? this.year,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      currentMileage: currentMileage ?? this.currentMileage,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      lastMaintenanceMileage: lastMaintenanceMileage ?? this.lastMaintenanceMileage,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}

