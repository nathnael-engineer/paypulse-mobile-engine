import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paypulse_mobile_engine/main.dart';

void main() {
  group('PayPulse Mobile Engine Widget Tests', () {
    testWidgets('Renders balance and transfer button', (WidgetTester tester) async {
      await tester.pumpWidget(const PayPulseApp());
      await tester.pumpAndSettle();

      expect(find.text('PayPulse Mobile Engine'), findsOneWidget);
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('\$38450.21'), findsOneWidget);

      final transferButton = find.byType(ElevatedButton);
      expect(transferButton, findsOneWidget);
    });
  });
}