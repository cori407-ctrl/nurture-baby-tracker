import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/database.dart';
import '../utils/units.dart';

/// Builds a pediatrician-ready PDF report for a date range.
/// Pure function of the events + locale + unit — no UI dependency.
class PdfExport {
  PdfExport._();

  static String _kindLabel(String kind, String locale) {
    const en = {
      EventKind.formula: 'Bottle',
      EventKind.breastfeed: 'Nursing',
      EventKind.diaperWet: 'Wet diaper',
      EventKind.diaperDirty: 'Dirty diaper',
      EventKind.diaperBoth: 'Wet + dirty',
      EventKind.burp: 'Burp',
    };
    const es = {
      EventKind.formula: 'Biberón',
      EventKind.breastfeed: 'Pecho',
      EventKind.diaperWet: 'Pañal mojado',
      EventKind.diaperDirty: 'Pañal sucio',
      EventKind.diaperBoth: 'Mojado + sucio',
      EventKind.burp: 'Eructo',
    };
    return (locale == 'es' ? es : en)[kind] ?? kind;
  }

  static String _detail(LogEvent e, String locale, String unit) {
    switch (e.kind) {
      case EventKind.formula:
        return Units.format(e.amountMl ?? 0, unit);
      case EventKind.breastfeed:
        final side = e.side == 'left'
            ? (locale == 'es' ? 'izq.' : 'L')
            : e.side == 'right'
                ? (locale == 'es' ? 'der.' : 'R')
                : '';
        final min = locale == 'es' ? 'min' : 'min';
        return '${e.durationMin ?? 0} $min ${side.isEmpty ? '' : '($side)'}'.trim();
      default:
        return '✓';
    }
  }

  static Future<void> shareReport({
    required List<LogEvent> events,
    required DateTime from,
    required DateTime to,
    required String locale,
    required String unit,
  }) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('MMM d, yyyy', locale == 'es' ? 'es' : 'en');
    final timeFmt = DateFormat('h:mm a', locale == 'es' ? 'es' : 'en');
    final dayFmt = DateFormat('EEEE, MMM d', locale == 'es' ? 'es' : 'en');

    final title = locale == 'es'
        ? 'Informe del diario de alimentación'
        : 'Feeding Diary Report';
    final rangeLabel = locale == 'es' ? 'Rango de fechas' : 'Date range';
    final totalsLabel = locale == 'es' ? 'Totales' : 'Totals';
    final generatedLabel = locale == 'es' ? 'Generado el' : 'Generated';
    final timeCol = locale == 'es' ? 'Hora' : 'Time';
    final typeCol = locale == 'es' ? 'Tipo' : 'Type';
    final detailsCol = locale == 'es' ? 'Detalles' : 'Details';

    // Totals.
    var totalFormulaMl = 0;
    var nursingSessions = 0;
    var nursingMin = 0;
    var wet = 0, dirty = 0, burps = 0;
    for (final e in events) {
      switch (e.kind) {
        case EventKind.formula:
          totalFormulaMl += e.amountMl ?? 0;
          break;
        case EventKind.breastfeed:
          nursingSessions++;
          nursingMin += e.durationMin ?? 0;
          break;
        case EventKind.diaperWet:
          wet++;
          break;
        case EventKind.diaperDirty:
          dirty++;
          break;
        case EventKind.diaperBoth:
          wet++;
          dirty++;
          break;
        case EventKind.burp:
          burps++;
          break;
      }
    }

    final totals = [
      '${locale == 'es' ? 'Fórmula total' : 'Total formula'}: ${Units.format(totalFormulaMl, unit)}',
      '${locale == 'es' ? 'Tomas de pecho' : 'Nursing sessions'}: $nursingSessions',
      '${locale == 'es' ? 'Minutos de pecho' : 'Nursing minutes'}: $nursingMin',
      '${locale == 'es' ? 'Pañales mojados' : 'Wet diapers'}: $wet',
      '${locale == 'es' ? 'Pañales sucios' : 'Dirty diapers'}: $dirty',
      '${locale == 'es' ? 'Eructos' : 'Burps'}: $burps',
    ];

    // Group by day.
    final byDay = <String, List<LogEvent>>{};
    for (final e in events) {
      final key = DateFormat('yyyy-MM-dd').format(e.timestamp);
      byDay.putIfAbsent(key, () => []).add(e);
    }
    final sortedDays = byDay.keys.toList()..sort();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Nurture — $title',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
                '$rangeLabel: ${dateFmt.format(from)} – ${dateFmt.format(to)}',
                style: const pw.TextStyle(fontSize: 11)),
            pw.Text(
                '$generatedLabel ${dateFmt.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          pw.Text(totalsLabel,
              style: pw.TextStyle(
                  fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...totals.map((t) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text(t, style: const pw.TextStyle(fontSize: 12)),
              )),
          pw.SizedBox(height: 14),
          for (final day in sortedDays) ...[
            pw.Text(dayFmt.format(DateTime.parse(day)),
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.TableHelper.fromTextArray(
              headers: [timeCol, typeCol, detailsCol],
              data: byDay[day]!
                  .map((e) => [
                        timeFmt.format(e.timestamp),
                        _kindLabel(e.kind, locale),
                        _detail(e, locale, unit),
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 11),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 6, vertical: 4),
            ),
            pw.SizedBox(height: 12),
          ],
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'nurture-report-${DateFormat('yyyyMMdd').format(from)}-${DateFormat('yyyyMMdd').format(to)}.pdf',
    );
  }
}
