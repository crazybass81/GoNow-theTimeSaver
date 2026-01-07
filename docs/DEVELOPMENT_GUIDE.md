# GoNow 개발 환경 설정 가이드

**최종 업데이트**: 2025-01-07
**문서 버전**: 2.0
**대상**: 신규 개발자, DevOps

---

## 📋 목차 / Table of Contents

1. [필수 요구사항](#1-필수-요구사항--prerequisites)
2. [개발 환경 설정](#2-개발-환경-설정--development-setup)
3. [프로젝트 설정](#3-프로젝트-설정--project-setup)
4. [Supabase 로컬 환경](#4-supabase-로컬-환경--supabase-local-dev)
5. [빌드 및 실행](#5-빌드-및-실행--build--run)
6. [디버깅](#6-디버깅--debugging)
7. [문제 해결](#7-문제-해결--troubleshooting)

---

## 1. 필수 요구사항 / Prerequisites

### 1.1 시스템 요구사항

| 항목 | 최소 버전 | 권장 버전 | 비고 |
|------|-----------|-----------|------|
| **macOS** | 12.0 (Monterey) | 13.0+ (Ventura) | iOS 개발 시 필수 |
| **RAM** | 8GB | 16GB+ | Flutter 컴파일 시 필요 |
| **저장공간** | 20GB | 50GB+ | Xcode, Android Studio 포함 |
| **인터넷** | - | 안정적 연결 | 패키지 다운로드 시 필요 |

---

### 1.2 필수 소프트웨어

#### Flutter SDK
```bash
# Flutter 설치 확인
flutter --version

# 예상 출력:
# Flutter 3.x.x • channel stable
# Dart 3.x.x
```

**설치 방법** (없는 경우):
```bash
# Homebrew로 설치 (권장)
brew install --cask flutter

# 또는 공식 사이트에서 다운로드
# https://docs.flutter.dev/get-started/install/macos
```

#### Android Studio (Android 개발)
- **버전**: 2023.x (Hedgehog) 이상
- **설치**: https://developer.android.com/studio
- **필수 플러그인**:
  - Flutter Plugin
  - Dart Plugin

#### Xcode (iOS 개발)
- **버전**: 14.0 이상
- **설치**: App Store에서 다운로드
- **추가 설정**:
  ```bash
  # Command Line Tools 설치
  xcode-select --install

  # 라이선스 동의
  sudo xcodebuild -license accept
  ```

#### Supabase CLI
```bash
# Homebrew로 설치
brew install supabase/tap/supabase

# 버전 확인
supabase --version
```

#### Git
```bash
# 설치 확인
git --version

# 없으면 설치
brew install git
```

---

### 1.3 선택 사항

| 도구 | 용도 | 설치 |
|------|------|------|
| **VS Code** | 가벼운 에디터 | https://code.visualstudio.com/ |
| **Docker Desktop** | Supabase 로컬 환경 | https://www.docker.com/products/docker-desktop |
| **Postman** | API 테스트 | https://www.postman.com/ |

---

## 2. 개발 환경 설정 / Development Setup

### 2.1 Flutter 환경 설정

#### Flutter Doctor 실행
```bash
flutter doctor -v
```

**예상 출력**:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.x)
[✓] VS Code (version 1.x.x)
[✓] Connected device (2 available)
[✓] Network resources
```

**문제 해결**:
- ❌가 있으면 해당 항목 옆의 가이드 따라 수정
- `flutter doctor`는 모든 ✓ 확인 후 진행

---

#### Flutter 설정 확인
```bash
# Android license 동의
flutter doctor --android-licenses

# iOS 설정 확인
flutter doctor --verbose | grep -A 10 "Xcode"
```

---

### 2.2 에디터 설정

#### VS Code (권장)

**필수 확장**:
```bash
# VS Code 실행 후 확장 설치
code --install-extension dart-code.flutter
code --install-extension dart-code.dart-code
code --install-extension usernamehw.errorlens
```

**settings.json 설정**:
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.rulers": [80, 120],
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

---

#### Android Studio

**Flutter 플러그인 설치**:
1. `Preferences` → `Plugins`
2. `Marketplace` 탭에서 "Flutter" 검색
3. `Install` 클릭 (Dart 자동 설치)
4. Android Studio 재시작

**Android SDK 설정**:
1. `Preferences` → `Appearance & Behavior` → `System Settings` → `Android SDK`
2. `SDK Platforms` 탭:
   - Android 13 (API 33) ✓
   - Android 12 (API 31) ✓
3. `SDK Tools` 탭:
   - Android SDK Build-Tools ✓
   - Android Emulator ✓
   - Android SDK Platform-Tools ✓

---

### 2.3 디바이스 설정

#### Android 에뮬레이터
```bash
# AVD Manager 열기
android studio → Tools → AVD Manager

# 추천 설정:
# - Device: Pixel 6
# - System Image: Android 13 (API 33)
# - RAM: 2048 MB
# - Internal Storage: 2048 MB
```

#### iOS 시뮬레이터
```bash
# 시뮬레이터 목록 확인
xcrun simctl list devices

# 시뮬레이터 실행 (예: iPhone 14)
open -a Simulator
```

#### 실제 디바이스 (Android)
1. 디바이스에서 **개발자 옵션** 활성화:
   - `설정` → `휴대전화 정보` → `빌드 번호` 7번 탭
2. **USB 디버깅** 활성화:
   - `설정` → `개발자 옵션` → `USB 디버깅` ON
3. USB 연결 후 확인:
   ```bash
   flutter devices
   ```

#### 실제 디바이스 (iOS)
1. Apple Developer 계정 필요
2. Xcode에서 프로비저닝 프로필 설정
3. USB 연결 후 확인:
   ```bash
   flutter devices
   ```

---

## 3. 프로젝트 설정 / Project Setup

### 3.1 저장소 클론

```bash
# 저장소 클론
git clone https://github.com/crazybass81/GoNow-theTimeSaver.git
cd GoNow-theTimeSaver

# 브랜치 확인
git branch
# * main
```

---

### 3.2 플랫폼 폴더 생성 (⚠️ 필수)

```bash
# Flutter 프로젝트 생성 (android/, ios/ 폴더 생성)
flutter create --org com.gonow .

# 주의: lib/main.dart 백업 (이미 완료됨)
# lib/main.dart.backup 파일 존재 확인
ls -la lib/main.dart.backup
```

**설명**:
- 현재 프로젝트에 `android/`와 `ios/` 폴더가 없음
- `flutter create .` 명령으로 플랫폼 폴더 생성
- 기존 `lib/` 코드는 유지됨

---

### 3.3 의존성 설치

```bash
# Flutter 패키지 설치
flutter pub get

# 예상 출력:
# Running "flutter pub get" in GoNow-theTimeSaver...
# Resolving dependencies...
# + cupertino_icons 1.0.6
# + flutter_local_notifications 16.0.0
# + provider 6.1.1
# + supabase_flutter 2.0.0
# + table_calendar 3.0.9
# + timezone 0.9.2
# Changed 42 dependencies!
```

**의존성 목록**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.0
  supabase_flutter: ^2.0.0
  flutter_local_notifications: ^16.0.0
  timezone: ^0.9.2
  table_calendar: ^3.0.9
  dio: ^5.4.0
  flutter_dotenv: ^5.1.0
  geolocator: ^10.1.0
  intl: ^0.18.1
```

---

### 3.4 환경 변수 설정

```bash
# .env.example을 .env로 복사
cp .env.example .env

# .env 파일 편집
nano .env
```

**.env 내용**:
```env
# Naver API (Transit only)
NAVER_CLIENT_ID=your_client_id_here
NAVER_CLIENT_SECRET=your_client_secret_here

# TMAP API (Routes & POI Search)
TMAP_APP_KEY=your_tmap_app_key_here

# Supabase (로컬 개발)
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=your_local_anon_key_here
```

**API 키 발급**:
- **TMAP API**: https://openapi.sk.com/ (Routes, POI Search)
- **Naver API**: https://www.ncloud.com/product/applicationService/maps (Transit only)
- **Supabase**: 로컬 환경은 `supabase start` 후 자동 생성

**Note**: 2025-01-07부터 자차 경로 계산은 TMAP Routes API를 사용합니다. 자세한 내용은 [TMAP_API_MIGRATION.md](./TMAP_API_MIGRATION.md)를 참고하세요.

---

## 4. Supabase 로컬 환경 / Supabase Local Dev

### 4.1 Docker 설치 확인

```bash
# Docker 버전 확인
docker --version

# Docker Desktop 실행 확인
docker ps
```

**없으면 설치**: https://www.docker.com/products/docker-desktop

---

### 4.2 Supabase 로컬 환경 시작

```bash
# Supabase 초기화 (이미 완료된 경우 스킵)
# supabase init

# Supabase 로컬 환경 시작
supabase start

# 예상 출력 (5-10분 소요):
# Started supabase local development setup.
#
#          API URL: http://127.0.0.1:54321
#      GraphQL URL: http://127.0.0.1:54321/graphql/v1
#           DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
#       Studio URL: http://127.0.0.1:54323
#     Inbucket URL: http://127.0.0.1:54324
#       JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
#         anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
# service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**.env 업데이트**:
```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... # 위의 anon key 복사
```

---

### 4.3 데이터베이스 마이그레이션

```bash
# 마이그레이션 확인
ls -la supabase/migrations/

# 마이그레이션 적용 (자동 적용됨)
# supabase db reset

# Supabase Studio에서 확인
open http://127.0.0.1:54323
```

**테이블 확인**:
- `trips` 테이블 존재 확인
- `auth.users` 테이블 `settings` 컬럼 확인
- RLS 정책 활성화 확인

---

### 4.4 Supabase Studio 사용

**URL**: http://127.0.0.1:54323

**기능**:
- **Table Editor**: 데이터 직접 수정
- **SQL Editor**: SQL 쿼리 실행
- **Auth**: 사용자 관리
- **API Docs**: 자동 생성된 API 문서

---

## 5. 빌드 및 실행 / Build & Run

### 5.1 앱 실행

#### iOS 시뮬레이터
```bash
# 디바이스 확인
flutter devices

# iOS 시뮬레이터 실행
flutter run -d ios

# 또는 특정 디바이스 지정
flutter run -d "iPhone 14"
```

#### Android 에뮬레이터
```bash
# 디바이스 확인
flutter devices

# Android 에뮬레이터 실행
flutter run -d android

# 또는 특정 디바이스 지정
flutter run -d emulator-5554
```

---

### 5.2 핫 리로드

**앱 실행 중**:
- `r` 키: Hot Reload (빠른 UI 업데이트)
- `R` 키: Hot Restart (전체 재시작)
- `q` 키: 종료

**VS Code**:
- `Cmd + S` (저장) 시 자동 Hot Reload

---

### 5.3 빌드

#### Debug 빌드 (개발용)
```bash
# Android APK
flutter build apk --debug

# iOS (Mac 전용)
flutter build ios --debug
```

#### Release 빌드 (배포용)
```bash
# Android APK
flutter build apk --release

# iOS (Mac 전용, 프로비저닝 프로필 필요)
flutter build ipa --release
```

---

## 6. 디버깅 / Debugging

### 6.1 로그 확인

```bash
# Flutter 로그 실시간 출력
flutter logs

# 디바이스별 로그
# Android
adb logcat | grep flutter

# iOS
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'
```

---

### 6.2 VS Code 디버깅

**launch.json 설정**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "GoNow (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=${env:SUPABASE_URL}",
        "--dart-define=SUPABASE_ANON_KEY=${env:SUPABASE_ANON_KEY}"
      ]
    },
    {
      "name": "GoNow (Profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    }
  ]
}
```

**사용법**:
1. `F5` 또는 `Run` → `Start Debugging`
2. 브레이크포인트 설정
3. 변수 값 확인

---

### 6.3 Flutter DevTools

```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools

# 앱 실행 후 브라우저에서:
# http://127.0.0.1:9100
```

**주요 기능**:
- **Inspector**: UI 트리 확인
- **Timeline**: 성능 프로파일링
- **Memory**: 메모리 사용량
- **Network**: API 호출 모니터링

---

## 7. 문제 해결 / Troubleshooting

### 7.1 일반적인 문제

#### 문제 1: `flutter: command not found`
**원인**: Flutter가 PATH에 없음
**해결**:
```bash
# .zshrc 또는 .bashrc에 추가
export PATH="$PATH:[Flutter SDK 경로]/bin"

# 예:
export PATH="$PATH:/usr/local/flutter/bin"

# 적용
source ~/.zshrc
```

---

#### 문제 2: `Waiting for another flutter command to release the startup lock`
**원인**: 다른 flutter 프로세스 실행 중
**해결**:
```bash
# 잠금 파일 삭제
rm -rf /path/to/flutter/bin/cache/lockfile

# 또는
killall -9 dart
flutter clean
```

---

#### 문제 3: `Supabase start` 실패
**원인**: Docker Desktop 실행 안 됨
**해결**:
```bash
# Docker Desktop 시작
open -a Docker

# 1분 대기 후 재시도
supabase start
```

---

#### 문제 4: iOS 빌드 실패 (CocoaPods)
**원인**: CocoaPods 의존성 문제
**해결**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

---

#### 문제 5: Android 빌드 실패 (Gradle)
**원인**: Gradle 캐시 문제
**해결**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

### 7.2 FAQ

**Q: `flutter create .` 실행 시 기존 코드가 삭제되나요?**
A: 아니요. `lib/` 폴더는 유지됩니다. 다만 `lib/main.dart`는 덮어쓰여질 수 있으므로 백업 권장.

**Q: Supabase 로컬 환경과 프로덕션 환경 전환은?**
A: `.env` 파일에서 `SUPABASE_URL`과 `SUPABASE_ANON_KEY`를 변경하면 됩니다.

**Q: 실제 디바이스에서 테스트하려면?**
A: Android는 USB 디버깅 활성화, iOS는 Apple Developer 계정과 프로비저닝 프로필 필요.

---

## 📚 참고 자료 / References

### Flutter 공식 문서
- [Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)
- [Flutter 디버깅](https://docs.flutter.dev/testing/debugging)

### Supabase 문서
- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

### 내부 문서
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - Phase별 구현 가이드

---

## ✅ 체크리스트 / Checklist

개발 환경 설정이 완료되었는지 확인하세요:

- [ ] Flutter SDK 설치 및 `flutter doctor` 통과
- [ ] Android Studio / Xcode 설치
- [ ] Supabase CLI 설치
- [ ] 프로젝트 클론 완료
- [ ] `flutter create .` 실행 (android/, ios/ 생성)
- [ ] `flutter pub get` 성공
- [ ] `.env` 파일 설정 완료
- [ ] `supabase start` 성공
- [ ] `flutter run` 성공 (앱 실행됨)
- [ ] Hot Reload 작동 확인

---

**작성일**: 2025-01-07
**다음 단계**: [IMPLEMENTATION_PHASES.md](./IMPLEMENTATION_PHASES.md) - 실제 개발 시작
