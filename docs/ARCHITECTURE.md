# GoNow 시스템 아키텍처

**최종 업데이트**: 2026-01-09
**문서 버전**: 2.2
**시스템 버전**: MVP v1.0 (Phase 4 완료, Phase 5 준비 중)

---

## 📐 목차 / Table of Contents

1. [시스템 개요](#1-시스템-개요--system-overview)
2. [아키텍처 다이어그램](#2-아키텍처-다이어그램--architecture-diagrams)
3. [기술 스택](#3-기술-스택--tech-stack)
4. [레이어별 상세 구조](#4-레이어별-상세-구조--layer-details)
5. [데이터 흐름](#5-데이터-흐름--data-flow)
6. [핵심 알고리즘](#6-핵심-알고리즘--core-algorithms)
7. [보안 및 인증](#7-보안-및-인증--security--authentication)
8. [성능 최적화](#8-성능-최적화--performance-optimization)
9. [확장성 고려사항](#9-확장성-고려사항--scalability)

---

## 1. 시스템 개요 / System Overview

### 1.1 아키텍처 원칙

**핵심 원칙**:
- **오프라인 우선 (Offline-First)**: 네트워크 없이도 기본 기능 작동
- **반응형 (Reactive)**: 실시간 데이터 변경에 즉각 반응
- **보안 우선 (Security-First)**: RLS, E2E 암호화, 로컬 데이터 보호
- **배터리 효율 (Battery-Efficient)**: 적응형 폴링, 최적화된 위젯 업데이트

**설계 패턴**:
- **MVVM** (Model-View-ViewModel): Flutter Provider 기반
- **Repository Pattern**: 데이터 소스 추상화
- **Strategy Pattern**: 교통수단별 경로 계산
- **Observer Pattern**: 실시간 업데이트

---

### 1.2 시스템 제약사항

| 제약사항 | 값 | 이유 |
|----------|----|----|
| **최소 Android 버전** | 6.0 (API 23) | Jetpack Glance 요구사항 |
| **최소 iOS 버전** | 14.0 | WidgetKit 요구사항 |
| **Flutter 버전** | 3.x | 최신 Material 3 지원 |
| **API 응답 타임아웃** | 10초 | 사용자 경험 유지 |
| **로컬 DB 크기 제한** | 50MB | 모바일 스토리지 고려 |
| **위젯 업데이트 주기** | 15/5/3분 (적응형) | 배터리 효율과 정확성 균형 |

---

## 2. 아키텍처 다이어그램 / Architecture Diagrams

### 2.1 전체 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Client Layer (Flutter)                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │   iOS App       │  │   Android App   │  │   Widgets       │     │
│  │  (Flutter/Dart) │  │  (Flutter/Dart) │  │  (Native)       │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘     │
│         │                     │                     │               │
│         └──────────┬──────────┴──────────┬──────────┘               │
│                    │                     │                          │
│         ┌──────────▼─────────────────────▼──────────┐               │
│         │     Flutter Application Layer             │               │
│         │  ┌────────────┐  ┌────────────────────┐   │               │
│         │  │  Screens   │  │   State Management │   │               │
│         │  │  (UI)      │  │    (Provider)      │   │               │
│         │  └────────────┘  └────────────────────┘   │               │
│         │                                            │               │
│         │  ┌────────────┐  ┌────────────────────┐   │               │
│         │  │  Services  │  │      Models        │   │               │
│         │  │  (Logic)   │  │    (Data DTOs)     │   │               │
│         │  └────────────┘  └────────────────────┘   │               │
│         └────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
┌──────────────────────┐  ┌─────────────────┐  ┌──────────────────┐
│   Supabase Backend   │  │  External APIs  │  │  Local Storage   │
│    (PostgreSQL)      │  │                 │  │                  │
│                      │  │  • TMAP Routes  │  │  • SharedPrefs   │
│  • Authentication    │  │  • TMAP POI     │  │  • SQLite        │
│  • Database (RLS)    │  │  • TMAP Transit │  │  • App Groups    │
│  • Realtime Updates  │  │                 │  │    (iOS)         │
│  • Storage           │  │                 │  │  • UserDefaults  │
└──────────────────────┘  └─────────────────┘  └──────────────────┘
```

---

### 2.2 Flutter 애플리케이션 레이어

```
lib/
├── main.dart                         # 앱 진입점, Provider 설정
│
├── screens/                          # UI 레이어 (7개 화면)
│   ├── auth/
│   │   ├── login_screen.dart         # 로그인 (이메일/비밀번호)
│   │   └── signup_screen.dart        # 회원가입 (3단계 플로우)
│   ├── dashboard/
│   │   └── dashboard_screen.dart     # 메인 화면 (카운트다운 + 경로)
│   ├── schedule/
│   │   ├── add_trip_screen.dart      # 일정 추가 (4단계 플로우)
│   │   └── calendar_screen.dart      # 월간 캘린더 (table_calendar)
│   └── settings/
│       └── settings_screen.dart      # 설정 (버퍼 시간, 알림, 계정)
│
├── services/                         # 비즈니스 로직 레이어
│   ├── supabase_service.dart         # Supabase 연동
│   ├── route_service.dart            # 경로 탐색 (TMAP Routes API)
│   ├── transit_service.dart          # 대중교통 경로 (TMAP Public Transit API)
│   ├── poi_search_service.dart       # 장소 검색 (TMAP POI Search API)
│   ├── scheduler_service.dart        # 역산 스케줄링 알고리즘
│   ├── notification_service.dart     # 로컬 푸시 알림
│   ├── widget_service.dart           # 홈 위젯 업데이트
│   ├── trip_service.dart             # Trip CRUD + Realtime
│   ├── polling_service.dart          # 적응형 폴링 (15/5/3분)
│   ├── real_time_updater.dart        # 실시간 경로 업데이트
│   └── settings_service.dart         # 사용자 설정 관리
│
├── providers/                        # 상태 관리 (Provider)
│   ├── auth_provider.dart            # 인증 상태
│   ├── trip_provider.dart            # 일정 상태 + 실시간 업데이트
│   └── settings_provider.dart        # 설정 상태
│
├── models/                           # 데이터 모델
│   ├── trip.dart                     # 일정 모델
│   ├── route.dart                    # 경로 모델
│   ├── user_settings.dart            # 사용자 설정 모델
│   └── buffer_times.dart             # 버퍼 시간 모델
│
├── widgets/                          # 재사용 가능한 위젯
│   ├── countdown_timer.dart          # 카운트다운 UI
│   ├── route_card.dart               # 경로 표시 카드
│   └── color_phase_indicator.dart    # 색상 단계 표시
│
└── utils/                            # 유틸리티 함수
    ├── date_utils.dart               # 날짜/시간 변환
    ├── format_utils.dart             # 포맷팅 (시간, 거리)
    └── constants.dart                # 상수 정의
```

#### 📊 GitHub Repository vs Local 구조 비교

**Local 프로젝트 특징** (Feature-based Architecture):
- ✅ **Feature별 그룹화**: auth/, dashboard/, schedule/, settings/ 서브디렉토리
- ✅ **재사용 위젯 분리**: widgets/ 폴더에 5개 공통 위젯
- ✅ **확장성 우수**: 새로운 feature 추가 시 독립적인 폴더 생성
- ✅ **유지보수성 향상**: 기능별 명확한 경계와 의존성 관리

**GitHub Repository (khyapple/go_now)** (Flat Architecture):
```
lib/screens/  # 모든 13개 화면이 직접 하위
├── admin_screen.dart
├── calendar_screen.dart
├── home_screen.dart
├── loading_screen.dart
├── login_screen.dart
├── main_wrapper.dart
├── privacy_policy_screen.dart
├── schedule_detail_screen.dart
├── schedule_edit_screen.dart
├── settings_screen.dart
├── signup_screen.dart
├── splash_screen.dart
└── terms_screen.dart
```

**구조적 우수성**:
- ✅ Local은 9개 화면 + 5개 위젯으로 GitHub 대비 더 체계적
- ✅ Provider + Supabase 상태 관리 (GitHub: SharedPreferences)
- ✅ GitHub UI 패턴 ~95% 준수하면서도 더 나은 아키텍처 제공
- 📖 상세 비교: [GITHUB_VS_LOCAL_UI_COMPARISON.md](../claudedocs/GITHUB_VS_LOCAL_UI_COMPARISON.md)

---

### 2.3 네이티브 레이어 구조

#### Android (Kotlin + Jetpack Glance)
```
android/app/src/main/
├── kotlin/com/gonow/gotimesaver/
│   ├── MainActivity.kt               # Flutter ↔ Native 통신
│   ├── GoNowWidget.kt                # Jetpack Glance 위젯
│   └── WidgetUpdateWorker.kt         # WorkManager 백그라운드 작업
│
└── res/
    ├── xml/
    │   └── gonow_widget_info.xml     # 위젯 메타데이터
    ├── layout/
    │   └── widget_initial_layout.xml # 초기 레이아웃
    ├── drawable/
    │   └── widget_background.xml     # 위젯 배경
    └── values/
        └── strings.xml               # 문자열 리소스
```

#### iOS (Swift + WidgetKit)
```
ios/
├── Runner/
│   └── AppDelegate.swift             # Flutter ↔ Native 통신
│
└── GoNowWidgetExtension/
    ├── GoNowWidget.swift             # WidgetKit 구현
    ├── Info.plist                    # 위젯 설정
    └── Assets.xcassets/              # 위젯 리소스
```

---

## 3. 기술 스택 / Tech Stack

### 3.1 프론트엔드

| 기술 | 버전 | 용도 | 선택 이유 |
|------|------|------|----------|
| **Flutter** | 3.x | 크로스 플랫폼 앱 | 빠른 개발, 단일 코드베이스 |
| **Dart** | 3.x | 프로그래밍 언어 | Flutter 공식 언어 |
| **Provider** | ^6.1.0 | 상태 관리 | 간단하고 효율적 |
| **table_calendar** | ^3.0.9 | 캘린더 UI | 한국 로케일 지원 |
| **flutter_local_notifications** | ^16.0.0 | 로컬 알림 | 서버 없이 알림 구현 |
| **timezone** | ^0.9.2 | 시간대 처리 | 정확한 알림 스케줄링 |

### 3.2 백엔드

| 기술 | 버전 | 용도 | 선택 이유 |
|------|------|------|----------|
| **Supabase** | Latest | BaaS | 실시간 동기화, RLS, Auth |
| **PostgreSQL** | 15.x | 데이터베이스 | 관계형 DB, JSON 지원 |
| **Supabase Auth** | - | 인증 | 이메일/소셜 로그인 |
| **Supabase Realtime** | - | 실시간 동기화 | WebSocket 기반 |

### 3.3 외부 API

| API | 용도 | 제한사항 |
|-----|------|----------|
| **TMAP Routes API** | 자차 경로 계산 (실시간 교통, GeoJSON) | SK Open API 정책 |
| **TMAP POI Search API** | 장소 검색 (실시간, WGS84 좌표) | 최대 20개 결과/요청 |
| **TMAP Public Transit API** | 대중교통 경로 (버스/지하철, 환승) | SK Open API 정책 |

**Note**:
- 2026-01-07: Naver Maps Directions API → TMAP Routes API 전환 완료
- 2026-01-07: Naver Transit API → TMAP Public Transit API 전환 완료
- 자세한 내용: [TMAP_API_MIGRATION.md](./TMAP_API_MIGRATION.md)

### 3.4 네이티브

| 플랫폼 | 기술 | 용도 |
|--------|------|------|
| **Android** | Kotlin, Jetpack Glance, WorkManager | 홈 위젯, 백그라운드 작업 |
| **iOS** | Swift, WidgetKit, Timeline Provider | 홈 위젯, 스케줄링 |

---

## 4. 레이어별 상세 구조 / Layer Details

### 4.1 Presentation Layer (UI)

**패턴**: MVVM (Model-View-ViewModel)

**구성 요소**:
- **View** (Screens): 사용자 인터페이스
- **ViewModel** (Providers): 화면 상태 관리
- **Model** (Models): 데이터 구조

**화면별 상태 관리**:
```dart
// 예: Dashboard Screen
DashboardScreen (View)
    ↓ 구독 (Consumer)
TripProvider (ViewModel)
    ↓ 사용
TripService (Business Logic)
    ↓ 호출
Supabase + TMAP API (Data Source)
```

---

### 4.2 Business Logic Layer (Services)

#### 4.2.1 SchedulerService (역산 스케줄링)

**책임**:
- 도착 시간 → 출발 시간 계산
- 4가지 버퍼 시간 적용
- 교통수단별 시간 계산

**알고리즘**:
```
출발 시간 = 도착 시간
          - 이동 시간
          - 이동 오차율 (%)
          - 외출 준비 시간
          - 일찍 도착 버퍼
```

**코드 위치**: `lib/services/scheduler_service.dart`

---

#### 4.2.2 RouteService (경로 탐색)

**책임**:
- TMAP Routes API 호출 (자차 경로 계산)
- 실시간 교통 정보 반영
- GeoJSON 경로 데이터 파싱
- 캐싱 전략 (5분 유효)
- 에러 핸들링 및 재시도

**API 플로우**:
```
1. 캐시 확인 (5분 이내?)
   ├─ Yes → 캐시 데이터 반환
   └─ No → TMAP API 호출
2. TMAP Routes API 호출 (timeout: 10초)
   ├─ Success → GeoJSON 파싱 → 캐시 저장 + 반환
   └─ Fail → 재시도 (최대 3회)
3. 재시도 실패 → 에러 반환
```

**코드 위치**: `lib/services/route_service.dart`

---

#### 4.2.3 POISearchService (장소 검색)

**책임**:
- TMAP POI Search API 호출 (장소 검색)
- WGS84 좌표계 변환
- 검색 결과 필터링 및 정렬
- 에러 핸들링 (네트워크, API 키 등)

**API 플로우**:
```
1. 검색 키워드 입력
   ↓
2. TMAP POI Search API 호출 (최대 20개 결과)
   ├─ Success → POIResult 객체 리스트 반환
   └─ Fail → POISearchException 발생
3. UI에 검색 결과 표시
   ├─ 장소 이름
   ├─ 도로명 주소 (우선) / 지번 주소
   ├─ 좌표 (WGS84)
   └─ 카테고리
```

**코드 위치**: `lib/services/poi_search_service.dart`

---

#### 4.2.4 NotificationService (알림)

**책임**:
- 30분 전 일반 알림
- 10분 전 긴급 알림
- 동적 알림 (교통 지연 시)
- 알림 권한 관리

**알림 스케줄**:
```
일정 추가
    ↓
NotificationService.scheduleNotifications()
    ├─ 30분 전: flutter_local_notifications.zonedSchedule()
    └─ 10분 전: flutter_local_notifications.zonedSchedule()
```

**코드 위치**: `lib/services/notification_service.dart`

---

#### 4.2.5 WidgetService (위젯 업데이트)

**책임**:
- Flutter → Android/iOS 네이티브 통신
- 위젯 데이터 포맷팅
- 시간대별 색상 결정

**MethodChannel 플로우**:
```
Flutter (WidgetService)
    ↓ MethodChannel('com.gonow.widget')
Android: MainActivity.kt
iOS: AppDelegate.swift
    ↓
SharedPreferences / UserDefaults (App Group)
    ↓
Widget 자동 갱신
```

**코드 위치**: `lib/services/widget_service.dart`

---

### 4.3 Data Layer

#### 4.3.1 Supabase Integration

**데이터베이스 스키마**:
```sql
-- trips 테이블
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    arrival_time TIMESTAMPTZ NOT NULL,
    departure_time TIMESTAMPTZ,
    transport_type TEXT NOT NULL,
    route_data JSONB,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- users 테이블 (설정 정보 추가)
ALTER TABLE auth.users
ADD COLUMN settings JSONB DEFAULT '{
    "prep_time": 15,
    "early_buffer": 10,
    "error_rate": 20,
    "completion_time": 5
}';

-- Row Level Security (RLS)
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own trips"
ON trips FOR ALL
USING (auth.uid() = user_id);
```

#### 4.3.2 로컬 스토리지

**SharedPreferences (Android) / UserDefaults (iOS)**:
- 사용자 설정 (버퍼 시간)
- 위젯 데이터
- 캐시 데이터

**App Groups (iOS)**:
- 위젯과 앱 간 데이터 공유
- Group ID: `group.com.gonow.gotimesaver`

---

## 5. 데이터 흐름 / Data Flow

### 5.1 일정 추가 플로우

```
사용자 입력 (AddTripScreen)
    ↓
TripProvider.addTrip()
    ↓
┌─ RouteService.getRoute() → TMAP API → 이동 시간 계산
│
├─ SchedulerService.calculateDepartureTime() → 출발 시간 산출
│
├─ TripService.createTrip() → Supabase 저장
│
├─ NotificationService.scheduleNotifications() → 알림 예약
│
└─ WidgetService.updateWidget() → 위젯 업데이트
    ↓
대시보드 자동 갱신 (Realtime Subscription)
```

---

### 5.2 실시간 업데이트 플로우

```
Supabase Realtime
    ↓ (PostgreSQL 변경 감지)
TripService.subscribeToTrips()
    ↓ (Stream<List<Trip>>)
TripProvider.notifyListeners()
    ↓ (상태 변경 알림)
DashboardScreen (Consumer)
    ↓ (UI 자동 재빌드)
화면 업데이트
```

---

### 5.3 위젯 업데이트 플로우

#### Android
```
TripProvider 변경
    ↓
WidgetService.updateWidget()
    ↓ MethodChannel
MainActivity.updateWidget()
    ↓
SharedPreferences 저장
    ↓
GoNowWidget.updateWidget()
    ↓
WorkManager 스케줄링 (15/5/3분)
    ↓
WidgetUpdateWorker.doWork()
    ↓
위젯 UI 갱신
```

#### iOS
```
TripProvider 변경
    ↓
WidgetService.updateWidget()
    ↓ MethodChannel
AppDelegate.updateWidget()
    ↓
UserDefaults (App Group) 저장
    ↓
WidgetCenter.reloadAllTimelines()
    ↓
Timeline Provider 스케줄링 (15/5/3분)
    ↓
위젯 UI 갱신
```

---

## 6. 핵심 알고리즘 / Core Algorithms

### 6.1 역산 스케줄링 알고리즘

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

**예시**:
```
도착 시간: 14:00
이동 시간: 30분
오차율: 20%

계산:
1. 조정된 이동 시간 = 30 * 1.2 = 36분
2. 버퍼 합계 = 15 (준비) + 10 (일찍 도착) + 5 (마무리) = 30분
3. 출발 시간 = 14:00 - 36분 - 30분 = 12:54
```

---

### 6.2 적응형 폴링 알고리즘

```dart
int getPollingInterval(int minutesRemaining) {
  if (minutesRemaining > 30) return 15; // 초록: 15분
  if (minutesRemaining > 15) return 5;  // 주황: 5분
  return 3;                             // 빨강: 3분
}

String getColorPhase(int minutesRemaining) {
  if (minutesRemaining > 30) return 'green';
  if (minutesRemaining > 15) return 'orange';
  if (minutesRemaining > 0) return 'red';
  return 'dark_red'; // 지각
}
```

---

### 6.3 환승 버퍼 시간 계산

```dart
int calculateTransferBuffer({
  required String fromType,    // 'bus', 'subway', 'walk'
  required String toType,
  required double distance,    // 미터
}) {
  // 기본 환승 시간
  final baseTime = {
    'bus_bus': 3,
    'bus_subway': 5,
    'subway_subway': 5,
    'walk_bus': 2,
    'walk_subway': 3,
  }['${fromType}_${toType}'] ?? 5;

  // 거리 기반 조정
  if (distance > 500) return baseTime + 5;  // 500m 초과 → +5분
  if (distance > 100) return baseTime + 2;  // 100m 초과 → +2분
  return baseTime;
}
```

---

## 7. 보안 및 인증 / Security & Authentication

### 7.1 Supabase Row Level Security (RLS)

**정책**:
```sql
-- 사용자는 본인 데이터만 접근
CREATE POLICY "Users can only access their own data"
ON trips
FOR ALL
USING (auth.uid() = user_id);

-- SELECT
CREATE POLICY "Users can read own trips"
ON trips FOR SELECT
USING (auth.uid() = user_id);

-- INSERT
CREATE POLICY "Users can insert own trips"
ON trips FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- UPDATE
CREATE POLICY "Users can update own trips"
ON trips FOR UPDATE
USING (auth.uid() = user_id);

-- DELETE
CREATE POLICY "Users can delete own trips"
ON trips FOR DELETE
USING (auth.uid() = user_id);
```

---

### 7.2 API 키 보안

**환경 변수 관리**:
```dart
// .env 파일 (Git에 커밋 안 됨)
TMAP_APP_KEY=your_tmap_app_key
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
```

**로딩**:
```dart
// lib/utils/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get tmapAppKey =>
      dotenv.env['TMAP_APP_KEY'] ?? '';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';
}
```

---

### 7.3 로컬 데이터 보안

**SharedPreferences 암호화** (Android):
```kotlin
// EncryptedSharedPreferences 사용
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val sharedPreferences = EncryptedSharedPreferences.create(
    context,
    "secret_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
```

---

## 8. 성능 최적화 / Performance Optimization

### 8.1 API 캐싱 전략

**5분 캐시**:
```dart
class RouteService {
  final Map<String, CachedRoute> _cache = {};

  Future<Route> getRoute(String from, String to) async {
    final cacheKey = '$from-$to';
    final cached = _cache[cacheKey];

    // 5분 이내 캐시 → 반환
    if (cached != null &&
        DateTime.now().difference(cached.timestamp).inMinutes < 5) {
      return cached.route;
    }

    // API 호출 → 캐시 저장
    final route = await _fetchFromAPI(from, to);
    _cache[cacheKey] = CachedRoute(route, DateTime.now());
    return route;
  }
}
```

---

### 8.2 위젯 업데이트 최적화

**배터리 효율**:
- 30분 이상: 15분마다 업데이트
- 15-30분: 5분마다 업데이트
- 15분 미만: 3분마다 업데이트

**변화율 체크**:
```dart
// 5% 이상 변화 시에만 업데이트
if ((newTime - oldTime).abs() / oldTime > 0.05) {
  updateWidget();
}
```

---

### 8.3 Realtime 구독 최적화

**필터링**:
```dart
// 완료되지 않은 일정만 구독
supabase
    .from('trips')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .eq('is_completed', false)
    .order('arrival_time')
    .listen((data) {
      // UI 업데이트
    });
```

---

## 9. 확장성 고려사항 / Scalability

### 9.1 향후 확장 계획

| Phase | 기능 | 기술 스택 | 상태 |
|-------|------|----------|------|
| **Phase 4** | 통합 테스트 & QA | Unit Tests, Integration Tests, UI Refinement | ✅ 완료 (100%) |
| **Phase 5** | 백엔드 통합 | Supabase, API Integration | 🔄 준비 중 |
| **Phase 6** | 게임화 (Streak, 배지) | Firebase Analytics | ⏳ 예정 |
| **Phase 7** | 지오펜싱 | Geolocation API | ⏳ 예정 |
| **Phase 8** | 소셜 기능 (친구, 랭킹) | Supabase + GraphQL | ⏳ 예정 |

---

### 9.2 수평 확장 전략

**데이터베이스**:
- Supabase 자동 스케일링
- Read Replica 추가 (읽기 부하 분산)
- Connection Pooling (pg_bouncer)

**API**:
- CDN 캐싱 (경로 데이터)
- Rate Limiting (사용자당 100 req/min)
- API Gateway (Kong, AWS API Gateway)

---

### 9.3 모니터링 및 로깅

**도구**:
- **Sentry**: 에러 추적
- **Firebase Analytics**: 사용자 행동 분석
- **Supabase Dashboard**: DB 성능 모니터링

**핵심 지표**:
- API 응답 시간 (p50, p95, p99)
- 위젯 업데이트 성공률
- 알림 전송 성공률
- 배터리 소모량

---

## 📚 참고 문서 / References

### 내부 문서
- [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 전체 MVP 명세
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 개발 환경 설정
- [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - Phase별 구현 가이드

### 외부 문서
- [Flutter Architecture Guide](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
- [Supabase Documentation](https://supabase.com/docs)
- [Jetpack Glance Guide](https://developer.android.com/jetpack/compose/glance)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)

---

**작성일**: 2026-01-07
**다음 리뷰**: Phase 4 완료 시 (MVP 출시 전)
**문서 유지관리자**: 개발 팀
