import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/database.dart';
import 'services/notifications.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Open the local SQLite database.
  final db = await AppDatabase.open();

  // Local notifications (appointment reminders). Best-effort: the app
  // works fine without notification permission.
  try {
    await NotificationService.init();
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const NurtureApp(),
    ),
  );
}
