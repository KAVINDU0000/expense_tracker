import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/utils/app_theme.dart';

class TestAuth extends ChangeNotifier implements AppAuthProvider {
  int submissions = 0;
  @override
  Future<String?> signIn(String email, String password) async {
    submissions++;
    return 'Incorrect email or password.';
  }
  @override
  Future<String?> signUp(String email, String password) async {
    submissions++;
    return null;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<TestAuth> mount(WidgetTester tester, Size size, {bool dark = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = TestAuth();
    await tester.pumpWidget(ChangeNotifierProvider<AppAuthProvider>.value(
      value: auth,
      child: MaterialApp(theme: dark ? AppTheme.dark : AppTheme.light,
        home: const RepaintBoundary(key: Key('screen'), child: LoginScreen())),
    ));
    await tester.pumpAndSettle();
    return auth;
  }

  testWidgets('Desktop authentication layout', (tester) async {
    await mount(tester, const Size(1280, 900));
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const Key('screen')), matchesGoldenFile('goldens/login_desktop.png'));
  });

  testWidgets('Mobile signup validates confirmation and supports dark mode', (tester) async {
    final auth = await mount(tester, const Size(390, 844), dark: true);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'example123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(auth.submissions, 0);
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const Key('screen')), matchesGoldenFile('goldens/signup_mobile.png'));
  });

  testWidgets('Login displays server errors and toggles password visibility', (tester) async {
    final auth = await mount(tester, const Size(360, 800));
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'example123');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(auth.submissions, 1);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
