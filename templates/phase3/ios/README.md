# iOS 네이티브 코드 설치 가이드 / iOS Native Code Setup Guide

**작성일**: 2026-01-07
**대상**: Phase 3 - iOS 위젯 구현

---

## 📋 사전 준비 / Prerequisites

### 필수 요구사항
- ✅ macOS 환경
- ✅ Xcode 14.0 이상
- ✅ iOS 14.0 이상 대상 디바이스
- ✅ `flutter create` 명령 실행 완료
- ✅ Apple Developer 계정 (App Groups 설정용)

---

## 🚀 설치 단계 / Installation Steps

### 1단계: AppDelegate.swift 교체

**파일**: `ios/Runner/AppDelegate.swift`

**작업**:
```bash
# 기존 AppDelegate.swift 백업
cp ios/Runner/AppDelegate.swift ios/Runner/AppDelegate.swift.backup

# 새 AppDelegate.swift 복사
cp claudedocs/ios_native_code/AppDelegate.swift ios/Runner/
```

**주의사항**:
- 기존 AppDelegate.swift가 있으면 백업 후 교체
- 기본 Flutter 코드는 새 파일에 포함되어 있음

---

### 2단계: Xcode에서 Widget Extension 추가 (**수동 작업**)

**소요 시간**: 약 5분

#### 2.1. Xcode 열기
```bash
open ios/Runner.xcworkspace
```

**중요**: `Runner.xcodeproj`가 아닌 `Runner.xcworkspace`를 열어야 합니다!

#### 2.2. Widget Extension 추가
1. **File** → **New** → **Target...** 클릭
2. 템플릿 선택:
   - **iOS** 탭 선택
   - **Widget Extension** 선택
   - **Next** 클릭

3. Widget Extension 설정:
   - **Product Name**: `GoNowWidgetExtension`
   - **Team**: 본인의 Apple Developer 계정 선택
   - **Project**: `Runner` 선택
   - **Language**: Swift
   - **Include Configuration Intent**: 체크 해제 ✅
   - **Finish** 클릭

4. "Activate 'GoNowWidgetExtension' scheme?" 팝업:
   - **Cancel** 클릭 (Runner scheme 유지)

#### 2.3. Widget Extension 파일 교체
1. Xcode 프로젝트 네비게이터에서:
   - `GoNowWidgetExtension` 폴더 찾기
   - 자동 생성된 `GoNowWidgetExtension.swift` 파일 삭제

2. Finder에서 Widget 코드 복사:
```bash
# GoNowWidget.swift를 Widget Extension 폴더로 복사
cp claudedocs/ios_native_code/GoNowWidget.swift \
   ios/GoNowWidgetExtension/
```

3. Xcode에서 파일 추가:
   - `GoNowWidgetExtension` 폴더 우클릭
   - **Add Files to "Runner"...** 선택
   - `GoNowWidget.swift` 파일 선택
   - **Add** 클릭

---

### 3단계: App Groups 설정 (**수동 작업**)

**소요 시간**: 약 5분

#### 3.1. Runner Target 설정
1. Xcode에서 **Runner** 타겟 선택
2. **Signing & Capabilities** 탭 클릭
3. **+ Capability** 버튼 클릭
4. **App Groups** 검색 후 선택
5. **+ (플러스)** 버튼 클릭
6. App Group ID 입력: `group.com.gonow.gotimesaver`
7. 생성된 그룹 체크 ✅

#### 3.2. Widget Extension Target 설정
1. Xcode에서 **GoNowWidgetExtension** 타겟 선택
2. **Signing & Capabilities** 탭 클릭
3. **+ Capability** 버튼 클릭
4. **App Groups** 검색 후 선택
5. 이미 생성된 `group.com.gonow.gotimesaver` 체크 ✅

**중요**: Runner와 Widget Extension 모두 **동일한 App Group ID**를 사용해야 합니다!

---

### 4단계: Info.plist 수정

**파일**: `ios/Runner/Info.plist`

**작업**:
1. Xcode에서 `ios/Runner/Info.plist` 파일 열기
2. `claudedocs/ios_native_code/Info_plist_ADDITIONS.xml` 파일 내용 확인
3. 다음 항목 추가:

```xml
<!-- App Group -->
<key>AppGroups</key>
<array>
    <string>group.com.gonow.gotimesaver</string>
</array>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

---

### 5단계: Widget Extension Bundle Identifier 확인

**파일**: Xcode → Widget Extension Target → **General** 탭

**확인 사항**:
- Bundle Identifier: `com.gonow.gotimesaver.GoNowWidgetExtension`
- Deployment Target: iOS 14.0 이상

**설정 방법**:
1. Xcode에서 **GoNowWidgetExtension** 타겟 선택
2. **General** 탭 클릭
3. **Identity** 섹션:
   - Bundle Identifier: `com.gonow.gotimesaver.GoNowWidgetExtension`
   - Version: 1.0
   - Build: 1
4. **Deployment Info** 섹션:
   - iOS Deployment Target: 14.0

---

## 🔧 빌드 및 테스트 / Build and Test

### 1. 클린 빌드
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 2. Xcode에서 빌드
1. Xcode에서 **Runner** scheme 선택
2. 시뮬레이터 또는 실제 디바이스 선택
3. **Product** → **Build** (⌘+B)

**예상 결과**: `Build Succeeded`

### 3. 앱 실행
```bash
flutter run -d ios
```

또는 Xcode에서:
- **Product** → **Run** (⌘+R)

---

## ✅ 위젯 확인 / Widget Verification

### iOS 시뮬레이터에서:
1. 홈 화면 → 위젯 편집 모드 (길게 터치)
2. **+** 버튼 클릭
3. 위젯 목록에서 **GoNow 일정** 검색
4. 위젯 크기 선택 (Small/Medium)
5. **Add Widget** 클릭

### 실제 디바이스에서:
1. 홈 화면 → 위젯 편집 모드
2. 상단 **+** 버튼 터치
3. **GoNow** 검색
4. **GoNow 일정** 위젯 추가

---

## 🐛 문제 해결 / Troubleshooting

### 문제 1: "No such module 'WidgetKit'"
**원인**: iOS 14.0 미만 타겟
**해결**:
- Xcode → Widget Extension Target → General → iOS Deployment Target → 14.0 이상

### 문제 2: 위젯이 목록에 나타나지 않음
**원인**: Widget Extension 빌드 실패 또는 미포함
**해결**:
1. Xcode → Product → Clean Build Folder (⌘+Shift+K)
2. Widget Extension 타겟 선택 후 빌드 (⌘+B)
3. Runner 타겟으로 전환 후 다시 빌드

### 문제 3: "App Group not found"
**원인**: App Groups 설정 누락 또는 불일치
**해결**:
1. Runner 타겟 → Signing & Capabilities → App Groups 확인
2. Widget Extension 타겟 → App Groups 확인
3. 두 타겟 모두 `group.com.gonow.gotimesaver` 체크 확인

### 문제 4: 위젯 데이터가 표시되지 않음
**원인**: UserDefaults App Group 접근 실패
**해결**:
1. AppDelegate.swift의 APP_GROUP 상수 확인: `"group.com.gonow.gotimesaver"`
2. GoNowWidget.swift의 APP_GROUP 상수 확인: 동일한 값
3. 앱 재설치 후 다시 테스트

### 문제 5: "Signing for 'GoNowWidgetExtension' requires a development team"
**원인**: Widget Extension에 Team 미설정
**해결**:
1. Xcode → Widget Extension 타겟 선택
2. Signing & Capabilities → Team 선택
3. Runner와 동일한 Team 사용

### 문제 6: 위젯이 업데이트되지 않음
**원인**: Timeline 갱신 미발생
**해결**:
1. 앱에서 일정 추가/수정 후 위젯 확인
2. 위젯 길게 터치 → 위젯 삭제 → 다시 추가
3. 디바이스 재부팅

---

## 📊 파일 구조 최종 확인 / Final File Structure

```
ios/
├── Runner/
│   ├── AppDelegate.swift ✅ (교체됨)
│   ├── Info.plist ✅ (수정됨)
│   └── Runner.entitlements ✅ (자동 생성)
│
├── GoNowWidgetExtension/ ✅ (수동 생성)
│   ├── GoNowWidget.swift ✅
│   ├── Info.plist ✅ (자동 생성)
│   └── GoNowWidgetExtension.entitlements ✅ (자동 생성)
│
└── Runner.xcworkspace/
```

---

## 🔒 Apple Developer Portal 설정

### App Groups 등록 (선택 사항)
**참고**: 개발용은 Xcode에서 자동 생성되지만, 프로덕션 배포 시 필요합니다.

1. https://developer.apple.com 접속
2. **Certificates, Identifiers & Profiles** 이동
3. **Identifiers** 선택
4. **App IDs** → 앱 선택
5. **App Groups** Capability 활성화
6. **App Groups** 선택 → **Configure**
7. **Edit** → `group.com.gonow.gotimesaver` 추가

---

## 🎯 다음 단계 / Next Steps

1. ✅ iOS 코드 설치 완료
2. ✅ Android 코드 설치 완료
3. ⏳ 통합 테스트
4. ⏳ 배터리 소모 테스트
5. ⏳ 실제 디바이스에서 검증

---

## 📝 체크리스트 / Checklist

### Xcode 설정
- [ ] Widget Extension 추가 완료
- [ ] Runner Target App Groups 설정 완료
- [ ] Widget Extension App Groups 설정 완료
- [ ] App Group ID 일치 확인: `group.com.gonow.gotimesaver`
- [ ] Widget Extension Bundle ID 확인
- [ ] iOS Deployment Target 14.0 이상 확인

### 코드 파일
- [ ] AppDelegate.swift 교체 완료
- [ ] GoNowWidget.swift 추가 완료
- [ ] Info.plist 수정 완료

### 빌드 및 테스트
- [ ] Xcode 빌드 성공
- [ ] 앱 실행 성공
- [ ] 위젯이 목록에 표시됨
- [ ] 위젯에 일정 표시됨
- [ ] 시간대별 색상 변경 확인

---

**작성 완료**: 2026-01-07
**예상 소요 시간**: 15-20분 (수동 작업 포함)
**다음 작업**: 통합 테스트
