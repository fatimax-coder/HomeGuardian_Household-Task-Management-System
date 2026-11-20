import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton Pattern Implementation: NotificationService
/// Centralizes local and scheduled reminders across supported platforms.
/// Gracefully falls back on Flutter Web without crashing.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes the local notification plugin with Android/iOS settings.
  Future<void> initialize() async {
    if (kIsWeb) {
      // Local hardware notifications are not supported on standard Web;
      // Web utilizes in-app notification banners.
      _isInitialized = true;
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization note: $e');
      _isInitialized = false;
    }
  }

  /// Displays an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('[In-App Notification Alert] $title: $body');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'home_guardian_channel',
      'HomeGuardian Reminders',
      channelDescription: 'Notifications for tasks, warranties, and maintenance',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }
}

