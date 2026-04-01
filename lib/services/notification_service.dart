import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart'; // Added for kIsWeb

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      // Default to Asia/Jakarta for the user's current context (+07:00)
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint('Timezone init error: $e');
      // Fallback to UTC if even that fails
      tz.setLocalLocation(tz.UTC);
    }
    
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse details) {
        // Handle notification tap if needed
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleServiceReminder({
    required int id, // This should be a hash of the docId
    required String vehicleName,
    required DateTime nextServiceDate,
    int hour = 8,
    int minute = 0,
  }) async {
    // Ensure ID is within 32-bit range for Android
    final int safeId = id.abs() % 1000000000;
    
    // Schedule H-2 Reminder (2 days before)
    final h2Date = nextServiceDate.subtract(const Duration(days: 2));
    final nowTz = tz.TZDateTime.now(tz.local);

    final scheduledH2 = tz.TZDateTime.from(
      DateTime(h2Date.year, h2Date.month, h2Date.day, hour, minute),
      tz.local,
    );

    if (scheduledH2.isAfter(nowTz)) {
      await _notificationsPlugin.zonedSchedule(
        id: safeId * 2,
        title: 'Pengingat Servis H-2',
        body: 'Halo! Kendaraan $vehicleName Anda ada jadwal servis 2 hari lagi nih. Jangan lupa ya!',
        scheduledDate: scheduledH2,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    // Schedule H-0 Reminder (Day of service)
    final scheduledH0 = tz.TZDateTime.from(
      DateTime(nextServiceDate.year, nextServiceDate.month, nextServiceDate.day, hour, minute),
      tz.local,
    );

    if (scheduledH0.isAfter(nowTz)) {
      await _notificationsPlugin.zonedSchedule(
        id: (safeId * 2) + 1,
        title: 'Waktunya Servis Hari Ini!',
        body: 'Hari ini saatnya servis untuk $vehicleName. Yuk, ke bengkel sekarang agar performa tetap prima!',
        scheduledDate: scheduledH0,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  fln.NotificationDetails _notificationDetails() {
    return const fln.NotificationDetails(
      android: fln.AndroidNotificationDetails(
        'service_reminders',
        'Service Reminders',
        channelDescription: 'Notifications for upcoming vehicle service schedules',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        ticker: 'ticker',
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
