# Phase 3: Widgets & Notifications

**작성일**: 2026-01-07
**상태**: Flutter 레이어 완료, 네이티브 코드 준비 완료
**다음 단계**: flutter create 실행 → 네이티브 코드 적용

---

## 📋 개요 / Overview

Phase 3에서는 Android/iOS 홈 위젯과 로컬 푸시 알림 시스템을 구현합니다.

### 완료된 작업
- ✅ Flutter 레이어 (WidgetService, NotificationService)
- ✅ Android 네이티브 코드 (Jetpack Glance)
- ✅ iOS 네이티브 코드 (WidgetKit)
- ✅ 통합 테스트 가이드

### 대기 중인 작업
- ⏳ flutter create 실행 (사용자 수동)
- ⏳ Android 네이티브 코드 적용
- ⏳ iOS 네이티브 코드 적용 (Xcode 작업 포함)
- ⏳ 통합 테스트 수행

---

## 📂 디렉토리 구조 / Directory Structure

```
phase3/
├── README.md                         # 이 파일
├── SUMMARY.md                        # Phase 3 작업 요약
├── IMPLEMENTATION_GUIDE.md           # 전체 구현 가이드
├── INTEGRATION_TEST_GUIDE.md        # 통합 테스트 가이드
│
├── android/                          # Android 네이티브 코드
│   ├── README.md                     # Android 설치 가이드
│   ├── AndroidManifest_ADDITIONS.xml # Manifest 추가 내용
│   ├── build_gradle_ADDITIONS.gradle # Gradle 추가 내용
│   ├── kotlin/                       # Kotlin 소스 코드
│   │   ├── MainActivity.kt           # MethodChannel 구현
│   │   ├── GoNowWidget.kt            # Jetpack Glance 위젯
│   │   └── WidgetUpdateWorker.kt     # WorkManager 백그라운드 작업
│   └── res/                          # Android 리소스
│       ├── xml/                      # 위젯 메타데이터
│       │   └── gonow_widget_info.xml
│       ├── layout/                   # 레이아웃
│       │   └── widget_initial_layout.xml
│       ├── drawable/                 # 드로어블
│       │   └── widget_background.xml
│       └── values/                   # 문자열 리소스
│           └── strings_ADDITIONS.xml
│
└── ios/                              # iOS 네이티브 코드
    ├── README.md                     # iOS 설치 가이드
    ├── Info_plist_ADDITIONS.xml      # Info.plist 추가 내용
    └── swift/                        # Swift 소스 코드
        ├── AppDelegate.swift         # MethodChannel 구현
        └── GoNowWidget.swift         # WidgetKit 구현
```

---

## 🚀 빠른 시작 / Quick Start

### 1단계: 사전 준비
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create --org com.gonow .
```

**주의**: `lib/main.dart`는 백업되어 있음 (`lib/main.dart.backup`)

---

### 2단계: Android 설치
```bash
# Android 설치 가이드 참고
cd claudedocs/phase3/android
cat README.md
```

**요약**:
1. Kotlin 파일 복사 (`kotlin/` → `android/app/src/main/kotlin/com/gonow/gotimesaver/`)
2. XML 리소스 복사 (`res/` → `android/app/src/main/res/`)
3. AndroidManifest.xml 수정
4. build.gradle 수정
5. Gradle 동기화 및 빌드

**예상 소요 시간**: 10-15분

---

### 3단계: iOS 설치
```bash
# iOS 설치 가이드 참고
cd claudedocs/phase3/ios
cat README.md
```

**요약**:
1. AppDelegate.swift 교체
2. Xcode에서 Widget Extension 추가 (수동)
3. App Groups 설정 (수동)
4. Info.plist 수정
5. 빌드 및 테스트

**예상 소요 시간**: 15-20분 (수동 작업 포함)

---

### 4단계: 통합 테스트
```bash
# 통합 테스트 가이드 참고
cat INTEGRATION_TEST_GUIDE.md
```

**테스트 항목**:
- 위젯 표시 및 업데이트
- 시간대별 색상 변경
- 알림 스케줄링 및 수신
- 배터리 소모 테스트
- 엣지 케이스 테스트

**예상 소요 시간**: 2-3시간

---

## 📚 상세 문서 / Detailed Documentation

### 구현 가이드
- [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
  - Phase 3 전체 구현 과정
  - 기술 스택 및 아키텍처
  - Android/iOS 구현 상세
  - 문제 해결 가이드

### 작업 요약
- [SUMMARY.md](./SUMMARY.md)
  - 완료된 작업 목록
  - 생성된 파일 목록
  - 선행 작업 필요 사항
  - 다음 단계

### Android 가이드
- [android/README.md](./android/README.md)
  - Android 설치 단계별 가이드
  - 파일 복사 방법
  - Gradle 설정
  - 문제 해결

### iOS 가이드
- [ios/README.md](./ios/README.md)
  - iOS 설치 단계별 가이드
  - Xcode Widget Extension 추가
  - App Groups 설정
  - 문제 해결

### 통합 테스트
- [INTEGRATION_TEST_GUIDE.md](./INTEGRATION_TEST_GUIDE.md)
  - 기능 테스트 시나리오
  - 성능 테스트
  - 엣지 케이스 테스트
  - 테스트 리포트 템플릿

---

## 🔑 핵심 기능 / Key Features

### 1. 홈 위젯 / Home Widget
- **Android**: Jetpack Glance
- **iOS**: WidgetKit
- **크기**: Small (4x2), Medium (4x4)
- **업데이트 주기**: 15/5/3분 (시간대별 적응형)

### 2. 시간대별 색상 시스템 / Time-based Color System
- 🟢 **초록색** (30분 이상): 여유있음
- 🟠 **주황색** (15-30분): 준비 필요
- 🔴 **빨간색** (0-15분): 긴급 출발
- 🔴 **진한 빨간색** (지각): 지각 위험

### 3. 로컬 푸시 알림 / Local Push Notifications
- **30분 전 알림**: 일반 알림 (준비 시작)
- **10분 전 알림**: 긴급 알림 (즉시 출발)
- **동적 알림**: 교통 상황 변화 시

### 4. 백그라운드 업데이트 / Background Update
- **Android**: WorkManager (주기적 업데이트)
- **iOS**: Timeline Provider (스케줄링)
- **배터리 효율**: 최적화된 업데이트 전략

---

## 🏗️ 아키텍처 / Architecture

### Flutter 레이어
```
lib/services/
├── widget_service.dart        # 위젯 업데이트 인터페이스
└── notification_service.dart  # 알림 스케줄링
```

### Android 레이어
```
android/app/src/main/
├── kotlin/com/gonow/gotimesaver/
│   ├── MainActivity.kt        # MethodChannel
│   ├── GoNowWidget.kt         # Glance 위젯
│   └── WidgetUpdateWorker.kt  # WorkManager
└── res/
    └── xml/gonow_widget_info.xml
```

### iOS 레이어
```
ios/
├── Runner/
│   └── AppDelegate.swift      # MethodChannel
└── GoNowWidgetExtension/
    └── GoNowWidget.swift      # WidgetKit
```

---

## 🔄 데이터 흐름 / Data Flow

### 위젯 업데이트 플로우
```
Flutter App (TripProvider)
    ↓
WidgetService.updateWidget()
    ↓
MethodChannel ('com.gonow.widget')
    ↓
Android: MainActivity.updateWidget()
iOS: AppDelegate.updateWidget()
    ↓
SharedPreferences / UserDefaults (App Group)
    ↓
Widget 자동 갱신
```

### 알림 플로우
```
Flutter App (TripProvider)
    ↓
NotificationService.scheduleNotifications()
    ↓
flutter_local_notifications
    ↓
30분 전: 일반 알림
10분 전: 긴급 알림
동적: 상황 변화 알림
```

---

## ⚠️ 중요 참고 사항 / Important Notes

### 선행 작업 필수
1. **flutter create 실행**
   ```bash
   flutter create --org com.gonow .
   ```
   - `android/`와 `ios/` 폴더 생성 필수
   - `lib/main.dart` 백업 권장

2. **패키지 추가** (이미 완료)
   ```yaml
   dependencies:
     flutter_local_notifications: ^16.0.0
     timezone: ^0.9.2
   ```

### Android 필수 설정
- minSdkVersion: 23 이상
- Jetpack Glance 1.0.0
- WorkManager 2.9.0
- Compose UI 1.5.4

### iOS 필수 설정
- iOS Deployment Target: 14.0 이상
- WidgetKit framework
- App Groups 설정 (group.com.gonow.gotimesaver)
- Xcode Widget Extension 추가 (수동)

---

## 📊 진행 현황 / Progress Status

| 항목 | 상태 | 비고 |
|------|------|------|
| Flutter WidgetService | ✅ 완료 | `lib/services/widget_service.dart` |
| Flutter NotificationService | ✅ 완료 | `lib/services/notification_service.dart` |
| Android MainActivity | ✅ 완료 | Kotlin 코드 준비 완료 |
| Android GoNowWidget | ✅ 완료 | Jetpack Glance 구현 |
| Android WorkManager | ✅ 완료 | 백그라운드 업데이트 |
| iOS AppDelegate | ✅ 완료 | Swift 코드 준비 완료 |
| iOS GoNowWidget | ✅ 완료 | WidgetKit 구현 |
| flutter create | ⏳ 대기 | 사용자 수동 실행 필요 |
| Android 코드 적용 | ⏳ 대기 | flutter create 후 진행 |
| iOS 코드 적용 | ⏳ 대기 | Xcode 작업 포함 (~10분) |
| 통합 테스트 | ⏳ 대기 | 네이티브 코드 적용 후 |

---

## 🎯 다음 단계 / Next Steps

### 즉시 실행 가능
1. ✅ Phase 3 문서 모두 준비 완료
2. ✅ 네이티브 코드 모두 작성 완료

### 사용자 작업 필요
1. **터미널에서 flutter create 실행**
   ```bash
   cd /Users/t/021_DEV/GoNow-theTimeSaver
   flutter create --org com.gonow .
   ```

2. **Android 설치 진행** (10-15분)
   - [android/README.md](./android/README.md) 참고
   - 파일 복사 및 설정 수정

3. **iOS 설치 진행** (15-20분)
   - [ios/README.md](./ios/README.md) 참고
   - Xcode 작업 포함

4. **통합 테스트 수행** (2-3시간)
   - [INTEGRATION_TEST_GUIDE.md](./INTEGRATION_TEST_GUIDE.md) 참고

---

## 📞 문제 발생 시 / Troubleshooting

### 일반적인 문제
- [android/README.md - 문제 해결 섹션](./android/README.md#-문제-해결--troubleshooting)
- [ios/README.md - 문제 해결 섹션](./ios/README.md#-문제-해결--troubleshooting)

### 추가 지원
- 메인 스펙: `claudedocs/GO_NOW_COMPLETE_MVP_SPEC.md`
- 구현 가이드: `IMPLEMENTATION_GUIDE.md`
- 세션 요약: `claudedocs/SESSION_SUMMARY_2026-01-07.md`

---

**작성 완료**: 2026-01-07
**버전**: 1.0
**마지막 업데이트**: Phase 3 네이티브 코드 준비 완료
