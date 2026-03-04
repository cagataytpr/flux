import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/flux_messages.dart';

// ─── Task Name Constants ────────────────────────────────────────────────────
const String kTaskCheckIn = 'flux_scheduled_checkin';
const String kTaskBillReminder = 'flux_bill_reminder';

/// Provider for the Notification Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialization ─────────────────────────────────────────────────────
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
  }

  // ─── Request Permission (Android 13+) ───────────────────────────────────
  Future<void> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  // ─── 1. Budget Threshold Alert (75%) ────────────────────────────────────
  Future<void> showBudgetThresholdAlert() async {
    final random = Random();
    final message = fluxBudgetAlertMessages[random.nextInt(fluxBudgetAlertMessages.length)];

    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Alerts when your monthly budget crosses a threshold',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'FluxAI Budget',
    );
    const NotificationDetails details = NotificationDetails(android: android);

    await _plugin.show(
      id: 0,
      title: 'DİKKAT! 🚨',
      body: message,
      notificationDetails: details,
      payload: 'budget_threshold',
    );
  }

  // ─── 2. Scheduled Check-in (Every 3 Days) ──────────────────────────────
  Future<void> showCheckInNotification() async {
    final random = Random();
    final message = fluxMessages[random.nextInt(fluxMessages.length)];

    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'checkin_reminders',
      'Check-in Reminders',
      channelDescription: 'Periodic reminders to log your expenses',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'FluxAI Check-in',
    );
    const NotificationDetails details = NotificationDetails(android: android);

    await _plugin.show(
      id: 1,
      title: 'Hey kanka! 👋',
      body: message,
      notificationDetails: details,
      payload: 'checkin',
    );
  }

  // ─── 3. End-of-Month Bill Reminder ──────────────────────────────────────
  Future<void> showBillReminderNotification() async {
    final random = Random();
    final message = fluxBillReminderMessages[random.nextInt(fluxBillReminderMessages.length)];

    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'bill_reminders',
      'Bill Reminders',
      channelDescription: 'Reminders for upcoming subscription bills',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'FluxAI Bills',
    );
    const NotificationDetails details = NotificationDetails(android: android);

    await _plugin.show(
      id: 2,
      title: 'Ay sonu yaklaşıyor! 📅',
      body: message,
      notificationDetails: details,
      payload: 'bill_reminder',
    );
  }

  // ─── Register Background Tasks with Workmanager ────────────────────────
  Future<void> registerPeriodicTasks() async {
    // Scheduled check-in every 3 days (minimum 15 min on Android)
    await Workmanager().registerPeriodicTask(
      'flux-checkin-task',
      kTaskCheckIn,
      frequency: const Duration(days: 3),
      initialDelay: _durationUntilNextOccurrence(hour: 11, minute: 0),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    // Bill reminder: runs daily; the callback checks if we're 5 days from EOM
    await Workmanager().registerPeriodicTask(
      'flux-bill-reminder-task',
      kTaskBillReminder,
      frequency: const Duration(days: 1),
      initialDelay: _durationUntilNextOccurrence(hour: 10, minute: 0),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Calculates the duration from now until the next occurrence of [hour]:[minute].
  Duration _durationUntilNextOccurrence({required int hour, required int minute}) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.difference(now);
  }
}

// ─── Workmanager Top-Level Callback ─────────────────────────────────────────
// This runs in an isolate when the app is closed.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService();
    await notificationService.init();

    switch (task) {
      case kTaskCheckIn:
        await notificationService.showCheckInNotification();
        break;
      case kTaskBillReminder:
        // Only fire if we are within 5 days of end-of-month
        final now = DateTime.now();
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        final daysRemaining = lastDay - now.day;
        if (daysRemaining <= 5) {
          await notificationService.showBillReminderNotification();
        }
        break;
    }
    return Future.value(true);
  });
}
