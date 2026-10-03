import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import '../state/providers.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final apptsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.apptTitle), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.apptAdd),
        onPressed: () => _showEditor(context, ref, null),
      ),
      body: apptsAsync.when(
        data: (appts) {
          if (appts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_outlined,
                      size: 64, color: Theme.of(context).hintColor),
                  const SizedBox(height: 12),
                  Text(l10n.apptEmpty,
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            );
          }
          final now = DateTime.now();
          final upcoming =
              appts.where((a) => a.dateTime.isAfter(now)).toList();
          final past =
              appts.where((a) => !a.dateTime.isAfter(now)).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _sectionHeader(context, l10n.apptUpcoming),
                for (final a in upcoming) _card(context, ref, a),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 8),
                _sectionHeader(context, l10n.apptPast),
                for (final a in past) _card(context, ref, a, dimmed: true),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).hintColor)),
    );
  }

  Widget _card(
      BuildContext context, WidgetRef ref, Appointment a,
      {bool dimmed = false}) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(a.dateTime);
    final timeStr = DateFormat('h:mm a').format(a.dateTime);
    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.local_hospital_outlined),
          title: Text(a.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('$dateStr · $timeStr'
              '${(a.notes?.isNotEmpty ?? false) ? '\n${a.notes}' : ''}'),
          isThreeLine: a.notes?.isNotEmpty ?? false,
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                _showEditor(context, ref, a);
              } else if (v == 'delete') {
                _confirmDelete(context, ref, a);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                  value: 'edit', child: Text(l10n.apptEdit)),
              PopupMenuItem(
                  value: 'delete', child: Text(l10n.apptDelete)),
            ],
          ),
          onTap: () => _showEditor(context, ref, a),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Appointment a) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.apptDelete),
        content: Text(a.title),
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
      await ref.read(logActionsProvider).deleteAppointment(a);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.apptDeleted)));
      }
    }
  }

  Future<void> _showEditor(
      BuildContext context, WidgetRef ref, Appointment? existing) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AppointmentEditor(existing: existing),
    );
  }
}

class _AppointmentEditor extends ConsumerStatefulWidget {
  const _AppointmentEditor({this.existing});

  final Appointment? existing;

  @override
  ConsumerState<_AppointmentEditor> createState() =>
      _AppointmentEditorState();
}

class _AppointmentEditorState
    extends ConsumerState<_AppointmentEditor> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dateTime;
  late bool _dayBefore;
  late bool _hourBefore;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _dateTime = e?.dateTime ??
        DateTime.now().add(const Duration(days: 1)).copyWith(
            hour: 9, minute: 0, second: 0, millisecond: 0);
    _dayBefore = e?.remindDayBefore ?? true;
    _hourBefore = e?.remindHourBefore ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  widget.existing == null ? l10n.apptAdd : l10n.apptEdit,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.apptName,
                  hintText: l10n.apptNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                          '${l10n.apptDate}\n${DateFormat('MMM d, yyyy').format(_dateTime)}',
                          textAlign: TextAlign.center),
                      onPressed: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _dateTime,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                        );
                        if (p != null) {
                          setState(() => _dateTime = DateTime(
                              p.year,
                              p.month,
                              p.day,
                              _dateTime.hour,
                              _dateTime.minute));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: Text(
                          '${l10n.apptTime}\n${DateFormat('h:mm a').format(_dateTime)}',
                          textAlign: TextAlign.center),
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_dateTime),
                        );
                        if (t != null) {
                          setState(() => _dateTime = DateTime(
                              _dateTime.year,
                              _dateTime.month,
                              _dateTime.day,
                              t.hour,
                              t.minute));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.apptNotes,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.apptReminders,
                  style: TextStyle(color: Theme.of(context).hintColor)),
              SwitchListTile(
                title: Text(l10n.apptDayBefore),
                value: _dayBefore,
                onChanged: (v) => setState(() => _dayBefore = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: Text(l10n.apptHourBefore),
                value: _hourBefore,
                onChanged: (v) => setState(() => _hourBefore = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  final title = _titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  await ref.read(logActionsProvider).saveAppointment(
                        id: widget.existing?.id,
                        title: title,
                        dateTime: _dateTime,
                        notes: _notesCtrl.text.trim().isEmpty
                            ? null
                            : _notesCtrl.text.trim(),
                        remindDayBefore: _dayBefore,
                        remindHourBefore: _hourBefore,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.apptSaved)));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child:
                      Text(l10n.saveButton, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
