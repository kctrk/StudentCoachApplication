import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showStudyCompletedNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'study_channel',
        'Çalışma Bildirimleri',
        channelDescription: 'Çalışma süresi bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      0,
      'Çalışma tamamlandı 🎉',
      'Harika! Çalışma süreni tamamladın.',
      details,
    );
  }
}
