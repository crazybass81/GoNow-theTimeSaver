# GoNow: The Time Saver ⏰

> ADHD 사용자를 위한 역산 스케줄링 기반 시간 관리 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📖 프로젝트 개요

**GoNow**는 ADHD 사용자의 "계획 오류(Planning Fallacy)"와 "시간 맹목(Time Blindness)"를 해결하기 위한 모바일 앱입니다.

### 🎯 핵심 기능

1. **역산 스케줄링 (Backward Planning)**
   - 도착 시간에서 역으로 계산하여 출발 시간 자동 산출
   - 4가지 독립 버퍼 시간 설정:
     - 외출 준비 시간 (15분)
     - 일찍 도착 버퍼 (10분)
     - 이동 오차율 (20%)
     - 일정 마무리 시간 (5분)

2. **실시간 교통 정보**
   - TMAP Routes API: 자동차 경로 탐색 (실시간 교통 반영)
   - TMAP Public Transit API: 대중교통 경로 (버스/지하철)

3. **스마트 알림**
   - 시간대별 색상 시스템 (초록→주황→빨강)
   - 적응형 알림 (15분/5분/3분 전)

4. **홈 위젯**
   - Android: Jetpack Glance
   - iOS: WidgetKit
   - 15분 주기 자동 업데이트

## 🏗️ 기술 스택

### Frontend
- **Framework**: Flutter 3.x (Dart)
- **State Management**: Provider
- **UI**: Material Design 3

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Security**: Row Level Security (RLS)

### External APIs
- **TMAP Routes API**: 자동차 경로 탐색 (실시간 교통) - *2026-01-07 마이그레이션*
- **TMAP Public Transit API**: 대중교통 경로 (버스/지하철)
- **TMAP POI Search API**: 장소 검색 - *2026-01-07 통합*

## 🚀 빠른 시작

### 필수 요구사항

- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Xcode (iOS 개발용)
- Android Studio (Android 개발용)

### 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/crazybass81/GoNow-theTimeSaver.git
cd GoNow-theTimeSaver
```

2. **의존성 설치**
```bash
flutter pub get
```

**⚠️ 중요**: Phase 1 완료 후 `table_calendar` 패키지가 추가되었습니다. 반드시 `flutter pub get`을 실행하세요!

3. **환경 변수 설정**
```bash
cp .env.example .env
# .env 파일을 열어서 실제 API 키로 수정
```

4. **Supabase 로컬 개발 환경 시작**
```bash
supabase start
# 마이그레이션이 자동으로 적용됩니다
# API URL: http://127.0.0.1:54321
# Studio URL: http://127.0.0.1:54323
```

5. **앱 실행**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 📁 프로젝트 구조

```
GoNow-theTimeSaver/
├── lib/
│   ├── main.dart                 # 앱 진입점
│   ├── screens/                  # 화면 위젯
│   │   ├── auth/                 # 인증 (로그인, 회원가입)
│   │   ├── dashboard/            # 대시보드 (메인)
│   │   ├── schedule/             # 일정 추가/수정
│   │   └── settings/             # 설정
│   ├── services/                 # 비즈니스 로직
│   │   ├── supabase_service.dart # Supabase 연동
│   │   ├── route_service.dart    # 경로 탐색 (Naver API)
│   │   └── notification_service.dart # 로컬 알림
│   ├── models/                   # 데이터 모델
│   ├── providers/                # 상태 관리 (Provider)
│   ├── widgets/                  # 재사용 가능한 위젯
│   └── utils/                    # 유틸리티 함수
├── supabase/
│   ├── migrations/               # SQL 마이그레이션 파일
│   └── README.md                 # Supabase 설정 가이드
├── android/                      # Android 네이티브 코드
├── ios/                          # iOS 네이티브 코드
├── assets/                       # 이미지, 아이콘, 폰트
├── docs/                         # 프로젝트 문서
│   ├── GO_NOW_COMPLETE_MVP_SPEC.md  # 완전한 MVP 명세서 v3.4
│   ├── IMPLEMENTATION_PHASES.md     # 구현 가이드 v2.0
│   ├── ARCHITECTURE.md              # 시스템 아키텍처 v2.0
│   ├── DEVELOPMENT_GUIDE.md         # 개발 환경 설정 v2.0
│   ├── TMAP_API_MIGRATION.md        # TMAP API 마이그레이션
│   └── archive/                     # 문서 아카이브
├── pubspec.yaml                  # Flutter 의존성
├── .env.example                  # 환경 변수 템플릿
└── README.md                     # 이 파일
```

## 📋 개발 계획

**MVP 출시 목표일**: 2026년 1월 31일 (25일)

**전체 MVP 진행률**: ~65%
- Phase 1-2: 100% 완료
- Phase 3: 60% 완료 (Flutter 레이어 완료, 네이티브 통합 대기)
- Phase 4: 90% 진행 중
- Phase 5: 대기 중

📄 상세 진행 상황: [IMPLEMENTATION_PHASES.md v2.0](docs/IMPLEMENTATION_PHASES.md)

### ✅ Phase 1: Foundation & UI (Day 1~5) - **완료!** (2026-01-06)
- ✅ Git 저장소 설정
- ✅ Supabase 프로젝트 설정 (로컬 개발 환경)
- ✅ Flutter 프로젝트 기본 구조
- ✅ 디자인 시스템 정의 (색상/타이포그래피)
- ✅ 핵심 화면 UI (7개)
  - ✅ 로그인 화면
  - ✅ 회원가입 화면 (3단계 플로우)
  - ✅ 인증 상태 관리 (AuthProvider)
  - ✅ 대시보드 화면 (카운트다운 + 경로 표시)
  - ✅ 일정 추가/수정 화면 (4단계 플로우)
  - ✅ 월간 캘린더 화면 (table_calendar 패키지)
  - ✅ 설정 화면 (버퍼 시간, 알림, 계정 관리)

### ✅ Phase 2: Core Logic & API (Day 6~10) - **완료!** (2026-01-07)
- ✅ **Task 2.1: 경로 API 연동** (완료 - 2026-01-07)
  - ✅ ~~Naver Directions API~~ → **TMAP Routes API 마이그레이션** (2026-01-07)
  - ✅ TMAP API 연동 (자차 경로, 실시간 교통, GeoJSON 경로)
  - ✅ API 에러 핸들링 (8가지 에러 타입, 자동 재시도)
  - ✅ 캐싱 전략 구현 (5분 유효, 중복 요청 방지)
  - 📄 마이그레이션 문서: [TMAP_API_MIGRATION.md](docs/TMAP_API_MIGRATION.md)
- ✅ **Task 2.2: TMAP Public Transit API 연동** (완료 - 2026-01-06)
  - ✅ Transit API 연동 (버스/지하철 통합, dio 패키지)
  - ✅ Singleton 패턴 및 에러 핸들링 (8가지 에러 타입)
  - ✅ 캐싱 전략 구현 (5분 유효, 재시도 로직)
  - ✅ 환승 버퍼 시간 자동 계산 (도보 5분, 버스 3분, 지하철 5분)
  - ✅ 거리 기반 조정 로직 (100m/500m 임계값)
- ✅ **Task 2.3: 역산 스케줄링 알고리즘** (완료 - 2026-01-06)
  - ✅ SubTask 2.3.1: SchedulerService 기본 구현
    - ✅ calculateDepartureTime() 메서드 (4가지 버퍼 시간 반영)
    - ✅ 단위 테스트 100% 통과 (48개 테스트)
  - ✅ SubTask 2.3.2: Adaptive Polling 로직
    - ✅ getPollingInterval() 메서드 (15분/5분/3분 간격)
    - ✅ 시간대별 색상 시스템 (초록/주황/빨강)
    - ✅ 단위 테스트 100% 통과
  - ✅ SubTask 2.3.3: 실시간 업데이트 로직
    - ✅ Timer 기반 자동 갱신
    - ✅ 변화율 5% 미만 시 스킵 (배터리 효율)
    - ✅ UI 자동 업데이트 콜백
    - ✅ 단위 테스트 100% 통과
- ✅ **Task 2.4: Supabase 데이터 모델 구현** (완료 - 2026-01-07)
  - ✅ Trip 모델 및 TripService (CRUD, Realtime 구독)
  - ✅ UserSettings 모델 및 SettingsService (로컬 캐싱)
  - ✅ Supabase 마이그레이션 (users 테이블 설정 컬럼 추가)
- ✅ **Task 2.5: API 및 로직 통합** (완료 - 2026-01-07)
  - ✅ TripProvider 생성 (상태 관리)
  - ✅ 대시보드 실시간 업데이트 연결
  - ✅ 실제 데이터 표시 (Trip, 카운트다운, 경로)
  - ✅ 에러 처리 및 빈 상태 UI

### 🚧 Phase 3: Widgets & Notifications (Day 11~15) - **60% 완료** (2026-01-07)

**상태**: Flutter 레이어 100% 완료, 네이티브 통합 대기

- ✅ **Flutter 레이어 구현** (완료 - 2026-01-07)
  - ✅ WidgetService 생성 (22개 테스트 통과)
  - ✅ NotificationService 생성 (17개 테스트 통과)
  - ✅ pubspec.yaml 업데이트 (timezone, flutter_local_notifications)
  - ✅ RealTimeUpdater 서비스 생성 (적응형 폴링, 변화율 5% 스킵)

- ✅ **네이티브 코드 템플릿 준비** (완료 - 2026-01-07)
  - ✅ Android: Jetpack Glance 위젯 구조 (templates/phase3/android/)
  - ✅ iOS: WidgetKit 구조 (templates/phase3/ios/)
  - 📄 가이드: [templates/phase3/android/README.md](templates/phase3/android/README.md)
  - 📄 가이드: [templates/phase3/ios/README.md](templates/phase3/ios/README.md)

- ⏳ **네이티브 통합 대기** (사용자 수동 작업 필요)
  - ⏳ `flutter create` 실행 (android/, ios/ 폴더 생성)
  - ⏳ Android 네이티브 코드 적용 (10-15분)
  - ⏳ iOS Xcode Widget Extension 생성 (20-25분)
  - ⏳ 통합 테스트 (실제 기기)

📄 상세 문서:
- [IMPLEMENTATION_PHASES.md v2.0](docs/IMPLEMENTATION_PHASES.md) - 전체 구현 가이드
- [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - 테스트 전략

### 🚧 Phase 4: Integration & QA (Day 16~20) - **진행 중 (90%)** (2026-01-07)

**완료된 작업**:
- ✅ **Widget Tests 완료** (66개 테스트)
  - DashboardScreen: 16개 테스트
  - AddScheduleScreen: 31개 테스트
  - SettingsScreen: 19개 테스트
- ✅ **E2E Tests 작성 완료** (23개 테스트)
  - app_start_test: 3개 (앱 시작 및 LoginScreen)
  - dashboard_rendering_test: 5개 (대시보드 렌더링)
  - add_schedule_flow_test: 10개 (일정 추가 플로우)
  - integrated_scenario_test: 5개 (통합 시나리오)
- ✅ **API 통합 완료** (2026-01-07)
  - TMAP POI Search Service 구현 (장소 검색 API)
  - 현재 위치 서비스 통합 (Geolocator, GPS)
  - 실제 경로 계산 및 저장 (mock 데이터 제거)
  - add_schedule_screen 실제 API 연동
  - 📄 세션 문서: [SESSION_2025_01_07_API_Integration.md](claudedocs/SESSION_2025_01_07_API_Integration.md)

**전체 테스트 현황**: ✅ **328개 테스트 통과** (2026-01-07)
- Unit Tests: 305개 (100% 통과)
- Integration Tests: 4개 (TMAP API, 100% 통과)
- Widget Tests: 66개 (작성 완료)
- E2E Tests: 23개 (100% 통과)
- 📄 테스트 문서: [TEST_RESULTS_2025_01_07.md](docs/TEST_RESULTS_2025_01_07.md)
- 🚀 디바이스 테스트: SM A136S (Android 14) 배포 완료

**남은 작업**:
- ⏳ 성능 및 배터리 최적화
- ⏳ Alpha 사용자 테스트

### Phase 5: Launch (Day 21~25)
- 스토어 제출 준비
- 앱스토어/플레이스토어 출시

자세한 개발 계획은 [GO_NOW_COMPLETE_MVP_SPEC.md](docs/GO_NOW_COMPLETE_MVP_SPEC.md)를 참조하세요.

## 🔐 보안

- **Row Level Security (RLS)**: 사용자는 본인 데이터만 접근 가능
- **환경 변수**: API 키는 `.env` 파일로 관리 (Git에 커밋되지 않음)
- **Supabase Auth**: 이메일/비밀번호 + 소셜 로그인 (Google, Apple, Kakao)

## 📄 문서

### 핵심 문서
- [완전한 MVP 명세서](docs/GO_NOW_COMPLETE_MVP_SPEC.md)
- [시스템 아키텍처](docs/ARCHITECTURE.md)
- [구현 가이드](docs/IMPLEMENTATION_PHASES.md)
- [테스트 가이드](docs/TESTING_GUIDE.md)
- [개발 환경 설정](docs/DEVELOPMENT_GUIDE.md)
- [Supabase 설정 가이드](supabase/README.md)

### 최신 업데이트 (2026-01-07)
- 🆕 [구현 가이드 v2.0](docs/IMPLEMENTATION_PHASES.md) - **대규모 업데이트**: 원형 타이머, ScheduleDetailScreen, Settings 상세 문서화 (304줄 추가, 전체 진행률 65% 반영)
- 🆕 [검증 리포트](docs/archive/final_verification_report.md) - IMPLEMENTATION_PHASES.md v2.0 검증 분석 (327줄)
- [API 통합 세션](claudedocs/SESSION_2025_01_07_API_Integration.md) - POI Search, Location, Real Route 통합
- [TMAP API 마이그레이션 문서](docs/TMAP_API_MIGRATION.md) - Naver → TMAP API 전환 + POI Search
- [테스트 결과 리포트](docs/archive/test_results_archive_2025_01_07/TEST_RESULTS_2025_01_07.md) - 328개 테스트 100% 통과

### 아카이브
- [문서 아카이브](docs/archive/) - 이전 버전 문서
- [테스트 결과 아카이브](archive/test_results_archive_2025_01_07/) - 이전 테스트 결과

## 🤝 기여

현재 MVP 개발 중이므로 외부 기여는 받지 않습니다.

## 📝 라이선스

MIT License

## 📧 문의

프로젝트 관련 문의: [이슈 생성](https://github.com/crazybass81/GoNow-theTimeSaver/issues)

---

**Made with 🤖 [Claude Code](https://claude.com/claude-code)**
