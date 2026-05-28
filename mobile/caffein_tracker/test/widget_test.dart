import 'package:flutter_test/flutter_test.dart';

import 'package:caffein_tracker/models/models.dart';
import 'package:caffein_tracker/services/personalization_service.dart';

void main() {
  test('daily sugar cap by sensitivity', () {
    final p = PersonalizationService();
    expect(p.getDailySugarCap(SugarSensitivity.medium), 35);
    expect(p.getDailySugarCap(SugarSensitivity.high), 25);
  });
}
