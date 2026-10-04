import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Nurture is a free, private newborn tracker. No accounts, no ads, no tracking — your baby\'s data never leaves this phone.'**
  String get aboutBody;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'{n} mL'**
  String amountMl(int n);

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Nurture'**
  String get appTitle;

  /// No description provided for @apptAdd.
  ///
  /// In en, this message translates to:
  /// **'Add visit'**
  String get apptAdd;

  /// No description provided for @apptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get apptDate;

  /// No description provided for @apptDayBefore.
  ///
  /// In en, this message translates to:
  /// **'Day before'**
  String get apptDayBefore;

  /// No description provided for @apptDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete visit'**
  String get apptDelete;

  /// No description provided for @apptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Visit deleted'**
  String get apptDeleted;

  /// No description provided for @apptEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit visit'**
  String get apptEdit;

  /// No description provided for @apptEmpty.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits.'**
  String get apptEmpty;

  /// No description provided for @apptHourBefore.
  ///
  /// In en, this message translates to:
  /// **'Hour before'**
  String get apptHourBefore;

  /// No description provided for @apptName.
  ///
  /// In en, this message translates to:
  /// **'Visit name'**
  String get apptName;

  /// No description provided for @apptNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pediatrician checkup'**
  String get apptNameHint;

  /// No description provided for @apptNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get apptNotes;

  /// No description provided for @apptPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get apptPast;

  /// No description provided for @apptReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get apptReminders;

  /// No description provided for @apptSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit saved'**
  String get apptSaved;

  /// No description provided for @apptTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get apptTime;

  /// No description provided for @apptTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor visits'**
  String get apptTitle;

  /// No description provided for @apptUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get apptUpcoming;

  /// No description provided for @breastfeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nursing timer'**
  String get breastfeedTitle;

  /// No description provided for @burpNow.
  ///
  /// In en, this message translates to:
  /// **'Log burp now'**
  String get burpNow;

  /// No description provided for @burpOptionalTimer.
  ///
  /// In en, this message translates to:
  /// **'Optional: time it'**
  String get burpOptionalTimer;

  /// No description provided for @burpTitle.
  ///
  /// In en, this message translates to:
  /// **'Burp'**
  String get burpTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This entry will be removed.'**
  String get confirmDeleteBody;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get confirmDeleteTitle;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customAmount;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @diapersToday.
  ///
  /// In en, this message translates to:
  /// **'Diapers today'**
  String get diapersToday;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get entrySaved;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get eventDeleted;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @formulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Log bottle'**
  String get formulaTitle;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily log'**
  String get historyTitle;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String hoursAgo(int n);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @kindBoth.
  ///
  /// In en, this message translates to:
  /// **'Wet + dirty'**
  String get kindBoth;

  /// No description provided for @kindBreastfeed.
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get kindBreastfeed;

  /// No description provided for @kindBurp.
  ///
  /// In en, this message translates to:
  /// **'Burp'**
  String get kindBurp;

  /// No description provided for @kindDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty diaper'**
  String get kindDirty;

  /// No description provided for @kindFormula.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get kindFormula;

  /// No description provided for @kindWet.
  ///
  /// In en, this message translates to:
  /// **'Wet diaper'**
  String get kindWet;

  /// No description provided for @lastFeed.
  ///
  /// In en, this message translates to:
  /// **'Last feed'**
  String get lastFeed;

  /// No description provided for @leftSide.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftSide;

  /// No description provided for @logBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get logBoth;

  /// No description provided for @logBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get logBottle;

  /// No description provided for @logBreastfeed.
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get logBreastfeed;

  /// No description provided for @logBurp.
  ///
  /// In en, this message translates to:
  /// **'Burp'**
  String get logBurp;

  /// No description provided for @logButton.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logButton;

  /// No description provided for @logDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get logDirty;

  /// No description provided for @logManual.
  ///
  /// In en, this message translates to:
  /// **'Or log manually'**
  String get logManual;

  /// No description provided for @logWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get logWet;

  /// No description provided for @loggedBoth.
  ///
  /// In en, this message translates to:
  /// **'Diaper logged'**
  String get loggedBoth;

  /// No description provided for @loggedBottle.
  ///
  /// In en, this message translates to:
  /// **'Bottle logged'**
  String get loggedBottle;

  /// No description provided for @loggedBurp.
  ///
  /// In en, this message translates to:
  /// **'Burp logged'**
  String get loggedBurp;

  /// No description provided for @loggedDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty diaper logged'**
  String get loggedDirty;

  /// No description provided for @loggedNurse.
  ///
  /// In en, this message translates to:
  /// **'Nursing logged'**
  String get loggedNurse;

  /// No description provided for @loggedWet.
  ///
  /// In en, this message translates to:
  /// **'Wet diaper logged'**
  String get loggedWet;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String minutesAgo(int n);

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get navAppointments;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get navHistory;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this day.'**
  String get noEvents;

  /// No description provided for @noFeedYet.
  ///
  /// In en, this message translates to:
  /// **'No feeds yet'**
  String get noFeedYet;

  /// No description provided for @notifApptTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit'**
  String get notifApptTitle;

  /// No description provided for @notifDayBefore.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow: {title} at {time}'**
  String notifDayBefore(String time, String title);

  /// No description provided for @notifHourBefore.
  ///
  /// In en, this message translates to:
  /// **'In one hour: {title}'**
  String notifHourBefore(String title);

  /// No description provided for @pdfBurps.
  ///
  /// In en, this message translates to:
  /// **'Burps'**
  String get pdfBurps;

  /// No description provided for @pdfDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get pdfDetails;

  /// No description provided for @pdfDirtyDiapers.
  ///
  /// In en, this message translates to:
  /// **'Dirty diapers'**
  String get pdfDirtyDiapers;

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String pdfGeneratedOn(String date);

  /// No description provided for @pdfNursingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Nursing minutes'**
  String get pdfNursingMinutes;

  /// No description provided for @pdfNursingSessions.
  ///
  /// In en, this message translates to:
  /// **'Nursing sessions'**
  String get pdfNursingSessions;

  /// No description provided for @pdfRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get pdfRange;

  /// No description provided for @pdfTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get pdfTime;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding Diary Report'**
  String get pdfTitle;

  /// No description provided for @pdfTotalFormula.
  ///
  /// In en, this message translates to:
  /// **'Total formula'**
  String get pdfTotalFormula;

  /// No description provided for @pdfTotals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get pdfTotals;

  /// No description provided for @pdfType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pdfType;

  /// No description provided for @pdfWetDiapers.
  ///
  /// In en, this message translates to:
  /// **'Wet diapers'**
  String get pdfWetDiapers;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get pickDate;

  /// No description provided for @rightSide.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get rightSide;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Nurture'**
  String get settingsAbout;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export data (PDF)'**
  String get settingsExport;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageEs;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimer;

  /// No description provided for @stopAndLog.
  ///
  /// In en, this message translates to:
  /// **'Stop & log'**
  String get stopAndLog;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timing…'**
  String get timerRunning;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @totalFormulaToday.
  ///
  /// In en, this message translates to:
  /// **'Formula today'**
  String get totalFormulaToday;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @unitMilliliters.
  ///
  /// In en, this message translates to:
  /// **'Milliliters (mL)'**
  String get unitMilliliters;

  /// No description provided for @unitFluidOunces.
  ///
  /// In en, this message translates to:
  /// **'Fluid ounces (oz)'**
  String get unitFluidOunces;

  /// No description provided for @unitMlShort.
  ///
  /// In en, this message translates to:
  /// **'mL'**
  String get unitMlShort;

  /// No description provided for @unitOzShort.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOzShort;

  /// No description provided for @amountOz.
  ///
  /// In en, this message translates to:
  /// **'{n} oz'**
  String amountOz(Object n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
