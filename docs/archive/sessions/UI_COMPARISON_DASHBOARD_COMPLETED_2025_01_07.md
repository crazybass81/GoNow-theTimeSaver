# UI Comparison: Reference home_screen.dart vs Current dashboard_screen.dart

**Date**: 2026-01-07
**Purpose**: Screen-by-screen UI matching between reference repository (khyapple/go_now) and current implementation

---

## Overall Structure Comparison

### Reference home_screen.dart
```
Scaffold
├── AppBar (없음 - Date header가 body 최상단)
├── Body (SingleChildScrollView)
│   ├── Date Header (날짜 + 요일)
│   ├── Circular Progress Timer (45분 고정)
│   ├── Current Schedule Title
│   ├── Arrival Estimate
│   ├── Route Selection (ExpansionTile dropdown)
│   └── Upcoming Schedules List
└── FAB (없음)
```

### Current dashboard_screen.dart
```
Scaffold
├── AppBar (calendar + settings buttons)
├── Body (RefreshIndicator + SingleChildScrollView)
│   ├── Welcome Section (user name)
│   ├── Next Schedule Card (destination info)
│   ├── CircularTimerWidget (dynamic countdown)
│   ├── Route Section (ExpansionTile)
│   ├── Departure Button ("출발했어요")
│   └── Upcoming Schedules List
├── FAB (add schedule)
└── Empty/Error States
```

---

## 1. Header Section

### Reference
- **없음** - Date header가 body 내부에 위치
- 날짜 표시: "2024년 1월 15일 (월)" 형식
- Typography: 32px bold for date

### Current
- **있음** - AppBar with title and action buttons
- Title: "대시보드"
- Actions: Calendar icon, Settings icon
- Welcome message: "환영합니다, {userName}님"

**차이점**:
- ❌ Reference는 AppBar 없음, 날짜가 body 최상단
- ✅ Current는 AppBar + Welcome message

---

## 2. Color Scheme

### Reference (Hardcoded)
```dart
Background: Colors.grey[50]
Cards: Colors.white
Primary: Colors.blue[600]
Secondary text: Colors.grey[600]
Shadows: color: Colors.black.withOpacity(0.1), blurRadius: 10
```

### Current (Theme-based)
```dart
Background: theme.colorScheme.surface
Cards: theme.colorScheme.surface / surfaceVariant
Primary: theme.colorScheme.primary
Secondary text: theme.colorScheme.onSurface.withOpacity(0.6)
Shadows: AppColors.cardShadow(theme.colorScheme.primary)
         - Multiple shadows with different blur radii (15, 8)
```

**차이점**:
- ❌ Reference는 하드코딩된 Colors.blue[600], grey[50]
- ✅ Current는 동적 테마 시스템 (theme.colorScheme)
- ⚠️ Shadow 시스템 다름: Reference는 단순, Current는 multi-layered

---

## 3. Typography System

### Reference (Inline Styles)
```dart
Date: 32px, bold, grey[800]
Titles: 28px, bold
Body: 16px, medium (w500)
Labels: 12px, bold, grey[600]
```

### Current (AppTextStyles + Theme)
```dart
Uses: AppTextStyles.sectionTitle, scheduleTitle, scheduleSubtitle, etc.
Examples:
- sectionTitle: theme.textTheme.titleMedium?.copyWith(fontWeight: w600)
- scheduleTitle: custom styles from AppTextStyles
- Responsive to theme changes
```

**차이점**:
- ❌ Reference는 인라인 스타일 (하드코딩)
- ✅ Current는 중앙화된 AppTextStyles + theme integration
- ⚠️ Font sizes potentially different (need to check AppTextStyles constants)

---

## 4. Circular Timer Widget

### Reference
```dart
CircularProgressIndicator(
  value: 0.75, // 하드코딩 (45분 표시)
  strokeWidth: 12,
  backgroundColor: Colors.grey[300],
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
)
Center: "45분" text (하드코딩)
```

### Current
```dart
CircularTimerWidget(
  targetTime: trip.arrivalTime,
  departureTime: trip.departureTime,
  onCountdownComplete: () { ... },
)
- Dynamic countdown calculation
- Real-time updates
- Callback on completion
```

**차이점**:
- ❌ Reference는 정적 표시 (45분 하드코딩)
- ✅ Current는 동적 카운트다운 (실시간 계산)
- ⚠️ UI appearance might differ (need to check CircularTimerWidget implementation)

---

## 5. Next Schedule / Current Schedule Section

### Reference
```dart
Current Schedule Title (단순 텍스트)
- "회사 미팅" 같은 제목만 표시
- 도착 예정 시간: "15:30 도착 예정"
- 단순 Text widgets
```

### Current
```dart
Next Schedule Card (Container with decoration)
- Destination info card with:
  - Place icon
  - Emoji + Title
  - Arrival time
  - Destination address
- Styled container:
  - Border radius 12px
  - Multi-layered shadows
  - Primary color accent
```

**차이점**:
- ❌ Reference는 단순 텍스트 표시
- ✅ Current는 카드 형태로 더 많은 정보 (주소, 이모지 등)
- ⚠️ Visual hierarchy 다름

---

## 6. Route Selection (ExpansionTile)

### Reference
```dart
ExpansionTile(
  title: "경로 선택",
  children: [
    ListTile("자동차 - 30분"),
    ListTile("대중교통 - 45분"),
    ListTile("도보 - 60분"),
  ],
)
Style:
- Standard Material ExpansionTile
- Blue color on leading icon
- Divider between items
```

### Current
```dart
Container with ExpansionTile inside
- Custom container decoration (surfaceVariant background)
- Theme.copyWith(dividerColor: transparent) to hide dividers
- Leading icon based on transportMode
- Title shows transport type + duration
- Children: _buildRouteDetails() with nested container
Style:
- Border radius 12px
- Custom shadows
- More padding
```

**차이점**:
- ✅ Both use ExpansionTile
- ⚠️ Reference는 ListTile options, Current는 nested container
- ⚠️ Styling significantly different (Current more customized)

---

## 7. Departure Button

### Reference
- **없음** - No visible departure/start button

### Current
```dart
ElevatedButton(
  onPressed: () { show confirmation dialog },
  child: Row(
    Icon(Icons.directions_run),
    Text("출발했어요"),
  ),
)
- Full width button
- Primary color background
- Dialog confirmation before completing trip
```

**차이점**:
- ❌ Reference에는 출발 버튼 없음
- ✅ Current는 출발 확인 버튼 있음 (기능적 추가)

---

## 8. Upcoming Schedules List

### Reference
```dart
ListView of schedule cards:
- White background cards
- Time badge (colored box with hour:minute)
- Title + location
- "N분 남음" label
- Card shadows
- GestureDetector for navigation

Card layout:
Row(
  Time Badge (colored) | Title + Location | Arrow icon
)
```

### Current
```dart
Column of mapped containers:
- Surface background
- Time badge with color from Trip.color
- Emoji + Title
- Location with place icon
- Forward arrow icon
- Card shadows with scheduleColor

Card layout (similar):
Row(
  Time Badge (colored) | Title + Location | Arrow icon
)
```

**차이점**:
- ✅ Similar structure
- ⚠️ Reference uses GestureDetector, Current doesn't have tap handler yet
- ⚠️ Badge styling might differ
- ⚠️ Color selection logic different (Reference has helper method, Current uses AppColors.getColorByName)

---

## 9. Empty State / Error Handling

### Reference
- **없음** - No visible empty state handling in provided description

### Current
```dart
Empty State:
- Icon (Icons.event_busy)
- "일정이 없습니다"
- "새로운 일정을 추가해보세요"
- Button: "일정 추가하기"

Error State:
- Icon (Icons.error_outline)
- "일정을 불러오는데 실패했습니다"
- Error message
- Refresh button
```

**차이점**:
- ❌ Reference에 없음 (또는 제공된 설명에 없음)
- ✅ Current는 comprehensive empty/error states

---

## 10. Additional Features

### Reference
- Schedule data from `ScheduleManager` service
- Navigation to schedule detail screen on card tap
- Color name to MaterialColor conversion helper
- SharedPreferences integration (implied by imports)

### Current
- Provider pattern (AuthProvider, TripProvider)
- RefreshIndicator for pull-to-refresh
- FloatingActionButton for quick add
- Trip completion flow with dialog
- Countdown completion callback
- More sophisticated state management

---

## Summary of Key Differences

### Visual/UI Differences:
1. **AppBar**: Reference 없음 vs Current 있음
2. **Color System**: Reference 하드코딩 vs Current theme-based
3. **Typography**: Reference 인라인 vs Current AppTextStyles
4. **Timer**: Reference 정적 vs Current 동적
5. **Schedule Card**: Reference 단순 vs Current 상세 정보
6. **Departure Button**: Reference 없음 vs Current 있음
7. **Shadows**: Reference 단순 vs Current multi-layered

### Functional Differences:
1. **State Management**: Reference ScheduleManager vs Current Provider
2. **Refresh**: Reference 없음 vs Current RefreshIndicator
3. **Empty/Error States**: Reference 없음 vs Current 있음
4. **Trip Completion**: Reference 없음 vs Current dialog flow
5. **Navigation**: Both support, but Current has more actions

---

## Priority Changes for UI Matching

### High Priority (Visual Consistency):
1. ⚠️ **Remove AppBar** or make it match Reference style
2. ⚠️ **Simplify Timer** to match Reference static appearance
3. ⚠️ **Adjust Color Scheme** to use grey[50] background + blue[600] primary
4. ⚠️ **Typography Updates** to match Reference sizes (32px, 28px, 16px, 12px)
5. ⚠️ **Simplify Next Schedule Card** to text-only format

### Medium Priority (Component Behavior):
6. ⚠️ **Route ExpansionTile Styling** to match Reference
7. ⚠️ **Upcoming Cards Layout** fine-tuning
8. ⚠️ **Shadow System** simplification

### Low Priority (Optional Features):
9. ✅ **Keep Departure Button** (adds value, not in Reference)
10. ✅ **Keep Empty/Error States** (good UX, not in Reference)
11. ✅ **Keep RefreshIndicator** (good UX, not in Reference)

---

## Recommended Implementation Order

1. **Color & Theme Changes** (foundation)
2. **Typography System Update** (foundation)
3. **AppBar Removal/Simplification** (structural)
4. **Timer Widget Update** (visual impact)
5. **Next Schedule Card Simplification** (visual impact)
6. **Route Section Styling** (refinement)
7. **Upcoming Cards Polish** (refinement)
8. **Shadow System Adjustment** (polish)

---

## Notes

- Reference repo appears to be **simpler/earlier version**
- Current repo has **more features and better UX**
- Consider **keeping functional improvements** while matching visual style
- May need to **fetch actual Reference source code** for exact styling values
