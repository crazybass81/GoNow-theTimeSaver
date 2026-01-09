# GoNow: The Time Saver - 프로젝트 문서

> ADHD 사용자를 위한 역산 스케줄링 기반 시간 관리 앱

**최종 업데이트**: 2026-01-09
**문서 버전**: 3.6
**프로젝트 상태**: MVP v1.0 (Phase 4 완료, Phase 5 준비 중)

---

## 📚 문서 네비게이션 / Documentation Navigation

### 🎯 시작하기 / Getting Started
| 문서 | 설명 | 대상 |
|------|------|------|
| [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) | **전체 MVP 명세서** (v3.4) | 전체 팀 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 시스템 아키텍처 및 기술 스택 | 개발자 |
| [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) | 개발 환경 설정 및 시작 가이드 | 신규 개발자 |

### 📋 구현 가이드 / Implementation Guides
| 문서 | 설명 | 상태 |
|------|------|------|
| [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) | Phase 1~5 구현 상세 | Phase 4 완료 (100%) |
| [TESTING_GUIDE.md](./TESTING_GUIDE.md) | 전체 테스트 전략 및 체크리스트 | ✅ 완료 |
| [PHASE_4_INTEGRATION_TEST_PLAN.md](./PHASE_4_INTEGRATION_TEST_PLAN.md) | Phase 4 통합 테스트 계획 | ✅ 완료 |

### 🔄 최신 업데이트 (2026-01-09)
| 문서 | 설명 | 중요도 |
|------|------|--------|
| [../claudedocs/GITHUB_VS_LOCAL_UI_COMPARISON.md](../claudedocs/GITHUB_VS_LOCAL_UI_COMPARISON.md) | GitHub 저장소 vs 로컬 프로젝트 UI 비교 분석 | ⭐ 필독 |
| [TMAP_API_MIGRATION.md](./TMAP_API_MIGRATION.md) | Naver → TMAP API 마이그레이션 | ⚠️ 중요 |

### 🎯 최근 완료 작업 (2026-01-08~09)
- ✅ **Loading Screen & Calendar 기능**: Task 4.10 & 4.11 완료 (2026-01-09 Evening)
  - **Task 4.10: Loading Screen 생성**:
    - Provider 기반 인증 상태 확인 및 TripProvider 데이터 프리로드
    - 에러 처리 및 재시도 UI, Graceful degradation 지원
    - lib/screens/splash/loading_screen.dart (244 lines, 신규)
  - **Task 4.11: Calendar 일정 추가 기능**:
    - 빈 날짜 클릭 시 ScheduleEditScreen 자동 이동
    - 선택 날짜를 initialDate로 전달, 기본 도착 시간(오전 9시) 자동 설정
    - lib/screens/calendar/calendar_screen.dart (updated)
    - lib/screens/schedule/schedule_edit_screen.dart (updated)
  - **Code Quality**: flutter analyze 크리티컬 에러 모두 해결
- ✅ **Settings Screen Modal Update**: Task 4.9 완료 (2026-01-09 Afternoon)
  - **UI 패턴 일관성 개선**:
    - 앱 설정 섹션을 ListTile → Modal 패턴으로 변경
    - 다른 설정 섹션과 100% 일관성 달성
  - **Transport Mode Modal**:
    - TMAP API 지원 수단만 포함 (대중교통, 자가용, 도보)
    - RadioListTile 선택 방식, 아이콘 + 한글 레이블
  - **Buffer Time Modal**:
    - 4개 버퍼 시간 설정 통합 (외출 준비, 도착 버퍼, 오차율, 마무리)
    - 저장/취소 기능, 스크롤 가능한 전체 화면 모달
  - **코드 정리**: 230 lines 제거, 215 lines 추가 (더 간결)
  - **빌드 성공**: 132.7초, 56.5MB APK
- ✅ **Legal Screens & Splash Screen**: Task 4.8 완료 (2026-01-08)
  - **Legal Screens 구현 (필수)**:
    - TermsScreen: 이용약관 (178 lines, 8개 조항)
    - PrivacyPolicyScreen: 개인정보 처리방침 (242 lines, 9개 섹션)
    - 앱스토어 심사 필수 요구사항 충족 (개인정보보호법 준수)
  - **Splash Screen 구현 (선택)**:
    - 브랜딩 경험 제공 (FadeTransition 1.5s, 2.5s 후 전환)
    - UIConstants 적용 (radiusDialog, spacingSectionGap)
    - main.dart 업데이트 (splash home, /auth route)
  - **Loading Screen 확인**: AuthGate Provider 기반 (이미 구현됨)
  - **코드 품질**: 0 errors, 0 warnings, deprecated 수정 완료
- ✅ **GitHub 저장소 UI 비교 분석 완료**: [상세 보고서](../claudedocs/GITHUB_VS_LOCAL_UI_COMPARISON.md)
  - **아키텍처 비교**: GitHub(Flat 13개) vs Local(Feature-based 9개 + 5 widgets)
  - **UI 패턴 일치율**: ~95% 달성 (Border 100%, Spacing 95%, Shadow 100%)
  - **구조적 우수성**: Feature-based 구조로 확장성·유지보수성 우수
  - **상태 관리 개선**: SharedPreferences → Provider + Supabase
  - **문서화 품질**: Bilingual JSDoc (한글/English) 적용
- ✅ **GitHub UI 패턴 ~95% 일치율 달성**: 20개 이슈 수정 완료 (14개 기본 + 6개 Priority/Medium)
  - **Phase 3 (14개 기본)**:
    - Border Radius 통일: 16px → 12px (Cards), 24px (Dialogs)
    - Spacing 표준화: 모든 카드 간격 12px 통일
    - Color Picker 크기 조정: 60x60px → 50x50px
  - **Phase 4 (6개 추가)**:
    - Priority 2-1: Settings 아이콘 배경 (48x48 blue[50], 9개)
    - Medium 2: Shadow 패턴 통일 (opacity 0.05, blur 10, 3곳)
    - Medium 3: Spacing 중앙화 (14개 값 → GitHubUI 상수)
  - **일치율 상세**:
    - Border Radius: 100%, Spacing: 95%, Shadow: 100%, Components: 90%
  - **미달성 5%**: Flutter 플랫폼 한계 (네이티브 상호작용 재현 불가)
  - **GitHub 대비 강점**: Feature-based 구조, 재사용 위젯, Provider 상태 관리
- ✅ **대시보드 Collapsible 컴포넌트 구현**: GitHub 스타일 접었다 펼치는 UI
  - AnimatedContainer + AnimatedRotation + AnimatedSize 조합
  - 300ms 부드러운 애니메이션 (Curves.easeInOut)
  - 동적 shadow 효과 (collapsed: 0.04 → expanded: 0.08 opacity)
  - InkWell 리플 효과, 12px borderRadius 준수
- ✅ **문서 최신화 완료**: claudedocs 4개 + docs 6개 문서 검증 및 업데이트
  - claudedocs: UI_MATCH_ANALYSIS (~95%), GITHUB_UI_GAP_ANALYSIS (Phase 4), DESIGN_TOKENS (새 토큰)
  - claudedocs: **GITHUB_VS_LOCAL_UI_COMPARISON.md (신규)** - 10개 섹션, 전체 UI 아키텍처 비교
  - docs: IMPLEMENTATION_PHASES (v2.3, Task 4.8), GO_NOW_COMPLETE_MVP_SPEC, README (v3.3)

### 🎯 이전 완료 작업 (2026-01-07)
- ✅ **Phase 3 Android 위젯 구현 완료**: Jetpack Glance 기반 홈 화면 위젯
  - Flutter ↔ Android MethodChannel 완전 통합
  - TripProvider → WidgetService 호출 통합 (loadTrips, addTrip, completeTrip, cancelTrip)
  - Kotlin: GoNowWidget, GoNowWidgetReceiver, WidgetUpdateWorker, MainActivity
  - WorkManager 적응형 폴링 (15분/5분/3분)
  - 실제 기기 테스트 완료 (SM A136S)
- ✅ **문서 최신화 완료 (v2.0)**: 모든 문서 TMAP API 전면 전환 반영
  - ARCHITECTURE.md v2.0: TMAP Public Transit API 전환 완료 표시
  - DEVELOPMENT_GUIDE.md v2.0:
    - 의존성 목록 최신화 (pubspec.yaml 100% 동기화)
    - TMAP API 단일화 (Routes, POI Search, Public Transit)
    - Naver API 완전 제거 (환경 변수, 체크리스트)
    - 체크리스트 7단계 세분화 (API 권한 확인 추가)
- ✅ **DB-UI 정합성 수정 완료**: 색상/이모지 저장 기능 구현
  - Supabase migration: color, emoji 컬럼 추가
  - Trip 모델 업데이트 및 동적 UI 표시
  - 전체 테스트 통과 (Trip: 29/29, Dashboard: 16/16)
- ✅ **E2E 테스트 완료**: 전체 328개 테스트 100% 통과

### 🔧 템플릿 및 코드 / Templates & Code
| 위치 | 설명 | 사용 시점 |
|------|------|----------|
| [../templates/](../templates/) | 네이티브 코드 템플릿 | flutter create 후 |
| [../templates/phase3/](../templates/phase3/) | Phase 3 Android/iOS 코드 | Phase 3 구현 시 |

### 📦 아카이브 / Archive
| 위치 | 설명 |
|------|------|
| [archive/DB_UI_ALIGNMENT_REPORT_COMPLETED_2025_01_07.md](./archive/DB_UI_ALIGNMENT_REPORT_COMPLETED_2025_01_07.md) | DB-UI 정합성 분석 보고서 (완료) |
| [archive/test_results_archive_2025_01_07/](./archive/test_results_archive_2025_01_07/) | 2025-01-07 테스트 결과 아카이브 |
| [archive/UI_IMPROVEMENT_PLAN_PHASE1_2_COMPLETED_2025_01_07.md](./archive/UI_IMPROVEMENT_PLAN_PHASE1_2_COMPLETED_2025_01_07.md) | UI 개선 계획 Phase 1&2 (완료) |
| [archive/sessions/](./archive/sessions/) | 세션별 작업 기록 |
| [archive/old_docs/](./archive/old_docs/) | 구버전 문서 |
| [archive/phase3_original/](./archive/phase3_original/) | Phase 3 원본 문서 |
| [archive/](./archive/) | 과거 계획 문서 |

---

## 🚀 빠른 시작 / Quick Start

### 1. 프로젝트 이해하기
```bash
# 1️⃣ 메인 스펙 읽기 (필수)
cat GO_NOW_COMPLETE_MVP_SPEC.md

# 2️⃣ 아키텍처 이해
cat ARCHITECTURE.md
```

### 2. 개발 환경 설정
```bash
# 개발 가이드 참고
cat DEVELOPMENT_GUIDE.md

# Flutter 프로젝트 생성
flutter create --org com.gonow .

# 의존성 설치
flutter pub get

# Supabase 로컬 환경 시작
supabase start
```

### 3. 현재 Phase 작업
```bash
# Phase 3 상세 가이드
cat IMPLEMENTATION_PHASES.md

# 템플릿 코드 적용
cd ../templates/phase3
cat README.md
```

---

## 📊 프로젝트 현황 / Project Status

### 개발 진행률 (2026-01-09 기준)

| Phase | 상태 | 진행률 | 완료일 |
|-------|------|--------|--------|
| **Phase 1**: Foundation & UI | ✅ 완료 | 100% | 2026-01-06 |
| **Phase 2**: Core Logic & API | ✅ 완료 | 100% | 2026-01-07 |
| **Phase 3**: Widgets & Notifications | ⏳ 80% 완료 | 80% | - |
| **Phase 4**: Integration & QA | 🚧 진행 중 | ~95% | - |
| **Phase 5**: Launch | ⏳ 대기 | 0% | - |

**전체 MVP 진행률**: ~92%

**Phase 4 주요 완료 사항** (2026-01-09):
- ✅ 전체 테스트: 328개 100% 통과
- ✅ TMAP API 통합 완료
- ✅ GitHub UI 패턴 ~95% 일치
- ⏳ 성능 최적화 대기
- ⏳ Alpha 테스트 대기

### Phase 3 세부 진행률

| 항목 | 상태 | 비고 |
|------|------|------|
| Flutter 레이어 | ✅ 완료 | WidgetService, NotificationService |
| Android 네이티브 | ✅ 코드 완료 | 템플릿 준비, 적용 대기 |
| iOS 네이티브 | ✅ 코드 완료 | 템플릿 준비, 적용 대기 |
| flutter create | ⏳ 대기 | 사용자 수동 실행 필요 |
| 통합 테스트 | ⏳ 대기 | 네이티브 코드 적용 후 |

---

## 🏗️ 프로젝트 구조 / Project Structure

### 코드베이스
```
GoNow-theTimeSaver/
├── lib/                          # Flutter 앱 코드
│   ├── main.dart                 # 앱 진입점
│   ├── screens/                  # 화면 위젯 (7개)
│   ├── services/                 # 비즈니스 로직
│   ├── models/                   # 데이터 모델
│   ├── providers/                # 상태 관리 (Provider)
│   └── widgets/                  # 재사용 위젯
│
├── supabase/                     # Supabase 설정
│   └── migrations/               # DB 마이그레이션
│
├── android/                      # Android 네이티브 (flutter create 후 생성)
├── ios/                          # iOS 네이티브 (flutter create 후 생성)
│
├── templates/                    # 네이티브 코드 템플릿
│   └── phase3/
│       ├── android/              # Android 템플릿
│       └── ios/                  # iOS 템플릿
│
└── docs/                   # 프로젝트 문서
    ├── README.md                 # 이 파일
    ├── GO_NOW_COMPLETE_MVP_SPEC.md
    ├── ARCHITECTURE.md
    ├── DEVELOPMENT_GUIDE.md
    ├── IMPLEMENTATION_PHASES.md
    ├── TESTING_GUIDE.md
    └── archive/                  # 아카이브
```

### 문서 구조
```
docs/
├── README.md                     # 📍 시작점 (이 파일)
├── GO_NOW_COMPLETE_MVP_SPEC.md   # 📘 전체 MVP 명세 (v3.4)
├── ARCHITECTURE.md               # 🏗️ 시스템 아키텍처
├── DEVELOPMENT_GUIDE.md          # 🔧 개발 환경 설정
├── IMPLEMENTATION_PHASES.md      # 📋 Phase별 구현 가이드
├── TESTING_GUIDE.md              # 🧪 테스트 전략
│
└── archive/                      # 📦 아카이브
    ├── sessions/                 # 세션별 작업 기록
    ├── old_docs/                 # 구버전 문서
    ├── phase3_original/          # Phase 3 원본 문서
    └── [과거 계획 문서들]
```

---

## 🎯 핵심 기능 / Core Features

### 1. 역산 스케줄링 (Backward Planning)
- 도착 시간에서 역으로 계산하여 출발 시간 자동 산출
- 4가지 독립 버퍼 시간 설정

### 2. 실시간 교통 정보
- TMAP Routes API: 자동차 경로 (실시간 교통 반영)
- TMAP Public Transit API: 대중교통 경로 (버스/지하철)

### 3. 스마트 알림
- 시간대별 색상 시스템 (초록→주황→빨강)
- 적응형 알림 (15분/5분/3분 전)
- 30분/10분 전 로컬 푸시 알림

### 4. 홈 위젯
- Android: Jetpack Glance
- iOS: WidgetKit
- 15분 주기 자동 업데이트

---

## 🛠️ 기술 스택 / Tech Stack

### Frontend
- **Framework**: Flutter 3.x (Dart)
- **State Management**: Provider
- **UI**: Material Design 3

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Security**: Row Level Security (RLS)

### External APIs
- **TMAP Routes API**: 자동차 경로 탐색
- **TMAP Public Transit API**: 대중교통 경로
- **TMAP POI Search API**: 장소 검색

### Native
- **Android**: Kotlin, Jetpack Glance, WorkManager
- **iOS**: Swift, WidgetKit, Timeline Provider

---

## 📖 문서 사용 가이드 / Documentation Guide

### 신규 개발자 (New Developers)
1. 📘 [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 프로젝트 전체 이해
2. 🏗️ [ARCHITECTURE.md](./ARCHITECTURE.md) - 기술 아키텍처 파악
3. 🔧 [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 환경 설정
4. 📋 [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - 현재 Phase 작업

### 프론트엔드 개발자 (Frontend Developers)
1. 🏗️ [ARCHITECTURE.md](./ARCHITECTURE.md) - Flutter 구조 이해
2. 📋 [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - UI 구현 상세
3. 🧪 [TESTING_GUIDE.md](./TESTING_GUIDE.md) - UI 테스트 전략

### 백엔드/네이티브 개발자 (Backend/Native Developers)
1. 🏗️ [ARCHITECTURE.md](./ARCHITECTURE.md) - API 및 네이티브 구조
2. 📋 [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - 네이티브 구현
3. 📦 [../templates/phase3/](../templates/phase3/) - 네이티브 코드 템플릿

### QA/테스터 (QA/Testers)
1. 📘 [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 요구사항 이해
2. 🧪 [TESTING_GUIDE.md](./TESTING_GUIDE.md) - 테스트 케이스 및 체크리스트

### 프로젝트 매니저 (Project Managers)
1. 📘 [GO_NOW_COMPLETE_MVP_SPEC.md](./GO_NOW_COMPLETE_MVP_SPEC.md) - 전체 로드맵
2. 📊 이 파일 (README.md) - 진행 현황 대시보드

---

## 🔗 관련 링크 / Related Links

### 외부 문서
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Supabase 문서](https://supabase.com/docs)
- [TMAP API](https://openapi.sk.com/)
- [Jetpack Glance 가이드](https://developer.android.com/jetpack/compose/glance)
- [WidgetKit 가이드](https://developer.apple.com/documentation/widgetkit)

### 프로젝트 저장소
- **GitHub**: `crazybass81/GoNow-theTimeSaver`
- **Supabase 프로젝트**: 로컬 개발 환경

---

## 📝 문서 업데이트 정책 / Documentation Update Policy

### 문서 버전 관리
- **Major Update** (예: 1.0 → 2.0): 문서 구조 대폭 변경
- **Minor Update** (예: 2.0 → 2.1): 내용 추가 또는 수정
- **Patch Update** (예: 2.1.0 → 2.1.1): 오타 수정, 링크 업데이트

### 문서 업데이트 시점
- Phase 완료 시: 해당 Phase 문서 업데이트
- 주요 기능 추가 시: ARCHITECTURE.md 업데이트
- 버그 수정 및 개선 시: 관련 가이드 업데이트

### 아카이브 정책
- 구버전 문서는 `archive/old_docs/`로 이동
- 날짜별 작업 기록은 `archive/sessions/`로 이동
- Phase별 원본 문서는 `archive/phase{N}_original/`로 이동

---

## ❓ FAQ / 자주 묻는 질문

### Q1: 어떤 문서부터 읽어야 하나요?
**A**: 역할에 따라 다릅니다:
- **처음 오신 분**: GO_NOW_COMPLETE_MVP_SPEC.md → ARCHITECTURE.md
- **개발 시작**: DEVELOPMENT_GUIDE.md → IMPLEMENTATION_PHASES.md
- **테스트**: TESTING_GUIDE.md

### Q2: Phase 3 작업을 시작하려면?
**A**:
1. `IMPLEMENTATION_PHASES.md`의 Phase 3 섹션 읽기
2. `flutter create --org com.gonow .` 실행
3. `templates/phase3/README.md` 참고하여 템플릿 적용

### Q3: 문서가 최신인지 확인하는 방법은?
**A**: 각 문서 상단의 "최종 업데이트" 날짜 확인. 의심스러우면 README.md의 프로젝트 현황 참조.

### Q4: 아카이브된 문서는 언제 참고하나요?
**A**:
- 과거 의사결정 배경 이해 시
- 문제 해결을 위한 히스토리 추적 시
- 일반적으로는 현재 문서만 참고하면 충분

---

## 📧 문의 / Contact

### 프로젝트 관련 질문
- GitHub Issues: [이슈 생성](https://github.com/crazybass81/GoNow-theTimeSaver/issues)

### 문서 관련 피드백
- 문서 개선 제안: GitHub Issues에 `documentation` 라벨로 등록

---

## 📜 라이선스 / License

MIT License

---

**Made with 🤖 [Claude Code](https://claude.com/claude-code)**

**Documentation Version**: 2.0
**Last Updated**: 2026-01-07
**Next Review**: Phase 3 완료 시
