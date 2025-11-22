import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  bool _isInitialized = false;
  String? _fcmToken;
  final List<NotificationData> _notifications = [];

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;
  List<NotificationData> get notifications => List.unmodifiable(_notifications);

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();
    
    // Request FCM permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      throw Exception('Notification permission denied');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      notifyListeners();
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.info,
  }) async {
    if (!_isInitialized) return;

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'bus_management_channel',
        'Bus Management Notifications',
        channelDescription: 'Notifications for bus management system',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
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
        id,
        title,
        body,
        details,
        payload: payload,
      );

      // Store notification data
      _notifications.add(NotificationData(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
        payload: payload,
      ));

      notifyListeners();
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Show critical alert
  Future<void> showCriticalAlert({
    required String title,
    required String body,
    String? busId,
    String? alertType,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 CRITICAL: $title',
      body: body,
      type: NotificationType.critical,
      payload: 'critical_alert|$busId|$alertType',
    );
  }

  // Show maintenance reminder
  Future<void> showMaintenanceReminder({
    required String busNumber,
    required String maintenanceType,
    required DateTime dueDate,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔧 Maintenance Due',
      body: '$maintenanceType for Bus $busNumber is due on ${_formatDate(dueDate)}',
      type: NotificationType.warning,
      payload: 'maintenance|$busNumber|$maintenanceType',
    );
  }

  // Show location alert
  Future<void> showLocationAlert({
    required String busNumber,
    required String message,
    String? location,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📍 Location Alert',
      body: 'Bus $busNumber: $message${location != null ? ' at $location' : ''}',
      type: NotificationType.info,
      payload: 'location|$busNumber',
    );
  }

  // Show sensor alert
  Future<void> showSensorAlert({
    required String busNumber,
    required String sensorType,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⚡ Sensor Alert',
      body: 'Bus $busNumber - $sensorType: $message',
      type: NotificationType.warning,
      payload: 'sensor|$busNumber|$sensorType',
    );
  }

  // Schedule maintenance notification
  Future<void> scheduleMaintenanceNotification({
    required String busNumber,
    required String maintenanceType,
    required DateTime scheduledTime,
  }) async {
    await _localNotifications.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 1000,
      '🔧 Maintenance Scheduled',
      '$maintenanceType for Bus $busNumber is scheduled for ${_formatDateTime(scheduledTime)}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance_channel',
          'Maintenance Reminders',
          channelDescription: 'Scheduled maintenance notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'maintenance|$busNumber|$maintenanceType',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    final notification = message.notification;
    if (notification != null) {
      showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Bus Management',
        body: notification.body ?? '',
        payload: message.data.toString(),
        type: NotificationType.info,
      );
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    final data = message.data;
    if (data.isNotEmpty) {
      _handleNotificationPayload(data.toString());
    }
  }

  // Handle notification payload
  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate accordingly
    // This would typically involve navigation to specific screens
    debugPrint('Handling notification payload: $payload');
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    _notifications.clear();
    notifyListeners();
  }

  // Clear specific notification
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Get notification count
  int get notificationCount => _notifications.length;

  // Get critical alert count
  int get criticalAlertCount => _notifications.where((n) => n.type == NotificationType.critical).length;

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

// Notification data model
class NotificationData {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final String? payload;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.payload,
  });
}

// Notification types
enum NotificationType {
  info,
  warning,
  critical,
  maintenance,
  location,
  sensor,
}
