// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutBody =>
      'Nurture es un registro de recién nacidos gratuito y privado. Sin cuentas, sin anuncios, sin rastreo — los datos de tu bebé nunca salen de este teléfono.';

  @override
  String amountMl(int n) {
    return '$n mL';
  }

  @override
  String get appTitle => 'Nurture';

  @override
  String get apptAdd => 'Añadir visita';

  @override
  String get apptDate => 'Fecha';

  @override
  String get apptDayBefore => 'Día anterior';

  @override
  String get apptDelete => 'Eliminar visita';

  @override
  String get apptDeleted => 'Visita eliminada';

  @override
  String get apptEdit => 'Editar visita';

  @override
  String get apptEmpty => 'Sin próximas visitas.';

  @override
  String get apptHourBefore => 'Una hora antes';

  @override
  String get apptName => 'Nombre de la visita';

  @override
  String get apptNameHint => 'p. ej. Control con el pediatra';

  @override
  String get apptNotes => 'Notas (opcional)';

  @override
  String get apptPast => 'Pasadas';

  @override
  String get apptReminders => 'Recordatorios';

  @override
  String get apptSaved => 'Visita guardada';

  @override
  String get apptTime => 'Hora';

  @override
  String get apptTitle => 'Visitas al médico';

  @override
  String get apptUpcoming => 'Próximas';

  @override
  String get breastfeedTitle => 'Temporizador de pecho';

  @override
  String get burpNow => 'Registrar eructo ahora';

  @override
  String get burpOptionalTimer => 'Opcional: cronometrar';

  @override
  String get burpTitle => 'Eructo';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get confirmDeleteBody => 'Este registro se eliminará.';

  @override
  String get confirmDeleteTitle => '¿Eliminar registro?';

  @override
  String get customAmount => 'Otra cantidad';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get diapersToday => 'Pañales hoy';

  @override
  String get eventDeleted => 'Registro eliminado';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get formulaTitle => 'Registrar biberón';

  @override
  String get fromDate => 'Desde';

  @override
  String get generatePdf => 'Generar PDF';

  @override
  String get historyTitle => 'Registro diario';

  @override
  String hoursAgo(int n) {
    return 'hace $n h';
  }

  @override
  String get justNow => 'ahora mismo';

  @override
  String get kindBoth => 'Mojado + sucio';

  @override
  String get kindBreastfeed => 'Pecho';

  @override
  String get kindBurp => 'Eructo';

  @override
  String get kindDirty => 'Pañal sucio';

  @override
  String get kindFormula => 'Biberón';

  @override
  String get kindWet => 'Pañal mojado';

  @override
  String get lastFeed => 'Última toma';

  @override
  String get leftSide => 'Izquierdo';

  @override
  String get logBoth => 'Ambos';

  @override
  String get logBottle => 'Biberón';

  @override
  String get logBreastfeed => 'Pecho';

  @override
  String get logBurp => 'Eructo';

  @override
  String get logButton => 'Registrar';

  @override
  String get logDirty => 'Sucio';

  @override
  String get logManual => 'O registrar manual';

  @override
  String get logWet => 'Mojado';

  @override
  String get loggedBoth => 'Pañal registrado';

  @override
  String get loggedBottle => 'Biberón registrado';

  @override
  String get loggedBurp => 'Eructo registrado';

  @override
  String get loggedDirty => 'Pañal sucio registrado';

  @override
  String get loggedNurse => 'Pecho registrado';

  @override
  String get loggedWet => 'Pañal mojado registrado';

  @override
  String minutesAgo(int n) {
    return 'hace $n min';
  }

  @override
  String get minutesLabel => 'minutos';

  @override
  String get navAppointments => 'Visitas';

  @override
  String get navHistory => 'Registro';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get noButton => 'No';

  @override
  String get noEvents => 'Nada registrado este día.';

  @override
  String get noFeedYet => 'Sin tomas aún';

  @override
  String get notifApptTitle => 'Visita al médico';

  @override
  String notifDayBefore(String time, String title) {
    return 'Mañana: $title a las $time';
  }

  @override
  String notifHourBefore(String title) {
    return 'En una hora: $title';
  }

  @override
  String get pdfBurps => 'Eructos';

  @override
  String get pdfDetails => 'Detalles';

  @override
  String get pdfDirtyDiapers => 'Pañales sucios';

  @override
  String pdfGeneratedOn(String date) {
    return 'Generado el $date';
  }

  @override
  String get pdfNursingMinutes => 'Minutos de pecho';

  @override
  String get pdfNursingSessions => 'Tomas de pecho';

  @override
  String get pdfRange => 'Rango de fechas';

  @override
  String get pdfTime => 'Hora';

  @override
  String get pdfTitle => 'Informe del diario de alimentación';

  @override
  String get pdfTotalFormula => 'Fórmula total';

  @override
  String get pdfTotals => 'Totales';

  @override
  String get pdfType => 'Tipo';

  @override
  String get pdfWetDiapers => 'Pañales mojados';

  @override
  String get pickDate => 'Elige un día';

  @override
  String get rightSide => 'Derecho';

  @override
  String get saveButton => 'Guardar';

  @override
  String get settingsAbout => 'Acerca de Nurture';

  @override
  String get settingsExport => 'Exportar datos (PDF)';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageEs => 'Español';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsTheme => 'Apariencia';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get startTimer => 'Iniciar';

  @override
  String get stopAndLog => 'Detener y registrar';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get timerRunning => 'En curso…';

  @override
  String get toDate => 'Hasta';

  @override
  String get today => 'Hoy';

  @override
  String get totalFormulaToday => 'Fórmula hoy';

  @override
  String get undo => 'Deshacer';

  @override
  String get yesButton => 'Sí';

  @override
  String get settingsUnits => 'Unidades';

  @override
  String get unitMilliliters => 'Mililitros (mL)';

  @override
  String get unitFluidOunces => 'Onzas líquidas (oz)';

  @override
  String get unitMlShort => 'mL';

  @override
  String get unitOzShort => 'oz';

  @override
  String amountOz(Object n) {
    return '$n oz';
  }
}
