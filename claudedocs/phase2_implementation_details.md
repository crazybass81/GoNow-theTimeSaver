# Phase 2 상세 구현 계획: 구조적 변경

**날짜**: 2026-01-07
**목표**: 참조 저장소(khyapple/go_now)의 시각적 구조에 맞춰 주요 UI 컴포넌트 단순화

---

## 📋 Phase 2 개요

### 목표
참조 저장소의 단순하고 깔끔한 디자인을 따라가기 위한 구조적 변경:
1. AppBar 단순화 + 날짜 헤더 추가
2. CircularTimerWidget 시각적 단순화 (기능 보존)
3. Next Schedule Card 단순화 (Container 제거, 텍스트만)

### 예상 소요 시간
- Task 2.1: 30분
- Task 2.2: 40분
- Task 2.3: 20분
- 테스트: 15분
- **총 예상**: ~1시간 45분

---

## Task 2.1: AppBar & 날짜 헤더 변경

### 현재 상태
```dart
// lib/screens/dashboard/dashboard_screen.dart:72-102
appBar: AppBar(
  title: const Text('GoNow'),
  actions: [
    IconButton(icon: Icon(Icons.calendar_month_outlined), ...),
    IconButton(icon: Icon(Icons.settings_outlined), ...),
  ],
),
body: ...[
  _buildWelcomeSection(theme, authProvider),  // "안녕하세요, {userName}님"
  ...
]
```

### 참조 저장소
- AppBar 없음
- body 최상단에 날짜 헤더: "2024년 1월 15일 (월)" (32px, bold, centered)

### 변경 후 (Option B: 기능 보존)
```dart
appBar: AppBar(
  elevation: 0,  // flat
  centerTitle: true,
  backgroundColor: Colors.transparent,  // or theme.colorScheme.surface
  title: Text(
    _getFormattedDate(),  // "2024년 1월 15일 (월)"
    style: AppTextStyles.dateHeader.copyWith(
      color: theme.colorScheme.onSurface,
    ),
  ),
  actions: [
    // 캘린더/설정 버튼 유지
    IconButton(icon: Icon(Icons.calendar_month_outlined), ...),
    IconButton(icon: Icon(Icons.settings_outlined), ...),
  ],
),
body: ...[
  // _buildWelcomeSection 제거
  tripProvider.upcomingTrip != null ? ... : ...,
]
```

### 날짜 포맷 헬퍼 메서드
```dart
/// 날짜 헤더 텍스트 생성 / Generate date header text
/// 예: "2024년 1월 15일 (월)"
String _getFormattedDate() {
  final now = DateTime.now();
  final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[now.weekday - 1];

  return '${now.year}년 ${now.month}월 ${now.day}일 ($weekday)';
}
```

### 변경 포인트
1. **AppBar title 변경**: `const Text('GoNow')` → `Text(_getFormattedDate(), style: AppTextStyles.dateHeader)`
2. **AppBar elevation 추가**: `elevation: 0`
3. **centerTitle 추가**: `centerTitle: true`
4. **_buildWelcomeSection 제거**: lines 121, 245-267 삭제
5. **_getFormattedDate() 메서드 추가**: 클래스 내부에 추가

---

## Task 2.2: CircularTimerWidget 스타일링 단순화

### 파일 위치
`lib/widgets/circular_timer_widget.dart`

### 변경 포인트

#### 2.2-a: strokeWidth 변경
```dart
// Before (lines 198, 211):
strokeWidth: 20,

// After:
strokeWidth: 12,
```

#### 2.2-b: 색상 단순화
```dart
// Before:
// 동적 색상 시스템 사용 (_currentColor = AppTheme.getTimeColor(_minutesLeft))
// lines 43, 112, 200, 213, 229, 283

// After:
// 고정 색상 사용
import '../utils/app_colors.dart';

// Background circle (line 196-202):
SizedBox(
  width: 250,
  height: 250,
  child: CircularProgressIndicator(
    value: 1.0,
    strokeWidth: 12,
    valueColor: AlwaysStoppedAnimation<Color>(
      const Color(0xFFBDBDBD),  // Colors.grey[400] for background
    ),
  ),
),

// Progress circle (line 206-217):
SizedBox(
  width: 250,
  height: 250,
  child: CircularProgressIndicator(
    value: _calculateProgress(),
    strokeWidth: 12,
    valueColor: AlwaysStoppedAnimation<Color>(
      AppColors.primary,  // blue[600]
    ),
    strokeCap: StrokeCap.round,
  ),
),

// 텍스트 색상 (line 229):
color: AppColors.primary,  // 고정 색상
```

#### 2.2-c: 펄스 애니메이션 제거
```dart
// 제거할 것:
1. _pulseController 선언 (line 38)
2. _pulseAnimation 선언 (line 39)
3. _initializeAnimations() 메서드 (lines 61-82)
4. dispose()에서 _pulseController.dispose() (line 56)
5. 펄스 시작/중지 로직 (lines 115-120)
6. AnimatedBuilder 래퍼 (lines 158-161, 260)
7. Transform.scale (lines 161-163)

// 유지할 것:
- _updateRemainingTime() 로직 (카운트다운)
- _calculateProgress() 로직
- Timer 업데이트
```

**변경 후 build() 메서드 구조**:
```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppColors.referenceShadow,  // 단순화된 그림자
    ),
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 원형 타이머 (250x250px Stack)
        SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(...),
              // Progress circle
              SizedBox(...),
              // 중앙 텍스트
              Column(...),
            ],
          ),
        ),
        // 상태 인디케이터 제거 (lines 252-305 삭제)
      ],
    ),
  );
}
```

#### 2.2-d: 상태 인디케이터 제거
```dart
// 제거:
- _buildStatusIndicator() 메서드 전체 (lines 265-305)
- build()에서 호출 부분 (line 255)
- const SizedBox(height: 24) (line 252)

// After:
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    SizedBox(width: 250, height: 250, child: Stack(...)),
    // 상태 인디케이터 제거 - Stack 바로 아래 끝
  ],
),
```

#### 2.2-e: BoxShadow 단순화
```dart
// Before (lines 168-179):
boxShadow: [
  BoxShadow(
    color: _currentColor.withOpacity(0.15),
    blurRadius: 20,
    offset: const Offset(0, 4),
  ),
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 2),
  ),
],

// After:
boxShadow: AppColors.referenceShadow,
```

### 제거할 변수 및 메서드 목록
1. `_pulseController` (line 38)
2. `_pulseAnimation` (line 39)
3. `_currentColor` (line 43) - 더 이상 동적 색상 불필요
4. `_minutesLeft` (line 42) - 상태 인디케이터에만 사용되므로 제거 가능
5. `_initializeAnimations()` (lines 61-82)
6. `_buildStatusIndicator()` (lines 265-305)
7. `AppTheme.getTimeColor()` 호출 (line 112)

### 보존할 변수 및 메서드 목록
1. `_timer` - 카운트다운 업데이트
2. `_remainingTime` - 남은 시간 계산
3. `_updateRemainingTime()` - 시간 업데이트 로직
4. `_calculateProgress()` - 프로그레스 바 값
5. `_getRemainingTimeText()` - "N분 후 출발" 텍스트
6. `_getArrivalTimeText()` - "HH:MM 도착" 텍스트
7. `onCountdownComplete` 콜백

---

## Task 2.3: Next Schedule Card 단순화

### 파일 위치
`lib/screens/dashboard/dashboard_screen.dart`

### 현재 _buildNextScheduleSection (lines 270-366)
```dart
Widget _buildNextScheduleSection(ThemeData theme, Trip trip) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // "다음 일정" 타이틀 (lines 274-289)
      Row(
        children: [
          Icon(Icons.event, ...),
          Text('다음 일정', ...),
        ],
      ),

      // Container 카드 (lines 293-350)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [...],  // 복잡한 그림자
        ),
        child: Row(
          children: [
            Icon(Icons.place, ...),
            Column(
              '${trip.emoji} ${trip.title}',
              '도착 예정 시간',
              'trip.destinationAddress',  // 주소 표시
            ),
          ],
        ),
      ),

      // CircularTimerWidget (lines 354-363)
      CircularTimerWidget(...),
    ],
  );
}
```

### 참조 저장소 구조
```dart
// 타이틀 없음
// 카드 없음
// 단순 텍스트:
Text("회사 미팅", 28px, bold, centered),
Text("15:30 도착 예정", 16px, medium, centered),
CircularProgressIndicator,
```

### 변경 후
```dart
/// 다음 일정 섹션 / Next schedule section (참조 저장소 패턴)
Widget _buildNextScheduleSection(ThemeData theme, Trip trip) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,  // center alignment
    children: [
      // 일정 제목 (emoji + title)
      Text(
        '${trip.emoji} ${trip.title}',
        style: AppTextStyles.referenceTitle.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),

      // 도착 예정 시간
      Text(
        '${trip.arrivalTime.hour}:${trip.arrivalTime.minute.toString().padLeft(2, '0')} 도착 예정',
        style: AppTextStyles.referenceBody.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),

      // 원형 타이머
      CircularTimerWidget(
        targetTime: trip.arrivalTime,
        departureTime: trip.departureTime,
        onCountdownComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('출발 시간입니다!')),
          );
        },
      ),
    ],
  );
}
```

### 변경 포인트
1. **"다음 일정" 타이틀 제거**: lines 274-289 삭제
2. **Container 카드 제거**: lines 293-350 삭제
3. **crossAxisAlignment 변경**: `start` → `center`
4. **단순 텍스트로 교체**: emoji + title, 도착 시간만
5. **AppTextStyles 사용**: `referenceTitle` (28px), `referenceBody` (16px)
6. **textAlign 추가**: `TextAlign.center`
7. **destinationAddress 제거**: 주소 표시 안 함
8. **Icon 제거**: Icons.event, Icons.place 모두 제거

---

## 테스트 체크리스트

### Task 2.1 테스트
- [ ] AppBar에 날짜가 정확하게 표시됨 (오늘 날짜 + 요일)
- [ ] 날짜 포맷이 올바름: "YYYY년 M월 D일 (요일)"
- [ ] AppBar가 flat함 (elevation: 0)
- [ ] 제목이 중앙 정렬됨
- [ ] 캘린더/설정 버튼 정상 작동
- [ ] Welcome 섹션이 사라짐
- [ ] 화면 레이아웃이 자연스러움

### Task 2.2 테스트
- [ ] CircularProgressIndicator strokeWidth가 얇아짐 (12px)
- [ ] 배경 원이 회색으로 표시됨 (grey[300])
- [ ] 진행 원이 파란색으로 표시됨 (blue[600])
- [ ] 동적 색상 변화 없음 (항상 파란색)
- [ ] 펄스 애니메이션 없음
- [ ] 상태 인디케이터("여유 있어요" 등) 없음
- [ ] 카운트다운이 정상 작동함 (1초마다 업데이트)
- [ ] onCountdownComplete 콜백 작동
- [ ] 그림자가 단순해짐

### Task 2.3 테스트
- [ ] "다음 일정" 타이틀 없음
- [ ] Container 카드 없음 (배경색, 테두리 없음)
- [ ] emoji + title이 중앙 정렬로 표시됨
- [ ] 도착 시간이 중앙 정렬로 표시됨
- [ ] 주소가 표시되지 않음
- [ ] CircularTimerWidget이 정상 표시됨
- [ ] 텍스트 크기가 올바름 (28px, 16px)

### 전체 통합 테스트
- [ ] 앱 실행 시 크래시 없음
- [ ] 일정이 있을 때 정상 표시
- [ ] 일정이 없을 때 Empty state 표시
- [ ] RefreshIndicator 정상 작동
- [ ] FloatingActionButton 정상 작동
- [ ] 경로 섹션 정상 표시 (다음 Phase에서 수정 예정)
- [ ] 이후 일정 리스트 정상 표시 (다음 Phase에서 수정 예정)

---

## 예상 문제점 및 해결 방안

### 문제 1: CircularTimerWidget 색상 import 오류
**증상**: AppColors 또는 AppTheme import 오류
**해결**:
```dart
import '../utils/app_colors.dart';
// AppTheme.dart 대신 AppColors.dart 사용
```

### 문제 2: _currentColor 제거로 인한 참조 오류
**증상**: _currentColor를 참조하는 코드 남아있음
**해결**: 전체 검색하여 모든 _currentColor 참조를 AppColors.primary로 교체

### 문제 3: 애니메이션 제거 후 상태 관리 오류
**증상**: SingleTickerProviderStateMixin 관련 오류
**해결**:
```dart
// Before:
class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {

// After (애니메이션 없으므로):
class _CircularTimerWidgetState extends State<CircularTimerWidget> {
```

### 문제 4: 날짜 헤더 요일 오류
**증상**: 요일 배열 인덱스 오류
**해결**:
```dart
// DateTime.weekday는 1 (월요일) ~ 7 (일요일)
final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
final weekday = weekdays[now.weekday - 1];  // -1 중요!
```

### 문제 5: AppTextStyles.referenceTitle 없음
**증상**: referenceTitle이 정의되지 않음
**해결**: Phase 1에서 이미 추가했으므로 문제 없음. 만약 오류 발생 시:
```dart
// app_text_styles.dart에 추가
static const TextStyle referenceTitle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  height: 1.3,
);
```

### 문제 6: 중앙 정렬 후 레이아웃 깨짐
**증상**: Next Schedule 섹션이 이상하게 표시됨
**해결**:
```dart
// Column의 mainAxisSize 확인
Column(
  mainAxisSize: MainAxisSize.min,  // min으로 설정
  crossAxisAlignment: CrossAxisAlignment.center,
  ...
)
```

---

## 구현 순서

### 권장 구현 순서
1. **Task 2.3 먼저** (가장 간단, 빠른 시각적 피드백)
   - _buildNextScheduleSection 단순화
   - 테스트

2. **Task 2.1** (중간 난이도)
   - AppBar 수정
   - _buildWelcomeSection 제거
   - 테스트

3. **Task 2.2** (가장 복잡, 신중히 작업)
   - CircularTimerWidget 단순화
   - 애니메이션 제거
   - 테스트

### 이유
- 간단한 것부터 시작하여 자신감 획득
- 각 단계에서 테스트하여 문제 조기 발견
- CircularTimerWidget은 가장 복잡하므로 마지막에 집중

---

## 다음 단계 (Phase 3 미리보기)

Phase 2 완료 후 Phase 3에서 수정할 것:
1. Route section ExpansionTile 스타일링
2. Upcoming cards 레이아웃 정리
3. 전체적인 spacing/padding 조정

---

## 커밋 메시지 템플릿

```
feat: Phase 2 - UI 구조 단순화 (참조 저장소 패턴)

**Task 2.1: AppBar & 날짜 헤더**:
- AppBar title을 날짜 헤더로 변경 (YYYY년 M월 D일 (요일))
- elevation: 0으로 flat하게
- _buildWelcomeSection 제거

**Task 2.2: CircularTimerWidget 단순화**:
- strokeWidth: 20 → 12
- 동적 색상 제거 (grey[300] background, blue[600] progress)
- 펄스 애니메이션 제거
- 상태 인디케이터 제거
- BoxShadow 단순화

**Task 2.3: Next Schedule Card 단순화**:
- "다음 일정" 타이틀 제거
- Container 카드 제거
- 단순 텍스트로 표시 (emoji + title, 도착 시간)
- 중앙 정렬

**Context**: khyapple/go_now 참조 저장소 UI 매칭

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
