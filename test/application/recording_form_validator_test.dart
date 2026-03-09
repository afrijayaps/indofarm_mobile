import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/recordings/recording_form_validator.dart';

void main() {
  const validator = RecordingFormValidator();

  test('validateNumber rejects negative and non-numeric value', () {
    expect(validator.validateNumber('-1', 'Pakan'), isNotNull);
    expect(validator.validateNumber('abc', 'Pakan'), isNotNull);
  });

  test('validateDateIso accepts ISO date', () {
    expect(validator.validateDateIso('2026-03-09'), isNull);
  });
}
