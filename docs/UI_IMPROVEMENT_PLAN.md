# UI Improvement Plan - 기준 저장소 패턴 적용

**작성일**: 2025-01-07
**최종 업데이트**: 2025-01-07 17:45
**기준 저장소**: https://github.com/khyapple/go_now (master 브랜치)
**상태**: Phase 2 완료 (100%)

## 📈 진행 상황

### ✅ Phase 1 완료 (100%)
- [x] 원형 타이머 위젯 구현 (`CircularTimerWidget`)
- [x] MainWrapper 네비게이션 구현 (PageView + SharedPreferences)
- [x] DashboardScreen BoxShadow 적용
- [x] LoginScreen 네비게이션 업데이트

### ✅ Phase 2 완료 (100%)
- [x] 색상 피커 위젯 구현 (`ColorPickerWidget`)
- [x] 이모지 피커 위젯 구현 (`EmojiPickerWidget`)
- [x] AddScheduleScreen 리팩토링 완료 (4단계 PageView → 단일 스크롤)
- [x] DashboardScreen FAB 네비게이션 업데이트 (`AddScheduleScreenNew` 사용)

### ⏳ Phase 3 대기 중
- [ ] 추가 디자인 시스템 개선
- [ ] 애니메이션 최적화

---

## 📊 비교 분석

### 화면 매핑

| 현재 프로젝트 | 기준 저장소 | 상태 |
|--------------|------------|------|
| DashboardScreen | HomeScreen | ✅ 존재 |
| AddScheduleScreen | ScheduleEditScreen | ✅ 존재 |
| CalendarScreen | CalendarScreen | ✅ 존재 |
| SettingsScreen | SettingsScreen | ✅ 존재 |
| LoginScreen | LoginScreen | ✅ 존재 |
| SignupScreen | SignupScreen | ✅ 존재 |
| MainWrapper | MainWrapper | ✅ 구현 완료 (PageView 네비게이션) |
| - | SplashScreen | ❌ 미구현 |
| - | ScheduleDetailScreen | ❌ 미구현 |
| - | PrivacyPolicyScreen | ❌ 미구현 |
| - | TermsScreen | ❌ 미구현 |

---

## 🎯 주요 개선 사항

### 1. DashboardScreen → HomeScreen 패턴 적용

#### 현재 구조
```dart
// 현재: 기본적인 카운트다운 위젯
Container(
  child: CountdownWidget(...),
)

// 기본 카드 레이아웃
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

#### 개선 목표 (기준 저장소 패턴)
```dart
// ✨ 원형 타이머 위젯 (큰 시각적 임팩트)
Stack(
  alignment: Alignment.center,
  children: [
    // 진행률 표시 원형 인디케이터
    SizedBox(
      width: 250,
      height: 250,
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 20,
      ),
    ),
    // 중앙 시간 표시
    Column(
      children: [
        Text('45분 후 출발', fontSize: 64, fontWeight: FontWeight.bold),
        Text('14:30 도착', fontSize: 28),
      ],
    ),
  ],
)

// 🎨 색상 기반 카테고리 구분
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
)

// 🔽 ExpansionTile 경로 선택
ExpansionTile(
  tilePadding: EdgeInsets.zero,
  childrenPadding: EdgeInsets.zero,
  trailing: Icon(...),
  children: [
    // 경로 옵션들
  ],
)

// ⏱️ 시간 배지 포함 스케줄 카드
Row(
  children: [
    Container(
      // 색상 배지
      decoration: BoxDecoration(
        color: scheduleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(12),
      child: Text('14:30'),
    ),
    // 일정 정보
  ],
)
```

**적용할 UI 패턴:**
- ✅ 원형 타이머 디스플레이 (250x250px, 진행률 표시)
- ✅ BoxShadow 깊이감 (blurRadius: 10-20)
- ✅ ExpansionTile 경로 선택
- ✅ 색상 기반 카테고리 구분
- ✅ 시간 배지가 있는 스케줄 카드

---

### 2. MainWrapper 구현 (네비게이션 패턴)

#### 현재 구조
```dart
// 현재: 개별 화면 간 Navigator.push
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CalendarScreen()),
);
```

#### 개선 목표 (기준 저장소 패턴)
```dart
// ✨ PageView 기반 네비게이션
class MainWrapper extends StatefulWidget {
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentPage(); // SharedPreferences에서 복원
  }

  Future<void> _loadCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('current_page') ?? 0;
    setState(() => _currentPage = savedPage);
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_page', page);
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView로 홈/캘린더 전환
          PageView(
            controller: _pageController,
            onPageChanged: _savePage,
            children: [
              HomeScreen(),
              CalendarScreen(),
            ],
          ),
          // 커스텀 하단 인디케이터
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator('홈', 0),
                SizedBox(width: 40),
                _buildPageIndicator('캘린더', 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(String label, int index) {
    final isActive = _currentPage == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

**적용할 UI 패턴:**
- ✅ PageView 기반 스와이프 네비게이션
- ✅ SharedPreferences 페이지 상태 저장
- ✅ 커스텀 페이지 인디케이터 (하단 중앙)
- ✅ 애니메이션 페이지 전환 (300ms, easeInOut)

---

### 3. AddScheduleScreen → ScheduleEditScreen 패턴 적용

#### 현재 구조
```dart
// 현재: 4단계 PageView 플로우
PageView(
  controller: _pageController,
  children: [
    _buildStep1(), // 목적지
    _buildStep2(), // 시간/이동수단
    _buildStep3(), // 버퍼 시간
    _buildStep4(), // 확인
  ],
)
```

#### 개선 목표 (기준 저장소 패턴)
```dart
// ✨ 단일 스크롤 화면 + 섹션 구분
SingleChildScrollView(
  child: Column(
    children: [
      // 제목
      TextField(...),
      SizedBox(height: 20),

      // 날짜/시간
      _buildReadOnlyField(
        label: '날짜 및 시간',
        value: formattedDateTime,
        onTap: () => _showDateTimePicker(),
      ),

      // 위치 (주소 검색 통합)
      _buildReadOnlyField(
        label: '위치',
        value: address,
        onTap: () => _showAddressSearch(),
      ),

      // 이동 수단 (DropdownButton)
      DropdownButton<String>(
        value: transportMode,
        items: [
          DropdownMenuItem(
            value: 'transit',
            child: Row(
              children: [
                Icon(Icons.directions_transit),
                SizedBox(width: 8),
                Text('대중교통'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'car',
            child: Row(
              children: [
                Icon(Icons.directions_car),
                SizedBox(width: 8),
                Text('자동차'),
              ],
            ),
          ),
        ],
        onChanged: (value) => setState(() => transportMode = value),
      ),

      // 🎨 색상 선택
      _buildColorPicker(),

      // 😊 이모지 선택
      _buildEmojiPicker(),

      // ⏰ 준비 시간 커스터마이징
      _buildTimeItemSelector(
        title: '준비 시간',
        items: preparationItems,
        onAdd: () => _showTimeItemDialog('preparation'),
      ),

      // 🏁 마무리 시간 커스터마이징
      _buildTimeItemSelector(
        title: '마무리 시간',
        items: finishingItems,
        onAdd: () => _showTimeItemDialog('finishing'),
      ),

      // 저장 버튼
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveSchedule,
          child: Text('저장'),
        ),
      ),
    ],
  ),
)

// 🎨 색상 피커
Widget _buildColorPicker() {
  return Wrap(
    spacing: 10,
    children: [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ].map((color) {
      final isSelected = selectedColor == color;
      return GestureDetector(
        onTap: () => setState(() => selectedColor = color),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.black, width: 3)
                : null,
            boxShadow: isSelected
                ? [BoxShadow(blurRadius: 8, color: color.withOpacity(0.5))]
                : null,
          ),
          child: isSelected
              ? Icon(Icons.check, color: Colors.white)
              : null,
        ),
      );
    }).toList(),
  );
}

// 😊 이모지 피커
Widget _buildEmojiPicker() {
  final emojis = ['😊', '🎉', '💼', '🏃', '📚', '🍽️', '⚽', '🎵', '🛒', '✈️',
                  '🏥', '🎓', '💰', '🏠', '🚗', '🎂', '☕', '🎮', '🧘', '🐶'];

  return GridView.count(
    crossAxisCount: 5,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: emojis.map((emoji) {
      final isSelected = selectedEmoji == emoji;
      return GestureDetector(
        onTap: () => setState(() => selectedEmoji = emoji),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 32)),
          ),
        ),
      );
    }).toList(),
  );
}

// ⏰ 시간 아이템 선택기
Widget _buildTimeItemSelector({
  required String title,
  required List<TimeItem> items,
  required VoidCallback onAdd,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: onAdd,
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: items.map((item) {
          return Chip(
            avatar: Text(item.emoji, style: TextStyle(fontSize: 20)),
            label: Text('${item.name} (${item.minutes}분)'),
            onDeleted: () => _removeTimeItem(item),
          );
        }).toList(),
      ),
    ],
  );
}
```

**적용할 UI 패턴:**
- ✅ 단일 스크롤 화면 (단계 분리 대신)
- ✅ 색상 피커 (원형 스와치, 선택 표시)
- ✅ 이모지 선택기 (5열 그리드)
- ✅ 준비/마무리 시간 커스터마이징
- ✅ DropdownButton 이동 수단 선택
- ✅ ReadOnly 필드 + Tap → Picker 패턴

---

## 📋 구현 우선순위

### Phase 1: 핵심 화면 개선 (우선순위: 높음)
1. **DashboardScreen → HomeScreen 패턴**
   - [ ] 원형 타이머 위젯 구현
   - [ ] ExpansionTile 경로 선택
   - [ ] 색상 카테고리 시스템
   - [ ] BoxShadow 깊이감 적용
   - [ ] 시간 배지 스케줄 카드

2. **MainWrapper 구현**
   - [ ] PageView 네비게이션
   - [ ] SharedPreferences 상태 저장
   - [ ] 커스텀 페이지 인디케이터
   - [ ] 애니메이션 전환

### Phase 2: 일정 관리 개선 (우선순위: 중간) ✅ 완료
3. **AddScheduleScreen → ScheduleEditScreen 패턴**
   - [x] 단일 스크롤 레이아웃 전환
   - [x] 색상 피커 구현 (`ColorPickerWidget`)
   - [x] 이모지 선택기 구현 (`EmojiPickerWidget`)
   - [x] 버퍼 시간 슬라이더 구현 (준비/도착버퍼/오차율/마무리)
   - [x] DropdownButton 이동 수단

### Phase 3: 추가 화면 구현 (우선순위: 낮음)
4. **새 화면 추가**
   - [ ] SplashScreen
   - [ ] ScheduleDetailScreen
   - [ ] PrivacyPolicyScreen / TermsScreen

---

## 🎨 디자인 시스템 통일

### 색상 시스템
```dart
// 기준 저장소 패턴
class AppColors {
  // 카테고리 색상
  static const Map<String, Color> scheduleColors = {
    'blue': Color(0xFF2196F3),
    'red': Color(0xFFE57373),
    'orange': Color(0xFFFFB74D),
    'yellow': Color(0xFFFFF176),
    'green': Color(0xFF81C784),
    'purple': Color(0xFFBA68C8),
  };

  // 그림자
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
```

### 타이포그래피
```dart
// 기준 저장소 패턴
class AppTextStyles {
  static const timerLarge = TextStyle(fontSize: 64, fontWeight: FontWeight.bold);
  static const timerMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const scheduleTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const scheduleSubtitle = TextStyle(fontSize: 14, color: Colors.grey);
  static const badgeTime = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
```

### 간격 시스템
```dart
// 기준 저장소 패턴
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}
```

### 둥근 모서리
```dart
// 기준 저장소 패턴
class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double circular = 20;
}
```

---

## 🔧 기술 스택 변경사항

### 새로 추가할 패키지
```yaml
dependencies:
  # 네비게이션 상태 저장
  shared_preferences: ^2.2.2

  # 현재 이미 사용 중
  # table_calendar: ^3.0.9  # CalendarScreen
  # intl: ^0.18.1            # 날짜 포맷팅
```

---

## 📝 구현 체크리스트

### Phase 1: DashboardScreen + MainWrapper
- [ ] `lib/widgets/circular_timer_widget.dart` 생성
- [ ] `lib/widgets/schedule_card_widget.dart` 개선 (색상 배지 추가)
- [ ] `lib/screens/dashboard/dashboard_screen.dart` → `home_screen.dart` 리팩토링
- [ ] `lib/screens/main_wrapper.dart` 생성
- [ ] `lib/main.dart` 진입점을 `MainWrapper`로 변경
- [ ] `lib/utils/app_colors.dart` 생성 (색상 시스템)
- [ ] `lib/utils/app_text_styles.dart` 생성 (타이포그래피)

### Phase 2: AddScheduleScreen 개선 ✅ 완료
- [x] `lib/widgets/color_picker_widget.dart` 생성
- [x] `lib/widgets/emoji_picker_widget.dart` 생성
- [x] `lib/screens/schedule/add_schedule_screen_new.dart` 생성 (단일 스크롤 레이아웃)
- [x] `lib/screens/dashboard/dashboard_screen.dart` FAB 업데이트

### Phase 3: 추가 화면
- [ ] `lib/screens/splash_screen.dart` 생성
- [ ] `lib/screens/schedule/schedule_detail_screen.dart` 생성
- [ ] `lib/screens/policy/privacy_policy_screen.dart` 생성
- [ ] `lib/screens/policy/terms_screen.dart` 생성

---

## 🧪 테스트 계획

### Widget Tests
- [ ] `circular_timer_widget_test.dart`
- [ ] `color_picker_widget_test.dart`
- [ ] `emoji_picker_widget_test.dart`
- [ ] `main_wrapper_test.dart`

### Integration Tests
- [ ] `home_screen_integration_test.dart`
- [ ] `navigation_flow_test.dart`
- [ ] `schedule_edit_flow_test.dart`

### E2E Tests
- [ ] `complete_schedule_creation_test.dart`
- [ ] `navigation_persistence_test.dart`

---

## 📅 일정

### Week 1: Phase 1 구현
- Day 1-2: 원형 타이머 위젯 + DashboardScreen 개선
- Day 3-4: MainWrapper 구현 + 네비게이션 통합
- Day 5: 테스트 및 버그 수정

### Week 2: Phase 2 구현
- Day 1-2: 색상/이모지 피커 구현
- Day 3-4: ScheduleEditScreen 리팩토링
- Day 5: 테스트 및 버그 수정

### Week 3: Phase 3 + 마무리
- Day 1-2: 추가 화면 구현
- Day 3-4: 통합 테스트 및 QA
- Day 5: 문서화 및 릴리스 준비

---

## 🚀 릴리스 전략

1. **Feature Branch**: `feature/ui-components`
2. **PR 생성**: UI 개선 완료 후 main 브랜치로 PR
3. **테스트**: 전체 테스트 통과 확인 (328개 + 신규 테스트)
4. **문서 업데이트**: IMPLEMENTATION_PHASES.md, README.md
5. **릴리스**: v1.1.0 태그 생성

---

**작성자**: Claude Code
**검토**: 2025-01-07
**다음 검토**: Phase 1 완료 시
