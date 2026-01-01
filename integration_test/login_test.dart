import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:kasirmadura/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login Test', (WidgetTester tester) async {
    app.main();

    // tunggu app & splash
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ===== STEP 1: TAP GET STARTED =====
    final getStartedButton =
    find.byKey(const Key('get_started_button'));
    expect(getStartedButton, findsOneWidget);

    await tester.tap(getStartedButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ===== STEP 2: LOGIN =====
    final usernameField =
    find.byKey(const Key('login_username_field'));
    final passwordField =
    find.byKey(const Key('login_password_field'));
    final loginButton =
    find.byKey(const Key('login_button'));

    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(usernameField, 'admin');
    await tester.enterText(passwordField, 'admin123');
    await tester.tap(loginButton);

    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
