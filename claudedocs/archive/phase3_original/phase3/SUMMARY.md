# Phase 3 작업 요약 / Phase 3 Summary

**작성일**: 2026-01-07
**작업자**: Claude
**상태**: Flutter 레이어 완료, 네이티브 구현 대기

---

## 📊 작업 개요 / Work Overview

Phase 3 (Widgets & Notifications)의 **Flutter 레이어 구현**을 완료했습니다.
Android와 iOS 네이티브 코드 구현을 위한 모든 기초 작업이 준비되었습니다.

---

## ✅ 완료된 작업 / Completed Work

### 1. WidgetService 생성 (`lib/services/widget_service.dart`)

**목적**: Android/iOS 홈 위젯 업데이트를 위한 공통 인터페이스

**주요 기능**:
- MethodChannel 설정 (`com.gonow.widget`)
- Trip 데이터를 위젯용 포맷으로 변환
- 시간대별 색상 시스템 (초록/주황/빨강/진한빨강)
- 위젯 업데이트/초기화/강제 새로고침 메서드

**핵심 메서드**:
```dart
Future<void> updateWidget({Trip? upcomingTrip})  // 위젯 업데이트
Future<void> forceRefreshWidget()                // 강제 새로고침
```

**데이터 포맷**:
```dart
{
  'tripId': String,
  'title': String,
  'destinationAddress': String,
  'arrivalTime': String (ISO8601),
  'departureTime': String (ISO8601),
  'minutesRemaining': int,
  'colorPhase': String ('green'|'orange'|'red'|'dark_red'),
  'transportMode': String,
  'travelDurationMinutes': int,
  'departureTimeFormatted': String (HH:mm),
  'arrivalTimeFormatted': String (HH:mm),
  'timeRemainingText': String ('15분 남음')
}
```

---

### 2. NotificationService 생성 (`lib/services/notification_service.dart`)

**목적**: 로컬 푸시 알림 시스템 구현

**주요 기능**:
- flutter_local_notifications 통합
- 30분 전 일반 알림
- 10분 전 긴급 알림
- 동적 알림 (교통 상황 변화 시)
- Android 알림 채널 생성 (일반/긴급)
- iOS 알림 권한 요청 및 관리

**핵심 메서드**:
```dart
Future<void> initialize()                              // 초기화
Future<void> scheduleNotifications(Trip trip)          // 알림 예약
Future<void> sendDynamicNotification(...)              // 동적 알림
Future<void> cancelNotifications(Trip trip)            // 알림 취소
Future<bool> requestPermission()                       // 권한 요청
```

**알림 ID 규칙**:
- 30분 알림: `trip.id.hashCode`
- 10분 알림: `trip.id.hashCode + 1`
- 동적 알림: `trip.id.hashCode + 2`

**알림 채널** (Android):
- `trip_reminders`: 일반 알림 (Importance.high)
- `trip_urgent`: 긴급 알림 (Importance.max)

---

### 3. pubspec.yaml 업데이트

**추가된 패키지**:
```yaml
dependencies:
  flutter_local_notifications: ^16.0.0  # (기존)
  timezone: ^0.9.2                      # (신규 추가)
```

**이유**: flutter_local_notifications의 예약 알림 기능에 timezone 패키지 필수

---

### 4. Phase 3 구현 가이드 문서 (`claudedocs/PHASE_3_IMPLEMENTATION_GUIDE.md`)

**내용**:
- **Android 위젯 구현 가이드**
  - Jetpack Glance 위젯 구조
  - SharedPreferences 데이터 공유
  - WorkManager 자동 업데이트
  - 전체 Kotlin 코드 템플릿

- **iOS 위젯 구현 가이드**
  - WidgetKit 위젯 구조
  - App Groups 데이터 공유
  - Timeline Provider
  - 전체 Swift 코드 템플릿

- **알림 구현 가이드**
  - NotificationService 사용법
  - 권한 요청 UI
  - 테스트 방법

---

## ⚠️ 선행 작업 필요 / Prerequisites Required

### flutter create 명령 실행

**현재 상황**:
- 프로젝트에 `android/`와 `ios/` 플랫폼 폴더가 없음
- Flutter 프로젝트가 `lib/` 폴더만 있는 상태

**필요한 작업**:
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create .
```

**이 명령어의 효과**:
- ✅ 기존 `lib/` 코드는 **그대로 유지됨**
- ✅ `android/`, `ios/`, `web/` 등 플랫폼 폴더 생성
- ✅ 기본 네이티브 설정 파일 생성 (build.gradle, Info.plist 등)
- ⚠️ `main.dart`는 템플릿으로 덮어쓰일 수 있으므로 백업 권장

**주의사항**:
```bash
# 패키지명 지정 권장
flutter create --org com.gonow .

# 또는 기존 main.dart 백업
cp lib/main.dart lib/main.dart.backup
flutter create .
# 필요시 main.dart 복원
```

---

## 🔄 다음 단계 / Next Steps

### 1단계: 플랫폼 폴더 생성
```bash
flutter create --org com.gonow .
```

### 2단계: Android 네이티브 구현

**파일 구조**:
```
android/
└── app/
    └── src/
        └── main/
            ├── kotlin/
            │   └── com/
            │       └── gonow/
            │           ├── MainActivity.kt          (수정)
            │           └── widget/
            │               ├── GoNowWidget.kt       (신규)
            │               └── WidgetUpdateWorker.kt (신규)
            ├── res/
            │   └── xml/
            │       └── gonow_widget_info.xml       (신규)
            └── AndroidManifest.xml                 (수정)
```

**구현 순서**:
1. `MainActivity.kt` 수정 (MethodChannel 추가)
2. `GoNowWidget.kt` 생성 (Jetpack Glance 위젯)
3. `WidgetUpdateWorker.kt` 생성 (WorkManager)
4. `gonow_widget_info.xml` 생성 (위젯 메타데이터)
5. `AndroidManifest.xml` 수정 (위젯 등록)
6. `build.gradle` 수정 (의존성 추가)

**참고 문서**: `claudedocs/PHASE_3_IMPLEMENTATION_GUIDE.md` → Android 섹션

---

### 3단계: iOS 네이티브 구현

**파일 구조**:
```
ios/
├── Runner/
│   ├── AppDelegate.swift       (수정)
│   └── Info.plist              (수정 - App Groups)
└── GoNowWidget/                (Xcode에서 생성)
    ├── GoNowWidget.swift       (신규)
    └── Info.plist              (자동 생성)
```

**구현 순서**:
1. Xcode에서 Widget Extension 추가
2. App Groups 설정 (`group.com.gonow.widget`)
3. `AppDelegate.swift` 수정 (MethodChannel 추가)
4. `GoNowWidget.swift` 작성 (WidgetKit)
5. Timeline Provider 구현

**참고 문서**: `claudedocs/PHASE_3_IMPLEMENTATION_GUIDE.md` → iOS 섹션

---

### 4단계: 위젯 + 알림 통합

**TripProvider 수정** (`lib/providers/trip_provider.dart`):
```dart
import '../services/widget_service.dart';
import '../services/notification_service.dart';

class TripProvider with ChangeNotifier {
  final WidgetService _widgetService = WidgetService();
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize(String userId) async {
    await _notificationService.initialize();
    await loadTrips(userId);
  }

  Future<Trip> addTrip(...) async {
    final createdTrip = await _tripService.createTrip(trip);

    // 위젯 업데이트
    await _widgetService.updateWidget(upcomingTrip: createdTrip);

    // 알림 예약
    await _notificationService.scheduleNotifications(createdTrip);

    return createdTrip;
  }

  Future<void> completeTrip(String tripId) async {
    await _tripService.completeTrip(tripId);

    // 알림 취소
    final trip = _trips.firstWhere((t) => t.id == tripId);
    await _notificationService.cancelNotifications(trip);

    // 위젯 업데이트 (다음 일정 또는 빈 상태)
    _findUpcomingTrip();
    if (_upcomingTrip != null) {
      await _widgetService.updateWidget(upcomingTrip: _upcomingTrip);
    } else {
      await _widgetService.updateWidget();
    }
  }
}
```

---

### 5단계: 권한 요청 UI 추가

**설정 화면에 추가** (`lib/screens/settings/settings_screen.dart`):
```dart
// 알림 권한 섹션
ListTile(
  title: const Text('알림 권한'),
  subtitle: const Text('출발 시간 알림을 받으려면 권한이 필요합니다'),
  trailing: FutureBuilder<bool>(
    future: NotificationService().hasPermission(),
    builder: (context, snapshot) {
      final hasPermission = snapshot.data ?? false;
      return Icon(
        hasPermission ? Icons.check_circle : Icons.error,
        color: hasPermission ? Colors.green : Colors.red,
      );
    },
  ),
  onTap: () async {
    final granted = await NotificationService().requestPermission();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? '알림 권한이 허용되었습니다' : '알림 권한이 거부되었습니다',
          ),
        ),
      );
    }
  },
)
```

---

### 6단계: 테스트

**기능 테스트 체크리스트**:
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

**디버그 명령어**:
```dart
// WidgetService 디버그 정보
print(WidgetService().getDebugInfo());

// NotificationService 디버그 정보
print(await NotificationService().getDebugInfo());

// TripProvider 디버그 정보
print(tripProvider.getDebugInfo());
```

---

## 📂 생성된 파일 / Created Files

```
lib/
├── services/
│   ├── widget_service.dart           ✅ (신규 생성)
│   └── notification_service.dart     ✅ (신규 생성)
└── (기존 파일들)

claudedocs/
├── PHASE_3_IMPLEMENTATION_GUIDE.md   ✅ (신규 생성)
└── PHASE_3_SUMMARY.md                ✅ (현재 파일)

pubspec.yaml                          ✅ (업데이트: timezone 추가)
GO_NOW_COMPLETE_MVP_SPEC.md          ✅ (업데이트: Phase 3 진행 상황)
```

---

## 🎯 현재 상태 / Current Status

**Phase 2**: ✅ 완료 (100%)
**Phase 3**: 🚧 진행 중 (Flutter 레이어 완료, 네이티브 구현 대기)

**완료율**:
- Flutter 레이어: 100% ✅
- Android 네이티브: 0% ⏳
- iOS 네이티브: 0% ⏳
- 통합 테스트: 0% ⏳

**전체 진행률**: ~30%

---

## 📝 중요 참고 사항 / Important Notes

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
- Group ID: `group.com.gonow.widget`

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

## 🐛 예상 문제 및 해결책 / Troubleshooting

### 문제 1: flutter create 실행 후 main.dart가 덮어써짐

**해결책**:
```bash
# 백업
cp lib/main.dart lib/main.dart.backup

# flutter create 실행
flutter create .

# 복원 (필요시)
cp lib/main.dart.backup lib/main.dart
```

---

### 문제 2: Android 위젯이 업데이트되지 않음

**원인**:
- SharedPreferences 키 불일치
- MethodChannel 이름 불일치
- WorkManager 미실행

**해결책**:
1. 로그 확인: `adb logcat | grep GoNow`
2. SharedPreferences 키 확인: `com.gonow.widget_prefs`
3. WorkManager 스케줄 확인: `WorkManager.getInstance().getWorkInfosForUniqueWork()`

---

### 문제 3: iOS 위젯 데이터 공유 안됨

**원인**:
- App Groups 설정 누락
- Group ID 불일치
- SharedUserDefaults 키 불일치

**해결책**:
1. Xcode → Signing & Capabilities 확인
2. Runner와 Widget Extension 모두 같은 Group ID 설정
3. Group ID: `group.com.gonow.widget`

---

### 문제 4: 알림이 오지 않음

**원인**:
- 권한 거부됨
- timezone 설정 오류
- 알림 시간이 이미 지남

**해결책**:
1. 권한 확인: `await NotificationService().hasPermission()`
2. Pending notifications 확인: `await NotificationService().getPendingNotifications()`
3. 로그 확인: `debugPrint` 출력

---

## 🚀 다음 세션에서 할 일 / Next Session Tasks

1. **flutter create 실행**
   ```bash
   cd /Users/t/021_DEV/GoNow-theTimeSaver
   flutter create --org com.gonow .
   ```

2. **Android 구현**
   - MainActivity.kt 수정
   - GoNowWidget.kt 생성
   - WidgetUpdateWorker.kt 생성

3. **iOS 구현**
   - Widget Extension 추가
   - AppDelegate.swift 수정
   - GoNowWidget.swift 작성

4. **통합 테스트**
   - 위젯 + 알림 동작 확인
   - 배터리 소모 테스트

---

**작성자**: Claude
**완료일**: 2026-01-07
**다음 업데이트**: 네이티브 구현 완료 시
