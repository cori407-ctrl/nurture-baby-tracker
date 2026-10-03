import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurture/app.dart';
import 'package:nurture/data/database.dart';
import 'package:nurture/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget smoke test: the whole app pumps with an in-memory database,
/// all four tabs are reachable, and both locales render.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const NurtureApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home screen renders quick-log buttons', (tester) async {
    await pumpApp(tester);
    expect(find.text('Nurture'), findsOneWidget);
    // 6 quick-log buttons
    expect(find.byType(InkWell), findsWidgets);
  });

  testWidgets('all four tabs are reachable', (tester) async {
    await pumpApp(tester);

    // History tab
    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();
    expect(find.text('Daily log'), findsOneWidget);

    // Appointments tab
    await tester.tap(find.text('Visits'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor visits'), findsOneWidget);

    // Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);

    // Back home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Nurture'), findsOneWidget);
  });

  testWidgets('one-tap diaper log writes to the database', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Wet'));
    await tester.pumpAndSettle();
    final events = await db.eventsBetween(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 1)));
    expect(events.any((e) => e.kind == EventKind.diaperWet), isTrue);
  });

  testWidgets('Spanish locale renders', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', 'es');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const NurtureApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsOneWidget); // navHome in Spanish
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Unidades'), findsOneWidget); // settingsUnits in Spanish
    expect(find.text('Idioma'), findsOneWidget); // settingsLanguage in Spanish
  });
}
