import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    
    // Get current user's name for more personalized notification
    final String? userName = FirebaseAuth.instance.currentUser?.displayName;
    final String greeting = userName != null ? 'Halo $userName! ' : 'Halo! ';

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
        body: '${greeting}Kendaraan $vehicleName Anda ada jadwal servis 2 hari lagi nih. Jangan lupa ya!',
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
        body: '${greeting}Hari ini saatnya servis untuk $vehicleName. Yuk, ke bengkel sekarang agar performa tetap prima!',
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
        largeIcon: fln.DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Color(0xFF8100D1),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelServiceReminder(int id) async {
    final int safeId = id.abs() % 1000000000;
    await _notificationsPlugin.cancel(id: safeId * 2);
    await _notificationsPlugin.cancel(id: (safeId * 2) + 1);
  }

  /// Reschedule notifications for a specific user from Firestore
  Future<void> rescheduleUserNotifications(String? userId) async {
    if (userId == null) return;

    try {
      // 1. Cancel all first to ensure no duplicates or old data
      await cancelAllNotifications();

      // 2. Fetch upcoming services for this user
      final now = DateTime.now();
      final snapshots = await FirebaseFirestore.instance
          .collection('services')
          .where('userId', isEqualTo: userId)
          .where('nextServiceDate', isGreaterThan: Timestamp.fromDate(now))
          .get();

      if (snapshots.docs.isEmpty) return;

      // Collect unique vehicle IDs to fetch them efficiently
      final vehicleIds = snapshots.docs
          .map((doc) => doc.data()['vehicleId'] as String?)
          .whereType<String>()
          .toSet();

      // Fetch all required vehicles in parallel
      final Map<String, String> vehicleNames = {};
      await Future.wait(vehicleIds.map((vId) async {
        final vehicleDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vId).get();
        if (vehicleDoc.exists) {
          vehicleNames[vId] = (vehicleDoc.data()?['name'] ?? 'Kendaraan') as String;
        }
      }));

      // Schedule all reminders concurrently
      final List<Future<void>> scheduleFutures = [];
      for (var doc in snapshots.docs) {
        final data = doc.data();
        final String docId = doc.id;
        final String? vehicleId = data['vehicleId'];
        final Timestamp? nextServiceTimestamp = data['nextServiceDate'];
        final String? reminderTimeStr = data['reminderTime'];

        if (nextServiceTimestamp != null && vehicleId != null) {
          int hour = 8;
          int minute = 0;

          if (reminderTimeStr != null) {
            final parts = reminderTimeStr.split(':');
            if (parts.length == 2) {
              hour = int.tryParse(parts[0]) ?? 8;
              minute = int.tryParse(parts[1]) ?? 0;
            }
          }

          final vehicleName = vehicleNames[vehicleId] ?? 'Kendaraan';

          scheduleFutures.add(scheduleServiceReminder(
            id: docId.hashCode,
            vehicleName: vehicleName,
            nextServiceDate: nextServiceTimestamp.toDate(),
            hour: hour,
            minute: minute,
          ));
        }
      }
      
      await Future.wait(scheduleFutures);
      debugPrint('Successfully rescheduled ${snapshots.docs.length} notifications for user $userId');
    } catch (e) {
      debugPrint('Error rescheduling notifications: $e');
    }
  }
}
