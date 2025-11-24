class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String maintenanceCollection = 'maintenance';
  static const String sensorDataCollection = 'sensor_data';
  static const String notificationsCollection = 'notifications';
  static const String maintenanceRulesCollection = 'maintenance_rules';
  static const String alertsCollection = 'alerts';

  // Sensor Thresholds
  static const double maxEngineTemperature = 100.0; // Celsius
  static const double minBatteryVoltage = 11.5; // Volts
  static const double minOilPressure = 20.0; // PSI
  static const double minFuelLevel = 10.0; // Percentage
  static const double warningEngineTemperature = 85.0;
  static const double warningBatteryVoltage = 12.0;

  // Maintenance Types
  static const List<String> maintenanceTypes = [
    'Oil Change',
    'Brake Inspection',
    'Tire Inspection',
    'Regular Maintenance',
    'Repair',
    'Filter Replacement',
    'Battery Check',
    'Other Maintenance',
  ];

  // Notification Types
  static const String notificationTypeMaintenance = 'maintenance';
  static const String notificationTypeAlert = 'alert';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeInfo = 'info';

  // Status Types
  static const String statusOK = 'OK';
  static const String statusWarning = 'WARNING';
  static const String statusCritical = 'CRITICAL';

  // Currency
  static const String currency = 'OMR'; // Omani Rial

  // Default Location (Muscat, Oman)
  static const double defaultLatitude = 23.61467025;
  static const double defaultLongitude = 58.58783425;
}

