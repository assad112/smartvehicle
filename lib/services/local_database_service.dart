import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vehicle_model.dart';
import '../models/maintenance_model.dart';
import '../models/sensor_data_model.dart';
import '../models/notification_model.dart';
import 'package:uuid/uuid.dart';

/// Local database service - works without Firebase
/// Uses SharedPreferences to store data locally
class LocalDatabaseService {
  final Uuid _uuid = const Uuid();
  
  static const String _vehiclesKey = 'vehicles';
  static const String _maintenanceKey = 'maintenance';
  static const String _sensorDataKey = 'sensor_data';
  static const String _notificationsKey = 'notifications';

  // ========== Vehicle Operations ==========

  Future<VehicleModel?> getVehicle(String vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey) ?? '[]';
      final List<dynamic> vehiclesList = json.decode(vehiclesJson);
      
      for (var vehicleMap in vehiclesList) {
        final vehicle = VehicleModel.fromMap(vehicleMap as Map<String, dynamic>);
        if (vehicle.id == vehicleId) {
          return vehicle;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vehicle data: ${e.toString()}');
    }
  }

  Future<VehicleModel?> getVehicleByOwner(String ownerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey) ?? '[]';
      final List<dynamic> vehiclesList = json.decode(vehiclesJson);
      
      for (var vehicleMap in vehiclesList) {
        final vehicle = VehicleModel.fromMap(vehicleMap as Map<String, dynamic>);
        if (vehicle.ownerId == ownerId) {
          return vehicle;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vehicle data: ${e.toString()}');
    }
  }

  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey) ?? '[]';
      final List<dynamic> vehiclesList = json.decode(vehiclesJson);
      
      return vehiclesList
          .map((v) => VehicleModel.fromMap(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveVehicle(VehicleModel vehicle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey) ?? '[]';
      final List<dynamic> vehiclesList = json.decode(vehiclesJson);
      
      bool found = false;
      for (int i = 0; i < vehiclesList.length; i++) {
        final vehicleMap = vehiclesList[i] as Map<String, dynamic>;
        if (vehicleMap['id'] == vehicle.id) {
          vehiclesList[i] = vehicle.toMap();
          found = true;
          break;
        }
      }
      
      if (!found) {
        vehiclesList.add(vehicle.toMap());
      }
      
      await prefs.setString(_vehiclesKey, json.encode(vehiclesList));
    } catch (e) {
      throw Exception('Error saving vehicle data: ${e.toString()}');
    }
  }

  // ========== Maintenance Operations ==========

  Future<List<MaintenanceModel>> getMaintenanceRecords(String vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maintenanceJson = prefs.getString(_maintenanceKey) ?? '[]';
      final List<dynamic> maintenanceList = json.decode(maintenanceJson);
      
      return maintenanceList
          .where((m) => (m as Map<String, dynamic>)['vehicleId'] == vehicleId)
          .map((m) => MaintenanceModel.fromMap(m as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  Future<void> addMaintenanceRecord(MaintenanceModel maintenance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maintenanceJson = prefs.getString(_maintenanceKey) ?? '[]';
      final List<dynamic> maintenanceList = json.decode(maintenanceJson);
      
      maintenanceList.add(maintenance.toMap());
      await prefs.setString(_maintenanceKey, json.encode(maintenanceList));
      
      // Update vehicle's last maintenance info
      final vehicle = await getVehicle(maintenance.vehicleId);
      if (vehicle != null) {
        await saveVehicle(vehicle.copyWith(
          lastMaintenanceDate: maintenance.date,
          lastMaintenanceMileage: maintenance.mileage,
        ));
      }
    } catch (e) {
      throw Exception('Error adding maintenance record: ${e.toString()}');
    }
  }

  Future<void> updateMaintenanceRecord(MaintenanceModel maintenance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maintenanceJson = prefs.getString(_maintenanceKey) ?? '[]';
      final List<dynamic> maintenanceList = json.decode(maintenanceJson);
      
      for (int i = 0; i < maintenanceList.length; i++) {
        final m = maintenanceList[i] as Map<String, dynamic>;
        if (m['id'] == maintenance.id) {
          maintenanceList[i] = maintenance.copyWith(updatedAt: DateTime.now()).toMap();
          break;
        }
      }
      
      await prefs.setString(_maintenanceKey, json.encode(maintenanceList));
    } catch (e) {
      throw Exception('Error updating maintenance record: ${e.toString()}');
    }
  }

  Future<void> deleteMaintenanceRecord(String maintenanceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maintenanceJson = prefs.getString(_maintenanceKey) ?? '[]';
      final List<dynamic> maintenanceList = json.decode(maintenanceJson);
      
      maintenanceList.removeWhere((m) => (m as Map<String, dynamic>)['id'] == maintenanceId);
      await prefs.setString(_maintenanceKey, json.encode(maintenanceList));
    } catch (e) {
      throw Exception('Error deleting maintenance record: ${e.toString()}');
    }
  }

  // ========== Sensor Data Operations ==========

  Future<SensorDataModel?> getLatestSensorData(String vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sensorDataJson = prefs.getString(_sensorDataKey) ?? '[]';
      final List<dynamic> sensorDataList = json.decode(sensorDataJson);
      
      final vehicleData = sensorDataList
          .where((s) => (s as Map<String, dynamic>)['vehicleId'] == vehicleId)
          .map((s) => SensorDataModel.fromMap(s as Map<String, dynamic>))
          .toList();
      
      if (vehicleData.isEmpty) return null;
      
      vehicleData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return vehicleData.first;
    } catch (e) {
      return null;
    }
  }

  Future<List<SensorDataModel>> getSensorDataHistory(
      String vehicleId, int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sensorDataJson = prefs.getString(_sensorDataKey) ?? '[]';
      final List<dynamic> sensorDataList = json.decode(sensorDataJson);
      
      return sensorDataList
          .where((s) => (s as Map<String, dynamic>)['vehicleId'] == vehicleId)
          .map((s) => SensorDataModel.fromMap(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
        ..take(limit);
    } catch (e) {
      return [];
    }
  }

  Future<void> addSensorData(SensorDataModel sensorData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sensorDataJson = prefs.getString(_sensorDataKey) ?? '[]';
      final List<dynamic> sensorDataList = json.decode(sensorDataJson);
      
      sensorDataList.add(sensorData.toMap());
      await prefs.setString(_sensorDataKey, json.encode(sensorDataList));
    } catch (e) {
      throw Exception('Error saving sensor data: ${e.toString()}');
    }
  }

  // ========== Notification Operations ==========

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      
      return notificationsList
          .where((n) => (n as Map<String, dynamic>)['userId'] == userId)
          .map((n) => NotificationModel.fromMap(n as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final notifications = await getNotifications(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      
      notificationsList.add(notification.toMap());
      await prefs.setString(_notificationsKey, json.encode(notificationsList));
    } catch (e) {
      throw Exception('Error adding notification: ${e.toString()}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      
      for (int i = 0; i < notificationsList.length; i++) {
        final n = notificationsList[i] as Map<String, dynamic>;
        if (n['id'] == notificationId) {
          n['isRead'] = true;
          break;
        }
      }
      
      await prefs.setString(_notificationsKey, json.encode(notificationsList));
    } catch (e) {
      throw Exception('Error updating notification status: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      
      for (var n in notificationsList) {
        final notification = n as Map<String, dynamic>;
        if (notification['userId'] == userId && notification['isRead'] == false) {
          notification['isRead'] = true;
        }
      }
      
      await prefs.setString(_notificationsKey, json.encode(notificationsList));
    } catch (e) {
      throw Exception('Error updating notifications status: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      
      notificationsList.removeWhere((n) => (n as Map<String, dynamic>)['id'] == notificationId);
      await prefs.setString(_notificationsKey, json.encode(notificationsList));
    } catch (e) {
      throw Exception('Error deleting notification: ${e.toString()}');
    }
  }

  String generateId() => _uuid.v4();
}

