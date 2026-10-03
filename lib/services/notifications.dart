import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local-only appointment reminders. No server, no push — everything
/// is scheduled on-device.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Fall back to UTC if the device timezone can't be resolved.
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Android 13+ runtime permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static const _androidDetails = AndroidNotificationDetails(
    'nurture_appointments',
    'Doctor visits',
    channelDescription: 'Reminders for pediatrician appointments',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _iosDetails = DarwinNotificationDetails();
  static const _details =
      NotificationDetails(android: _androidDetails, iOS: _iosDetails);

  /// Notification IDs: appointment id * 10 + slot (1 = day-before, 2 = hour-before).
  static int _idFor(int appointmentId, int slot) => appointmentId * 10 + slot;

  static String _locale() {
    // Best-effort sync read is not possible; the caller passes prefs.
    return 'en';
  }

  static String _dayBeforeBody(String locale, String title, String time) =>
      locale == 'es' ? 'Mañana: $title a las $time' : 'Tomorrow: $title at $time';

  static String _hourBeforeBody(String locale, String title) =>
      locale == 'es' ? 'En una hora: $title' : 'In one hour: $title';

  static Future<void> scheduleForAppointment({
    required int id,
    required String title,
    required DateTime dateTime,
    required bool remindDayBefore,
    required bool remindHourBefore,
    String? localeOverride,
  }) async {
    await cancelForAppointment(id);
    String locale = localeOverride ?? _locale();
    try {
      final prefs = await SharedPreferences.getInstance();
      locale = prefs.getString('locale') ?? locale;
    } catch (_) {}
    final now = tz.TZDateTime.now(tz.local);

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (remindDayBefore) {
      final when = tz.TZDateTime.from(
          dateTime.subtract(const Duration(days: 1)), tz.local);
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          _idFor(id, 1),
          'Nurture',
          _dayBeforeBody(locale, title, timeStr),
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
    if (remindHourBefore) {
      final when = tz.TZDateTime.from(
          dateTime.subtract(const Duration(hours: 1)), tz.local);
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          _idFor(id, 2),
          'Nurture',
          _hourBeforeBody(locale, title),
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelForAppointment(int appointmentId) async {
    await _plugin.cancel(_idFor(appointmentId, 1));
    await _plugin.cancel(_idFor(appointmentId, 2));
  }

  /// For tests / QC: list pending notification requests.
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
