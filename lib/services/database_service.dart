import '../models/vehicle_model.dart';
import '../models/maintenance_model.dart';
import '../models/sensor_data_model.dart';
import '../models/notification_model.dart';
import 'firebase_database_service.dart';

// Using Firebase Database Service
class DatabaseService {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  // ========== Vehicle Operations ==========

  // Get vehicle by ID
  Future<VehicleModel?> getVehicle(String vehicleId) async {
    return await _firebaseDb.getVehicle(vehicleId);
  }

  // Get vehicle by owner ID
  Future<VehicleModel?> getVehicleByOwner(String ownerId) async {
    return await _firebaseDb.getVehicleByOwner(ownerId);
  }

  // Get all vehicles (for admin)
  Stream<List<VehicleModel>> getAllVehicles() {
    return _firebaseDb.getAllVehicles();
  }

  // Create or update vehicle
  Future<void> saveVehicle(VehicleModel vehicle) async {
    return await _firebaseDb.saveVehicle(vehicle);
  }

  // ========== Maintenance Operations ==========

  // Get maintenance records for a vehicle
  Stream<List<MaintenanceModel>> getMaintenanceRecords(String vehicleId) {
    return _firebaseDb.getMaintenanceRecords(vehicleId);
  }

  // Add maintenance record
  Future<void> addMaintenanceRecord(MaintenanceModel maintenance) async {
    return await _firebaseDb.addMaintenanceRecord(maintenance);
  }

  // Update maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceModel maintenance) async {
    return await _firebaseDb.updateMaintenanceRecord(maintenance);
  }

  // Delete maintenance record
  Future<void> deleteMaintenanceRecord(String maintenanceId) async {
    return await _firebaseDb.deleteMaintenanceRecord(maintenanceId);
  }

  // ========== Sensor Data Operations ==========

  // Get latest sensor data for a vehicle
  Stream<SensorDataModel?> getLatestSensorData(String vehicleId) {
    return _firebaseDb.getLatestSensorData(vehicleId);
  }

  // Get sensor data history
  Stream<List<SensorDataModel>> getSensorDataHistory(
    String vehicleId,
    int limit,
  ) {
    return _firebaseDb.getSensorDataHistory(vehicleId, limit);
  }

  // Add sensor data (typically called by IoT device)
  Future<void> addSensorData(SensorDataModel sensorData) async {
    return await _firebaseDb.addSensorData(sensorData);
  }

  // ========== Notification Operations ==========

  // Get notifications for a user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firebaseDb.getNotifications(userId);
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firebaseDb.getUnreadNotificationsCount(userId);
  }

  // Add notification
  Future<void> addNotification(NotificationModel notification) async {
    return await _firebaseDb.addNotification(notification);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    return await _firebaseDb.markNotificationAsRead(notificationId);
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    return await _firebaseDb.markAllNotificationsAsRead(userId);
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    return await _firebaseDb.deleteNotification(notificationId);
  }

  // Helper to generate ID
  String generateId() => _firebaseDb.generateId();
}
