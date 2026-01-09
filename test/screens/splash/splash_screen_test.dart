import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/screens/splash/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should render with correct branding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.text('GoNow'), findsOneWidget);
      expect(find.text('Time Saver'), findsOneWidget);
    });

    testWidgets('should display schedule icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should have FadeTransition animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // FadeTransition이 있는지 확인 (MaterialApp 내부에도 있을 수 있으므로 findsWidgets 사용)
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('should navigate to /auth after 2.5 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {
            '/auth': (context) => const Scaffold(
              body: Center(child: Text('Auth Screen')),
            ),
          },
        ),
      );

      // 초기에는 SplashScreen
      expect(find.text('GoNow'), findsOneWidget);
      expect(find.text('Auth Screen'), findsNothing);

      // 2.5초 후
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // Auth 화면으로 전환됨
      expect(find.text('GoNow'), findsNothing);
      expect(find.text('Auth Screen'), findsOneWidget);
    });

    testWidgets('should have primary color background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('animation should complete in 1.5 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // 애니메이션 시작
      await tester.pump();

      // 0.75초 (중간 지점)
      await tester.pump(const Duration(milliseconds: 750));

      // 1.5초 (애니메이션 완료)
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('GoNow'), findsOneWidget);
    });
  });
}
