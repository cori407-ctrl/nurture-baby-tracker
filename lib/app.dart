import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'state/providers.dart';
import 'ui/appointments_screen.dart';
import 'ui/history_screen.dart';
import 'ui/home_screen.dart';
import 'ui/settings_screen.dart';

class NurtureApp extends ConsumerWidget {
  const NurtureApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    const seed = Color(0xFF7FB6A4); // soft sage-teal, calm & nurturing

    ThemeData themed(Brightness b) {
      final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
      return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        brightness: b,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Nurture',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: themed(Brightness.light),
      darkTheme: themed(Brightness.dark),
      home: const _RootTabs(),
    );
  }
}

class _RootTabs extends ConsumerStatefulWidget {
  const _RootTabs();

  @override
  ConsumerState<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends ConsumerState<_RootTabs> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Re-schedule reminders for upcoming appointments on every cold start
    // (covers device reboots, where scheduled notifications are lost).
    Future.microtask(
        () => ref.read(logActionsProvider).rescheduleAll().catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = const [
      HomeScreen(),
      HistoryScreen(),
      AppointmentsScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome),
          NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt),
              label: l10n.navHistory),
          NavigationDestination(
              icon: const Icon(Icons.event_outlined),
              selectedIcon: const Icon(Icons.event),
              label: l10n.navAppointments),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.navSettings),
        ],
      ),
    );
  }
}
