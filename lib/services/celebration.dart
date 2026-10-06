import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 3am-proof entry confirmation.
///
/// A sleep-deprived brain needs more than a "Saved" toast, so every logged
/// entry fires three signals:
///   1. Haptic buzz — felt even with the phone on silent. The most reliable
///      "it saved" signal.
///   2. Soft chime — gentle two-tone pop. Respects the device silent switch,
///      so it never wakes the baby.
///   3. Mini confetti rain — small, tasteful burst from the top of the screen.
///
/// All three are fire-and-forget: a failure in any of them must never block
/// or crash the logging flow.
class Celebration {
  Celebration._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(BuildContext context) async {
    // Confetti + chime first (synchronous — no async gap on context).
    _rain(context);
    _playChime(); // fire and forget
    // Haptic last — instant, silent-mode-proof.
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> _playChime() async {
    try {
      await _player.play(AssetSource('sounds/saved-chime.wav'));
    } catch (_) {
      // Audio is a nice-to-have; a missing codec must not break logging.
    }
  }

  static void _rain(BuildContext context) {
    OverlayState? overlay;
    try {
      overlay = Overlay.of(context, rootOverlay: true);
    } catch (_) {
      return;
    }
    final controller =
        ConfettiController(duration: const Duration(milliseconds: 800));
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirection: pi / 2, // rain downward
            blastDirectionality: BlastDirectionality.directional,
            emissionFrequency: 0.03,
            numberOfParticles: 24,
            gravity: 0.4,
            colors: const [
              Colors.teal,
              Colors.pinkAccent,
              Colors.amber,
              Colors.lightBlue,
              Colors.green,
            ],
          ),
        ),
      ),
    );
    overlay.insert(entry);
    controller.play();
    Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        controller.dispose();
      } catch (_) {}
      try {
        entry.remove();
      } catch (_) {}
    });
  }
}
