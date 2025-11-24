import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/maintenance_model.dart';
import '../models/sensor_data_model.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';
import 'package:uuid/uuid.dart';

class FirebaseDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ========== Vehicle Operations ==========

  // Get vehicle by ID
  Future<VehicleModel?> getVehicle(String vehicleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicleId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return VehicleModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vehicle data: ${e.toString()}');
    }
  }

  // Get vehicle by owner ID
  Future<VehicleModel?> getVehicleByOwner(String ownerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.vehiclesCollection)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data is Map<String, dynamic>) {
          return VehicleModel.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vehicle data: ${e.toString()}');
    }
  }

  // Get all vehicles (for admin)
  Stream<List<VehicleModel>> getAllVehicles() {
    return _firestore
        .collection(AppConstants.vehiclesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data is Map<String, dynamic>) {
                return VehicleModel.fromMap(data);
              }
              throw Exception('Invalid vehicle data');
            })
            .toList());
  }

  // Create or update vehicle
  Future<void> saveVehicle(VehicleModel vehicle) async {
    try {
      await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(vehicle.id)
          .set(vehicle.toMap());
    } catch (e) {
      throw Exception('Error saving vehicle data: ${e.toString()}');
    }
  }

  // ========== Maintenance Operations ==========

  // Get maintenance records for a vehicle
  Stream<List<MaintenanceModel>> getMaintenanceRecords(String vehicleId) {
    return _firestore
        .collection(AppConstants.maintenanceCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data is Map<String, dynamic>) {
                return MaintenanceModel.fromMap(data);
              }
              throw Exception('Invalid maintenance data');
            })
            .toList());
  }

  // Add maintenance record
  Future<void> addMaintenanceRecord(MaintenanceModel maintenance) async {
    try {
      await _firestore
          .collection(AppConstants.maintenanceCollection)
          .doc(maintenance.id)
          .set(maintenance.toMap());

      // Update vehicle's last maintenance info
      await _firestore
          .collection(AppConstants.vehiclesCollection)
          .doc(maintenance.vehicleId)
          .update({
        'lastMaintenanceDate': maintenance.date.toIso8601String(),
        'lastMaintenanceMileage': maintenance.mileage,
      });
    } catch (e) {
      throw Exception('Error adding maintenance record: ${e.toString()}');
    }
  }

  // Update maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceModel maintenance) async {
    try {
      await _firestore
          .collection(AppConstants.maintenanceCollection)
          .doc(maintenance.id)
          .update(maintenance.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Error updating maintenance record: ${e.toString()}');
    }
  }

  // Delete maintenance record
  Future<void> deleteMaintenanceRecord(String maintenanceId) async {
    try {
      await _firestore
          .collection(AppConstants.maintenanceCollection)
          .doc(maintenanceId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting maintenance record: ${e.toString()}');
    }
  }

  // ========== Sensor Data Operations ==========

  // Get latest sensor data for a vehicle
  Stream<SensorDataModel?> getLatestSensorData(String vehicleId) {
    return _firestore
        .collection(AppConstants.sensorDataCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Sort in memory to avoid index requirement
        final sortedDocs = snapshot.docs.toList()
          ..sort((a, b) {
            final aTimestamp = a.data()['timestamp'] as String?;
            final bTimestamp = b.data()['timestamp'] as String?;
            if (aTimestamp == null || bTimestamp == null) return 0;
            return DateTime.parse(bTimestamp).compareTo(DateTime.parse(aTimestamp));
          });
        
        final data = sortedDocs.first.data();
        return SensorDataModel.fromMap(data);
      }
      return null;
    }).handleError((error) {
      print('Error getting latest sensor data: $error');
      return null;
    });
  }

  // Get sensor data history
  Stream<List<SensorDataModel>> getSensorDataHistory(
      String vehicleId, int limit) {
    return _firestore
        .collection(AppConstants.sensorDataCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
          // Sort in memory to avoid index requirement
          final sortedDocs = snapshot.docs.toList()
            ..sort((a, b) {
              final aTimestamp = a.data()['timestamp'] as String?;
              final bTimestamp = b.data()['timestamp'] as String?;
              if (aTimestamp == null || bTimestamp == null) return 0;
              return DateTime.parse(bTimestamp).compareTo(DateTime.parse(aTimestamp));
            });
          
          return sortedDocs
              .take(limit)
              .map((doc) => SensorDataModel.fromMap(doc.data()))
              .toList();
        }).handleError((error) {
          print('Error getting sensor data history: $error');
          return <SensorDataModel>[];
        });
  }

  // Add sensor data (typically called by IoT device)
  Future<void> addSensorData(SensorDataModel sensorData) async {
    try {
      await _firestore
          .collection(AppConstants.sensorDataCollection)
          .doc(sensorData.id)
          .set(sensorData.toMap());
    } catch (e) {
      throw Exception('Error saving sensor data: ${e.toString()}');
    }
  }

  // ========== Notification Operations ==========

  // Get notifications for a user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('📬 Notifications snapshot: ${snapshot.docs.length} documents for userId: $userId');
          // Sort in memory instead of using orderBy to avoid index requirement
          final notifications = snapshot.docs
              .map((doc) {
                final data = doc.data();
                if (data is Map<String, dynamic>) {
                  return NotificationModel.fromMap(data);
                }
                throw Exception('Invalid notification data');
              })
              .toList();
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          print('📬 Processed ${notifications.length} notifications');
          return notifications;
        }).handleError((error) {
          print('❌ Error getting notifications: $error');
          return <NotificationModel>[];
        });
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Add notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      print('📤 Adding notification: ${notification.id} for userId: ${notification.userId}');
      print('📤 Notification title: ${notification.title}');
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());
      print('✅ Notification added successfully');
    } catch (e) {
      print('❌ Error adding notification: $e');
      throw Exception('Error adding notification: ${e.toString()}');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error updating notification status: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      throw Exception('Error updating notifications status: ${e.toString()}');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting notification: ${e.toString()}');
    }
  }

  // Helper to generate ID
  String generateId() => _uuid.v4();
}

