class MaintenanceModel {
  final String id;
  final String vehicleId;
  final String type; // Maintenance type (oil change, brake check, etc.)
  final DateTime date;
  final double cost; // Cost in Omani Rial
  final String? notes; // Optional notes
  final double? mileage; // Vehicle mileage at maintenance time
  final DateTime createdAt;
  final DateTime? updatedAt;

  MaintenanceModel({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    required this.cost,
    this.notes,
    this.mileage,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type,
      'date': date.toIso8601String(),
      'cost': cost,
      'notes': notes,
      'mileage': mileage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MaintenanceModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      type: map['type'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      cost: map['cost']?.toDouble() ?? 0.0,
      notes: map['notes'],
      mileage: map['mileage']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  MaintenanceModel copyWith({
    String? id,
    String? vehicleId,
    String? type,
    DateTime? date,
    double? cost,
    String? notes,
    double? mileage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      mileage: mileage ?? this.mileage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

