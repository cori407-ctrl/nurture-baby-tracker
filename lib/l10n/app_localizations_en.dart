// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutBody =>
      'Nurture is a free, private newborn tracker. No accounts, no ads, no tracking — your baby\'s data never leaves this phone.';

  @override
  String amountMl(int n) {
    return '$n mL';
  }

  @override
  String get appTitle => 'Nurture';

  @override
  String get apptAdd => 'Add visit';

  @override
  String get apptDate => 'Date';

  @override
  String get apptDayBefore => 'Day before';

  @override
  String get apptDelete => 'Delete visit';

  @override
  String get apptDeleted => 'Visit deleted';

  @override
  String get apptEdit => 'Edit visit';

  @override
  String get apptEmpty => 'No upcoming visits.';

  @override
  String get apptHourBefore => 'Hour before';

  @override
  String get apptName => 'Visit name';

  @override
  String get apptNameHint => 'e.g. Pediatrician checkup';

  @override
  String get apptNotes => 'Notes (optional)';

  @override
  String get apptPast => 'Past';

  @override
  String get apptReminders => 'Reminders';

  @override
  String get apptSaved => 'Visit saved';

  @override
  String get apptTime => 'Time';

  @override
  String get apptTitle => 'Doctor visits';

  @override
  String get apptUpcoming => 'Upcoming';

  @override
  String get breastfeedTitle => 'Nursing timer';

  @override
  String get burpNow => 'Log burp now';

  @override
  String get burpOptionalTimer => 'Optional: time it';

  @override
  String get burpTitle => 'Burp';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get closeButton => 'Close';

  @override
  String get confirmDeleteBody => 'This entry will be removed.';

  @override
  String get confirmDeleteTitle => 'Delete entry?';

  @override
  String get customAmount => 'Custom';

  @override
  String get deleteButton => 'Delete';

  @override
  String get diapersToday => 'Diapers today';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get entrySaved => 'Entry updated';

  @override
  String get eventDeleted => 'Entry deleted';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get formulaTitle => 'Log bottle';

  @override
  String get fromDate => 'From';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get historyTitle => 'Daily log';

  @override
  String hoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String get justNow => 'just now';

  @override
  String get kindBoth => 'Wet + dirty';

  @override
  String get kindBreastfeed => 'Nursing';

  @override
  String get kindBurp => 'Burp';

  @override
  String get kindDirty => 'Dirty diaper';

  @override
  String get kindFormula => 'Bottle';

  @override
  String get kindWet => 'Wet diaper';

  @override
  String get lastFeed => 'Last feed';

  @override
  String get leftSide => 'Left';

  @override
  String get logBoth => 'Both';

  @override
  String get logBottle => 'Bottle';

  @override
  String get logBreastfeed => 'Nurse';

  @override
  String get logBurp => 'Burp';

  @override
  String get logButton => 'Log';

  @override
  String get logDirty => 'Dirty';

  @override
  String get logManual => 'Or log manually';

  @override
  String get logWet => 'Wet';

  @override
  String get loggedBoth => 'Diaper logged';

  @override
  String get loggedBottle => 'Bottle logged';

  @override
  String get loggedBurp => 'Burp logged';

  @override
  String get loggedDirty => 'Dirty diaper logged';

  @override
  String get loggedNurse => 'Nursing logged';

  @override
  String get loggedWet => 'Wet diaper logged';

  @override
  String minutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String get minutesLabel => 'minutes';

  @override
  String get navAppointments => 'Visits';

  @override
  String get navHistory => 'Log';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get noButton => 'No';

  @override
  String get noEvents => 'Nothing logged this day.';

  @override
  String get noFeedYet => 'No feeds yet';

  @override
  String get notifApptTitle => 'Doctor visit';

  @override
  String notifDayBefore(String time, String title) {
    return 'Tomorrow: $title at $time';
  }

  @override
  String notifHourBefore(String title) {
    return 'In one hour: $title';
  }

  @override
  String get pdfBurps => 'Burps';

  @override
  String get pdfDetails => 'Details';

  @override
  String get pdfDirtyDiapers => 'Dirty diapers';

  @override
  String pdfGeneratedOn(String date) {
    return 'Generated $date';
  }

  @override
  String get pdfNursingMinutes => 'Nursing minutes';

  @override
  String get pdfNursingSessions => 'Nursing sessions';

  @override
  String get pdfRange => 'Date range';

  @override
  String get pdfTime => 'Time';

  @override
  String get pdfTitle => 'Feeding Diary Report';

  @override
  String get pdfTotalFormula => 'Total formula';

  @override
  String get pdfTotals => 'Totals';

  @override
  String get pdfType => 'Type';

  @override
  String get pdfWetDiapers => 'Wet diapers';

  @override
  String get pickDate => 'Pick a day';

  @override
  String get rightSide => 'Right';

  @override
  String get saveButton => 'Save';

  @override
  String get settingsAbout => 'About Nurture';

  @override
  String get settingsExport => 'Export data (PDF)';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsVersion => 'Version';

  @override
  String get startTimer => 'Start';

  @override
  String get stopAndLog => 'Stop & log';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get timerRunning => 'Timing…';

  @override
  String get toDate => 'To';

  @override
  String get today => 'Today';

  @override
  String get totalFormulaToday => 'Formula today';

  @override
  String get undo => 'Undo';

  @override
  String get yesButton => 'Yes';

  @override
  String get settingsUnits => 'Units';

  @override
  String get unitMilliliters => 'Milliliters (mL)';

  @override
  String get unitFluidOunces => 'Fluid ounces (oz)';

  @override
  String get unitMlShort => 'mL';

  @override
  String get unitOzShort => 'oz';

  @override
  String amountOz(Object n) {
    return '$n oz';
  }
}
