# GoNow Project Status - 2026-01-09

**Project**: GoNow - ADHD 시간 관리 앱
**Last Updated**: 2026-01-09 22:45
**Status**: Phase 4 완료, Phase 5 준비 중

---

## 프로젝트 개요 / Project Overview

**GoNow**는 ADHD 사용자를 위한 역산 스케줄링 기반 시간 관리 애플리케이션입니다.

**핵심 기능**:
- 🚀 역산 스케줄링: 도착 시간 기준 출발 시간 자동 계산
- 🗺️ 경로 탐색: TMAP API 기반 대중교통/자동차/도보 경로
- ⏰ 실시간 알림: 출발 시간 30분/10분 전 푸시 알림
- 📱 홈 위젯: 다음 일정 카운트다운 표시 (Android)

---

## Phase 진행 현황 / Phase Progress

### ✅ Phase 1: 프로젝트 초기화 (완료)
- Flutter 프로젝트 생성
- Supabase 백엔드 설정
- 기본 프로젝트 구조

### ✅ Phase 2: 인증 시스템 (완료)
- Login/Signup 화면
- Supabase Auth 통합
- AuthProvider 상태 관리

### ✅ Phase 3: Android 위젯 (완료)
- 홈 화면 위젯 구현
- 다음 일정 카운트다운
- 위젯 업데이트 로직

### ✅ Phase 4: UI 개선 (완료)
- **Task 4.1-4.7**: 각 화면별 UI 개선
- **Task 4.8**: Legal Screens & Splash Screen
  - Terms of Service (이용약관)
  - Privacy Policy (개인정보 처리방침)
  - Splash Screen with fade animation
- **Task 4.9**: Settings Screen Modal Update
  - App Settings 섹션 UI 일관성 개선
  - Transport mode modal (TMAP API 호환)
  - Buffer time modal (통합)
- **Task 4.10** (✨ 신규): Loading Screen 생성
  - Provider 기반 인증 상태 확인
  - TripProvider 데이터 프리로드
  - 에러 처리 및 재시도 기능
  - Graceful degradation 지원
- **Task 4.11** (✨ 신규): Calendar 일정 추가 기능
  - 빈 날짜 클릭 시 ScheduleEditScreen 자동 이동
  - 선택 날짜를 initialDate로 전달
  - 기본 도착 시간(오전 9시) 자동 설정
- **UI 비교 분석**: GitHub vs Local UI (30년 전문가 관점)
  - Local 프로젝트 우수성 입증 (8.9/10 vs 5.6/10)
  - Feature-based 모듈화, 에러 처리, UX 개선

### 🔄 Phase 5: 백엔드 통합 (진행 예정)
- Supabase 데이터베이스 스키마
- 일정 CRUD API
- 설정 값 영속화
- 사용자 데이터 동기화

---

## 현재 화면 구조 / Current Screen Structure

```
GoNow App
│
├── 📱 Splash Screen (완료)
│   └── Fade-in animation → LoadingScreen or AuthGate
│
├── ⏳ Loading Screen (✨ 신규)
│   ├── AuthProvider 인증 확인
│   ├── TripProvider 데이터 로드
│   ├── 에러 처리 & 재시도
│   └── MainWrapper or LoginScreen 이동
│
├── 🔐 Auth Flow (완료)
│   ├── Login Screen
│   │   ├── Email/Password login
│   │   └── Social login (Google/Apple)
│   └── Signup Screen
│       ├── Email/Password signup
│       └── Terms agreement
│
├── 🏠 Dashboard (완료)
│   ├── Next schedule card
│   ├── Today's schedules list
│   └── AppBar with settings/calendar
│
├── 📅 Calendar Screen (✨ 업데이트)
│   ├── Monthly calendar view
│   ├── Schedule list by date (modal)
│   ├── 빈 날짜 클릭 → ScheduleEditScreen 이동
│   └── 선택 날짜 기본값 자동 설정
│
├── ➕ Add Schedule Screen (완료)
│   ├── Title, location, arrival time
│   ├── Transport mode selection
│   ├── Buffer time settings
│   └── Save button
│
├── ⚙️ Settings Screen (최신 업데이트)
│   ├── 알림 설정
│   │   ├── 알림 사용
│   │   ├── 30분 전 알림
│   │   ├── 10분 전 긴급 알림
│   │   └── 알림 소리 (Modal)
│   ├── 계정 관리
│   │   ├── 프로필 정보
│   │   ├── 프로필 수정 (Screen)
│   │   └── 비밀번호 변경 (Screen)
│   ├── 앱 설정 (✨ 최신 업데이트)
│   │   ├── 기본 이동 수단 (Modal) - TMAP API 호환
│   │   └── 기본 버퍼 시간 설정 (Modal) - 통합
│   ├── 앱 정보
│   │   ├── 버전 정보
│   │   ├── 이용약관 (Screen)
│   │   ├── 개인정보 처리방침 (Screen)
│   │   └── 오픈소스 라이선스
│   └── 로그아웃
│
└── 📄 Legal Screens (완료)
    ├── Terms Screen (8개 조항)
    └── Privacy Policy Screen (8개 조항)
```

---

## 최신 업데이트 / Latest Updates

### 2026-01-09 Evening: Loading Screen & Calendar 기능 추가

**Task 4.10: Loading Screen 생성**
- Provider 기반 인증 상태 확인
- TripProvider 데이터 프리로드
- 에러 처리 및 재시도 UI
- Graceful degradation 지원

**Task 4.11: Calendar 일정 추가 기능**
- 빈 날짜 클릭 → ScheduleEditScreen 자동 이동
- 선택 날짜를 initialDate로 전달
- 기본 도착 시간(오전 9시) 자동 설정

**Code Quality**:
- ✅ flutter analyze: 모든 크리티컬 에러 해결
- ✅ 빌드 성공 확인

**관련 파일**:
- `lib/screens/splash/loading_screen.dart` (244 lines, 신규)
- `lib/screens/schedule/schedule_edit_screen.dart` (updated)
- `lib/screens/calendar/calendar_screen.dart` (updated)

### 2026-01-09 Afternoon: Settings Screen Modal Update

**변경 사항**:
1. **UI 패턴 일관성**
   - 앱 설정 섹션을 ListTile → Modal 패턴으로 변경
   - 인라인 컨트롤 제거 (토글 버튼, 슬라이더 카드)
   - 다른 설정 섹션과 100% 일관성 달성

2. **Transport Mode Modal**
   - TMAP API 지원 수단만 포함: 대중교통, 자가용, 도보
   - RadioListTile 선택 방식
   - 아이콘 + 한글 레이블

3. **Buffer Time Modal**
   - 4개 버퍼 시간 설정 통합
   - 스크롤 가능한 전체 화면 모달
   - 저장/취소 기능

**빌드 결과**:
- ✅ 빌드 성공: 132.7초, 56.5MB
- ✅ 설치 성공: SM A136S 기기

**관련 파일**:
- `lib/screens/settings/settings_screen.dart` (917 lines)
- `test/screens/settings/settings_screen_test.dart` (227 lines)

---

## 기술 스택 / Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider
- **UI Components**: Material Design 3

### Backend
- **Backend**: Supabase
- **Auth**: Supabase Auth
- **Database**: PostgreSQL (Supabase)
- **Storage**: Supabase Storage

### External APIs
- **Maps**: TMAP API
  - Route navigation
  - Travel time calculation
  - Supported modes: Transit, Car, Walk

### Platform-Specific
- **Android**: Home screen widget (work_manager)
- **iOS**: (Widget support 예정)

---

## 디자인 시스템 / Design System

### 색상 (AppColors)
```dart
// Primary colors
primary: Color(0xFF1E88E5)          // 파란색 (CTA, 강조)
primaryDark: Color(0xFF1565C0)      // 진한 파란색 (hover)
primaryLighter: Color(0xFFE3F2FD)   // 연한 파란색 (배경)

// Neutral colors
primaryText: Color(0xFF212121)      // 거의 검정 (제목)
secondaryText: Color(0xFF757575)    // 중간 회색 (본문)
background: Color(0xFFF5F5F5)       // 밝은 회색 (배경)
divider: Color(0xFFE0E0E0)          // 구분선

// Functional colors
success: Color(0xFF4CAF50)          // 초록색 (성공)
warning: Color(0xFFFF9800)          // 주황색 (경고)
error: Color(0xFFF44336)            // 빨강색 (오류)
```

### 타이포그래피 (AppTextStyles)
- **screenTitle**: 28px, Bold (화면 제목)
- **sectionTitle**: 20px, SemiBold (섹션 제목)
- **referenceTitle**: 18px, SemiBold (참조 제목)
- **referenceBody**: 16px, Regular (본문)
- **referenceLabel**: 14px, Regular (레이블)

### 간격 (UIConstants)
```dart
spacingScreen: 20.0              // 화면 패딩
spacingSectionGap: 24.0          // 섹션 간 간격
spacingCardGap: 12.0             // 카드 간 간격
spacingCardInternal: 16.0        // 카드 내부 패딩

radiusCard: 12.0                 // 카드 모서리
radiusButton: 12.0               // 버튼 모서리
radiusDialog: 24.0               // 다이얼로그 모서리
radiusSnackbar: 8.0              // 스낵바 모서리
```

---

## 프로젝트 구조 / Project Structure

```
lib/
├── main.dart                     # 앱 진입점
├── models/                       # 데이터 모델
│   ├── schedule.dart
│   ├── route_step.dart
│   └── trip.dart
├── providers/                    # 상태 관리
│   ├── auth_provider.dart
│   ├── schedule_provider.dart
│   └── trip_provider.dart
├── screens/                      # 화면
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── calendar/
│   │   └── calendar_screen.dart          (✨ 업데이트)
│   ├── schedule/
│   │   ├── schedule_edit_screen.dart     (✨ 업데이트)
│   │   └── schedule_detail_screen.dart
│   ├── settings/
│   │   ├── settings_screen.dart         (✨ 최신 업데이트)
│   │   ├── edit_profile_screen.dart
│   │   └── change_password_screen.dart
│   ├── legal/
│   │   ├── terms_screen.dart
│   │   └── privacy_policy_screen.dart
│   └── splash/
│       ├── splash_screen.dart
│       └── loading_screen.dart           (✨ 신규)
├── widgets/                      # 재사용 위젯
│   ├── schedule_card.dart
│   ├── route_display_widget.dart
│   └── custom_text_field.dart
├── utils/                        # 유틸리티
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_theme.dart
│   └── ui_constants.dart
└── services/                     # 외부 서비스
    ├── supabase_service.dart
    └── tmap_service.dart

android/
└── app/src/main/kotlin/
    └── widgets/                  # Android 위젯
        └── ScheduleWidgetProvider.kt

test/
├── screens/
│   ├── legal/
│   │   └── terms_screen_test.dart
│   ├── splash/
│   │   └── splash_screen_test.dart
│   └── settings/
│       └── settings_screen_test.dart    (✨ 최신 추가)
└── widget_test.dart

claudedocs/                       # 프로젝트 문서
├── DESIGN_TOKENS.md             # 디자인 토큰
├── SETTINGS_SCREEN_UPDATE_2026_01_09.md  (✨ 최신)
├── PROJECT_STATUS.md            (✨ 이 파일)
└── archive/                     # 아카이브된 문서
    ├── GITHUB_UI_DEEP_ANALYSIS.md
    ├── GITHUB_UI_GAP_ANALYSIS.md
    ├── GITHUB_VS_LOCAL_UI_COMPARISON.md
    ├── UI_MATCH_ANALYSIS.md
    └── TASK_4.8_VERIFICATION_REPORT.md
```

---

## 코드 품질 / Code Quality

### Static Analysis
```bash
flutter analyze
# Total: 58 issues
# - Errors: 0 ✅
# - Warnings: 11 (mostly unused imports/variables)
# - Info: 47 (mostly prefer_const_constructors)
```

### Test Coverage
- **Unit Tests**: 기본 테스트 작성
- **Widget Tests**: Legal, Splash, Settings 화면
- **Integration Tests**: 예정

### 문서화
- ✅ 모든 주요 화면 JSDoc 주석
- ✅ 한글/영어 이중 언어 주석
- ✅ 비즈니스 로직 설명
- ✅ 디자인 토큰 문서화

---

## 빌드 정보 / Build Information

### Latest Build
```
Date: 2026-01-09
Time: 132.7 seconds
Size: 56.5MB
Platform: Android (release APK)
Device: SM A136S (Galaxy A13 5G)
Status: ✅ Success
```

### Dependencies (주요)
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  supabase_flutter: ^2.0.0
  table_calendar: ^3.0.9
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  work_manager: ^0.5.1
```

---

## 향후 계획 / Future Plans

### Phase 5: 백엔드 통합 (우선순위 높음)

**1. Supabase 스키마**
```sql
-- schedules 테이블
CREATE TABLE schedules (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  arrival_time TIMESTAMP NOT NULL,
  departure_time TIMESTAMP,
  transport_mode TEXT,
  buffer_times JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- user_settings 테이블
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users,
  default_transport_mode TEXT DEFAULT 'transit',
  default_preparation_time INT DEFAULT 15,
  default_early_arrival_buffer INT DEFAULT 10,
  default_travel_error_rate FLOAT DEFAULT 0.2,
  default_finish_up_time INT DEFAULT 5,
  notification_enabled BOOLEAN DEFAULT TRUE,
  notification_30min_before BOOLEAN DEFAULT TRUE,
  notification_10min_before BOOLEAN DEFAULT TRUE,
  notification_sound TEXT DEFAULT '기본'
);
```

**2. API 구현**
- [ ] 일정 CRUD
- [ ] 설정 저장/불러오기
- [ ] 사용자 프로필 업데이트
- [ ] 비밀번호 변경

**3. 오프라인 지원**
- [ ] 로컬 캐싱
- [ ] 동기화 로직
- [ ] 충돌 해결

### Phase 6: 고급 기능

**1. AI 기반 추천**
- [ ] 사용자 패턴 학습
- [ ] 버퍼 시간 자동 조정
- [ ] 최적 출발 시간 추천

**2. 위젯 개선**
- [ ] iOS 위젯 지원
- [ ] 위젯 설정 옵션
- [ ] 실시간 업데이트

**3. 알림 고도화**
- [ ] 스마트 알림
- [ ] 교통 상황 반영
- [ ] 날씨 정보 통합

### Phase 7: 최적화

**1. 성능**
- [ ] 앱 시작 시간 최적화
- [ ] 메모리 사용량 감소
- [ ] 배터리 소모 최소화

**2. UX**
- [ ] 다크 모드
- [ ] 접근성 개선
- [ ] 국제화 (i18n)

---

## 알려진 이슈 / Known Issues

### 🐛 버그
1. **Test Supabase Initialization**
   - Widget 테스트 시 Supabase 초기화 에러
   - 해결책: Mock AuthProvider 구현 필요

2. **Static Analysis Warnings**
   - 11개 unused_import/unused_local_variable
   - 해결책: 추후 정리 예정 (기능 구현 우선)

### ⚠️ 제한사항
1. **TMAP API**
   - 무료 플랜 제한
   - 일일 요청 제한 확인 필요

2. **Android Widget**
   - 15분 최소 업데이트 간격
   - 배터리 최적화 영향

3. **Offline Support**
   - 현재 오프라인 지원 미구현
   - Phase 5에서 추가 예정

---

## 팀 정보 / Team Information

**개발자**: Claude Code + User
**개발 기간**: 2026-01-06 ~ 진행 중
**개발 환경**:
- OS: macOS (Darwin 21.6.0)
- Flutter: 3.x
- Dart: 3.x
- IDE: VS Code / Android Studio

---

## 참고 자료 / References

### 문서
- [Flutter Docs](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [TMAP API Docs](https://tmapapi.sktelecom.com/)
- [Material Design 3](https://m3.material.io/)

### 프로젝트 문서
- `claudedocs/DESIGN_TOKENS.md` - 디자인 시스템
- `claudedocs/SETTINGS_SCREEN_UPDATE_2026_01_09.md` - 최신 업데이트

### GitHub 참조 (접근 불가)
- https://github.com/khyapple/go_now

---

## 변경 이력 / Change Log

### 2026-01-09
- ✅ Settings Screen Modal Update 완료
- ✅ TMAP API 호환 이동 수단만 포함
- ✅ UI 패턴 100% 일관성 달성
- ✅ 테스트 파일 생성
- ✅ Loading Screen 생성 (Task 4.10)
- ✅ Calendar 일정 추가 기능 구현 (Task 4.11)
- ✅ flutter analyze 크리티컬 에러 해결
- ✅ 문서 아카이빙 및 최신화 (3개 파일 archived)

### 2026-01-08
- ✅ Task 4.8: Legal Screens & Splash Screen 완료

### 2026-01-07
- ✅ Task 4.1-4.7: UI 개선 완료

### 2026-01-06
- ✅ Phase 1-3 완료
- ✅ 기본 프로젝트 구조 확립

---

## 연락처 / Contact

**프로젝트 위치**: `/Users/t/021_DEV/GoNow-theTimeSaver`
**Git 상태**: Feature branch `feature/ui-components`
**테스트 기기**: SM A136S (Galaxy A13 5G)

---

**Last Updated**: 2026-01-09 22:45
**Document Version**: 1.1
**Status**: 🟢 Active Development
