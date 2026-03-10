import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/presentation/common/widgets/custom_text_field.dart';

void main() {
  testWidgets('custom text field hides hint while focused', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CustomTextField(hintText: 'Email Hint', labelText: 'Email Label'),
              SizedBox(height: 16),
              Text('Outside'),
            ],
          ),
        ),
      ),
    );

    TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, 'Email Hint');
    expect(field.decoration?.labelText, 'Email Label');

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, '');
    expect(field.decoration?.labelText, 'Email Label');

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();

    field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, 'Email Hint');
    expect(field.decoration?.labelText, 'Email Label');
  });

  testWidgets('custom text field can hide label while focused when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            hintText: 'Email Hint',
            labelText: 'Email Label',
            clearLabelOnFocus: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, '');
    expect(field.decoration?.labelText, '');
  });
}
