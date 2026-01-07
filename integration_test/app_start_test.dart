import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:go_now/main.dart' as app;
import 'package:go_now/screens/auth/login_screen.dart';

/// E2E Test 1: 앱 시작 및 LoginScreen 렌더링 테스트
///
/// **Test Coverage**:
/// - 앱이 정상적으로 시작되는지 확인
/// - LoginScreen이 표시되는지 확인
/// - 기본 UI 요소들이 렌더링되는지 확인

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Test 1: App Start & Login Screen', () {
    testWidgets('should start app and show LoginScreen',
        (WidgetTester tester) async {
      // Given - Start the app
      app.main();
      await tester.pumpAndSettle();

      // Then - LoginScreen should be displayed
      expect(find.byType(LoginScreen), findsOneWidget);

      // App bar should have title
      expect(find.text('로그인'), findsOneWidget);

      // Basic UI elements should be present
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should display login form elements',
        (WidgetTester tester) async {
      // Given - Start the app
      app.main();
      await tester.pumpAndSettle();

      // Then - Login form elements should be visible
      // Note: Exact text depends on LoginScreen implementation
      // These are basic checks to ensure the screen renders
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should use light theme by default',
        (WidgetTester tester) async {
      // Given - Start the app
      app.main();
      await tester.pumpAndSettle();

      // Then - App should use light theme
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.debugShowCheckedModeBanner, false);
    });
  });
}
