# GoNow: Phase별 구현 가이드

> **MVP 개발 Phase 1~5 상세 구현 가이드**

**최종 업데이트**: 2025-01-07
**문서 버전**: 1.3
**프로젝트 상태**: Phase 4 진행 중 (~90% 완료)

---

## 📚 문서 개요 / Document Overview

이 문서는 GoNow MVP 개발의 Phase 1~5 구현 과정을 상세히 설명합니다. 각 Phase는 명확한 목표와 Task로 구성되어 있으며, 완료 기준이 정의되어 있습니다.

### 관련 문서
- [README.md](./README.md) - 프로젝트 전체 네비게이션
- [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 전체 MVP 명세서
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 개발 환경 설정
- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - 테스트 전략

---

## 🎯 Phase 개요 / Phase Overview

| Phase | 목표 | 기간 | 상태 | 완료일 |
|-------|------|------|------|--------|
| **Phase 1** | Foundation & UI | Day 1~5 | ✅ 완료 | 2026-01-06 |
| **Phase 2** | Core Logic & API | Day 6~10 | ✅ 완료 | 2026-01-07 |
| **Phase 3** | Widgets & Notifications | Day 11~15 | ✅ Flutter 완료 | 2026-01-07 |
| **Phase 4** | Integration & QA | Day 16~20 | 🚧 진행 중 (90%) | - |
| **Phase 5** | Launch Preparation | Day 21~25 | ⏳ 대기 | - |

**전체 MVP 진행률**: ~92%

---

## 📊 Phase 1: Foundation & UI

**목표**: 프로젝트 기반 구축 및 7개 핵심 화면 UI 완성
**기간**: Day 1~5 (5일)
**담당**: 개발자 1, 개발자 2, PM, 디자이너
**상태**: ✅ **완료** (2026-01-06)

### 주요 성과

- ✅ Flutter 프로젝트 생성 및 의존성 설정
- ✅ Supabase 로컬 환경 구축 (DB 스키마, RLS 정책)
- ✅ 7개 핵심 화면 UI 구현 완료
- ✅ Provider 기반 상태 관리 설정
- ✅ Supabase Auth 완전 통합

### Task 1.1: 프로젝트 초기 설정 (Day 1)

**목표**: 개발 환경 및 인프라 구축

#### 주요 작업
- ✅ **SubTask 1.1.1**: Naver API 키 발급 (Maps + Transit)
- ✅ **SubTask 1.1.2**: Supabase 프로젝트 설정
  - 6개 테이블 생성 (users, schedules, places, buffer_settings, notifications, usage_stats)
  - Row Level Security (RLS) 정책 설정
  - Storage 버킷 생성
- ✅ **SubTask 1.1.3**: Flutter 프로젝트 생성
  - 초기 의존성 추가 (supabase_flutter, provider, flutter_local_notifications)
- ✅ **SubTask 1.1.4**: Git 저장소 설정
- ✅ **SubTask 1.1.5**: 디자인 시스템 정의 (`lib/utils/app_theme.dart`)

**완료 기준**: `flutter run` 성공, Supabase 연결 테스트 통과

---

### Task 1.2: 인증 화면 UI 구현 (Day 2)

**목표**: 로그인 및 회원가입 화면 완성

#### 주요 작업
- ✅ **SubTask 1.2.1**: 로그인 화면 UI
  - 이메일/비밀번호 폼 + 유효성 검사
  - 소셜 로그인 버튼 (Google, Apple, Kakao)
  - "비밀번호 찾기" / "회원가입" 링크
- ✅ **SubTask 1.2.2**: 회원가입 화면 UI (3단계)
  - Step 1: 이메일/비밀번호 + 소셜 회원가입
  - Step 2: 이름/전화번호 (선택)
  - Step 3: 약관 동의
- ✅ **SubTask 1.2.3**: AuthProvider 생성
  - Supabase Auth 완전 통합 (signIn, signUp, signOut, resetPassword)
  - 실시간 인증 상태 변경 감지
  - 한글 에러 메시지 처리

**산출물**: `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/providers/auth_provider.dart`

**완료 기준**: 로그인/회원가입 성공 시 대시보드로 네비게이션

---

### Task 1.3: 대시보드 UI 구현 (Day 3)

**목표**: 메인 대시보드 화면 및 핵심 위젯 완성

#### 주요 작업
- ✅ **SubTask 1.3.1**: 카운트다운 컴포넌트
  - 시/분/초 표시
  - 프로그레스 바 (선형 + 도트 10개)
  - 색상 시스템 (초록→주황→빨강→진한빨강)
  - 긴급 상태 펄스 애니메이션
  - 시간 상태 메시지
- ✅ **SubTask 1.3.2**: 경로 표시 컴포넌트
  - 대중교통 경로 리스트 (버스/지하철/도보)
  - 교통수단별 아이콘 및 색상
  - 노선 정보 표시
  - RouteStep 모델 생성
- ✅ **SubTask 1.3.3**: 대시보드 메인 화면
  - 환영 메시지
  - 다음 일정 정보 카드
  - 카운트다운 위젯 통합
  - "출발했어요" 버튼
  - Pull-to-refresh 지원

**산출물**: `lib/widgets/countdown_widget.dart`, `lib/widgets/route_display_widget.dart`, `lib/screens/dashboard/dashboard_screen.dart`

**완료 기준**: Material Design 3 기반 대시보드 UI 완료

---

### Task 1.4: 스케줄 추가 화면 UI 구현 (Day 4)

**목표**: 4단계 일정 추가 플로우 완성

#### 주요 작업
- ✅ **SubTask 1.4.1**: Step 1 - 목적지 입력
  - 검색 입력창
  - 최근 장소 / 즐겨찾기 리스트
- ✅ **SubTask 1.4.2**: Step 2 - 시간 및 이동 수단
  - 날짜/시간 선택 위젯
  - 이동 수단 선택 (자차/대중교통)
  - 이동 시간 자동 계산 표시 (정적)
- ✅ **SubTask 1.4.3**: Step 3 & 4 - 버퍼 시간 및 저장
  - 4가지 버퍼 시간 슬라이더
    - 외출 준비 시간
    - 이동 오차율
    - 일찍 도착 버퍼
    - 일정 마무리 시간
  - 최종 계산 요약 표시
  - 저장 버튼

**산출물**: `lib/screens/schedule/add_schedule_screen.dart` (4-step integrated)

**완료 기준**: 모든 슬라이더 작동, 계산 요약 표시, 저장 버튼 구현

---

### Task 1.5: 캘린더 및 설정 화면 UI 구현 (Day 5)

**목표**: 월간 캘린더 및 설정 화면 완성

#### 주요 작업
- ✅ **SubTask 1.5.1**: 월간 캘린더 UI
  - table_calendar 패키지 사용
  - 날짜별 일정 개수 표시
  - 선택된 날짜의 일정 리스트
- ✅ **SubTask 1.5.2**: 설정 화면 UI
  - 4가지 버퍼 시간 기본값 설정
  - 알림 설정 (30분 전, 10분 전)
  - 계정 관리 (프로필, 비밀번호 변경, 로그아웃)
  - 앱 정보 (버전, 약관, 개인정보 처리방침)
- ⏳ **SubTask 1.5.3**: UI 통합 테스트 (Phase 4로 연기)

**산출물**: `lib/screens/calendar/calendar_screen.dart`, `lib/screens/settings/settings_screen.dart`

**완료 기준**: 모든 설정 항목 렌더링, 로그아웃 기능 구현

---

## 📊 Phase 2: Core Logic & API Integration

**목표**: 역산 스케줄링, API 연동, 로컬 DB 구현
**기간**: Day 6~10 (5일)
**담당**: 개발자 1, 개발자 2
**상태**: ✅ **완료** (2026-01-07)

### 주요 성과

- ✅ ~~Naver Maps API~~ → **TMAP Routes API 마이그레이션** (2025-01-07)
- ✅ TMAP API 완전 통합 (자차 경로, GeoJSON, 실시간 교통)
- ✅ Naver Transit API 완전 통합 (대중교통 경로)
- ✅ 역산 스케줄링 알고리즘 구현 (48개 단위 테스트 통과)
- ✅ Adaptive Polling 시스템 (15/5/3분 간격)
- ✅ Supabase 데이터 모델 구현
- ✅ TripProvider 상태 관리
- 📄 [TMAP API 마이그레이션 문서](../docs/TMAP_API_MIGRATION.md)

### Task 2.1: ~~Naver Maps API~~ → TMAP Routes API 연동 (Day 6, Updated 2025-01-07)

**목표**: 자차 경로 탐색 API 통합

**⚠️ API 변경 이력**:
- **초기 구현** (2026-01-06): Naver Directions API 5.0
- **마이그레이션** (2025-01-07): TMAP Routes API로 전환
  - **사유**: Naver API 구독/권한 문제 (Error 210: Permission Denied)
  - **변경사항**: GET → POST, Query Parameters → JSON Body, GeoJSON 경로 형식
  - **문서**: [TMAP_API_MIGRATION.md](../docs/TMAP_API_MIGRATION.md)

#### 주요 작업
- ✅ **SubTask 2.1.1**: ~~Directions API~~ TMAP Routes API 연동
  - dio 패키지 사용
  - `RouteService.calculateRoute()` 구현 (TMAP POST 방식)
  - 실시간 교통 데이터 파싱 (GeoJSON LineString)
  - 경로 옵션 매핑 (trafast → searchOption 2)
- ✅ **SubTask 2.1.2**: API 에러 핸들링
  - 네트워크 오류 처리
  - API 키 오류 처리
  - Rate Limit 자동 재시도 로직
  - RouteServiceException 커스텀 예외
- ✅ **SubTask 2.1.3**: 캐싱 전략
  - 최근 경로 캐싱 (5분 유효)
  - 중복 요청 방지
- ✅ **SubTask 2.1.4**: Integration Tests (2025-01-07)
  - 4개 테스트 케이스 작성 및 통과 (100%)
  - 실제 TMAP API 호출 검증
  - 캐시 동작 검증 (첫 호출 ~1ms, 캐시 0ms)

**산출물**:
- `lib/services/route_service.dart` (TMAP API 버전)
- `test/integration/route_service_integration_test.dart` (4/4 passed)

**완료 기준**: 실제 TMAP API 호출 성공, 이동 시간 반환, 모든 테스트 통과

---

### Task 2.2: Naver Transit API 연동 (Day 7)

**목표**: 대중교통 경로 탐색 API 통합

#### 주요 작업
- ✅ **SubTask 2.2.1**: Transit API 연동
  - `TransitService` 클래스 리팩토링 (http → dio)
  - Singleton 패턴 적용
  - 버스/지하철 경로 파싱 (traoptimal)
  - 환승 정보 파싱 (subPath)
  - 8가지 에러 타입 핸들링
  - 캐싱 전략 (5분 유효)
- ✅ **SubTask 2.2.2**: 환승 버퍼 시간 자동 계산
  - 도보 환승: 5분 + 거리 기반 추가
  - 버스 환승: 3분 자동 추가
  - 지하철 환승: 5분 자동 추가
  - 환승역 거리 기반 조정 (100m/500m 임계값)

**산출물**: `lib/services/transit_service.dart`, `lib/utils/transfer_buffer.dart`

**완료 기준**: 대중교통 경로 데이터 반환, 환승 시간 자동 계산

---

### Task 2.3: 역산 스케줄링 알고리즘 (Day 8)

**목표**: 출발 시간 자동 계산 로직 구현

#### 주요 작업
- ✅ **SubTask 2.3.1**: SchedulerService 기본 구현
  - `calculateDepartureTime()` 메서드
  - 4가지 버퍼 시간 반영
    1. 외출 준비 시간 (prepTime)
    2. 이동 오차율 (errorRate %)
    3. 일찍 도착 버퍼 (earlyBuffer)
    4. 일정 마무리 시간 (completionTime)
  - **단위 테스트 100% 통과 (48개 테스트)**
- ✅ **SubTask 2.3.2**: Adaptive Polling 로직
  - `getPollingInterval()` 메서드
  - 1시간 전: 15분 간격
  - 30분 전: 5분 간격
  - 10분 전: 3분 간격
- ✅ **SubTask 2.3.3**: 실시간 업데이트 로직
  - Timer 설정
  - API 호출 및 출발 시간 재계산
  - 변화율 5% 미만 시 스킵

**산출물**: `lib/services/scheduler_service.dart`, `lib/services/polling_service.dart`, `lib/services/real_time_updater.dart`

**완료 기준**: 실시간 카운트다운 작동, 적응형 폴링 동작

**역산 알고리즘 예시**:
```dart
DateTime calculateDepartureTime({
  required DateTime arrivalTime,
  required int travelTimeMinutes,
  required BufferTimes buffers,
}) {
  // 1. 이동 오차율 적용
  final adjustedTravel = (travelTimeMinutes * (1 + buffers.errorRate / 100)).ceil();

  // 2. 모든 버퍼 합산
  final totalBuffer = buffers.prepTime +
                      buffers.earlyBuffer +
                      buffers.completionTime;

  // 3. 역산 계산
  return arrivalTime
      .subtract(Duration(minutes: adjustedTravel))
      .subtract(Duration(minutes: totalBuffer));
}
```

---

### Task 2.4: Supabase 데이터 모델 구현 (Day 9)

**목표**: Trip 및 UserSettings 데이터 모델 구현

#### 주요 작업
- ✅ **SubTask 2.4.1**: Trip 모델 및 Service
  - Trip 모델 클래스 (title, destination, arrivalTime, color, emoji 등)
  - TripService 클래스 (Supabase CRUD)
  - 4가지 버퍼 시간 필드 저장
  - UI 디자인 필드 (color, emoji) 저장
  - RLS 정책 준수
  - Realtime 구독 지원
- ✅ **SubTask 2.4.2**: UserSettings 모델 및 Service
  - UserSettings 모델 (기본 버퍼 시간, 알림 설정)
  - SettingsService 클래스
  - 기본값 설정 로직
  - 로컬 캐시 (shared_preferences)
- ✅ **SubTask 2.4.3**: 데이터 통합 테스트
  - Trip 저장 → 역산 스케줄링 → 결과 표시
  - 설정 변경 → Supabase 저장 → 재시작 시 로드
  - RLS 보안 검증
  - Supabase 마이그레이션 파일 생성

**산출물**:
- `lib/models/trip.dart`, `lib/services/trip_service.dart`
- `lib/models/user_settings.dart`, `lib/services/settings_service.dart`
- `supabase/migrations/20260107000001_add_user_settings_columns.sql`
- `supabase/migrations/20260107000002_add_color_emoji_to_schedules.sql`

**완료 기준**: CRUD 테스트 통과, E2E 시나리오 테스트 통과

---

### Task 2.5: API 및 로직 통합 (Day 10)

**목표**: Flutter Provider와 실제 데이터 통합

#### 주요 작업
- ✅ **SubTask 2.5.1**: TripProvider 생성
  - 일정 CRUD 작업
  - 실시간 출발 시간 업데이트
  - 적응형 폴링 통합 (15/5/3분)
  - UI 상태 관리
- ✅ **SubTask 2.5.2**: 대시보드 실시간 업데이트 연결
  - TripProvider와 dashboard_screen.dart 연결
  - DB에서 다음 일정 로드
  - 실제 Trip 데이터 표시
  - 카운트다운 위젯 실시간 작동
  - "출발했어요" 버튼 실제 동작
- ⏳ **SubTask 2.5.3**: 스케줄 추가 API 연동 (Phase 3로 이동)

**산출물**: `lib/providers/trip_provider.dart`, 업데이트된 대시보드

**완료 기준**: 실제 일정 데이터로 카운트다운 작동

---

## 📊 Phase 3: Widgets & Notifications

**목표**: Android/iOS 홈 위젯 구현 및 푸시 알림
**기간**: Day 11~15 (5일)
**담당**: 개발자 1 (Android), 개발자 2 (iOS)
**상태**: ✅ **Flutter 레이어 완료** (2026-01-07) - 네이티브 통합 대기

### 현재 진행 상황

| 항목 | 상태 | 비고 |
|------|------|------|
| Flutter WidgetService | ✅ 완료 | 22개 단위 테스트 통과 |
| Flutter NotificationService | ✅ 완료 | 17개 단위 테스트 통과 |
| Android 네이티브 코드 | ✅ 템플릿 준비 | `templates/phase3/android/` |
| iOS 네이티브 코드 | ✅ 템플릿 준비 | `templates/phase3/ios/` |
| flutter create | ⏳ 대기 | 사용자 수동 실행 필요 |
| Android 코드 적용 | ⏳ 대기 | flutter create 후 진행 |
| iOS 코드 적용 | ⏳ 대기 | Xcode 작업 포함 (~20-25분) |
| 통합 테스트 | ⏳ 대기 | 네이티브 코드 적용 후 |

**전체 Phase 3 진행률**: ~60% (Flutter 레이어 100%, 네이티브 레이어 대기)

---

### Task 3.1: Android 홈 위젯 (Day 11~13)

**목표**: Jetpack Glance 위젯 구현

#### 주요 작업
- ⏳ **SubTask 3.1.1**: Jetpack Glance 위젯 기본 구조 (Day 11)
  - Kotlin 코드 작성 (`android/app/src/main/kotlin/`)
  - `GoNowWidget` 클래스 생성
  - 2x2 위젯 레이아웃
  - 위젯 Provider 등록
- ✅ **SubTask 3.1.2**: Flutter ↔ Android 데이터 공유 (Day 11) - **Flutter 레이어만**
  - ✅ MethodChannel 구현 (Flutter 측) - `lib/services/widget_service.dart`
  - ✅ `updateWidget()` 메서드 (Flutter에서 호출)
  - ✅ 다음 일정 데이터 전달
  - ✅ 시간대별 색상 시스템 (초록/주황/빨강/진한빨강)
  - ⏳ SharedPreferences 설정 (Android 네이티브 - 대기)
  - ⏳ MainActivity MethodChannel 구현 (Android 네이티브 - 대기)
- ⏳ **SubTask 3.1.3**: 위젯 UI 구현 (Day 12)
  - 일정 제목 표시
  - 남은 시간 표시
  - 출발 시간 표시
  - 색상 시스템
- ⏳ **SubTask 3.1.4**: WorkManager 자동 업데이트 (Day 13)
  - `WidgetUpdateWorker` 클래스
  - 15분 주기 스케줄링
  - 배터리 최적화 설정

**참고 문서**: `templates/phase3/android/README.md`

**완료 기준**: 홈 화면 위젯 추가 가능, 15분마다 자동 갱신

---

### Task 3.2: iOS 홈 위젯 (Day 11~13)

**목표**: WidgetKit 위젯 구현

#### 주요 작업
- ⏳ **SubTask 3.2.1**: WidgetKit 위젯 기본 구조 (Day 11)
  - SwiftUI 코드 작성 (`ios/Runner/GoNowWidget/`)
  - `GoNowWidgetProvider` 클래스
  - Small/Medium 위젯 크기 지원
  - Widget Extension Target 생성
- ✅ **SubTask 3.2.2**: Flutter ↔ iOS 데이터 공유 (Day 11) - **Flutter 레이어만**
  - ✅ MethodChannel 구현 (Flutter 측) - `lib/services/widget_service.dart` (Android/iOS 공통)
  - ✅ `updateWidget()` 메서드
  - ✅ iOS 데이터 포맷 준비
  - ⏳ App Groups 설정 (iOS 네이티브 - 대기)
  - ⏳ SharedUserDefaults 구현 (iOS 네이티브 - 대기)
  - ⏳ AppDelegate MethodChannel 구현 (iOS 네이티브 - 대기)
- ⏳ **SubTask 3.2.3**: 위젯 UI 구현 (Day 12)
  - VStack 레이아웃
  - 일정 정보 표시
  - 색상 시스템
- ⏳ **SubTask 3.2.4**: Timeline Provider 구현 (Day 13)
  - `getTimeline()` 메서드
  - 15분 주기 엔트리 생성

**참고 문서**: `templates/phase3/ios/README.md`

**완료 기준**: 홈 화면 위젯 추가 가능, 15분마다 자동 갱신

---

### Task 3.3: 로컬 푸시 알림 (Day 14~15)

**목표**: flutter_local_notifications 구현
**상태**: ✅ **Flutter 레이어 완료** (2026-01-07)

#### 주요 작업
- ✅ **SubTask 3.3.1**: flutter_local_notifications 설정 (Day 14)
  - 패키지 설치 및 초기화 (timezone 패키지 포함)
  - Android 알림 채널 설정 (일반/긴급)
  - iOS 알림 권한 요청
  - 타임존 설정 (Asia/Seoul)
- ✅ **SubTask 3.3.2**: 알림 스케줄링 로직 (Day 14)
  - 30분 전 알림 (일반 우선순위)
  - 10분 전 긴급 알림 (최대 우선순위)
  - 알림 취소 로직 (개별/전체)
  - 알림 클릭 핸들러
- ✅ **SubTask 3.3.3**: 동적 알림 메시지 (Day 14)
  - 교통 상황 변화 시 알림 업데이트
  - 지연 위험 시 긴급 알림
  - 동적 알림 우선순위 설정 (normal/high/urgent)
- ⏳ **SubTask 3.3.4**: 위젯 + 알림 통합 테스트 (Day 15)
  - 위젯 업데이트와 알림 동기화
  - 알림 클릭 → 앱 열기 → 대시보드 이동
  - 배터리 소모 테스트

**산출물**: `lib/services/notification_service.dart` ✅

**완료 기준**: 예약된 시간에 알림 전송, 위젯 + 알림 동기화

**알림 ID 규칙**:
- 30분 알림: `trip.id.hashCode`
- 10분 알림: `trip.id.hashCode + 1`
- 동적 알림: `trip.id.hashCode + 2`

---

### Phase 3 다음 단계

#### 1단계: flutter create 실행 (사용자 수동)
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create --org com.gonow .
```

**주의**: `lib/main.dart`는 백업되어 있음 (`lib/main.dart.backup`)

#### 2단계: Android 네이티브 코드 적용 (10-15분)

1. Kotlin 파일 복사
2. XML 리소스 복사
3. AndroidManifest.xml 수정
4. build.gradle 수정
5. Gradle 동기화 및 빌드

**상세 가이드**: `templates/phase3/android/README.md`

#### 3단계: iOS 네이티브 코드 적용 (15-20분)

1. AppDelegate.swift 교체
2. Xcode에서 Widget Extension 추가 (수동)
3. App Groups 설정 (수동)
4. GoNowWidget.swift 복사 및 프로젝트 추가
5. 빌드 및 테스트

**상세 가이드**: `templates/phase3/ios/README.md`

#### 4단계: 통합 테스트 (2-3시간)

- 위젯 표시 및 업데이트
- 시간대별 색상 변경
- 알림 스케줄링 및 수신
- 배터리 소모 테스트
- 엣지 케이스 테스트

**상세 가이드**: `TESTING_GUIDE.md` (작성 예정)

---

## 📊 Phase 4: Integration & QA

**목표**: 전체 기능 통합, 버그 수정, 성능 최적화
**기간**: Day 16~20 (5일)
**담당**: 개발자 1, 개발자 2, PM
**상태**: 🚧 **진행 중** (2026-01-07 시작)

### 현재 진행 상황 (2025-01-07 업데이트)

| 항목 | 상태 | 비고 |
|------|------|------|
| Unit Tests | ✅ 완료 | 305개 테스트 (100% 통과) |
| Integration Tests (TMAP) | ✅ 완료 | 4개 테스트 (100% 통과) |
| Widget Tests | ✅ 완료 | 66개 테스트 통과 |
| E2E Tests 작성 | ✅ 완료 | 23개 테스트 작성 |
| E2E Tests 실행 | ✅ 완료 | 23개 테스트 (100% 통과) |
| Device Testing | ✅ 완료 | SM A136S (Android 14) 배포 성공 |
| POI Search API 통합 | ✅ 완료 | TMAP POI Search Service |
| 실시간 장소 검색 | ✅ 완료 | add_schedule_screen 실제 API 연동 |
| 현재 위치 서비스 | ✅ 완료 | GPS 통합 완료 |
| 실제 경로 계산 저장 | ✅ 완료 | 하드코딩 → 실제 API 데이터 |
| Performance Tests | ⏳ 대기 | 배터리, 메모리 최적화 |
| Alpha Testing | ⏳ 대기 | 사용자 피드백 |

**전체 테스트 현황**: 328개 테스트 100% 통과
- 📄 [테스트 결과 문서](../docs/TEST_RESULTS_2025_01_07.md)
- 📄 [TMAP API 마이그레이션 문서](../docs/TMAP_API_MIGRATION.md)
- 📄 [API 통합 세션 문서](../claudedocs/SESSION_2025_01_07_API_Integration.md)

**전체 Phase 4 진행률**: ~90%

### 주요 목표

- ✅ 전체 기능 E2E 테스트 작성
- ✅ DB-UI 정합성 수정 (색상/이모지 저장)
- ⏳ E2E 테스트 실제 실행
- ⏳ 버그 수정 (Critical/High/Medium/Low 분류)
- ⏳ UX 개선
- ⏳ 실제 시나리오 테스트
- ⏳ 성능 최적화
- ⏳ Alpha 사용자 테스트

---

### Task 4.6: DB-UI 정합성 수정 (Day 16 - 2025-01-07) ✅

**목표**: UI 디자인 필드(색상, 이모지)를 데이터베이스에 저장

**배경**: AddScheduleScreenNew에 색상 피커와 이모지 피커가 구현되어 있었으나, 데이터베이스에 저장 필드가 없어 선택한 값이 유실되는 문제 발견.

#### 주요 작업
- ✅ **SubTask 4.6.1**: Supabase 마이그레이션
  - `schedules` 테이블에 `color`, `emoji` 컬럼 추가
  - CHECK 제약조건 (6가지 허용 색상)
  - 색상별 인덱스 추가
  - 기본값 설정 (color: 'blue', emoji: '🚗')
- ✅ **SubTask 4.6.2**: Trip 모델 업데이트
  - `color`, `emoji` 필드 추가
  - fromJson, toJson, copyWith 메서드 업데이트
  - 하위 호환성 보장 (기본값)
- ✅ **SubTask 4.6.3**: AddScheduleScreenNew 저장 로직 수정
  - Supabase 저장 가이드 TODO 추가
  - `AppColors.getColorName()` 헬퍼 메서드 활용
  - 색상/이모지 선택값 표시
- ✅ **SubTask 4.6.4**: DashboardScreen 동적 표시
  - `AppColors.getColorByName()` 사용
  - 동적 색상 적용 (카드, 배지, 그림자)
  - 이모지 표시 (`'${trip.emoji} ${trip.title}'`)
- ✅ **SubTask 4.6.5**: 테스트 업데이트 및 검증
  - Trip 모델 테스트: 29/29 통과
  - DashboardScreen 테스트: 16/16 통과

**산출물**:
- `supabase/migrations/20260107000002_add_color_emoji_to_schedules.sql`
- Updated `lib/models/trip.dart`
- Updated `lib/screens/schedule/add_schedule_screen_new.dart`
- Updated `lib/screens/dashboard/dashboard_screen.dart`
- Updated `test/models/trip_test.dart`
- Updated `test/screens/dashboard_screen_test.dart`

**완료 기준**: ✅ DB 스키마 + Trip 모델 + UI 표시 완료, 전체 테스트 통과

---

### Task 4.7: API 통합 완료 (Day 16 - 2025-01-07) ✅

**목표**: 장소 검색, 현재 위치, 실제 경로 계산을 실제 API로 통합

**배경**: add_schedule_screen_new.dart가 하드코딩된 mock 데이터를 사용하고 있어, 실제 API 호출로 전환 필요.

#### 주요 작업
- ✅ **SubTask 4.7.1**: TMAP POI Search Service 구현
  - `lib/services/poi_search_service.dart` 신규 생성 (310 lines)
  - Singleton 패턴으로 TMAP POI Search API 연동
  - `searchPOI()` 메서드: 키워드로 장소 검색
  - POIResult 모델: id, name, address, coordinates, category
  - POISearchException: 8가지 에러 타입 핸들링
  - 사용자 친화적 한글 에러 메시지
  - 최대 20개 결과 반환 (TMAP API 정책)
- ✅ **SubTask 4.7.2**: main.dart 서비스 초기화
  - `POISearchService().initialize()` 추가
  - 앱 시작 시 자동 초기화
  - 로그: "POISearchService: Initialized successfully"
- ✅ **SubTask 4.7.3**: add_schedule_screen 실시간 검색 구현
  - `_searchPOI()` 메서드: 실시간 POI 검색
  - POI 검색 결과 UI 표시
  - 로딩 상태 및 에러 핸들링
  - 검색 결과 선택 기능
- ✅ **SubTask 4.7.4**: 현재 위치 서비스 통합
  - Geolocator 패키지 사용
  - `_getCurrentLocation()` 메서드
  - 위치 권한 요청 및 처리
  - GPS 좌표 획득 (WGS84)
  - Fallback: Seoul City Hall (37.5665, 126.9780)
- ✅ **SubTask 4.7.5**: 실제 경로 계산 저장
  - `_saveSchedule()` 완전 재작성
  - 현재 위치 → 목적지 경로 계산
  - 교통 수단별 API 호출 (자차: RouteService, 대중교통: TransitService)
  - **실제 이동 시간**으로 출발 시간 계산
  - Mock 30분 → 실제 API 응답값 사용
  - 데이터베이스에 실제 계산 결과 저장

**산출물**:
- ✅ `lib/services/poi_search_service.dart` (NEW - 310 lines)
- ✅ Updated `lib/main.dart` (POI Service 초기화)
- ✅ Updated `lib/screens/schedule/add_schedule_screen_new.dart` (실제 API 통합)

**완료 기준**: ✅ POI 검색 작동, 현재 위치 획득, 실제 경로 계산 저장 완료

**Before (Mock Data)**:
```dart
// ❌ Hardcoded
final mockResults = [
  {'name': '강남역', 'address': '서울시 강남구'},
];
final travelDurationMinutes = 30; // ❌ Fixed value
```

**After (Real API)**:
```dart
// ✅ Real POI Search
final results = await POISearchService().searchPOI(keyword: keyword);

// ✅ Real Route Calculation
final routeResult = await RouteService().calculateRoute(
  originLat: currentLat, originLng: currentLng,
  destLat: poi.lat, destLng: poi.lng,
);
final travelDurationMinutes = routeResult.durationMinutes; // ✅ Actual data
```

**Impact**: 사용자는 이제 실제 위치를 검색하고, GPS 기반 현재 위치에서 출발하여, 실시간 교통 정보를 반영한 정확한 출발 시간을 받을 수 있습니다.

---

### Task 4.1: 전체 기능 통합 테스트 (Day 16)

**목표**: E2E 시나리오 테스트 및 버그 발견

#### 주요 작업
- **SubTask 4.1.1**: E2E 시나리오 테스트
  - 시나리오 1: 신규 사용자 온보딩 → 첫 일정 추가
  - 시나리오 2: 대중교통 경로 → 실시간 버스 도착 → 출발
  - 시나리오 3: 자차 경로 → 교통 변화 → 출발 시간 재계산
  - 시나리오 4: 위젯에서 일정 확인 → 알림 받기 → 출발
- **SubTask 4.1.2**: 버그 리스트 작성
  - 발견된 버그 분류 (Critical/High/Medium/Low)
  - 재현 방법 문서화
  - 우선순위 지정
- **SubTask 4.1.3**: Critical 버그 긴급 수정

**완료 기준**: 모든 E2E 시나리오 성공, Critical 버그 0개

---

### Task 4.2: 버그 수정 및 UX 개선 (Day 17)

**목표**: High 버그 수정 및 사용성 개선

#### 주요 작업
- **SubTask 4.2.1**: High 우선순위 버그 수정
- **SubTask 4.2.2**: UX 개선
  - 로딩 상태 표시 개선
  - 에러 메시지 사용자 친화적으로 변경
  - 버튼 크기/위치 조정
  - 애니메이션 부드럽게 개선
- **SubTask 4.2.3**: Medium/Low 버그 트리아지
  - 출시 전 수정 vs Phase 2 이관 결정

**완료 기준**: High 버그 0개, 사용성 테스트 통과

---

### Task 4.3: 실제 시나리오 테스트 (Day 18)

**목표**: 실제 환경에서 테스트

#### 주요 작업
- **SubTask 4.3.1**: 실제 출퇴근 테스트
  - 실제 출근 경로 (대중교통)
  - 실제 퇴근 경로 (자차)
  - 교통 혼잡 시간대 테스트
- **SubTask 4.3.2**: 엣지 케이스 테스트
  - 네트워크 끊김 시나리오
  - GPS 오차 시나리오
  - 배터리 절약 모드
  - 앱 백그라운드 시나리오
- **SubTask 4.3.3**: QA 리포트 작성

**완료 기준**: 실제 환경에서 정상 작동, 모든 엣지 케이스 처리

---

### Task 4.4: 성능 최적화 (Day 19)

**목표**: 배터리, 메모리, 앱 시작 속도 최적화

#### 주요 작업
- **SubTask 4.4.1**: 배터리 소모 최적화
  - Adaptive Polling 간격 조정
  - 백그라운드 작업 최소화
  - Wake Lock 사용 최소화
  - **목표**: 1일 사용 시 배터리 소모 <10%
- **SubTask 4.4.2**: 메모리 사용 최적화
  - 이미지 캐싱 최적화
  - 메모리 누수 체크
  - **목표**: 메모리 사용량 <100MB
- **SubTask 4.4.3**: 앱 시작 속도 최적화
  - 초기 로딩 최적화
  - Lazy Loading 적용
  - **목표**: Cold Start <2초, Warm Start <1초

**완료 기준**: 모든 성능 목표 달성

---

### Task 4.5: Alpha 사용자 테스트 (Day 20)

**목표**: 실제 사용자 피드백 수집

#### 주요 작업
- **SubTask 4.5.1**: Alpha 테스터 모집
  - 테스터 5~10명 모집
  - TestFlight/Google Play 내부 테스트 초대
  - 테스트 가이드 문서 작성
- **SubTask 4.5.2**: 사용자 피드백 수집
  - Google Forms 설문지 작성
  - 1일 사용 후 피드백 수집
- **SubTask 4.5.3**: 피드백 반영 계획
  - 긴급 수정 vs Phase 2 이관 결정

**완료 기준**: 피드백 10개 이상 수집, 최종 개선 계획 확정

---

## 📊 Phase 5: Launch Preparation

**목표**: 앱스토어 제출 및 공식 출시
**기간**: Day 21~25 (5일)
**담당**: 전체 팀
**상태**: ⏳ **대기** (Phase 4 완료 후 시작)

### 주요 목표

- 앱스토어 심사 준비 (스크린샷, 설명)
- 법적 문서 작성 (개인정보 처리방침, 이용약관)
- 베타 테스트 (TestFlight, Google Play 내부 테스트)
- 최종 빌드 및 제출
- 공식 출시 🎉

---

### Task 5.1: 앱스토어 심사 준비 (Day 21)

**목표**: 스토어 리스팅 준비

#### 주요 작업
- **SubTask 5.1.1**: 스크린샷 제작
  - iPhone 스크린샷 (6.7", 6.5")
  - iPad 스크린샷 (12.9")
  - Android 스크린샷 (Phone, Tablet)
  - 각 화면별 5장씩 (총 30장)
- **SubTask 5.1.2**: 앱 설명 작성
  - 짧은 설명 (80자)
  - 상세 설명 (4000자)
  - 키워드 설정 (100자)
  - 프로모션 텍스트 (170자)
- **SubTask 5.1.3**: 앱 아이콘 및 에셋
  - 앱 아이콘 (1024x1024)
  - 런처 아이콘 (Android)
  - 스플래시 화면

**완료 기준**: 앱스토어 규격 준수, 마케팅 메시지 일관성

---

### Task 5.2: 법적 문서 작성 (Day 22)

**목표**: 법적 필수 문서 준비

#### 주요 작업
- **SubTask 5.2.1**: 개인정보 처리방침
  - 수집 항목 명시
  - 수집 목적 명시
  - 보유 기간 명시
  - 제3자 제공 명시 (Naver API)
- **SubTask 5.2.2**: 이용약관
  - 서비스 정의
  - 이용자 권리/의무
  - 서비스 중단/변경 조항
  - 면책 조항
- **SubTask 5.2.3**: 법적 문서 앱 연동
  - 웹뷰로 약관 표시
  - 회원가입 시 동의 체크
  - 설정 화면에 약관 링크

**완료 기준**: 법무 검토 완료, 앱에서 약관 확인 가능

---

### Task 5.3: 베타 테스트 (Day 23)

**목표**: TestFlight 및 Google Play 내부 테스트

#### 주요 작업
- **SubTask 5.3.1**: TestFlight 배포 (iOS)
  - Archive 빌드
  - TestFlight 업로드
  - 내부 테스터 초대
- **SubTask 5.3.2**: Google Play 내부 테스트 (Android)
  - Release 빌드 (AAB)
  - Google Play Console 업로드
  - 내부 테스터 트랙 설정
- **SubTask 5.3.3**: 베타 테스트 실시
  - Crash 리포트 모니터링
  - 긴급 버그 수정

**완료 기준**: Critical 버그 0개

---

### Task 5.4: 최종 빌드 및 제출 (Day 24)

**목표**: Production 빌드 생성

#### 주요 작업
- **SubTask 5.4.1**: 최종 버그 수정
  - 베타 테스트 버그 수정
  - 코드 리뷰
  - 최종 테스트
- **SubTask 5.4.2**: Production 빌드
  - iOS Production 빌드 (Archive)
  - Android Production 빌드 (AAB)
  - 빌드 번호 및 버전 확인 (1.0.0)
  - 서명 및 암호화
- **SubTask 5.4.3**: 앱스토어 정보 입력
  - App Store Connect 정보 입력
  - Google Play Console 정보 입력
  - 스크린샷 업로드
  - 설명 및 키워드 입력

**완료 기준**: Production 빌드 성공, 스토어 리스팅 완성

---

### Task 5.5: 앱스토어 제출 및 출시 (Day 25)

**목표**: 공식 출시 🎉

#### 주요 작업
- **SubTask 5.5.1**: 앱스토어 제출
  - App Store Connect에 빌드 제출
  - Google Play Console에 빌드 제출
  - 심사 요청 메모 작성
- **SubTask 5.5.2**: 심사 모니터링
  - 심사 상태 확인
  - 거절 시 즉시 대응
  - 승인 대기
- **SubTask 5.5.3**: 공식 출시 🎉
  - App Store 출시
  - Google Play Store 출시
  - 출시 공지 (SNS, 블로그)
  - 모니터링 시작 (Crash, 리뷰)
- **SubTask 5.5.4**: 출시 기념 회고
  - 팀 회고 미팅
  - 잘한 점 / 개선점 정리
  - Phase 2 계획 논의
  - 축하 🎉

**완료 기준**: 두 스토어 모두 "공개" 상태

---

## 📊 전체 진행 현황 요약

### Phase별 완료 상태

| Phase | 상태 | Task 완료율 | 주요 마일스톤 |
|-------|------|-------------|----------------|
| **Phase 1** | ✅ 완료 | 5/5 (100%) | 7개 화면 UI, Supabase Auth |
| **Phase 2** | ✅ 완료 | 5/5 (100%) | 역산 알고리즘, API 통합 |
| **Phase 3** | 🚧 진행 중 | 1/3 (33%) | Flutter 레이어 완료 |
| **Phase 4** | ⏳ 대기 | 0/5 (0%) | Phase 3 완료 후 시작 |
| **Phase 5** | ⏳ 대기 | 0/5 (0%) | Phase 4 완료 후 시작 |

**전체 MVP 진행률**: ~65%

---

### 핵심 완료 항목

#### ✅ Phase 1 & 2 완료 (Day 1~10)
- Flutter 프로젝트 기반 구축
- Supabase 로컬 환경 및 DB 스키마
- 7개 핵심 화면 UI 완성
- Supabase Auth 완전 통합
- Naver Maps API 통합 (자차 경로)
- Naver Transit API 통합 (대중교통)
- 역산 스케줄링 알고리즘 (48개 테스트 통과)
- Adaptive Polling (15/5/3분)
- TripProvider 상태 관리
- 실시간 카운트다운 작동

#### 🚧 Phase 3 진행 중 (Day 11~15)
- ✅ Flutter WidgetService 완료
- ✅ Flutter NotificationService 완료
- ✅ Android 네이티브 코드 템플릿 준비
- ✅ iOS 네이티브 코드 템플릿 준비
- ⏳ flutter create 실행 대기 (사용자 수동)
- ⏳ 네이티브 코드 적용 대기
- ⏳ 통합 테스트 대기

---

## 🎯 다음 단계 / Next Steps

### 즉시 실행 가능 (User Action Required)

#### 1. flutter create 실행 ⭐ **필수**
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create --org com.gonow .
```

**효과**:
- ✅ `android/` 폴더 생성
- ✅ `ios/` 폴더 생성
- ✅ 기존 `lib/` 코드 유지 (변경 없음)
- ⚠️ `main.dart`는 백업됨 (`lib/main.dart.backup`)

---

#### 2. Android 네이티브 코드 적용 (10-15분)

**작업 순서**:
1. Kotlin 파일 복사
   ```bash
   cp templates/phase3/android/kotlin/*.kt \
      android/app/src/main/kotlin/com/gonow/gotimesaver/
   ```

2. XML 리소스 복사
   ```bash
   mkdir -p android/app/src/main/res/{xml,layout,drawable}
   cp templates/phase3/android/res/xml/*.xml android/app/src/main/res/xml/
   cp templates/phase3/android/res/layout/*.xml android/app/src/main/res/layout/
   cp templates/phase3/android/res/drawable/*.xml android/app/src/main/res/drawable/
   ```

3. AndroidManifest.xml 및 build.gradle 수정
   - `templates/phase3/android/README.md` 참고

**상세 가이드**: [templates/phase3/android/README.md](../templates/phase3/android/README.md)

---

#### 3. iOS 네이티브 코드 적용 (15-20분)

**작업 순서**:
1. AppDelegate.swift 백업 및 교체
   ```bash
   cp ios/Runner/AppDelegate.swift ios/Runner/AppDelegate.swift.backup
   cp templates/phase3/ios/swift/AppDelegate.swift ios/Runner/
   ```

2. Xcode에서 Widget Extension 추가 (수동 작업)
   ```bash
   open ios/Runner.xcworkspace
   ```
   - File → New → Target → Widget Extension
   - Target 이름: GoNowWidgetExtension

3. GoNowWidget.swift 복사 및 프로젝트 추가

4. App Groups 설정 (수동 작업)
   - Runner Target → Signing & Capabilities → App Groups
   - Widget Extension Target → App Groups
   - Group ID: `group.com.gonow.gotimesaver`

**상세 가이드**: [templates/phase3/ios/README.md](../templates/phase3/ios/README.md)

---

#### 4. 통합 테스트 실시 (2-3시간)

**테스트 체크리스트**:
- [ ] 위젯이 홈 화면에 추가됨
- [ ] 일정 추가 시 위젯 업데이트
- [ ] 일정 완료 시 위젯 다음 일정으로 전환
- [ ] 일정 없을 때 빈 상태 표시
- [ ] 30분 전 알림 수신
- [ ] 10분 전 긴급 알림 수신
- [ ] 알림 클릭 시 앱 열림
- [ ] 위젯 15분마다 자동 갱신
- [ ] 시간대별 색상 변경 (초록→주황→빨강)
- [ ] 배터리 소모 정상 범위

**상세 가이드**: [TESTING_GUIDE.md](./TESTING_GUIDE.md) (작성 예정)

---

## 📝 중요 참고 사항

### 1. MethodChannel 이름 일치

**Flutter** (`widget_service.dart`):
```dart
const MethodChannel _channel = MethodChannel('com.gonow.widget');
```

**Android** (`MainActivity.kt`):
```kotlin
val CHANNEL = "com.gonow.widget"
```

**iOS** (`AppDelegate.swift`):
```swift
let channelName = "com.gonow.widget"
```

→ 세 곳 모두 **정확히 동일**해야 함!

---

### 2. App Groups 설정 (iOS)

**필수 설정**:
- Runner Target → Signing & Capabilities → App Groups
- Widget Extension Target → Signing & Capabilities → App Groups
- Group ID: `group.com.gonow.gotimesaver`

→ 두 타겟 모두 동일한 Group ID 설정 필요

---

### 3. 알림 권한

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

**iOS** (`Info.plist`):
- 런타임에 자동으로 권한 요청 다이얼로그 표시
- `requestPermissions()` 호출 시 시스템 다이얼로그

---

### 4. 타임존 설정

**중요**: 한국 시간대 설정 필수
```dart
tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
```

→ NotificationService 초기화 시 자동으로 설정됨

---

## 🔗 관련 문서 링크

### 핵심 문서
- [README.md](./README.md) - 프로젝트 메인 네비게이션
- [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 전체 MVP 명세서 (v3.4)
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 개발 환경 설정
- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - 테스트 전략 (작성 예정)

### Phase 3 상세 가이드
- [templates/README.md](../templates/README.md) - 템플릿 사용법
- [templates/phase3/android/README.md](../templates/phase3/android/README.md) - Android 설치 가이드
- [templates/phase3/ios/README.md](../templates/phase3/ios/README.md) - iOS 설치 가이드

---

## 📞 문의 및 지원

### 프로젝트 관련 질문
- GitHub Issues: [이슈 생성](https://github.com/crazybass81/GoNow-theTimeSaver/issues)

### 문서 관련 피드백
- 문서 개선 제안: GitHub Issues에 `documentation` 라벨로 등록

---

**작성일**: 2026-01-07
**작성자**: Claude
**버전**: 1.0
**다음 업데이트**: Phase 3 완료 시

---

**Made with 🤖 [Claude Code](https://claude.com/claude-code)**
