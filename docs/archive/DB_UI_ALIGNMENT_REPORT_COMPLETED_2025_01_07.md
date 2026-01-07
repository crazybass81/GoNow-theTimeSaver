# DB-UI 정합성 검토 보고서 / DB-UI Alignment Report

**작성일**: 2026-01-07
**Phase**: Phase 1 UI 개선 완료 후 검토
**문서 버전**: 1.0

---

## 📋 목차 / Table of Contents

1. [검토 개요](#1-검토-개요)
2. [변경된 UI 컴포넌트](#2-변경된-ui-컴포넌트)
3. [현재 DB 스키마](#3-현재-db-스키마)
4. [정합성 분석](#4-정합성-분석)
5. [필요한 변경사항](#5-필요한-변경사항)
6. [마이그레이션 계획](#6-마이그레이션-계획)
7. [영향 범위 분석](#7-영향-범위-분석)

---

## 1. 검토 개요

### 1.1 검토 배경

Phase 1 UI 개선 작업에서 다음 기능들이 추가되었습니다:
- ✅ `AppColors` - 6가지 스케줄 색상 시스템
- ✅ `AppTextStyles` - 타이포그래피 시스템
- ✅ AddScheduleScreenNew - 색상 피커, 이모지 피커
- ✅ DashboardScreen - 색상별 시간 배지, ExpansionTile 경로 선택

**검토 목적**: UI에서 선택한 색상과 이모지를 데이터베이스에 저장하고 표시할 수 있는지 확인

### 1.2 검토 범위

- **대상 테이블**: `schedules` (일정), `places` (장소)
- **대상 모델**: `Trip` 클래스
- **대상 화면**: AddScheduleScreenNew, DashboardScreen
- **대상 컴포넌트**: ColorPickerWidget, EmojiPickerWidget

---

## 2. 변경된 UI 컴포넌트

### 2.1 색상 시스템 (`lib/utils/app_colors.dart`)

**구현 완료:**
```dart
class AppColors {
  static const Map<String, Color> scheduleColors = {
    'red': Color(0xFFE57373),      // 중요/긴급
    'blue': Color(0xFF64B5F6),     // 업무/회의
    'green': Color(0xFF81C784),    // 개인/운동
    'orange': Color(0xFFFFB74D),   // 학습/공부
    'purple': Color(0xFFBA68C8),   // 취미/여가
    'teal': Color(0xFF4DB6AC),     // 건강/의료
  };
}
```

**기능:**
- 6가지 스케줄 카테고리 색상 정의
- 색상별 Material Design 그림자 함수
- 헬퍼 메서드 (getColorName, getColorByName)

**DB 필요사항**:
- ❌ `schedules` 테이블에 색상을 저장할 필드 없음

### 2.2 이모지 피커 (`lib/widgets/emoji_picker_widget.dart`)

**구현 완료:**
```dart
class EmojiPickerWidget extends StatelessWidget {
  final String selectedEmoji;
  final Function(String) onEmojiSelected;

  static const List<String> availableEmojis = [
    '🚗', '🚌', '🚇', '✈️', '🏃', '🚶',  // 이동
    '💼', '📚', '🏋️', '🎮', '🍽️', '☕',  // 활동
    '🏥', '🏠', '🏢', '🏫', '🏪', '⛪',  // 장소
    // ... 총 36개
  ];
}
```

**기능:**
- 36개 이모지 선택 가능
- 카테고리별 분류 (이동, 활동, 장소, 사람, 기타, 특수)
- AddScheduleScreenNew에서 사용

**DB 필요사항**:
- ❌ `schedules` 테이블에 이모지를 저장할 필드 없음

### 2.3 AddScheduleScreenNew

**구현 완료:**
```dart
class _AddScheduleScreenNewState extends State<AddScheduleScreenNew> {
  String _selectedEmoji = '🚗';
  Color _selectedColor = const Color(0xFF64B5F6);

  void _saveSchedule() {
    // TODO: Supabase에 일정 저장
    // ❌ 색상과 이모지를 저장할 수 없음!
  }
}
```

**문제점**:
- 사용자가 선택한 색상과 이모지를 저장할 방법이 없음
- DB에 저장 후 다시 불러올 때 원래 선택한 값을 복원할 수 없음

### 2.4 DashboardScreen - 시간 배지

**구현 완료:**
```dart
Widget _buildUpcomingSchedulesSection(ThemeData theme) {
  final scheduleColor = AppColors.scheduleBlue; // ❌ 하드코딩!

  return Container(
    decoration: BoxDecoration(
      color: scheduleColor,
      boxShadow: AppColors.colorSwatchShadow(scheduleColor),
    ),
    child: Text(
      trip.arrivalTime.hour.toString(),
      style: AppTextStyles.badgeTimeLarge,
    ),
  );
}
```

**문제점**:
- 현재 모든 일정이 파란색(blue)으로 표시됨
- Trip 객체에서 색상 정보를 가져올 수 없음

---

## 3. 현재 DB 스키마

### 3.1 schedules 테이블

**현재 스키마:**
```sql
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 일정 기본 정보
  title TEXT NOT NULL,
  destination_address TEXT NOT NULL,
  destination_lat DOUBLE PRECISION NOT NULL,
  destination_lng DOUBLE PRECISION NOT NULL,

  -- 시간 정보
  arrival_time TIMESTAMPTZ NOT NULL,
  departure_time TIMESTAMPTZ NOT NULL,

  -- 경로 정보
  transport_mode TEXT NOT NULL CHECK (transport_mode IN ('car', 'transit')),
  route_data JSONB,
  travel_duration_minutes INTEGER NOT NULL,

  -- 버퍼 시간
  preparation_minutes INTEGER DEFAULT 15,
  early_arrival_buffer_minutes INTEGER DEFAULT 10,
  travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2,
  previous_task_wrapup_minutes INTEGER DEFAULT 5,

  -- 상태 관리
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  is_cancelled BOOLEAN DEFAULT FALSE,

  -- 알림 설정
  notification_enabled BOOLEAN DEFAULT TRUE,
  notification_sent_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**누락된 필드:**
- ❌ `color` - 일정 색상 카테고리
- ❌ `emoji` - 일정 아이콘

### 3.2 Trip 모델 (`lib/models/trip.dart`)

**현재 모델:**
```dart
class Trip {
  final String? id;
  final String userId;
  final String title;
  final String destinationAddress;
  // ... (색상, 이모지 필드 없음)
}
```

**누락된 필드:**
- ❌ `String? color` - 색상 카테고리 키
- ❌ `String? emoji` - 이모지 아이콘

---

## 4. 정합성 분석

### 4.1 데이터 흐름 분석

**현재 흐름 (불완전):**
```
AddScheduleScreenNew
  ↓ 사용자 선택
[색상: blue, 이모지: 🚗]
  ↓ 저장 시도
  ❌ DB에 저장 불가 (필드 없음)
  ↓
schedules 테이블
  ↓ 조회
Trip 모델 (색상/이모지 정보 없음)
  ↓
DashboardScreen
  ↓ 표시
❌ 기본 색상(blue)만 표시
```

**필요한 흐름 (완전):**
```
AddScheduleScreenNew
  ↓ 사용자 선택
[색상: red, 이모지: 💼]
  ↓ 저장
  ✅ DB에 color='red', emoji='💼' 저장
  ↓
schedules 테이블 (color, emoji 컬럼)
  ↓ 조회
Trip 모델 (color: 'red', emoji: '💼')
  ↓
DashboardScreen
  ↓ 표시
✅ AppColors.getColorByName('red') 사용하여 빨간색 배지 표시
✅ 이모지 '💼' 표시
```

### 4.2 정합성 문제점 요약

| 항목 | UI 구현 | DB 스키마 | 모델 | 상태 |
|------|---------|-----------|------|------|
| **색상 시스템** | ✅ 완료 | ❌ 없음 | ❌ 없음 | 🔴 불일치 |
| **이모지 선택** | ✅ 완료 | ❌ 없음 | ❌ 없음 | 🔴 불일치 |
| **시간 배지** | ✅ 완료 | ❌ 색상 없음 | ❌ 색상 없음 | 🔴 불완전 |
| **경로 정보** | ✅ 완료 | ✅ 있음 | ✅ 있음 | 🟢 일치 |

---

## 5. 필요한 변경사항

### 5.1 데이터베이스 마이그레이션

**추가 필요한 컬럼:**
```sql
-- schedules 테이블에 컬럼 추가
ALTER TABLE schedules
ADD COLUMN color TEXT DEFAULT 'blue',
ADD COLUMN emoji TEXT DEFAULT '🚗';

-- 색상 제약 조건 추가 (선택사항)
ALTER TABLE schedules
ADD CONSTRAINT check_color
CHECK (color IN ('red', 'blue', 'green', 'orange', 'purple', 'teal'));

-- 인덱스 추가 (선택사항 - 색상별 필터링 시 유용)
CREATE INDEX idx_schedules_color ON schedules(color);
```

**마이그레이션 파일 위치:**
```
supabase/migrations/
  └── 20260107_add_color_emoji_to_schedules.sql
```

### 5.2 Trip 모델 업데이트

**필요한 변경사항:**

1. **필드 추가** (`lib/models/trip.dart`):
```dart
class Trip {
  // 기존 필드...

  /// 일정 색상 카테고리 / Schedule color category
  /// 'red', 'blue', 'green', 'orange', 'purple', 'teal'
  final String? color;

  /// 일정 이모지 아이콘 / Schedule emoji icon
  final String? emoji;

  Trip({
    // 기존 파라미터...
    this.color = 'blue',  // 기본값: 파란색
    this.emoji = '🚗',     // 기본값: 자동차
  });
}
```

2. **JSON 직렬화 업데이트**:
```dart
factory Trip.fromJson(Map<String, dynamic> json) {
  return Trip(
    // 기존 필드...
    color: json['color'] as String? ?? 'blue',
    emoji: json['emoji'] as String? ?? '🚗',
  );
}

Map<String, dynamic> toJson() {
  return {
    // 기존 필드...
    if (color != null) 'color': color,
    if (emoji != null) 'emoji': emoji,
  };
}
```

3. **copyWith 메서드 업데이트**:
```dart
Trip copyWith({
  // 기존 파라미터...
  String? color,
  String? emoji,
}) {
  return Trip(
    // 기존 필드...
    color: color ?? this.color,
    emoji: emoji ?? this.emoji,
  );
}
```

### 5.3 AddScheduleScreenNew 업데이트

**저장 로직 수정** (`lib/screens/schedule/add_schedule_screen_new.dart`):
```dart
void _saveSchedule() {
  if (!_formKey.currentState!.validate()) return;
  if (_arrivalDateTime == null) return;

  // Supabase에 저장
  final scheduleData = {
    'user_id': userId,
    'title': _titleController.text,
    'destination_address': _destinationController.text,
    'arrival_time': _arrivalDateTime!.toIso8601String(),
    'transport_mode': _transportMode,
    'color': AppColors.getColorName(_selectedColor) ?? 'blue',  // ✅ 추가
    'emoji': _selectedEmoji,                                     // ✅ 추가
    // ... 기타 필드
  };

  await supabase.from('schedules').insert(scheduleData);
}
```

### 5.4 DashboardScreen 업데이트

**색상 동적 적용** (`lib/screens/dashboard/dashboard_screen.dart`):
```dart
Widget _buildUpcomingSchedulesSection(ThemeData theme) {
  // ❌ 기존: 하드코딩
  // final scheduleColor = AppColors.scheduleBlue;

  // ✅ 수정: Trip에서 색상 가져오기
  final scheduleColor = trip.color != null
      ? AppColors.getColorByName(trip.color!)
      : AppColors.scheduleBlue;

  return Container(
    decoration: BoxDecoration(
      color: scheduleColor,
      boxShadow: AppColors.colorSwatchShadow(scheduleColor),
    ),
    child: Column(
      children: [
        // 이모지 표시 추가
        if (trip.emoji != null)
          Text(trip.emoji!, style: TextStyle(fontSize: 24)),
        // 시간 배지...
      ],
    ),
  );
}
```

---

## 6. 마이그레이션 계획

### 6.1 단계별 실행 계획

**Phase 1: 데이터베이스 마이그레이션** (우선순위: 높음)
- [ ] Supabase 마이그레이션 파일 생성
- [ ] 로컬 개발 환경에서 마이그레이션 테스트
- [ ] 기존 데이터 기본값 적용 확인
- [ ] 프로덕션 환경 배포

**Phase 2: 모델 업데이트** (우선순위: 높음)
- [ ] Trip 모델에 color, emoji 필드 추가
- [ ] fromJson/toJson 메서드 업데이트
- [ ] copyWith 메서드 업데이트
- [ ] Trip 모델 테스트 업데이트

**Phase 3: UI 연동** (우선순위: 중간)
- [ ] AddScheduleScreenNew 저장 로직 수정
- [ ] DashboardScreen 색상 동적 적용
- [ ] 시간 배지에 이모지 표시 추가

**Phase 4: 테스트 및 검증** (우선순위: 높음)
- [ ] 단위 테스트 업데이트
- [ ] 통합 테스트 실행
- [ ] E2E 테스트 검증

### 6.2 롤백 계획

**마이그레이션 롤백:**
```sql
-- 색상/이모지 컬럼 제거
ALTER TABLE schedules
DROP COLUMN IF EXISTS color,
DROP COLUMN IF EXISTS emoji;

-- 인덱스 제거
DROP INDEX IF EXISTS idx_schedules_color;
```

**코드 롤백:**
- Git 커밋 이전 상태로 복원
- 현재 UI는 기본값(blue, 🚗)으로 동작하므로 롤백 시 영향 없음

---

## 7. 영향 범위 분석

### 7.1 영향받는 파일

**데이터베이스:**
- `supabase/migrations/20260107_add_color_emoji_to_schedules.sql` (신규)

**모델:**
- `lib/models/trip.dart` (수정 필요)
- `test/models/trip_test.dart` (테스트 업데이트 필요)

**화면:**
- `lib/screens/schedule/add_schedule_screen_new.dart` (저장 로직 수정)
- `lib/screens/dashboard/dashboard_screen.dart` (색상 동적 적용)

**서비스:**
- `lib/services/trip_service.dart` (영향 없음 - Trip 모델만 변경)

### 7.2 하위 호환성

**기존 데이터:**
- ✅ 기본값(blue, 🚗) 자동 적용으로 기존 데이터 정상 동작
- ✅ NULL 허용 필드로 설계하여 호환성 유지

**기존 코드:**
- ⚠️ Trip 모델 의존성 있는 코드는 재컴파일 필요
- ✅ color, emoji는 옵션 필드라 기존 로직 영향 없음

### 7.3 성능 영향

**데이터베이스:**
- ✅ TEXT 컬럼 2개 추가 - 무시할 수 있는 수준
- ✅ 인덱스 추가 시 약간의 쓰기 성능 감소 (미미함)

**애플리케이션:**
- ✅ 색상 조회 메서드(getColorByName) - O(1) Map 조회
- ✅ JSON 직렬화 - 필드 2개 추가로 영향 미미

---

## 8. 권장사항

### 8.1 즉시 적용 권장

1. **DB 마이그레이션 우선 실행**
   - 기존 데이터에 기본값 적용
   - 새로운 일정부터 색상/이모지 저장 가능

2. **Trip 모델 업데이트**
   - 색상/이모지 필드 추가
   - 테스트 코드 업데이트

3. **UI 연동**
   - AddScheduleScreenNew에서 선택 값 저장
   - DashboardScreen에서 동적 색상 표시

### 8.2 추가 개선 제안

1. **색상 카테고리 자동 추천**
   ```dart
   // 목적지 키워드로 색상 자동 추천
   String suggestColor(String destination) {
     if (destination.contains('병원')) return 'teal';
     if (destination.contains('회사')) return 'blue';
     if (destination.contains('헬스장')) return 'green';
     // ...
     return 'blue'; // 기본값
   }
   ```

2. **이모지 카테고리별 필터링**
   - places 테이블의 category와 연동
   - 목적지 종류에 따라 관련 이모지만 표시

3. **사용자 설정 저장**
   ```dart
   // 자주 사용하는 색상/이모지 조합 저장
   class FavoriteColorEmoji {
     final String color;
     final String emoji;
     final int usageCount;
   }
   ```

---

## 9. 결론

### 9.1 현재 상태

- ✅ **UI 구현**: 완료 (색상 피커, 이모지 피커, 시간 배지)
- ❌ **DB 스키마**: 불완전 (color, emoji 필드 없음)
- ❌ **모델 정의**: 불완전 (Trip에 필드 없음)
- ❌ **데이터 흐름**: 불완전 (저장/조회 불가)

### 9.2 다음 단계

**즉시 실행 필요:**
1. Supabase 마이그레이션 실행
2. Trip 모델 업데이트
3. UI-DB 연동 완성

**예상 소요 시간:**
- DB 마이그레이션: 30분
- 모델 업데이트: 1시간
- UI 연동: 1시간
- 테스트: 1시간
- **총 예상**: 3.5시간

### 9.3 비즈니스 가치

**사용자 경험 개선:**
- ✅ 일정을 색상으로 시각적 구분 가능
- ✅ 이모지로 일정 종류 빠르게 식별
- ✅ 개인화된 일정 관리 경험

**개발 완성도:**
- ✅ UI와 DB 정합성 확보
- ✅ 데이터 영속성 보장
- ✅ 기능 완전성 달성

---

**문서 작성자**: Claude Code Assistant
**검토 완료일**: 2026-01-07
**다음 업데이트 예정**: 마이그레이션 완료 후
