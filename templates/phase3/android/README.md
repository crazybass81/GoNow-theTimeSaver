# Android 네이티브 코드 설치 가이드 / Android Native Code Setup Guide

**작성일**: 2026-01-07
**대상**: Phase 3 - Android 위젯 구현

---

## 📋 사전 준비 / Prerequisites

### 1단계: flutter create 실행
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create --org com.gonow .
```

**주의사항**:
- ✅ 기존 `lib/` 폴더는 유지됩니다
- ⚠️ `lib/main.dart`는 백업 권장 (이미 백업됨: `lib/main.dart.backup`)
- ✅ `android/` 와 `ios/` 폴더가 자동 생성됩니다

---

## 📂 파일 복사 순서 / File Copy Order

### 1. Kotlin 소스 파일 복사

```bash
# MainActivity.kt
cp claudedocs/android_native_code/MainActivity.kt \
   android/app/src/main/kotlin/com/gonow/gotimesaver/

# GoNowWidget.kt
cp claudedocs/android_native_code/GoNowWidget.kt \
   android/app/src/main/kotlin/com/gonow/gotimesaver/

# WidgetUpdateWorker.kt
cp claudedocs/android_native_code/WidgetUpdateWorker.kt \
   android/app/src/main/kotlin/com/gonow/gotimesaver/
```

**참고**: `com/gonow/gotimesaver` 패키지 경로가 없으면 자동으로 생성됩니다.

---

### 2. XML 리소스 파일 복사

#### 2.1. Widget 메타데이터
```bash
# gonow_widget_info.xml
mkdir -p android/app/src/main/res/xml
cp claudedocs/android_native_code/gonow_widget_info.xml \
   android/app/src/main/res/xml/
```

#### 2.2. 레이아웃 파일
```bash
# widget_initial_layout.xml
mkdir -p android/app/src/main/res/layout
cp claudedocs/android_native_code/widget_initial_layout.xml \
   android/app/src/main/res/layout/
```

#### 2.3. Drawable 리소스
```bash
# widget_background.xml
mkdir -p android/app/src/main/res/drawable
cp claudedocs/android_native_code/widget_background.xml \
   android/app/src/main/res/drawable/
```

#### 2.4. 문자열 리소스
```bash
# strings.xml에 추가
# android/app/src/main/res/values/strings.xml 파일을 열고
# claudedocs/android_native_code/strings_ADDITIONS.xml 내용을 복사하여
# <resources> 태그 안에 추가합니다
```

---

### 3. 설정 파일 수정

#### 3.1. AndroidManifest.xml 수정

**파일**: `android/app/src/main/AndroidManifest.xml`

**작업**:
1. `claudedocs/android_native_code/AndroidManifest_ADDITIONS.xml` 파일을 엽니다
2. `<application>` 태그 안에 Widget Receiver와 WorkManager 설정을 복사합니다
3. `<manifest>` 태그 안에 필요한 권한을 추가합니다

**추가할 내용**:
```xml
<!-- <application> 태그 안에 추가 -->
<receiver
    android:name=".GoNowWidgetReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/gonow_widget_info" />
</receiver>

<!-- <manifest> 태그 안에 추가 (권한) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

---

#### 3.2. build.gradle 수정

**파일**: `android/app/build.gradle`

**작업**:
1. `claudedocs/android_native_code/build_gradle_ADDITIONS.gradle` 파일을 엽니다
2. 다음 내용을 확인하고 추가합니다:

**최소 SDK 버전 확인** (android → defaultConfig):
```gradle
android {
    defaultConfig {
        minSdkVersion 23  // 최소 23 필요
    }
}
```

**buildFeatures 추가** (android 블록 안):
```gradle
android {
    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = '1.5.4'
    }
}
```

**dependencies 추가**:
```gradle
dependencies {
    // Jetpack Glance for Widgets
    implementation 'androidx.glance:glance-appwidget:1.0.0'
    implementation 'androidx.glance:glance:1.0.0'

    // WorkManager for Background Tasks
    implementation 'androidx.work:work-runtime-ktx:2.9.0'

    // Kotlin Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'

    // Compose UI
    implementation 'androidx.compose.ui:ui:1.5.4'
    implementation 'androidx.compose.foundation:foundation:1.5.4'
}
```

---

## 🔧 빌드 및 동기화 / Build and Sync

### 1. Gradle 동기화
```bash
cd android
./gradlew --refresh-dependencies
```

또는 Android Studio에서:
- `File` → `Sync Project with Gradle Files` 클릭

### 2. 클린 빌드
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build apk --debug
```

---

## ✅ 검증 단계 / Verification Steps

### 1. 컴파일 확인
```bash
cd android
./gradlew assembleDebug
```

**예상 결과**: `BUILD SUCCESSFUL`

### 2. 위젯 확인
1. 앱을 디바이스/에뮬레이터에 설치
2. 홈 화면 → 위젯 추가
3. "GoNow 일정" 위젯이 목록에 있는지 확인

### 3. 기능 테스트
1. 앱에서 일정 추가
2. 위젯에 일정이 표시되는지 확인
3. 시간 경과에 따라 색상이 변하는지 확인 (초록 → 주황 → 빨강)

---

## 🐛 문제 해결 / Troubleshooting

### 문제 1: "Unresolved reference: Glance"
**원인**: Glance 의존성 누락
**해결**: `build.gradle`에 Glance 의존성 추가 후 Gradle 동기화

### 문제 2: "Minimum SDK version 23 required"
**원인**: minSdkVersion이 23 미만
**해결**: `build.gradle`에서 `minSdkVersion 23` 이상으로 설정

### 문제 3: 위젯이 목록에 나타나지 않음
**원인**: AndroidManifest.xml 설정 누락
**해결**:
- `<receiver>` 태그가 올바르게 추가되었는지 확인
- `gonow_widget_info.xml` 파일 경로 확인 (`res/xml/`)

### 문제 4: "Compose compiler version mismatch"
**원인**: Compose 컴파일러 버전 불일치
**해결**: `build.gradle`의 `kotlinCompilerExtensionVersion` 확인

### 문제 5: WorkManager 초기화 실패
**원인**: WorkManager provider 설정 누락
**해결**: `AndroidManifest.xml`에 WorkManager provider 추가

---

## 📊 파일 구조 최종 확인 / Final File Structure

```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── kotlin/
│   │       │   └── com/
│   │       │       └── gonow/
│   │       │           └── gotimesaver/
│   │       │               ├── MainActivity.kt ✅
│   │       │               ├── GoNowWidget.kt ✅
│   │       │               └── WidgetUpdateWorker.kt ✅
│   │       └── res/
│   │           ├── xml/
│   │           │   └── gonow_widget_info.xml ✅
│   │           ├── layout/
│   │           │   └── widget_initial_layout.xml ✅
│   │           ├── drawable/
│   │           │   └── widget_background.xml ✅
│   │           └── values/
│   │               └── strings.xml (수정됨) ✅
│   ├── build.gradle (수정됨) ✅
│   └── AndroidManifest.xml (수정됨) ✅
```

---

## 🎯 다음 단계 / Next Steps

1. ✅ Android 코드 설치 완료
2. ⏳ iOS Swift 코드 작성 (`claudedocs/ios_native_code/`)
3. ⏳ Xcode에서 Widget Extension 추가 (수동 작업)
4. ⏳ 통합 테스트

---

**작성 완료**: 2026-01-07
**다음 작업**: iOS 네이티브 코드 작성
