# Nurture — Newborn Feeding & Diaper Tracker

A free, no-ads, private newborn tracker for iOS and Android. Built with Flutter.
Replaces the paper "Feeding Diary" chart: log bottles (mL or oz), nursing sessions,
diapers, and burps in under 5 seconds — plus a pediatrician visit calendar with
reminders and PDF reports for the doctor.

**Working title:** Nurture (codename — Cori will pick the final name before store launch).

## Privacy promise
100% local-first. SQLite on-device, no accounts, no signup, no analytics, no ads,
no tracking SDKs. Baby data never leaves the phone.

## Features
- 🍼 Bottle logging: one-tap repeat of last amount, presets, custom entry — **mL or oz** (toggle in Settings or right in the logging sheet; always stored as mL)
- 🤱 Nursing timer with left/right side tracking + manual minute entry
- 💧 One-tap diaper logging: wet / dirty / both
- 🫧 Burp logging (one-tap + optional timer)
- 📅 Appointment calendar with on-device reminder notifications (day-before + hour-before)
- 📄 PDF report for any date range (share/email/print for the pediatrician)
- 🌙 Dark mode by default, huge touch targets, one-thumb 3 AM logging
- 🇪🇸 English / Spanish toggle

## Project layout
```
lib/
  main.dart            # entry point
  app.dart             # MaterialApp, theme, bottom-nav shell
  l10n/                # app_en.arb / app_es.arb (+ generated localizations)
  data/database.dart   # drift (SQLite) tables: LogEvents, Appointments
  state/providers.dart # Riverpod providers, settings, logging actions
  services/
    notifications.dart # local-only appointment reminders
    pdf_export.dart    # pediatrician PDF report builder
  ui/                  # home, sheets (formula/nurse/burp), history, appointments, settings
  utils/units.dart     # mL ⇄ fl oz conversion (stored as mL, displayed per setting)
```

## Setup (Linux build machine)

Prerequisites live under `~/workspace/sdks/` (persistent):
- `flutter/` — Flutter SDK 3.47.6 (stable)
- `jdk-17.0.17+10/` — Temurin JDK 17
- Android SDK cmdline-tools (installed via sdkmanager into `~/workspace/sdks/android-sdk`)

```bash
export FLUTTER=~/workspace/sdks/flutter/bin
export JAVA_HOME=~/workspace/sdks/jdk-17.0.17+10
export ANDROID_SDK_ROOT=~/workspace/sdks/android-sdk
export PATH="$FLUTTER:$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

cd ~/workspace/baby-tracker

# First-time (or after pulling): fetch deps, generate localizations + database code
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# Regenerate launcher icons (after changing assets/icon/)
dart run flutter_launcher_icons

# Static analysis
flutter analyze
```

## Builds

```bash
# Debug APK for on-phone testing (installable directly)
flutter build apk --debug

# Release App Bundle for Google Play upload (needs upload keystore — see HER-STEPS.md)
flutter build appbundle --release
```

Outputs:
- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/bundle/release/app-release.aab`

## iOS
The Xcode project under `ios/` is fully configured and code-complete, but IPAs
cannot be signed on Linux. See `HER-STEPS.md` for the Apple-side checklist
(Apple Developer account + Mac or Codemagic CI).

## Key product decisions
- **Storage unit is always mL.** The oz toggle is display/entry only; conversion is
  `1 fl oz = 29.5735 mL`, rounded to whole mL on save.
- **Notifications are inexact** (`inexactAllowWhileIdle`) — no exact-alarm permission
  needed; reminders may arrive within a few minutes of the target time.
- **Reboot resilience:** reminders are re-scheduled on every cold start.
- **PDF filename:** `nurture-report-YYYYMMDD-YYYYMMDD.pdf`.
