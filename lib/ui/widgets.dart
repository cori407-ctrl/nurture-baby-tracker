import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../services/celebration.dart';
import '../state/providers.dart';
import '../utils/units.dart';

/// A huge, thumb-friendly quick-log button.
class QuickLogButton extends StatelessWidget {
  const QuickLogButton({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: color),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(sublabel,
                  style: TextStyle(
                      fontSize: 13, color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// mL / oz quick toggle. Compact segmented control for use near logging fields.
class UnitToggle extends ConsumerWidget {
  const UnitToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitProvider);
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
            value: Units.ml, label: Text(l10n.unitMlShort)),
        ButtonSegment(
            value: Units.oz, label: Text(l10n.unitOzShort)),
      ],
      selected: {unit},
      onSelectionChanged: (s) =>
          ref.read(unitProvider.notifier).setUnit(s.first),
      style: ButtonStyle(
        visualDensity:
            compact ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}

/// Undo-capable snackbar helper.
/// Also fires the 3am-proof entry celebration (haptic + chime + confetti),
/// since every save in the app goes through here.
void showLoggedSnackbar(BuildContext context, String message, int eventId,
    {VoidCallback? onUndo}) {
  final l10n = AppLocalizations.of(context)!;
  // Celebration first: instant multi-sense confirmation the entry landed.
  Celebration.play(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: onUndo ?? () {},
        ),
      ),
    );
}

/// Relative-time label: "just now", "5 min ago", "2h ago".
String relativeTime(BuildContext context, DateTime when) {
  final l10n = AppLocalizations.of(context)!;
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  return l10n.hoursAgo(diff.inHours);
}
