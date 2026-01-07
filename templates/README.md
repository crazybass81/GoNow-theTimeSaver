# Templates / 템플릿 코드

**용도**: Flutter 프로젝트에서 사용할 네이티브 코드 템플릿 보관소

---

## 📂 디렉토리 구조 / Directory Structure

```
templates/
└── phase3/                    # Phase 3: Widgets & Notifications
    ├── android/               # Android 네이티브 코드
    │   ├── kotlin/            # Kotlin 소스 파일
    │   │   ├── MainActivity.kt
    │   │   ├── GoNowWidget.kt
    │   │   └── WidgetUpdateWorker.kt
    │   ├── res/               # Android 리소스
    │   │   ├── xml/gonow_widget_info.xml
    │   │   ├── layout/widget_initial_layout.xml
    │   │   ├── drawable/widget_background.xml
    │   │   └── values/strings_ADDITIONS.xml
    │   ├── AndroidManifest_ADDITIONS.xml
    │   ├── build_gradle_ADDITIONS.gradle
    │   └── README.md          # Android 설치 가이드
    │
    └── ios/                   # iOS 네이티브 코드
        ├── swift/             # Swift 소스 파일
        │   ├── AppDelegate.swift
        │   └── GoNowWidget.swift
        ├── Info_plist_ADDITIONS.xml
        └── README.md          # iOS 설치 가이드
```

---

## 🚀 사용 방법 / How to Use

### 사전 준비
1. **flutter create 실행** (필수)
   ```bash
   cd /Users/t/021_DEV/GoNow-theTimeSaver
   flutter create --org com.gonow .
   ```

   이 명령으로 `android/`와 `ios/` 폴더가 생성됩니다.

2. **백업 권장**
   ```bash
   # main.dart 백업 (이미 완료: lib/main.dart.backup)
   cp lib/main.dart lib/main.dart.backup
   ```

---

### Android 코드 적용

**상세 가이드**: [templates/phase3/android/README.md](./phase3/android/README.md)

**빠른 설치**:
```bash
# 1. Kotlin 파일 복사
cp templates/phase3/android/kotlin/*.kt \
   android/app/src/main/kotlin/com/gonow/gotimesaver/

# 2. XML 리소스 복사
mkdir -p android/app/src/main/res/xml
cp templates/phase3/android/res/xml/*.xml \
   android/app/src/main/res/xml/

mkdir -p android/app/src/main/res/layout
cp templates/phase3/android/res/layout/*.xml \
   android/app/src/main/res/layout/

mkdir -p android/app/src/main/res/drawable
cp templates/phase3/android/res/drawable/*.xml \
   android/app/src/main/res/drawable/

# 3. AndroidManifest.xml과 build.gradle 수정
# (templates/phase3/android/README.md 참고)
```

**예상 소요 시간**: 10-15분

---

### iOS 코드 적용

**상세 가이드**: [templates/phase3/ios/README.md](./phase3/ios/README.md)

**빠른 설치**:
```bash
# 1. AppDelegate.swift 교체
cp ios/Runner/AppDelegate.swift ios/Runner/AppDelegate.swift.backup
cp templates/phase3/ios/swift/AppDelegate.swift ios/Runner/

# 2. Xcode에서 Widget Extension 추가 (수동 작업)
open ios/Runner.xcworkspace

# 3. GoNowWidget.swift 복사 후 Xcode 프로젝트에 추가
# (templates/phase3/ios/README.md 참고)
```

**예상 소요 시간**: 15-20분 (수동 작업 포함)

---

## 📚 문서 참고 / Documentation

모든 문서는 `claudedocs/phase3/` 디렉토리에 있습니다:

- [claudedocs/phase3/README.md](../claudedocs/phase3/README.md) - Phase 3 개요
- [claudedocs/phase3/SUMMARY.md](../claudedocs/phase3/SUMMARY.md) - 작업 요약
- [claudedocs/phase3/IMPLEMENTATION_GUIDE.md](../claudedocs/phase3/IMPLEMENTATION_GUIDE.md) - 구현 가이드
- [claudedocs/phase3/INTEGRATION_TEST_GUIDE.md](../claudedocs/phase3/INTEGRATION_TEST_GUIDE.md) - 테스트 가이드

---

## ⚠️ 중요 참고 사항 / Important Notes

### 1. flutter create 필수
- 템플릿 코드를 적용하기 **전에** 반드시 `flutter create`를 실행하세요
- 이 명령이 `android/`와 `ios/` 폴더를 생성합니다

### 2. 패키지 경로
- Android 패키지: `com.gonow.gotimesaver`
- iOS Bundle ID: `com.gonow.gotimesaver`
- App Group: `group.com.gonow.gotimesaver`

### 3. 백업 권장
- `lib/main.dart` - Flutter 기본 코드
- `ios/Runner/AppDelegate.swift` - iOS 기본 코드

### 4. 수동 작업 필요
- iOS Widget Extension 추가 (Xcode)
- iOS App Groups 설정 (Xcode)

---

## 🔄 업데이트 이력 / Update History

| 날짜 | 버전 | 변경 사항 |
|------|------|-----------|
| 2026-01-07 | 1.0 | Phase 3 템플릿 초기 생성 |

---

**작성일**: 2026-01-07
**위치**: `/Users/t/021_DEV/GoNow-theTimeSaver/templates/`
