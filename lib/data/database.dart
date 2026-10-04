import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Event kinds stored in [LogEvent.kind].
class EventKind {
  static const formula = 'formula';
  static const breastfeed = 'breastfeed';
  static const diaperWet = 'diaper_wet';
  static const diaperDirty = 'diaper_dirty';
  static const diaperBoth = 'diaper_both';
  static const burp = 'burp';
}

/// A single logged event: feeding, diaper, or burp.
class LogEvent {
  final int id;
  final String kind;
  final DateTime timestamp;
  final int? amountMl;
  final int? durationMin;
  final String? side; // 'left' | 'right'
  final String? note;

  const LogEvent({
    required this.id,
    required this.kind,
    required this.timestamp,
    this.amountMl,
    this.durationMin,
    this.side,
    this.note,
  });

  factory LogEvent.fromRow(Row row) {
    return LogEvent(
      id: row['id'] as int,
      kind: row['kind'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      amountMl: row['amount_ml'] as int?,
      durationMin: row['duration_min'] as int?,
      side: row['side'] as String?,
      note: row['note'] as String?,
    );
  }
}

/// Data for inserting a new log event.
class NewLogEvent {
  final String kind;
  final DateTime timestamp;
  final int? amountMl;
  final int? durationMin;
  final String? side;
  final String? note;

  const NewLogEvent({
    required this.kind,
    required this.timestamp,
    this.amountMl,
    this.durationMin,
    this.side,
    this.note,
  });
}

/// A pediatrician / doctor appointment.
class Appointment {
  final int id;
  final String title;
  final DateTime dateTime;
  final String? notes;
  final bool remindDayBefore;
  final bool remindHourBefore;

  const Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    this.notes,
    this.remindDayBefore = true,
    this.remindHourBefore = true,
  });

  factory Appointment.fromRow(Row row) {
    return Appointment(
      id: row['id'] as int,
      title: row['title'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(row['date_time'] as int),
      notes: row['notes'] as String?,
      remindDayBefore: (row['remind_day_before'] as int) == 1,
      remindHourBefore: (row['remind_hour_before'] as int) == 1,
    );
  }
}

/// Data for inserting/updating an appointment.
class NewAppointment {
  final int? id; // null for insert, set for update
  final String title;
  final DateTime dateTime;
  final String? notes;
  final bool remindDayBefore;
  final bool remindHourBefore;

  const NewAppointment({
    this.id,
    required this.title,
    required this.dateTime,
    this.notes,
    this.remindDayBefore = true,
    this.remindHourBefore = true,
  });
}

/// Local SQLite database (100% on-device, no accounts).
///
/// Uses the `sqlite3` package directly — no code generation needed.
class AppDatabase {
  final Database _db;
  final _eventsController = StreamController<List<LogEvent>>.broadcast();
  final _appointmentsController =
      StreamController<List<Appointment>>.broadcast();

  /// [path] is for tests (e.g. `':memory:'`). If null, opens the app database.
  AppDatabase._(this._db) {
    _createTables();
  }

  /// Opens the app database in the documents directory.
  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'nurture.sqlite'));
    final db = sqlite3.open(file.path);
    return AppDatabase._(db);
  }

  /// Opens an in-memory database (for tests).
  factory AppDatabase.memory() {
    final db = sqlite3.openInMemory();
    return AppDatabase._(db);
  }

  void _createTables() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS log_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        amount_ml INTEGER,
        duration_min INTEGER,
        side TEXT,
        note TEXT
      )
    ''');
    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_log_events_timestamp
      ON log_events (timestamp)
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date_time INTEGER NOT NULL,
        notes TEXT,
        remind_day_before INTEGER NOT NULL DEFAULT 1,
        remind_hour_before INTEGER NOT NULL DEFAULT 1
      )
    ''');
    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_appointments_date_time
      ON appointments (date_time)
    ''');
  }

  void _notifyEvents() {
    // Emit current day's events to listeners
    _eventsController.add(_eventsForDay(DateTime.now()));
  }

  void _notifyAppointments() {
    _appointmentsController.add(_allAppointments());
  }

  // ---- Log events ----

  Future<int> insertEvent(NewLogEvent entry) async {
    final stmt = _db.prepare('''
      INSERT INTO log_events (kind, timestamp, amount_ml, duration_min, side, note)
      VALUES (?, ?, ?, ?, ?, ?)
    ''');
    try {
      stmt.execute([
        entry.kind,
        entry.timestamp.millisecondsSinceEpoch,
        entry.amountMl,
        entry.durationMin,
        entry.side,
        entry.note,
      ]);
      final id = _db.lastInsertRowId;
      _notifyEvents();
      return id;
    } finally {
      stmt.dispose();
    }
  }

  Future<void> deleteEvent(int id) async {
    _db.execute('DELETE FROM log_events WHERE id = ?', [id]);
    _notifyEvents();
  }

  Future<void> updateEvent(LogEvent e) async {
    _db.execute(
      'UPDATE log_events SET kind = ?, timestamp = ?, amount_ml = ?, duration_min = ?, side = ?, note = ? WHERE id = ?',
      [e.kind, e.timestamp.millisecondsSinceEpoch, e.amountMl, e.durationMin, e.side, e.note, e.id],
    );
    _notifyEvents();
  }

  List<LogEvent> _eventsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = _db.select(
      'SELECT * FROM log_events WHERE timestamp >= ? AND timestamp < ? '
      'ORDER BY timestamp DESC',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(LogEvent.fromRow).toList();
  }

  Stream<List<LogEvent>> watchEventsForDay(DateTime day) async* {
    // Emit current value, then updates (filtered to the requested day)
    yield _eventsForDay(day);
    await for (final _ in _eventsController.stream) {
      yield _eventsForDay(day);
    }
  }

  Future<List<LogEvent>> eventsBetween(DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59);
    final rows = _db.select(
      'SELECT * FROM log_events WHERE timestamp >= ? AND timestamp <= ? '
      'ORDER BY timestamp ASC',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(LogEvent.fromRow).toList();
  }

  Stream<List<LogEvent>> watchToday() => watchEventsForDay(DateTime.now());

  Future<LogEvent?> latestFeed() async {
    final rows = _db.select(
      'SELECT * FROM log_events WHERE kind IN (?, ?) '
      'ORDER BY timestamp DESC LIMIT 1',
      [EventKind.formula, EventKind.breastfeed],
    );
    if (rows.isEmpty) return null;
    return LogEvent.fromRow(rows.first);
  }

  // ---- Appointments ----

  Future<int> insertAppointment(NewAppointment entry) async {
    final stmt = _db.prepare('''
      INSERT INTO appointments
        (title, date_time, notes, remind_day_before, remind_hour_before)
      VALUES (?, ?, ?, ?, ?)
    ''');
    try {
      stmt.execute([
        entry.title,
        entry.dateTime.millisecondsSinceEpoch,
        entry.notes,
        entry.remindDayBefore ? 1 : 0,
        entry.remindHourBefore ? 1 : 0,
      ]);
      final id = _db.lastInsertRowId;
      _notifyAppointments();
      return id;
    } finally {
      stmt.dispose();
    }
  }

  Future<void> updateAppointment(NewAppointment entry) async {
    assert(entry.id != null, 'updateAppointment requires an id');
    _db.execute(
      '''
      UPDATE appointments SET
        title = ?, date_time = ?, notes = ?,
        remind_day_before = ?, remind_hour_before = ?
      WHERE id = ?
      ''',
      [
        entry.title,
        entry.dateTime.millisecondsSinceEpoch,
        entry.notes,
        entry.remindDayBefore ? 1 : 0,
        entry.remindHourBefore ? 1 : 0,
        entry.id,
      ],
    );
    _notifyAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    _db.execute('DELETE FROM appointments WHERE id = ?', [id]);
    _notifyAppointments();
  }

  List<Appointment> _allAppointments() {
    final rows = _db.select(
      'SELECT * FROM appointments ORDER BY date_time ASC',
    );
    return rows.map(Appointment.fromRow).toList();
  }

  Stream<List<Appointment>> watchAppointments() async* {
    yield _allAppointments();
    await for (final list in _appointmentsController.stream) {
      yield list;
    }
  }

  Future<List<Appointment>> upcomingAppointments() async {
    final now =
        DateTime.now().subtract(const Duration(minutes: 5));
    final rows = _db.select(
      'SELECT * FROM appointments WHERE date_time >= ? ORDER BY date_time ASC',
      [now.millisecondsSinceEpoch],
    );
    return rows.map(Appointment.fromRow).toList();
  }

  Future<void> close() async {
    await _eventsController.close();
    await _appointmentsController.close();
    _db.dispose();
  }
}
