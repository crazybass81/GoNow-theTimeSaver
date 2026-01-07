# GoNow: The Time Saver - 프로젝트 문서

> ADHD 사용자를 위한 역산 스케줄링 기반 시간 관리 앱

**최종 업데이트**: 2026-01-07
**문서 버전**: 2.0
**프로젝트 버전**: MVP v1.0 (Phase 3 진행 중)

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
| [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) | Phase 1~5 구현 상세 | Phase 3 진행 중 |
| [TESTING_GUIDE.md](./TESTING_GUIDE.md) | 전체 테스트 전략 및 체크리스트 | 작성 완료 |

### 🔧 템플릿 및 코드 / Templates & Code
| 위치 | 설명 | 사용 시점 |
|------|------|----------|
| [../templates/](../templates/) | 네이티브 코드 템플릿 | flutter create 후 |
| [../templates/phase3/](../templates/phase3/) | Phase 3 Android/iOS 코드 | Phase 3 구현 시 |

### 📦 아카이브 / Archive
| 위치 | 설명 |
|------|------|
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

### 개발 진행률 (2026-01-07 기준)

| Phase | 상태 | 진행률 | 완료일 |
|-------|------|--------|--------|
| **Phase 1**: Foundation & UI | ✅ 완료 | 100% | 2026-01-06 |
| **Phase 2**: Core Logic & API | ✅ 완료 | 100% | 2026-01-07 |
| **Phase 3**: Widgets & Notifications | 🚧 진행 중 | 30% | - |
| **Phase 4**: Integration & QA | ⏳ 대기 | 0% | - |
| **Phase 5**: Launch | ⏳ 대기 | 0% | - |

**전체 MVP 진행률**: ~65%

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
└── claudedocs/                   # 프로젝트 문서
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
claudedocs/
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
- Naver Maps API: 자동차 경로 (실시간 교통 반영)
- Naver Transit API: 대중교통 경로 (버스/지하철)

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
- **Naver Maps API**: 자동차 경로 탐색
- **Naver Transit API**: 대중교통 경로

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
- [Naver Maps API](https://www.ncloud.com/product/applicationService/maps)
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
