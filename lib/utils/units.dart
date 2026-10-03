/// Unit conversion helpers.
///
/// Storage rule: formula amounts are ALWAYS stored in milliliters (mL)
/// in the database. The display unit (mL or fl oz) only affects what the
/// user sees and enters.
class Units {
  Units._();

  static const String ml = 'ml';
  static const String oz = 'oz';

  /// 1 US fluid ounce in milliliters.
  static const double mlPerOz = 29.5735;

  static int ozToMl(double oz) => (oz * mlPerOz).round();

  static double mlToOz(int ml) => ml / mlPerOz;

  /// Format a stored mL amount for display in [unit].
  /// oz shows up to 1 decimal, trimming trailing zeros ("2 oz", "2.5 oz").
  static String format(int mlAmount, String unit) {
    if (unit == oz) {
      final ozVal = mlToOz(mlAmount);
      // Round to 1 decimal; show integer when whole.
      final rounded = (ozVal * 10).round() / 10;
      final text = rounded == rounded.roundToDouble()
          ? rounded.round().toString()
          : rounded.toStringAsFixed(1);
      return '$text oz';
    }
    return '$mlAmount mL';
  }

  /// Preset quick-log amounts in the *display* unit.
  static List<double> presets(String unit) =>
      unit == oz ? [1, 2, 3, 4, 5, 6] : [30, 60, 90, 120, 150, 180];

  /// Convert a preset/entered display value to stored mL.
  static int displayToMl(double displayValue, String unit) =>
      unit == oz ? ozToMl(displayValue) : displayValue.round();

  /// Convert a stored mL value to the display unit value.
  static double mlToDisplay(int mlAmount, String unit) =>
      unit == oz ? mlToOz(mlAmount) : mlAmount.toDouble();

  /// Label for a preset chip in the display unit.
  static String presetLabel(double displayValue, String unit) =>
      unit == oz
          ? (displayValue == displayValue.roundToDouble()
              ? '${displayValue.round()} oz'
              : '$displayValue oz')
          : '${displayValue.round()} mL';
}
