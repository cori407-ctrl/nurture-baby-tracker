import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../services/pdf_export.dart';
import '../state/providers.dart';
import '../utils/units.dart';
import 'sheets.dart';
import 'widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _day = DateTime.now();

  String _kindLabel(AppLocalizations l10n, String kind) {
    switch (kind) {
      case EventKind.formula:
        return l10n.kindFormula;
      case EventKind.breastfeed:
        return l10n.kindBreastfeed;
      case EventKind.diaperWet:
        return l10n.kindWet;
      case EventKind.diaperDirty:
        return l10n.kindDirty;
      case EventKind.diaperBoth:
        return l10n.kindBoth;
      default:
        return l10n.kindBurp;
    }
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case EventKind.formula:
        return Icons.baby_changing_station;
      case EventKind.breastfeed:
        return Icons.timer_outlined;
      case EventKind.diaperWet:
        return Icons.water_drop_outlined;
      case EventKind.diaperDirty:
        return Icons.delete_outline;
      case EventKind.diaperBoth:
        return Icons.layers_outlined;
      default:
        return Icons.air_outlined;
    }
  }

  String _detail(AppLocalizations l10n, LogEvent e, String unit) {
    switch (e.kind) {
      case EventKind.formula:
        return Units.format(e.amountMl ?? 0, unit);
      case EventKind.breastfeed:
        final side = e.side == 'left'
            ? l10n.leftSide
            : e.side == 'right'
                ? l10n.rightSide
                : '';
        return '${e.durationMin ?? 0} ${l10n.minutesLabel}${side.isEmpty ? '' : ' · $side'}';
      case EventKind.burp:
        return e.durationMin != null
            ? '${e.durationMin} ${l10n.minutesLabel}'
            : '';
      default:
        return '';
    }
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _confirmDelete(LogEvent e) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.noButton)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.deleteButton)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(logActionsProvider).deleteEvent(e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.eventDeleted)));
      }
    }
  }

  Future<void> _exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime from = _day.subtract(const Duration(days: 6));
    DateTime to = _day;
    final range = await showDialog<List<DateTime>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.exportPdf),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.fromDate),
                trailing: Text(DateFormat('MMM d, yyyy').format(from)),
                onTap: () async {
                  final p = await showDatePicker(
                      context: ctx,
                      initialDate: from,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now());
                  if (p != null) {
                    from = p;
                    (ctx as Element).markNeedsBuild();
                  }
                },
              ),
              ListTile(
                title: Text(l10n.toDate),
                trailing: Text(DateFormat('MMM d, yyyy').format(to)),
                onTap: () async {
                  final p = await showDatePicker(
                      context: ctx,
                      initialDate: to,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now());
                  if (p != null) {
                    to = p;
                    (ctx as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancelButton)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, [from, to]),
                child: Text(l10n.generatePdf)),
          ],
        );
      },
    );
    if (range == null) return;
    final db = ref.read(databaseProvider);
    final events = await db.eventsBetween(range[0], range[1]);
    final locale = ref.read(localeProvider).languageCode;
    final unit = ref.read(unitProvider);
    await PdfExport.shareReport(
      events: events,
      from: range[0],
      to: range[1],
      locale: locale,
      unit: unit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(dayEventsProvider(_day));
    final unit = ref.watch(unitProvider);
    final dayLabel = DateFormat('EEEE, MMM d').format(_day);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l10n.exportPdf,
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      setState(() => _day = _day.subtract(const Duration(days: 1))),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(dayLabel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: _pickDay,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      setState(() => _day = _day.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Text(l10n.noEvents,
                        style:
                            TextStyle(color: Theme.of(context).hintColor)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = events[i];
                    final detail = _detail(l10n, e, unit);
                    return Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red),
                      ),
                      confirmDismiss: (_) async {
                        await _confirmDelete(e);
                        return false;
                      },
                      child: ListTile(
                        onTap: () => showEditEventSheet(context, e),
                        leading: Icon(_kindIcon(e.kind),
                            color:
                                Theme.of(context).colorScheme.primary),
                        title: Text(_kindLabel(l10n, e.kind),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: detail.isEmpty ? null : Text(detail),
                        trailing: Text(
                            DateFormat('h:mm a').format(e.timestamp),
                            style: TextStyle(
                                color: Theme.of(context).hintColor)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.4),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }
}
