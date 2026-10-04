import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../services/notifications.dart';

/// Singleton database (must be overridden in main after async open).
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in main()');
});

/// SharedPreferences instance (overridden in main after init).
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

/// App locale: 'en' or 'es'. Persisted.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs)
      : super(Locale(_prefs.getString('locale') ?? 'en'));

  final SharedPreferences _prefs;

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString('locale', locale.languageCode);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.watch(sharedPrefsProvider));
});

/// Theme mode. Default: dark (3 AM use). Persisted.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs)
      : super(_fromString(_prefs.getString('themeMode')));

  final SharedPreferences _prefs;

  static ThemeMode _fromString(String? s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(
        'themeMode', mode == ThemeMode.light ? 'light' : mode == ThemeMode.system ? 'system' : 'dark');
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(sharedPrefsProvider));
});

/// Display unit for formula amounts: 'ml' or 'oz'. Stored values are always
/// milliliters — this only affects display and entry. Persisted.
class UnitNotifier extends StateNotifier<String> {
  UnitNotifier(this._prefs) : super(_prefs.getString('unit') ?? 'ml');

  final SharedPreferences _prefs;

  Future<void> setUnit(String unit) async {
    state = unit;
    await _prefs.setString('unit', unit);
  }
}

final unitProvider = StateNotifierProvider<UnitNotifier, String>((ref) {
  return UnitNotifier(ref.watch(sharedPrefsProvider));
});

/// Last used formula amount (speeds up repeat logging). Persisted.
final lastFormulaMlProvider = StateProvider<int>((ref) {
  return ref.watch(sharedPrefsProvider).getInt('lastFormulaMl') ?? 60;
});

/// Today's events stream.
final todayEventsProvider = StreamProvider<List<LogEvent>>((ref) {
  return ref.watch(databaseProvider).watchToday();
});

/// Events for a selected day.
final dayEventsProvider =
    StreamProvider.family<List<LogEvent>, DateTime>((ref, day) {
  return ref.watch(databaseProvider).watchEventsForDay(day);
});

/// Appointments stream.
final appointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  return ref.watch(databaseProvider).watchAppointments();
});

/// Logging actions.
final logActionsProvider = Provider<LogActions>((ref) {
  return LogActions(ref);
});

class LogActions {
  LogActions(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  Future<int> logFormula(int ml) async {
    final id = await _db.insertEvent(NewLogEvent(
      kind: EventKind.formula,
      timestamp: DateTime.now(),
      amountMl: ml,
    ));
    _ref.read(lastFormulaMlProvider.notifier).state = ml;
    await _ref.read(sharedPrefsProvider).setInt('lastFormulaMl', ml);
    return id;
  }

  Future<int> logBreastfeed(int minutes, String side) {
    return _db.insertEvent(NewLogEvent(
      kind: EventKind.breastfeed,
      timestamp: DateTime.now(),
      durationMin: minutes,
      side: side,
    ));
  }

  Future<int> logDiaper(String kind) {
    return _db.insertEvent(NewLogEvent(
      kind: kind,
      timestamp: DateTime.now(),
    ));
  }

  Future<int> logBurp({int? minutes}) {
    return _db.insertEvent(NewLogEvent(
      kind: EventKind.burp,
      timestamp: DateTime.now(),
      durationMin: minutes,
    ));
  }

  Future<void> deleteEvent(int id) => _db.deleteEvent(id);

  Future<void> updateEvent(LogEvent e) => _db.updateEvent(e);

  Future<void> undoEvent(int id) => _db.deleteEvent(id);

  // ---- Appointments ----

  Future<int> saveAppointment({
    int? id,
    required String title,
    required DateTime dateTime,
    String? notes,
    required bool remindDayBefore,
    required bool remindHourBefore,
  }) async {
    final entry = NewAppointment(
      id: id,
      title: title,
      dateTime: dateTime,
      notes: notes,
      remindDayBefore: remindDayBefore,
      remindHourBefore: remindHourBefore,
    );
    final int savedId;
    if (id == null) {
      savedId = await _db.insertAppointment(entry);
    } else {
      await _db.updateAppointment(entry);
      savedId = id;
    }
    await NotificationService.scheduleForAppointment(
      id: savedId,
      title: title,
      dateTime: dateTime,
      remindDayBefore: remindDayBefore,
      remindHourBefore: remindHourBefore,
    );
    return savedId;
  }

  Future<void> deleteAppointment(Appointment appt) async {
    await _db.deleteAppointment(appt.id);
    await NotificationService.cancelForAppointment(appt.id);
  }

  /// Re-schedule notifications for all upcoming appointments.
  /// Called on app start (covers device reboots).
  Future<void> rescheduleAll() async {
    final upcoming = await _db.upcomingAppointments();
    for (final a in upcoming) {
      await NotificationService.scheduleForAppointment(
        id: a.id,
        title: a.title,
        dateTime: a.dateTime,
        remindDayBefore: a.remindDayBefore,
        remindHourBefore: a.remindHourBefore,
      );
    }
  }
}
