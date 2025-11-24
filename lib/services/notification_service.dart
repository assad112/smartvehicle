import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'package:uuid/uuid.dart';

// Notification service with Firebase Messaging enabled
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Initialize local notifications
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings();
        const InitializationSettings initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );

        // Get FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('FCM Token: $token');
        }

        // Listen to foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        
        print('✅ Firebase Messaging initialized successfully');
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification
    await showLocalNotification(
      title: message.notification?.title ?? 'New notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  // Handle background message
  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle when app is opened from notification
    print('Background message: ${message.data}');
  }

  // Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smart_vehicle_channel',
      'Smart Vehicle Notifications',
      channelDescription: 'Smart Vehicle System notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      _uuid.v4().hashCode,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Create and save notification to database
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? vehicleId,
    String? maintenanceId,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🔔 NotificationService.createNotification called');
      print('🔔 userId: $userId');
      print('🔔 title: $title');
      print('🔔 message: $message');
      
      NotificationModel notification = NotificationModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        vehicleId: vehicleId,
        maintenanceId: maintenanceId,
        data: data,
      );

      print('🔔 Notification model created with id: ${notification.id}');
      print('🔔 Notification userId: ${notification.userId}');

      // Save to database
      await _databaseService.addNotification(notification);
      print('🔔 Notification saved to database');

      // Show local notification
      await showLocalNotification(
        title: title,
        body: message,
        payload: notification.id,
      );
      print('🔔 Local notification shown');
    } catch (e, stackTrace) {
      print('❌ Error creating notification: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // Create maintenance reminder notification
  Future<void> createMaintenanceReminder({
    required String userId,
    required String vehicleId,
    required String maintenanceType,
    required DateTime dueDate,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Maintenance reminder',
      message: 'The $maintenanceType service is due soon: ${dueDate.toString().split(' ')[0]}',
      type: AppConstants.notificationTypeMaintenance,
      vehicleId: vehicleId,
    );
  }

  // Create alert notification
  Future<void> createAlertNotification({
    required String userId,
    required String vehicleId,
    required String alertMessage,
    required String status,
  }) async {
    await createNotification(
      userId: userId,
      title: status == AppConstants.statusCritical
          ? 'Critical alert!'
          : 'Warning',
      message: alertMessage,
      type: status == AppConstants.statusCritical
          ? AppConstants.notificationTypeAlert
          : AppConstants.notificationTypeWarning,
      vehicleId: vehicleId,
    );
  }
}

// Background message handler - disabled (Firebase not used)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling background message: ${message.messageId}');
// }

