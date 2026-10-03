import 'package:flutter_test/flutter_test.dart';
import 'package:nurture/utils/units.dart';

void main() {
  group('Units conversion', () {
    test('oz to mL uses 29.5735 and rounds', () {
      expect(Units.ozToMl(1), 30); // 29.5735 -> 30
      expect(Units.ozToMl(2), 59); // 59.147 -> 59
      expect(Units.ozToMl(4), 118); // 118.294 -> 118
    });

    test('mL to oz', () {
      expect(Units.mlToOz(30), closeTo(1.014, 0.001));
      expect(Units.mlToOz(60), closeTo(2.028, 0.001));
    });

    test('round-trips through storage stay consistent', () {
      // Enter 2 oz -> store mL -> display back in oz
      final stored = Units.displayToMl(2, Units.oz);
      expect(Units.format(stored, Units.oz), '2 oz');
      // Enter 60 mL -> store -> display back in mL
      final storedMl = Units.displayToMl(60, Units.ml);
      expect(Units.format(storedMl, Units.ml), '60 mL');
    });

    test('oz formatting trims trailing zeros', () {
      expect(Units.format(Units.ozToMl(2), Units.oz), '2 oz');
      expect(Units.format(Units.ozToMl(2.5), Units.oz), '2.5 oz');
      expect(Units.format(Units.ozToMl(1.5), Units.oz), '1.5 oz');
    });

    test('mL formatting', () {
      expect(Units.format(90, Units.ml), '90 mL');
      expect(Units.format(0, Units.ml), '0 mL');
    });

    test('presets are in display unit', () {
      expect(Units.presets(Units.ml), [30, 60, 90, 120, 150, 180]);
      expect(Units.presets(Units.oz), [1, 2, 3, 4, 5, 6]);
    });

    test('preset labels', () {
      expect(Units.presetLabel(60, Units.ml), '60 mL');
      expect(Units.presetLabel(2, Units.oz), '2 oz');
    });
  });
}
