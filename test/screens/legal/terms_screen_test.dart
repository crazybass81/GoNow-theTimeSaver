import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/screens/legal/terms_screen.dart';

void main() {
  group('TermsScreen Widget Tests', () {
    testWidgets('should render with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      expect(find.text('이용약관'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display all 8 articles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      // 8개 조항 확인
      expect(find.text('제1조 (목적)'), findsOneWidget);
      expect(find.text('제2조 (정의)'), findsOneWidget);
      expect(find.text('제3조 (약관의 효력 및 변경)'), findsOneWidget);
      expect(find.text('제4조 (서비스의 제공)'), findsOneWidget);
      expect(find.text('제5조 (이용자의 의무)'), findsOneWidget);
      expect(find.text('제6조 (저작권의 귀속)'), findsOneWidget);
      expect(find.text('제7조 (개인정보 보호)'), findsOneWidget);
      expect(find.text('제8조 (면책사항)'), findsOneWidget);
    });

    testWidgets('should display supplementary provision', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('부칙'), 100);

      expect(find.text('부칙'), findsOneWidget);
      expect(find.textContaining('2026년 1월 1일'), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
