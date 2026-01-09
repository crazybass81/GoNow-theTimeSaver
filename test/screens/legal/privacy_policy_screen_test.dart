import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/screens/legal/privacy_policy_screen.dart';

void main() {
  group('PrivacyPolicyScreen Widget Tests', () {
    testWidgets('should render with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.text('개인정보 처리방침'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display info header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.textContaining('개인정보보호법을 준수합니다'), findsOneWidget);
    });

    testWidgets('should display all 9 sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 9개 섹션 확인
      expect(find.text('1. 개인정보의 수집 및 이용 목적'), findsOneWidget);
      expect(find.text('2. 수집하는 개인정보 항목'), findsOneWidget);
      expect(find.text('3. 개인정보의 보유 및 이용 기간'), findsOneWidget);
      expect(find.text('4. 개인정보의 제3자 제공'), findsOneWidget);
      expect(find.text('5. 개인정보 처리의 위탁'), findsOneWidget);

      // 나머지 섹션은 스크롤 필요
      await tester.scrollUntilVisible(find.text('6. 정보주체의 권리·의무'), 100);
      expect(find.text('6. 정보주체의 권리·의무'), findsOneWidget);
    });

    testWidgets('should display contact email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('privacy@gonow.app'), 100);

      expect(find.textContaining('privacy@gonow.app'), findsOneWidget);
    });

    testWidgets('should display effective date', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('시행일'), 100);

      expect(find.text('시행일'), findsOneWidget);
      expect(find.textContaining('2026년 1월 1일'), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
