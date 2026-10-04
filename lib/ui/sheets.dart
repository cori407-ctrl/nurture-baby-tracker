import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../utils/units.dart';
import 'widgets.dart';

// ---------------- Formula ----------------

Future<void> showFormulaSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FormulaSheet(),
  );
}

class _FormulaSheet extends ConsumerStatefulWidget {
  const _FormulaSheet();

  @override
  ConsumerState<_FormulaSheet> createState() => _FormulaSheetState();
}

class _FormulaSheetState extends ConsumerState<_FormulaSheet> {
  double? _customOzOrMl; // in display unit

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = ref.watch(unitProvider);
    final lastMl = ref.watch(lastFormulaMlProvider);
    final presets = Units.presets(unit);
    final lastDisplay = Units.mlToDisplay(lastMl, unit);

    Future<void> log(double displayValue) async {
      final ml = Units.displayToMl(displayValue, unit);
      final id = await ref.read(logActionsProvider).logFormula(ml);
      if (context.mounted) {
        Navigator.pop(context);
        showLoggedSnackbar(
            context, '${l10n.loggedBottle} — ${Units.format(ml, unit)}', id,
            onUndo: () => ref.read(logActionsProvider).undoEvent(id));
      }
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.formulaTitle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                // Quick unit toggle right next to the logging field.
                const UnitToggle(compact: true),
              ],
            ),
            const SizedBox(height: 16),
            // One-tap repeat of last amount — the fastest path at 3 AM.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.bolt),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      '${Units.presetLabel(lastDisplay, unit)} — ${l10n.logButton}',
                      style: const TextStyle(fontSize: 18)),
                ),
                onPressed: () => log(lastDisplay),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Text(Units.presetLabel(p, unit),
                          style: const TextStyle(fontSize: 16)),
                    ),
                    selected: false,
                    onSelected: (_) => log(p),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.customAmount,
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: unit == Units.oz ? '2.5' : '75',
                      suffixText:
                          unit == Units.oz ? l10n.unitOzShort : l10n.unitMlShort,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        _customOzOrMl = double.tryParse(v.trim()),
                    onSubmitted: (v) {
                      final val = double.tryParse(v.trim());
                      if (val != null && val > 0) log(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    final v = _customOzOrMl;
                    if (v != null && v > 0) log(v);
                  },
                  child: Text(l10n.logButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Breastfeeding timer ----------------

Future<void> showBreastfeedSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _BreastfeedSheet(),
  );
}

class _BreastfeedSheet extends ConsumerStatefulWidget {
  const _BreastfeedSheet();

  @override
  ConsumerState<_BreastfeedSheet> createState() => _BreastfeedSheetState();
}

class _BreastfeedSheetState extends ConsumerState<_BreastfeedSheet> {
  String _side = 'left';
  DateTime? _startedAt;
  Timer? _ticker;
  int _elapsedSec = 0;
  final _manualCtrl = TextEditingController();

  @override
  void dispose() {
    _ticker?.cancel();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _startedAt = DateTime.now();
      _elapsedSec = 0;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSec++);
    });
  }

  Future<void> _stopAndLog() async {
    _ticker?.cancel();
    final minutes = (_elapsedSec / 60).round().clamp(1, 999);
    final id = await ref
        .read(logActionsProvider)
        .logBreastfeed(minutes, _side);
    if (mounted) {
      Navigator.pop(context);
      final l10n = AppLocalizations.of(context)!;
      showLoggedSnackbar(
          context, '${l10n.loggedNurse} — $minutes ${l10n.minutesLabel}', id,
          onUndo: () => ref.read(logActionsProvider).undoEvent(id));
    }
  }

  String get _elapsedStr {
    final m = _elapsedSec ~/ 60;
    final s = _elapsedSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final running = _startedAt != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.breastfeedTitle,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'left',
                    label: Text(l10n.leftSide),
                    icon: const Icon(Icons.arrow_back)),
                ButtonSegment(
                    value: 'right',
                    label: Text(l10n.rightSide),
                    icon: const Icon(Icons.arrow_forward)),
              ],
              selected: {_side},
              onSelectionChanged: running ? null : (s) => setState(() => _side = s.first),
            ),
            const SizedBox(height: 20),
            Text(_elapsedStr,
                style: const TextStyle(
                    fontSize: 56, fontWeight: FontWeight.w200)),
            Text(running ? l10n.timerRunning : '--:--',
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: running ? _stopAndLog : _start,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                      running ? l10n.stopAndLog : l10n.startTimer,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${l10n.logManual}: ',
                    style: TextStyle(color: Theme.of(context).hintColor)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _manualCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '5',
                      suffixText: l10n.minutesLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    final v = int.tryParse(_manualCtrl.text.trim());
                    if (v == null || v <= 0) return;
                    final id = await ref
                        .read(logActionsProvider)
                        .logBreastfeed(v, _side);
                    if (context.mounted) {
                      Navigator.pop(context);
                      showLoggedSnackbar(context,
                          '${l10n.loggedNurse} — $v ${l10n.minutesLabel}', id,
                          onUndo: () =>
                              ref.read(logActionsProvider).undoEvent(id));
                    }
                  },
                  child: Text(l10n.logButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Burp ----------------

Future<void> showBurpSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (_) => const _BurpSheet(),
  );
}

class _BurpSheet extends ConsumerStatefulWidget {
  const _BurpSheet();

  @override
  ConsumerState<_BurpSheet> createState() => _BurpSheetState();
}

class _BurpSheetState extends ConsumerState<_BurpSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> log({int? minutes}) async {
      final id =
          await ref.read(logActionsProvider).logBurp(minutes: minutes);
      if (context.mounted) {
        Navigator.pop(context);
        showLoggedSnackbar(context, l10n.loggedBurp, id,
            onUndo: () => ref.read(logActionsProvider).undoEvent(id));
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.burpTitle,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l10n.burpOptionalTimer,
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => log(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child:
                      Text(l10n.burpNow, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '3',
                      suffixText: l10n.minutesLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {
                    final v = int.tryParse(_ctrl.text.trim());
                    log(minutes: v != null && v > 0 ? v : null);
                  },
                  child: Text(l10n.logButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Edit existing entry ----------------

/// Opens an edit sheet for an existing log entry (fix a wrong amount, time,
/// side, or diaper kind without delete + re-add).
Future<void> showEditEventSheet(BuildContext context, LogEvent event) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditEventSheet(event: event),
  );
}

class _EditEventSheet extends ConsumerStatefulWidget {
  final LogEvent event;
  const _EditEventSheet({required this.event});

  @override
  ConsumerState<_EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends ConsumerState<_EditEventSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _minutesCtrl;
  late String _side;
  late String _kind;
  late DateTime _timestamp;

  static String _displayNumber(int ml, String unit) {
    final v = Units.mlToDisplay(ml, unit);
    if (unit == Units.oz) {
      return v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
    }
    return '${v.round()}';
  }

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    final unit = ref.read(unitProvider);
    _side = e.side ?? 'left';
    _kind = e.kind;
    _timestamp = e.timestamp;
    _amountCtrl = TextEditingController(
      text: e.kind == EventKind.formula
          ? _displayNumber(e.amountMl ?? 0, unit)
          : '',
    );
    _minutesCtrl = TextEditingController(
      text: e.durationMin != null ? '${e.durationMin}' : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTimestamp() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (time == null) return;
    setState(() {
      _timestamp = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    final e = widget.event;
    final unit = ref.read(unitProvider);
    int? amountMl;
    int? durationMin;
    String? side;

    if (_kind == EventKind.formula) {
      final v = double.tryParse(_amountCtrl.text.trim());
      if (v == null || v <= 0) return; // invalid — keep sheet open
      amountMl = Units.displayToMl(v, unit);
    } else if (_kind == EventKind.breastfeed) {
      final v = int.tryParse(_minutesCtrl.text.trim());
      if (v == null || v <= 0) return;
      durationMin = v;
      side = _side;
    } else if (_kind == EventKind.burp) {
      final v = int.tryParse(_minutesCtrl.text.trim());
      durationMin = (v != null && v > 0) ? v : null;
    }

    final updated = LogEvent(
      id: e.id,
      kind: _kind,
      timestamp: _timestamp,
      amountMl: amountMl,
      durationMin: durationMin,
      side: side,
      note: e.note,
    );
    await ref.read(logActionsProvider).updateEvent(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).entrySaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = ref.watch(unitProvider);
    final isDiaper = _kind == EventKind.diaperWet ||
        _kind == EventKind.diaperDirty ||
        _kind == EventKind.diaperBoth;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.editEntry,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Kind-specific fields.
            if (_kind == EventKind.formula)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        suffixText: unit == Units.oz
                            ? l10n.unitOzShort
                            : l10n.unitMlShort,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
            if (_kind == EventKind.breastfeed) ...[
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'left',
                      label: Text(l10n.leftSide),
                      icon: const Icon(Icons.arrow_back)),
                  ButtonSegment(
                      value: 'right',
                      label: Text(l10n.rightSide),
                      icon: const Icon(Icons.arrow_forward)),
                ],
                selected: {_side},
                onSelectionChanged: (s) => setState(() => _side = s.first),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _minutesCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        suffixText: l10n.minutesLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
            ],
            if (_kind == EventKind.burp)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _minutesCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: '3',
                        suffixText: l10n.minutesLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
            if (isDiaper)
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(l10n.logWet),
                    selected: _kind == EventKind.diaperWet,
                    onSelected: (_) =>
                        setState(() => _kind = EventKind.diaperWet),
                  ),
                  ChoiceChip(
                    label: Text(l10n.logDirty),
                    selected: _kind == EventKind.diaperDirty,
                    onSelected: (_) =>
                        setState(() => _kind = EventKind.diaperDirty),
                  ),
                  ChoiceChip(
                    label: Text(l10n.logBoth),
                    selected: _kind == EventKind.diaperBoth,
                    onSelected: (_) =>
                        setState(() => _kind = EventKind.diaperBoth),
                  ),
                ],
              ),

            const SizedBox(height: 12),
            // Timestamp editor (all kinds).
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(DateFormat('EEE, MMM d · h:mm a').format(_timestamp)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickTimestamp,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(l10n.saveButton,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
