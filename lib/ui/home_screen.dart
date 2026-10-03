import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../utils/units.dart';
import 'sheets.dart';
import 'widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _instantLog(
      BuildContext context, WidgetRef ref, String kind) async {
    final actions = ref.read(logActionsProvider);
    final l10n = AppLocalizations.of(context)!;
    int id;
    String msg;
    switch (kind) {
      case EventKind.diaperWet:
        id = await actions.logDiaper(EventKind.diaperWet);
        msg = l10n.loggedWet;
        break;
      case EventKind.diaperDirty:
        id = await actions.logDiaper(EventKind.diaperDirty);
        msg = l10n.loggedDirty;
        break;
      case EventKind.diaperBoth:
        id = await actions.logDiaper(EventKind.diaperBoth);
        msg = l10n.loggedBoth;
        break;
      default:
        id = await actions.logBurp();
        msg = l10n.loggedBurp;
    }
    if (context.mounted) {
      showLoggedSnackbar(context, msg, id,
          onUndo: () => actions.undoEvent(id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todayAsync = ref.watch(todayEventsProvider);
    final unit = ref.watch(unitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(todayEventsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Today summary strip ----
            todayAsync.when(
              data: (events) => _SummaryStrip(events: events, unit: unit),
              loading: () => const SizedBox(height: 88),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            // ---- Quick-log grid ----
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                QuickLogButton(
                  icon: Icons.baby_changing_station,
                  label: l10n.logBottle,
                  sublabel: l10n.formulaTitle,
                  color: Colors.lightBlue,
                  onTap: () => showFormulaSheet(context),
                ),
                QuickLogButton(
                  icon: Icons.timer_outlined,
                  label: l10n.logBreastfeed,
                  sublabel: l10n.breastfeedTitle,
                  color: Colors.pinkAccent,
                  onTap: () => showBreastfeedSheet(context),
                ),
                QuickLogButton(
                  icon: Icons.water_drop_outlined,
                  label: l10n.logWet,
                  sublabel: l10n.kindWet,
                  color: Colors.teal,
                  onTap: () =>
                      _instantLog(context, ref, EventKind.diaperWet),
                ),
                QuickLogButton(
                  icon: Icons.delete_outline,
                  label: l10n.logDirty,
                  sublabel: l10n.kindDirty,
                  color: Colors.amber.shade700,
                  onTap: () =>
                      _instantLog(context, ref, EventKind.diaperDirty),
                ),
                QuickLogButton(
                  icon: Icons.layers_outlined,
                  label: l10n.logBoth,
                  sublabel: l10n.kindBoth,
                  color: Colors.deepPurpleAccent,
                  onTap: () =>
                      _instantLog(context, ref, EventKind.diaperBoth),
                ),
                QuickLogButton(
                  icon: Icons.air_outlined,
                  label: l10n.logBurp,
                  sublabel: l10n.burpTitle,
                  color: Colors.green,
                  onTap: () => showBurpSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.events, required this.unit});

  final List<LogEvent> events;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    var formulaMl = 0;
    var diapers = 0;
    LogEvent? lastFeed;
    for (final e in events) {
      if (e.kind == EventKind.formula) formulaMl += e.amountMl ?? 0;
      if (e.kind == EventKind.diaperWet ||
          e.kind == EventKind.diaperDirty ||
          e.kind == EventKind.diaperBoth) {
        diapers++;
      }
      if ((e.kind == EventKind.formula ||
              e.kind == EventKind.breastfeed) &&
          lastFeed == null) {
        lastFeed = e; // stream is newest-first
      }
    }

    Widget stat(String label, String value, IconData icon) {
      return Expanded(
        child: Column(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label,
                style:
                    TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            stat(l10n.totalFormulaToday, Units.format(formulaMl, unit),
                Icons.baby_changing_station),
            stat(l10n.diapersToday, '$diapers', Icons.layers_outlined),
            stat(
                l10n.lastFeed,
                lastFeed == null
                    ? l10n.noFeedYet
                    : relativeTime(context, lastFeed.timestamp),
                Icons.schedule),
          ],
        ),
      ),
    );
  }
}
