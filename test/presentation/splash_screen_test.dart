import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/presentation/common/splash_screen.dart';

void main() {
  testWidgets('splash screen renders loading indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
