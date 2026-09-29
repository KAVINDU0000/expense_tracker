import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/providers/currency_provider.dart';
import 'package:expense_tracker/widgets/currency_selector.dart';
import 'package:expense_tracker/widgets/summary_card.dart';

void main() {
  testWidgets('Currency selection updates totals and survives restart',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final currency = CurrencyProvider(prefs);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: currency,
      child: const MaterialApp(
          home: Scaffold(
              body: Column(children: [
        CurrencySelector(),
        SummaryCard(monthTotal: 5300),
      ]))),
    ));
    expect(find.text('USD 5,300.00'), findsOneWidget);
    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LKR — Sri Lankan Rupee'));
    await tester.pumpAndSettle();
    expect(find.text('LKR 5,300.00'), findsOneWidget);
    expect(CurrencyProvider(prefs).code, 'LKR');
  });

  test('Invalid saved currency falls back and yen uses currency precision',
      () async {
    SharedPreferences.setMockInitialValues({'currencyCode': 'invalid'});
    final prefs = await SharedPreferences.getInstance();
    final currency = CurrencyProvider(prefs);
    expect(currency.code, 'USD');
    await currency.select('JPY');
    expect(currency.formatter.format(1500), 'JPY 1,500');
    await expectLater(currency.select('invalid'), throwsArgumentError);
    expect(currency.code, 'JPY');
    currency.dispose();
  });
}
