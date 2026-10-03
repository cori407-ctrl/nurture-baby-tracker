import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../utils/units.dart';
import 'widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final unit = ref.watch(unitProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Language ----
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.settingsLanguage),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'en', label: Text(l10n.settingsLanguageEn)),
                ButtonSegment(
                    value: 'es', label: Text(l10n.settingsLanguageEs)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) => ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(s.first)),
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact),
            ),
          ),
          const Divider(),
          // ---- Units (mL / oz) ----
          ListTile(
            leading: const Icon(Icons.straighten_outlined),
            title: Text(l10n.settingsUnits),
            subtitle: Text(unit == Units.oz
                ? l10n.unitFluidOunces
                : l10n.unitMilliliters),
            trailing: const UnitToggle(compact: true),
          ),
          const Divider(),
          // ---- Theme ----
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.settingsTheme),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.dark, label: Text(l10n.themeDark)),
                ButtonSegment(
                    value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(
                    value: ThemeMode.system, label: Text(l10n.themeSystem)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeProvider.notifier).setTheme(s.first),
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact),
            ),
          ),
          const Divider(),
          // ---- Privacy ----
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacy(context),
          ),
          const Divider(),
          // ---- About ----
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            subtitle: Text('${l10n.settingsVersion} 1.0.0'),
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsPrivacy),
        content: SingleChildScrollView(child: Text(l10n.aboutBody)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.closeButton)),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.appTitle),
        content: Text(l10n.aboutBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.closeButton)),
        ],
      ),
    );
  }
}
