class SensorDataModel {
  final String id;
  final String vehicleId;
  final double? engineTemperature; // Engine temperature
  final double? batteryVoltage; // Battery voltage
  final double? fuelLevel; // Fuel level (0-100%)
  final double? vibrationLevel; // Vibration level
  final double? oilPressure; // Oil pressure
  final String status; // OK, WARNING, CRITICAL
  final DateTime timestamp;
  final double? latitude; // GPS latitude
  final double? longitude;

  SensorDataModel({
    required this.id,
    required this.vehicleId,
    this.engineTemperature,
    this.batteryVoltage,
    this.fuelLevel,
    this.vibrationLevel,
    this.oilPressure,
    this.status = 'OK',
    required this.timestamp,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'engineTemperature': engineTemperature,
      'batteryVoltage': batteryVoltage,
      'fuelLevel': fuelLevel,
      'vibrationLevel': vibrationLevel,
      'oilPressure': oilPressure,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      engineTemperature: map['engineTemperature']?.toDouble(),
      batteryVoltage: map['batteryVoltage']?.toDouble(),
      fuelLevel: map['fuelLevel']?.toDouble(),
      vibrationLevel: map['vibrationLevel']?.toDouble(),
      oilPressure: map['oilPressure']?.toDouble(),
      status: map['status'] ?? 'OK',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  // Helper method to determine status based on sensor values
  String calculateStatus() {
    if (engineTemperature != null && engineTemperature! > 100) return 'CRITICAL';
    if (batteryVoltage != null && batteryVoltage! < 11.5) return 'CRITICAL';
    if (oilPressure != null && oilPressure! < 20) return 'CRITICAL';
    if (fuelLevel != null && fuelLevel! < 10) return 'WARNING';
    if (engineTemperature != null && engineTemperature! > 85) return 'WARNING';
    if (batteryVoltage != null && batteryVoltage! < 12.0) return 'WARNING';
    return 'OK';
  }
}

