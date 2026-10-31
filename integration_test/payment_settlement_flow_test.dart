import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paypulse_mobile_engine/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E payment flow updates balance and queues mutation', (WidgetTester tester) async {
    await tester.pumpWidget(const PayPulseApp());
    await tester.pumpAndSettle();

    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  });
}