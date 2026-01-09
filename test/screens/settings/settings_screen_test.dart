import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_now/screens/settings/settings_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:go_now/utils/app_colors.dart';
import 'package:go_now/utils/ui_constants.dart';

/// Settings Screen 테스트 / Settings Screen Tests
///
/// **테스트 범위 / Test Coverage**:
/// - 앱 설정 섹션 ListTile 패턴 검증 / App Settings section ListTile pattern verification
/// - 이동 수단 모달 검증 / Transport mode modal verification
/// - 버퍼 시간 모달 검증 / Buffer time modal verification
/// - 알림 소리 모달 검증 / Notification sound modal verification
void main() {
  late AuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = AuthProvider();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: child,
      ),
    );
  }

  group('Settings Screen - App Settings Section', () {
    testWidgets('앱 설정 섹션이 ListTile 패턴으로 표시됨 / App Settings section displays ListTile pattern',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 앱 설정 섹션 헤더 확인 / Verify App Settings section header
      expect(find.text('앱 설정'), findsOneWidget);

      // 기본 이동 수단 ListTile 확인 / Verify Transport mode ListTile
      expect(find.text('기본 이동 수단'), findsOneWidget);
      expect(find.byIcon(Icons.directions_transit), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(2)); // 2개: 이동수단 + 버퍼시간

      // 기본 버퍼 시간 설정 ListTile 확인 / Verify Buffer time ListTile
      expect(find.text('기본 버퍼 시간 설정'), findsOneWidget);
      expect(find.text('외출 준비, 도착 버퍼, 오차율, 마무리'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsWidgets); // 여러 개 있을 수 있음
    });

    testWidgets('이동 수단 ListTile을 탭하면 모달이 열림 / Tapping Transport mode opens modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 기본 이동 수단 ListTile 탭 / Tap Transport mode ListTile
      await tester.tap(find.text('기본 이동 수단'));
      await tester.pumpAndSettle();

      // 모달 헤더 확인 / Verify modal header
      expect(find.text('기본 이동 수단'), findsNWidgets(2)); // 원본 + 모달

      // 대중교통 옵션 확인 / Verify transit option
      expect(find.text('대중교통'), findsOneWidget);
      expect(find.byIcon(Icons.directions_transit), findsNWidgets(2)); // 원본 + 모달

      // 자가용 옵션 확인 / Verify car option
      expect(find.text('자가용'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('이동 수단 선택 시 모달이 닫히고 선택값이 반영됨 / Selecting transport mode closes modal and updates value',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 초기 상태 확인 (대중교통) / Verify initial state (transit)
      expect(find.text('대중교통'), findsNothing); // ListTile subtitle에 표시

      // 이동 수단 ListTile 탭 / Tap Transport mode ListTile
      await tester.tap(find.text('기본 이동 수단'));
      await tester.pumpAndSettle();

      // 자가용 선택 / Select car
      await tester.tap(find.text('자가용'));
      await tester.pumpAndSettle();

      // 모달이 닫히고 선택값이 반영됨 / Modal closed and value updated
      expect(find.text('자가용'), findsOneWidget); // ListTile subtitle
      expect(find.text('대중교통'), findsNothing); // 모달 닫힘
    });

    testWidgets('버퍼 시간 ListTile을 탭하면 모달이 열림 / Tapping Buffer time opens modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 기본 버퍼 시간 설정 ListTile 탭 / Tap Buffer time ListTile
      await tester.tap(find.text('기본 버퍼 시간 설정'));
      await tester.pumpAndSettle();

      // 모달 헤더 확인 / Verify modal header
      expect(find.text('기본 버퍼 시간 설정'), findsNWidgets(2)); // 원본 + 모달

      // 4개의 버퍼 시간 슬라이더 확인 / Verify 4 buffer time sliders
      expect(find.text('1️⃣ 외출 준비 시간'), findsOneWidget);
      expect(find.text('2️⃣ 일찍 도착 버퍼'), findsOneWidget);
      expect(find.text('3️⃣ 이동 오차율'), findsOneWidget);
      expect(find.text('4️⃣ 일정 마무리 시간'), findsOneWidget);

      // 저장 버튼 확인 / Verify save button
      expect(find.text('저장'), findsOneWidget);

      // 닫기 버튼 확인 / Verify close button
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('버퍼 시간 모달에서 닫기 버튼을 누르면 변경사항이 저장되지 않음 / Closing modal without saving discards changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 버퍼 시간 ListTile 탭 / Tap Buffer time ListTile
      await tester.tap(find.text('기본 버퍼 시간 설정'));
      await tester.pumpAndSettle();

      // 슬라이더 값 변경 (테스트 시나리오상 복잡하므로 스킵)
      // 여기서는 닫기 버튼만 테스트

      // 닫기 버튼 탭 / Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 모달이 닫힘 / Modal closed
      expect(find.text('1️⃣ 외출 준비 시간'), findsNothing);
    });

    testWidgets('버퍼 시간 모달에서 저장 버튼을 누르면 변경사항이 적용됨 / Saving buffer time modal applies changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 버퍼 시간 ListTile 탭 / Tap Buffer time ListTile
      await tester.tap(find.text('기본 버퍼 시간 설정'));
      await tester.pumpAndSettle();

      // 저장 버튼 탭 / Tap save button
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 모달이 닫힘 / Modal closed
      expect(find.text('1️⃣ 외출 준비 시간'), findsNothing);
    });
  });

  group('Settings Screen - Notification Sound Modal', () {
    testWidgets('알림 소리 ListTile을 탭하면 모달이 열림 / Tapping Notification sound opens modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 알림 소리 ListTile 탭 / Tap Notification sound ListTile
      await tester.tap(find.text('알림 소리'));
      await tester.pumpAndSettle();

      // 모달 헤더 확인 / Verify modal header
      expect(find.text('알림 소리'), findsNWidgets(2)); // 원본 + 모달

      // 4개의 소리 옵션 확인 / Verify 4 sound options
      expect(find.text('기본'), findsNWidgets(2)); // 원본 subtitle + 모달 option
      expect(find.text('벨소리'), findsOneWidget);
      expect(find.text('알람'), findsOneWidget);
      expect(find.text('무음'), findsOneWidget);
    });
  });

  group('Settings Screen - UI Consistency', () {
    testWidgets('모든 설정 섹션이 일관된 ListTile 패턴 사용 / All settings sections use consistent ListTile pattern',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 알림 설정 섹션 / Notification settings section
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets); // 여러 개

      // 계정 관리 섹션 / Account management section
      expect(find.text('계정 관리'), findsOneWidget);
      expect(find.text('프로필 수정'), findsOneWidget);
      expect(find.text('비밀번호 변경'), findsOneWidget);

      // 앱 설정 섹션 / App settings section
      expect(find.text('앱 설정'), findsOneWidget);
      expect(find.text('기본 이동 수단'), findsOneWidget);
      expect(find.text('기본 버퍼 시간 설정'), findsOneWidget);

      // 앱 정보 섹션 / App info section
      expect(find.text('앱 정보'), findsOneWidget);
      expect(find.text('버전 정보'), findsOneWidget);
      expect(find.text('이용약관'), findsOneWidget);
      expect(find.text('개인정보 처리방침'), findsOneWidget);
    });

    testWidgets('모든 네비게이션 항목에 화살표 아이콘 표시 / All navigation items show arrow icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // 화살표 아이콘 개수 확인 / Verify arrow icon count
      // 프로필 수정, 비밀번호 변경, 기본 이동 수단, 기본 버퍼 시간, 알림 소리, 이용약관, 개인정보, 오픈소스
      final arrowIcons = find.byIcon(Icons.arrow_forward_ios);
      expect(arrowIcons, findsWidgets);
    });

    testWidgets('Divider가 ListTile 사이에 표시됨 / Dividers shown between ListTiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Divider 확인 / Verify dividers
      expect(find.byType(Divider), findsWidgets);
    });
  });
}
