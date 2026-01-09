# GoNow: 통합 테스트 가이드

> **전체 Phase 테스트 전략 및 체크리스트**

**최종 업데이트**: 2026-01-09
**문서 버전**: 1.5
**프로젝트 상태**: Phase 4 완료 (100%) - 모든 테스트 통과 (328/328), UI 개선 완료, Phase 5 준비 중
**테스트 결과**: [TEST_RESULTS_2025_01_07.md](../docs/archive/test_results_archive_2025_01_07/TEST_RESULTS_2025_01_07.md)

---

## 📚 문서 개요 / Document Overview

GoNow MVP 개발의 전체 테스트 전략을 다루는 통합 가이드입니다. Phase별 테스트 계획, 테스트 유형별 가이드, 그리고 체크리스트를 제공합니다.

### 관련 문서
- [README.md](./README.md) - 프로젝트 전체 네비게이션
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - Phase별 구현 가이드
- [phase3/INTEGRATION_TEST_GUIDE.md](./phase3/INTEGRATION_TEST_GUIDE.md) - Phase 3 상세 테스트 가이드

---

## 🎯 테스트 전략 개요 / Testing Strategy Overview

### 테스트 피라미드

```
       ┌─────────────┐
       │   E2E Tests │  ← 10% (사용자 시나리오)
       ├─────────────┤
       │  Integration │  ← 30% (API, DB, 외부 서비스)
       │    Tests     │
       ├─────────────┤
       │  Widget Tests│  ← 30% (UI 컴포넌트, 상태)
       ├─────────────┤
       │  Unit Tests  │  ← 30% (비즈니스 로직, 알고리즘)
       └─────────────┘
```

### 테스트 원칙

1. **Test First**: 기능 구현 전 테스트 케이스 작성 (TDD)
2. **Automation First**: 자동화 가능한 모든 테스트는 자동화
3. **Fast Feedback**: 빠른 실패, 빠른 수정
4. **Coverage Goals**:
   - Unit Tests: 80%+ 코드 커버리지
   - Widget Tests: 70%+ UI 커버리지
   - Integration Tests: 핵심 플로우 100%
   - E2E Tests: 주요 사용자 시나리오 100%

---

## 📊 Phase별 테스트 계획

### Phase 1: Foundation & UI (Day 1~5) ✅ 완료

**테스트 범위**:
- UI 위젯 렌더링
- 네비게이션 플로우
- 폼 유효성 검사
- 상태 관리 (Provider)

#### Widget Tests

**1.1 로그인 화면**
```dart
// test/screens/auth/login_screen_test.dart
testWidgets('로그인 화면이 정상적으로 렌더링됨', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  expect(find.text('이메일'), findsOneWidget);
  expect(find.text('비밀번호'), findsOneWidget);
  expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);
});

testWidgets('빈 이메일로 로그인 시 에러 메시지 표시', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
  await tester.pump();

  expect(find.text('이메일을 입력하세요'), findsOneWidget);
});
```

**1.2 회원가입 화면 (3단계)**
```dart
testWidgets('3단계 회원가입 플로우', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Step 1: 이메일/비밀번호
  await tester.enterText(find.byKey(Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();

  // Step 2: 이름/전화번호
  expect(find.text('이름'), findsOneWidget);
  await tester.enterText(find.byKey(Key('name')), '홍길동');
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();

  // Step 3: 약관 동의
  expect(find.text('이용약관'), findsOneWidget);
  await tester.tap(find.byType(Checkbox).first);
  expect(find.widgetWithText(ElevatedButton, '가입하기'), findsOneWidget);
});
```

**1.3 대시보드 화면**
```dart
testWidgets('카운트다운 위젯이 정상적으로 표시됨', (WidgetTester tester) async {
  final mockTrip = Trip(
    title: '테스트 일정',
    departureTime: DateTime.now().add(Duration(minutes: 45)),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: CountdownWidget(trip: mockTrip),
    ),
  );

  expect(find.text('45'), findsOneWidget); // 분
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

#### 체크리스트

- [ ] 모든 화면 렌더링 테스트 통과
- [ ] 폼 유효성 검사 테스트 통과
- [ ] 네비게이션 플로우 테스트 통과
- [ ] Provider 상태 관리 테스트 통과
- [ ] AuthProvider 로그인/로그아웃 테스트 통과

---

### Phase 2: Core Logic & API Integration (Day 6~10) ✅ 완료

**테스트 범위**:
- 역산 스케줄링 알고리즘
- TMAP API 통합
- Supabase CRUD
- 실시간 업데이트 로직

#### Unit Tests

**2.1 역산 스케줄링 알고리즘**
```dart
// test/services/scheduler_service_test.dart
group('SchedulerService', () {
  late SchedulerService scheduler;

  setUp(() {
    scheduler = SchedulerService();
  });

  test('기본 역산 계산이 정확함', () {
    final arrivalTime = DateTime(2024, 1, 1, 9, 0); // 09:00 도착
    final travelTime = 30; // 30분 이동
    final buffers = BufferTimes(
      prepTime: 10,     // 10분 준비
      errorRate: 20,    // 20% 오차
      earlyBuffer: 5,   // 5분 일찍
      completionTime: 0,
    );

    final result = scheduler.calculateDepartureTime(
      arrivalTime: arrivalTime,
      travelTimeMinutes: travelTime,
      buffers: buffers,
    );

    // 30분 * 1.2 = 36분 (오차 반영)
    // 36분 + 10분 + 5분 = 51분
    // 09:00 - 51분 = 08:09
    expect(result, DateTime(2024, 1, 1, 8, 9));
  });

  test('4가지 버퍼 시간 모두 반영됨', () {
    final arrivalTime = DateTime(2024, 1, 1, 10, 0);
    final travelTime = 20;
    final buffers = BufferTimes(
      prepTime: 15,
      errorRate: 10,
      earlyBuffer: 10,
      completionTime: 5,
    );

    final result = scheduler.calculateDepartureTime(
      arrivalTime: arrivalTime,
      travelTimeMinutes: travelTime,
      buffers: buffers,
    );

    // 20분 * 1.1 = 22분
    // 22분 + 15분 + 10분 + 5분 = 52분
    // 10:00 - 52분 = 09:08
    expect(result, DateTime(2024, 1, 1, 9, 8));
  });
});
```

**완료 현황**: ✅ 48개 단위 테스트 통과 (2026-01-06)

---

**2.2 Adaptive Polling**
```dart
// test/services/polling_service_test.dart
test('시간대별 폴링 간격이 정확함', () {
  final polling = PollingService();

  // 1시간 전: 15분 간격
  expect(polling.getPollingInterval(minutes: 60), Duration(minutes: 15));

  // 30분 전: 5분 간격
  expect(polling.getPollingInterval(minutes: 30), Duration(minutes: 5));

  // 10분 전: 3분 간격
  expect(polling.getPollingInterval(minutes: 10), Duration(minutes: 3));

  // 5분 전: 3분 간격 (최소)
  expect(polling.getPollingInterval(minutes: 5), Duration(minutes: 3));
});
```

---

#### Integration Tests

**2.3 TMAP API 통합**
```dart
// integration_test/api_integration_test.dart
testWidgets('TMAP Routes API 실제 호출 테스트', (WidgetTester tester) async {
  final routeService = RouteService();

  final result = await routeService.calculateRoute(
    startLat: 37.5665,
    startLng: 126.9780,
    endLat: 37.5665,
    endLng: 126.9990,
  );

  expect(result.duration, greaterThan(0));
  expect(result.distance, greaterThan(0));
  expect(result.path, isNotEmpty);
});

testWidgets('TMAP Public Transit API 실제 호출 테스트', (WidgetTester tester) async {
  final transitService = TransitService();

  final result = await transitService.calculateTransitRoute(
    startLat: 37.5665,
    startLng: 126.9780,
    endLat: 37.5665,
    endLng: 126.9990,
  );

  expect(result.totalTime, greaterThan(0));
  expect(result.pathList, isNotEmpty);
});
```

---

**2.4 Supabase CRUD**
```dart
// integration_test/supabase_integration_test.dart
testWidgets('Trip CRUD 통합 테스트', (WidgetTester tester) async {
  final tripService = TripService();
  final userId = 'test-user-123';

  // Create
  final trip = Trip(
    userId: userId,
    title: '통합 테스트 일정',
    destination: '테스트 목적지',
    arrivalTime: DateTime.now().add(Duration(hours: 2)),
  );

  final created = await tripService.createTrip(trip);
  expect(created.id, isNotNull);

  // Read
  final read = await tripService.getTrip(created.id);
  expect(read.title, '통합 테스트 일정');

  // Update
  final updated = await tripService.updateTrip(
    created.id,
    {'title': '수정된 일정'},
  );
  expect(updated.title, '수정된 일정');

  // Delete
  await tripService.deleteTrip(created.id);
  final deleted = await tripService.getTrip(created.id);
  expect(deleted, isNull);
});
```

#### 체크리스트

- [x] SchedulerService 48개 단위 테스트 통과 ✅
- [x] PollingService 테스트 통과 ✅
- [x] TMAP Routes API 통합 테스트 통과 ✅
- [x] TMAP Public Transit API 통합 테스트 통과 ✅
- [x] TripService CRUD 테스트 통과 ✅
- [x] SettingsService 테스트 통과 ✅
- [x] TripProvider 상태 관리 테스트 통과 ✅

---

### Phase 3: Widgets & Notifications (Day 11~15) ✅ Android 완료 / ⏳ iOS 대기

**테스트 범위**:
- Flutter ↔ Android/iOS 네이티브 통신
- 홈 위젯 표시 및 업데이트
- 시간대별 색상 변경
- 로컬 푸시 알림 스케줄링
- 배터리 및 성능 테스트

#### 상세 테스트 가이드

**Phase 3 테스트 가이드**: [phase3/INTEGRATION_TEST_GUIDE.md](./phase3/INTEGRATION_TEST_GUIDE.md)

이 가이드에는 다음 내용이 포함되어 있습니다:
- 위젯 기본 표시 테스트
- 시간대별 색상 변경 테스트 (초록/주황/빨강/진한빨강)
- 위젯 실시간 업데이트 테스트
- 알림 테스트 (30분 전, 10분 전, 동적 알림)
- 일정 완료/취소 테스트
- 배터리 소모 테스트
- 메모리 사용량 테스트
- 엣지 케이스 테스트 (네트워크 없음, 앱 강제 종료, 재부팅 등)

#### 핵심 테스트 요약

**3.1 위젯 표시 테스트**

```dart
// Flutter Widget Test
testWidgets('WidgetService가 네이티브로 데이터 전송', (WidgetTester tester) async {
  final widgetService = WidgetService();
  final trip = Trip(
    title: '테스트 일정',
    departureTime: DateTime.now().add(Duration(minutes: 45)),
  );

  await widgetService.updateWidget(upcomingTrip: trip);

  // MethodChannel 호출 확인
  verify(mockChannel.invokeMethod('updateWidget', any)).called(1);
});
```

**Android 네이티브 테스트**:
```kotlin
// android/app/src/test/kotlin/GoNowWidgetTest.kt
@Test
fun `SharedPreferences 데이터 저장 확인`() {
    val prefs = context.getSharedPreferences("gonow_widget_prefs", Context.MODE_PRIVATE)
    prefs.edit().putString("tripTitle", "테스트 일정").apply()

    val saved = prefs.getString("tripTitle", "")
    assertEquals("테스트 일정", saved)
}
```

**iOS 네이티브 테스트**:
```swift
// ios/GoNowWidgetExtensionTests/GoNowWidgetTests.swift
func testUserDefaultsDataSharing() {
    let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.gotimesaver")
    sharedDefaults?.set("테스트 일정", forKey: "tripTitle")

    let saved = sharedDefaults?.string(forKey: "tripTitle")
    XCTAssertEqual(saved, "테스트 일정")
}
```

---

**3.2 알림 테스트**

```dart
// integration_test/notification_test.dart
testWidgets('30분 전 알림 스케줄링', (WidgetTester tester) async {
  final notificationService = NotificationService();
  await notificationService.initialize();

  final trip = Trip(
    id: 'test-001',
    title: '테스트 일정',
    departureTime: DateTime.now().add(Duration(minutes: 31)),
  );

  await notificationService.scheduleNotifications(trip);

  final pending = await notificationService.getPendingNotifications();
  expect(pending.length, greaterThanOrEqualTo(2)); // 30분, 10분 알림
});
```

#### 체크리스트

**Flutter 레이어 - Unit Tests** ✅ 완료:
- [x] WidgetService 22개 단위 테스트 통과 ✅ (2026-01-06)
- [x] NotificationService 17개 단위 테스트 통과 ✅ (2026-01-06)
- [x] MethodChannel 통신 구현 ✅
- [x] 시간대별 색상 로직 테스트 ✅

**Flutter 레이어 - Widget Tests** ✅ 완료:
- [x] DashboardScreen 16개 위젯 테스트 통과 ✅ (2026-01-07)
  - UI 렌더링 (로딩, 에러, 빈 상태, 정상 데이터)
  - Welcome 메시지 (사용자 이름 표시)
  - Transport Mode 아이콘 (자동차/대중교통)
  - Upcoming Schedules 비즈니스 규칙
  - Navigation (FAB, Calendar, Settings)
  - Departure Button (출발 확인 다이얼로그)
- [x] AddScheduleScreen 31개 위젯 테스트 통과 ✅ (2026-01-07)
  - Initial Render (Step 0 목적지 선택)
  - Step Indicator UI (4단계 진행 표시)
  - Form Validation (목적지, 도착시간 필수)
  - Navigation Flow (next/back 버튼, 단계 이동)
  - Destination Selection (최근 장소, 즐겨찾기)
  - Transport Mode Selection (대중교통/자가용)
  - Date/Time Selection UI
  - Buffer Time Settings UI
  - Review Page UI
  - Save Functionality
- [x] SettingsScreen 19개 위젯 테스트 통과 ✅ (2026-01-07)
  - Initial Render (3 main sections: 알림 설정, 계정 관리, 앱 정보)
  - Buffer Time UI (4 sliders, default values)
  - Transport Mode Selection (대중교통/자가용)
  - Notification Settings (switches, sound setting)
  - Account Section (user profile display)
  - App Info Section (version, licenses)
  - UI Elements (scrollable, dividers, help text)

**Flutter 레이어 - E2E Tests** ✅ 완료:
- [x] E2E Test 1: 앱 시작 및 LoginScreen 렌더링 (3개 테스트) ✅ (2026-01-07)
  - 앱 시작 및 LoginScreen 표시
  - 로그인 폼 요소 렌더링
  - Light 테마 적용 확인
- [x] E2E Test 2: 대시보드 렌더링 - 로그인된 상태 (5개 테스트) ✅ (2026-01-07)
  - 인증된 사용자 DashboardScreen 표시
  - 사용자 환영 메시지
  - 빈 상태 표시 (일정 없음)
  - FAB 버튼 존재
  - 대시보드 UI 요소 렌더링
- [x] E2E Test 3: 일정 추가 플로우 (10개 테스트) ✅ (2026-01-07)
  - FAB 탭하여 AddScheduleScreen 이동
  - Step 1: 목적지 선택 UI
  - 최근 장소 및 즐겨찾기 표시
  - 목적지 선택 후 Step 2 이동
  - Step 2: 선택된 장소 표시
  - 이동 수단 옵션 표시
  - Step Indicator 표시
  - Next 버튼 표시
  - 유효성 검사 에러 표시
  - 대시보드로 뒤로 가기
- [x] E2E Test 4: 통합 시나리오 (5개 테스트) ✅ (2026-01-07)
  - 로그인 → 대시보드 → 일정 추가 전체 플로우
  - 빈 상태 대시보드 표시
  - 인증된 사용자 환영 메시지
  - 일정 추가 플로우 상태 유지
  - 다중 네비게이션 사이클 동작

**전체 테스트 현황**: 324개 테스트 통과 ✅

**Unit Tests** (235개):
- RouteService: 31개
- Trip Model: 29개
- NotificationService: 17개
- WidgetService: 22개
- PollingService, RealTimeUpdater, SchedulerService 등: 136개

**Widget Tests** (66개):
- DashboardScreen: 16개
- AddScheduleScreen: 31개
- SettingsScreen: 19개

**E2E Tests** (23개):
- App Start Test: 3개
- Dashboard Rendering Test: 5개
- Add Schedule Flow Test: 10개
- Integrated Scenario Test: 5개

**Android 네이티브** ⏳ 대기:
- [ ] Jetpack Glance 위젯 표시
- [ ] SharedPreferences 데이터 공유
- [ ] WorkManager 자동 업데이트
- [ ] 알림 채널 생성 및 알림 수신

**iOS 네이티브** ⏳ 대기:
- [ ] WidgetKit 위젯 표시
- [ ] App Groups 데이터 공유
- [ ] Timeline Provider 업데이트
- [ ] 알림 권한 및 알림 수신

**통합 테스트** ⏳ 대기:
- [ ] 위젯 + 알림 동기화
- [ ] 배터리 소모 < 2%/hour
- [ ] 메모리 사용량 < 50MB
- [ ] 모든 엣지 케이스 통과

---

### Phase 4: Integration & QA (Day 16~20) ✅ 완료 (100%)

**테스트 범위**:
- E2E 사용자 시나리오 ✅ 완료 (23개 테스트)
- TMAP API 통합 ✅ 완료 (4개 테스트)
- UI 패턴 일관성 ✅ 완료 (100% 일치율)
- Settings Screen Modal Update ✅ 완료 (Task 4.9)
- Legal Screens & Splash Screen ✅ 완료 (Task 4.8)
- 실제 환경 테스트 ⏳ 대기 (Phase 5로 이관)
- 성능 및 배터리 최적화 ⏳ 대기 (Phase 5로 이관)
- Alpha 사용자 테스트 ⏳ 대기 (Phase 5로 이관)

#### E2E Tests ✅ 완료 (23개 테스트)

**실제 구현된 E2E 테스트**:
1. **app_start_test.dart** (3 tests)
   - 앱 시작 및 LoginScreen 표시 확인
   - 로그인 폼 요소 렌더링 검증
   - 기본 테마 설정 확인

2. **dashboard_rendering_test.dart** (5 tests)
   - 인증된 사용자의 DashboardScreen 렌더링
   - 사용자 환영 메시지 표시
   - 빈 상태(일정 없음) UI 표시
   - FAB 버튼 존재 확인
   - 대시보드 UI 요소들 렌더링

3. **add_schedule_flow_test.dart** (10 tests)
   - FAB → AddScheduleScreen 네비게이션
   - 4단계 일정 추가 플로우 UI 검증
   - 목적지 선택 및 다음 단계 이동
   - 유효성 검사 에러 표시
   - 뒤로 가기 네비게이션

4. **integrated_scenario_test.dart** (5 tests)
   - 로그인 → 대시보드 → 일정 추가 전체 사용자 여정
   - 상태 유지 및 네비게이션 플로우 검증
   - 다중 네비게이션 사이클 동작 확인

---

**향후 계획 - E2E 시나리오 예시**

**4.1 신규 사용자 온보딩 시나리오**
```dart
// integration_test/e2e_onboarding_test.dart
testWidgets('신규 사용자 온보딩 플로우', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // 1. 회원가입
  await tester.tap(find.text('회원가입'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('email')), 'newuser@example.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  // ... 3단계 회원가입 플로우

  // 2. 첫 일정 추가
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('destination')), '강남역');
  // ... 4단계 일정 추가 플로우

  // 3. 대시보드에서 확인
  expect(find.text('강남역'), findsOneWidget);
  expect(find.byType(CountdownWidget), findsOneWidget);
});
```

**4.2 대중교통 경로 시나리오**
```dart
testWidgets('대중교통 경로 → 실시간 버스 도착 → 출발', (WidgetTester tester) async {
  // 1. 대중교통 일정 추가
  await addTransitTrip(tester, destination: '홍대입구역');

  // 2. 대시보드에서 경로 확인
  expect(find.byType(RouteDisplayWidget), findsOneWidget);
  expect(find.text('버스'), findsWidgets);

  // 3. 출발 버튼 클릭
  await tester.tap(find.text('출발했어요'));
  await tester.pumpAndSettle();

  // 4. 일정 완료 확인
  expect(find.text('일정이 없습니다'), findsOneWidget);
});
```

**4.3 교통 변화 시나리오**
```dart
testWidgets('자차 경로 → 교통 변화 → 출발 시간 재계산', (WidgetTester tester) async {
  // 1. 자차 일정 추가
  await addCarTrip(tester, destination: '판교역');

  final initialDepartureTime = findDepartureTime(tester);

  // 2. 교통 상황 변화 시뮬레이션 (TripProvider 모킹)
  when(mockRouteService.calculateRoute(any, any))
      .thenAnswer((_) async => RouteResult(duration: 45)); // 30분 → 45분

  // 3. 실시간 업데이트 대기
  await tester.pump(Duration(minutes: 5)); // 5분 간격 폴링
  await tester.pumpAndSettle();

  // 4. 출발 시간 재계산 확인
  final updatedDepartureTime = findDepartureTime(tester);
  expect(updatedDepartureTime.isBefore(initialDepartureTime), true);
});
```

**4.4 위젯 알림 통합 시나리오**
```dart
testWidgets('위젯 확인 → 알림 받기 → 출발', (WidgetTester tester) async {
  // 1. 일정 추가
  await addTrip(tester, minutesUntilDeparture: 31);

  // 2. 앱 종료 (백그라운드)
  await tester.pump(Duration(minutes: 1));

  // 3. 위젯 확인 (Native 테스트에서 수동)
  // - Android: 홈 화면에서 위젯 확인
  // - iOS: 홈 화면에서 위젯 확인

  // 4. 알림 수신 (1분 후 = 30분 전)
  // - 알림 확인 (Native 테스트에서 수동)

  // 5. 알림 클릭 → 앱 열기
  await tester.tap(find.byType(NotificationAction));
  await tester.pumpAndSettle();

  // 6. 대시보드로 이동 확인
  expect(find.byType(DashboardScreen), findsOneWidget);
});
```

#### 실제 시나리오 테스트

**4.5 실제 출퇴근 테스트**

**테스트 계획**:
1. **Day 1 (출근)**: 실제 출근 경로로 대중교통 테스트
   - 실제 위치에서 일정 추가
   - 실시간 버스/지하철 정보 확인
   - 알림 수신 확인
   - 실제로 출발하여 도착 시간 측정

2. **Day 1 (퇴근)**: 실제 퇴근 경로로 자차 테스트
   - 실제 교통 혼잡 시간대 테스트
   - 실시간 교통 정보 반영 확인
   - 출발 시간 재계산 확인

**측정 항목**:
- 예측 이동 시간 vs 실제 이동 시간 오차율
- 알림 타이밍 정확도
- 배터리 소모량
- 위젯 업데이트 주기 정확도

#### 성능 테스트

**4.6 배터리 소모 측정**

**Android**:
```bash
# 배터리 소모 측정 (8시간)
adb shell dumpsys batterystats --reset
# 8시간 대기 (일정 2개 추가, 위젯 활성화)
adb shell dumpsys batterystats | grep -A 10 "com.gonow.gotimesaver"
```

**목표**: 8시간 사용 시 배터리 소모 < 16% (시간당 2%)

**iOS**:
- 설정 → 배터리 → 앱별 배터리 사용량
- **목표**: 8시간 사용 시 배터리 소모 < 16%

---

**4.7 메모리 사용량 측정**

**Android**:
```bash
adb shell dumpsys meminfo com.gonow.gotimesaver
```

**목표**: 메모리 사용량 < 50MB

**iOS**:
- Xcode → Debug Navigator → Memory

**목표**: 메모리 사용량 < 50MB

---

**4.8 앱 시작 속도 측정**

**측정 방법**:
- Cold Start: 앱 완전 종료 후 실행
- Warm Start: 백그라운드에서 복귀

**Android**:
```bash
adb shell am start-activity -W com.gonow.gotimesaver/.MainActivity
```

**목표**:
- Cold Start < 2초
- Warm Start < 1초

**iOS**:
- Xcode → Debug Navigator → Time Profiler

**목표**:
- Cold Start < 2초
- Warm Start < 1초

#### Alpha 사용자 테스트

**4.9 사용자 피드백 수집**

**테스터 프로필**:
- 5-10명
- ADHD 진단 또는 유사 증상
- 출퇴근/약속 관리 필요
- Android/iOS 혼합

**테스트 기간**: 3일

**수집 항목**:
1. 기능 사용성 평가 (1-5점)
2. 버그 및 불편 사항
3. 개선 제안
4. 배터리 소모 체감
5. NPS 점수

#### 체크리스트

**E2E 테스트**:
- [ ] 신규 사용자 온보딩 시나리오 통과
- [ ] 대중교통 경로 시나리오 통과
- [ ] 자차 경로 시나리오 통과
- [ ] 위젯 알림 통합 시나리오 통과

**실제 환경 테스트**:
- [ ] 실제 출근 경로 테스트 완료
- [ ] 실제 퇴근 경로 테스트 완료
- [ ] 예측 vs 실제 오차율 < 15%

**성능 테스트**:
- [ ] 배터리 소모 < 2%/hour
- [ ] 메모리 사용량 < 50MB
- [ ] Cold Start < 2초
- [ ] Warm Start < 1초

**Alpha 테스트**:
- [ ] 10명 이상 테스터 확보
- [ ] 평균 사용성 점수 ≥ 4.0/5.0
- [ ] Critical 버그 0개
- [ ] High 버그 < 3개

---

### Phase 5: Launch Preparation (Day 21~25) ⏳ 대기

**테스트 범위**:
- 베타 테스트 (TestFlight, Google Play 내부 테스트)
- 스토어 제출 전 최종 검증
- 모니터링 시스템 테스트

#### 베타 테스트

**5.1 TestFlight 배포 (iOS)**

**테스트 항목**:
- [ ] Archive 빌드 성공
- [ ] TestFlight 업로드 성공
- [ ] 테스터 초대 및 다운로드 확인
- [ ] Crash 리포트 모니터링

---

**5.2 Google Play 내부 테스트 (Android)**

**테스트 항목**:
- [ ] Release 빌드 (AAB) 성공
- [ ] Google Play Console 업로드 성공
- [ ] 테스터 초대 및 다운로드 확인
- [ ] Crash 리포트 모니터링

---

**5.3 최종 검증 체크리스트**

**기능 검증**:
- [ ] 모든 핵심 기능 정상 작동
- [ ] Critical/High 버그 0개
- [ ] 알려진 Medium 버그 문서화

**성능 검증**:
- [ ] 배터리 소모 목표 달성
- [ ] 메모리 사용량 목표 달성
- [ ] 앱 시작 속도 목표 달성

**보안 검증**:
- [ ] API 키 환경 변수 처리
- [ ] RLS 정책 검증
- [ ] 민감 데이터 암호화 확인

**접근성 검증**:
- [ ] Screen Reader 지원
- [ ] 고대비 모드 지원
- [ ] 폰트 크기 조정 지원

**법적 검증**:
- [ ] 개인정보 처리방침 링크 확인
- [ ] 이용약관 링크 확인
- [ ] 약관 동의 체크 작동

---

## 🧪 테스트 유형별 가이드

### Unit Tests

**위치**: `test/`

**실행**:
```bash
flutter test
```

**커버리지 목표**: 80%+

**커버리지 측정**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**작성 가이드**:
```dart
// test/services/example_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExampleService', () {
    late ExampleService service;

    setUp(() {
      service = ExampleService();
    });

    test('메서드가 예상 값을 반환함', () {
      final result = service.calculate(10, 20);
      expect(result, 30);
    });

    test('잘못된 입력에 대해 예외를 던짐', () {
      expect(
        () => service.calculate(-1, 20),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

---

### Widget Tests

**위치**: `test/`

**실행**:
```bash
flutter test test/widgets/
```

**커버리지 목표**: 70%+

**작성 가이드**:
```dart
// test/widgets/example_widget_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('위젯이 정상적으로 렌더링됨', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExampleWidget(),
      ),
    );

    expect(find.text('예제 텍스트'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('버튼 클릭 시 상태 변경', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ExampleWidget()));

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.text('클릭됨'), findsOneWidget);
  });
}
```

---

### Integration Tests

**위치**: `integration_test/`

**실행**:
```bash
# Android
flutter test integration_test/app_test.dart

# iOS
flutter test integration_test/app_test.dart --device-id <device_id>
```

**작성 가이드**:
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('전체 앱 통합 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // 실제 API 호출, 실제 DB 연동
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    // 실제 네비게이션
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
```

---

### E2E Tests

**위치**: `integration_test/e2e/`

**실행**:
```bash
# 실제 디바이스 필요
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/e2e/complete_flow_test.dart
```

**작성 가이드**:
```dart
// integration_test/e2e/complete_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('완전한 사용자 플로우', (WidgetTester tester) async {
    // 1. 회원가입
    // 2. 로그인
    // 3. 일정 추가
    // 4. 대시보드 확인
    // 5. 위젯 확인 (Native 레이어 수동 확인 필요)
    // 6. 알림 수신 (Native 레이어 수동 확인 필요)
    // 7. 로그아웃
  });
}
```

---

## 🔒 보안 테스트

### API 키 보안

**체크리스트**:
- [ ] `.env` 파일이 `.gitignore`에 포함됨
- [ ] 코드에 하드코딩된 API 키 없음
- [ ] 환경 변수로 API 키 관리

**검증 방법**:
```bash
# Git 히스토리에서 API 키 검색
git log -p | grep -i "api_key\|secret\|password"

# 현재 코드에서 하드코딩 검색
grep -r "TMAP_API_KEY\|SUPABASE_KEY" lib/
```

---

### Row Level Security (RLS)

**체크리스트**:
- [ ] 모든 테이블에 RLS 정책 활성화
- [ ] 사용자는 자신의 데이터만 조회 가능
- [ ] INSERT/UPDATE/DELETE 권한 제한

**검증 방법**:
```sql
-- Supabase SQL Editor에서 실행
-- 다른 사용자의 데이터 조회 시도 (실패해야 함)
SELECT * FROM schedules WHERE user_id != auth.uid();
```

---

### 데이터 암호화

**체크리스트**:
- [ ] 로컬 저장 데이터 암호화 (EncryptedSharedPreferences)
- [ ] 네트워크 통신 HTTPS 사용
- [ ] 민감 정보 로그 출력 방지

---

## ♿ 접근성 테스트

### Screen Reader 지원

**Android (TalkBack)**:
```bash
# TalkBack 활성화 확인
adb shell settings get secure enabled_accessibility_services
```

**iOS (VoiceOver)**:
- 설정 → 손쉬운 사용 → VoiceOver 활성화

**체크리스트**:
- [ ] 모든 버튼에 의미 있는 라벨
- [ ] 이미지에 대체 텍스트 (semanticLabel)
- [ ] 네비게이션 순서 논리적

---

### 고대비 모드

**체크리스트**:
- [ ] 텍스트 대비 비율 ≥ 4.5:1
- [ ] 초록/주황/빨강 색상이 고대비 모드에서 구분 가능
- [ ] 색상만으로 정보 전달하지 않음 (아이콘 + 색상)

---

### 폰트 크기 조정

**테스트 방법**:
- Android: 설정 → 디스플레이 → 글꼴 크기
- iOS: 설정 → 손쉬운 사용 → 디스플레이 및 텍스트 크기

**체크리스트**:
- [ ] 큰 글꼴에서 레이아웃 깨지지 않음
- [ ] 작은 글꼴에서 가독성 유지
- [ ] Text overflow 적절히 처리

---

## 📊 테스트 리포트 템플릿

### 일일 테스트 리포트

```markdown
# 테스트 리포트 - 2026-01-07

## 테스트 정보
- **테스터**: [이름]
- **Phase**: Phase 3
- **플랫폼**: Android 14 / iOS 17
- **디바이스**: Pixel 7 / iPhone 14

## 테스트 결과 요약
- **Total Tests**: 120
- **Passed**: 115 (95.8%)
- **Failed**: 5 (4.2%)
- **Skipped**: 0

## 주요 발견 사항

### 🐛 버그
1. **[High] 위젯 업데이트 지연**
   - **재현**: 일정 추가 후 위젯 업데이트까지 30초 소요
   - **예상**: 5초 이내 업데이트
   - **플랫폼**: Android

2. **[Medium] 알림 메시지 오타**
   - **재현**: 10분 전 알림 메시지에 오타 발견
   - **플랫폼**: iOS

### ✅ 성공 항목
- 모든 색상 단계 테스트 통과
- 30분 알림 정확도 100%
- 배터리 소모 1.8%/hour (목표: 2%)

## 다음 단계
- [ ] High 버그 수정
- [ ] 재테스트 수행
- [ ] iOS 베타 배포
```

---

## 📝 테스트 자동화

### CI/CD 통합

**GitHub Actions 예시**:
```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## 🎯 전체 체크리스트 요약

### Phase 1 ✅
- [x] UI 위젯 렌더링 테스트
- [x] 네비게이션 플로우 테스트
- [x] 폼 유효성 검사 테스트
- [x] AuthProvider 상태 관리 테스트

### Phase 2 ✅
- [x] SchedulerService 48개 단위 테스트
- [x] TMAP API 통합 테스트
- [x] Supabase CRUD 테스트
- [x] TripProvider 통합 테스트

### Phase 3 ✅ Android / ⏳ iOS
- [x] Flutter WidgetService 테스트
- [x] Flutter NotificationService 테스트
- [x] Android 네이티브 위젯 테스트 (디바이스 검증 완료: SM A136S)
- [ ] iOS 네이티브 위젯 테스트 (Xcode 작업 후)
- [ ] 배터리 소모 테스트
- [ ] 메모리 사용량 테스트

### Phase 4 ✅
- [x] E2E 사용자 시나리오 테스트 (23개 테스트 통과)
- [x] TMAP API 통합 테스트 (4개 테스트 통과)
- [x] UI 패턴 일관성 개선 (100% 달성)
- [x] Settings Screen Modal Update (Task 4.9 완료)
- [x] Legal Screens & Splash Screen (Task 4.8 완료)
- [ ] 실제 환경 테스트 (Phase 5로 이관)
- [ ] 성능 최적화 검증 (Phase 5로 이관)
- [ ] Alpha 사용자 피드백 수집 (Phase 5로 이관)

### Phase 5 ⏳
- [ ] TestFlight 베타 테스트
- [ ] Google Play 내부 테스트
- [ ] 최종 검증 체크리스트
- [ ] 스토어 제출 전 리뷰

---

## 🔗 관련 문서 링크

- [README.md](./README.md) - 프로젝트 메인 네비게이션
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - Phase별 구현 가이드
- [phase3/INTEGRATION_TEST_GUIDE.md](./phase3/INTEGRATION_TEST_GUIDE.md) - Phase 3 상세 테스트 가이드

---

**작성일**: 2026-01-07
**최종 수정**: 2026-01-09
**작성자**: Claude
**버전**: 1.5
**다음 업데이트**: Phase 5 준비 시

---

**Made with 🤖 [Claude Code](https://claude.com/claude-code)**
