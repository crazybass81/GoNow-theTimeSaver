# Phase 3 구현 가이드 / Implementation Guide

**작성일**: 2026-01-07
**상태**: Flutter 측 준비 완료, 네이티브 구현 대기

---

## 📋 현재 상황 / Current Status

### ✅ 완료된 작업 / Completed
- **WidgetService 생성** (`lib/services/widget_service.dart`)
  - Android/iOS 공통 인터페이스
  - MethodChannel 설정
  - Trip 데이터 포맷팅
  - 시간대별 색상 시스템 (초록/주황/빨강/진한빨강)

### ⚠️ 선행 작업 필요 / Prerequisites Required

현재 프로젝트에 `android/`와 `ios/` 플랫폼 폴더가 없습니다. 네이티브 위젯을 구현하려면 먼저 Flutter 플랫폼 폴더를 생성해야 합니다.

**필수 명령어** / **Required Command**:
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create .
```

이 명령어는:
- 기존 `lib/` 코드를 유지하면서
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` 플랫폼 폴더 생성
- 기본 네이티브 설정 파일 생성 (build.gradle, Info.plist 등)

---

## 🤖 Task 3.1: Android 홈 위젯 구현

### SubTask 3.1.1: Jetpack Glance 위젯 기본 구조

**파일 생성 위치**: `android/app/src/main/kotlin/com/gonow/widget/GoNowWidget.kt`

**필요한 의존성** (`android/app/build.gradle`):
```gradle
dependencies {
    // Jetpack Glance for Widgets
    implementation "androidx.glance:glance-appwidget:1.0.0"

    // WorkManager for periodic updates
    implementation "androidx.work:work-runtime-ktx:2.9.0"
}
```

**GoNowWidget.kt 기본 구조**:
```kotlin
package com.gonow.widget

import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class GoNowWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // Widget UI content will go here
            GlanceTheme {
                GoNowWidgetContent()
            }
        }
    }
}

@Composable
fun GoNowWidgetContent() {
    // 위젯 UI 구현
    // SharedPreferences에서 데이터 읽기
    // 시간대별 색상 적용
}

class GoNowWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = GoNowWidget()
}
```

**Widget Provider 등록** (`android/app/src/main/res/xml/gonow_widget_info.xml`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="180dp"
    android:minHeight="110dp"
    android:updatePeriodMillis="900000"
    android:previewImage="@drawable/widget_preview"
    android:initialLayout="@layout/gonow_widget_layout"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

**AndroidManifest.xml 등록**:
```xml
<receiver
    android:name=".widget.GoNowWidgetReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/gonow_widget_info" />
</receiver>
```

---

### SubTask 3.1.2: Flutter ↔ Android 데이터 공유

**✅ Flutter 측 완료**: `lib/services/widget_service.dart` 생성됨

**Android 측 구현 필요**: `android/app/src/main/kotlin/com/gonow/MainActivity.kt`

```kotlin
package com.gonow

import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gonow.widget"
    private val PREFS_NAME = "com.gonow.widget_prefs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val data = call.arguments as? Map<String, Any>
                        if (data != null) {
                            saveWidgetData(data)
                            updateWidget()
                            result.success(true)
                        } else {
                            result.error("INVALID_DATA", "Widget data is null", null)
                        }
                    }
                    "clearWidget" -> {
                        clearWidgetData()
                        updateWidget()
                        result.success(true)
                    }
                    "forceRefresh" -> {
                        updateWidget()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveWidgetData(data: Map<String, Any>) {
        val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()

        editor.putString("tripId", data["tripId"] as? String)
        editor.putString("title", data["title"] as? String)
        editor.putString("destinationAddress", data["destinationAddress"] as? String)
        editor.putInt("minutesRemaining", data["minutesRemaining"] as? Int ?: 0)
        editor.putString("colorPhase", data["colorPhase"] as? String)
        editor.putString("departureTimeFormatted", data["departureTimeFormatted"] as? String)
        editor.putString("timeRemainingText", data["timeRemainingText"] as? String)

        editor.apply()
    }

    private fun clearWidgetData() {
        val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().clear().apply()
    }

    private fun updateWidget() {
        val intent = Intent(this, GoNowWidgetReceiver::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        sendBroadcast(intent)
    }
}
```

---

### SubTask 3.1.3: 위젯 UI 구현

**GoNowWidgetContent.kt**:
```kotlin
@Composable
fun GoNowWidgetContent() {
    val context = LocalContext.current
    val prefs = context.getSharedPreferences("com.gonow.widget_prefs", Context.MODE_PRIVATE)

    val title = prefs.getString("title", null)
    val minutesRemaining = prefs.getInt("minutesRemaining", 0)
    val colorPhase = prefs.getString("colorPhase", "green")
    val departureTime = prefs.getString("departureTimeFormatted", "")
    val timeRemainingText = prefs.getString("timeRemainingText", "")

    if (title == null) {
        // 빈 상태 / Empty state
        EmptyWidgetState()
    } else {
        // 일정 표시 / Show trip
        TripWidgetContent(
            title = title,
            departureTime = departureTime,
            timeRemaining = timeRemainingText,
            colorPhase = colorPhase
        )
    }
}

@Composable
fun TripWidgetContent(
    title: String,
    departureTime: String,
    timeRemaining: String,
    colorPhase: String
) {
    val backgroundColor = when (colorPhase) {
        "green" -> Color(0xFF4CAF50)
        "orange" -> Color(0xFFFF9800)
        "red" -> Color(0xFFF44336)
        "dark_red" -> Color(0xFFD32F2F)
        else -> Color(0xFF4CAF50)
    }

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(backgroundColor)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = TextStyle(
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.White)
            )
        )

        Spacer(modifier = GlanceModifier.height(8.dp))

        Text(
            text = timeRemaining,
            style = TextStyle(
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.White)
            )
        )

        Spacer(modifier = GlanceModifier.height(4.dp))

        Text(
            text = "$departureTime까지 출발",
            style = TextStyle(
                fontSize = 14.sp,
                color = ColorProvider(Color.White)
            )
        )
    }
}
```

---

### SubTask 3.1.4: WorkManager 자동 업데이트

**WidgetUpdateWorker.kt**:
```kotlin
package com.gonow.widget

import android.content.Context
import androidx.work.*
import java.util.concurrent.TimeUnit

class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {

    override fun doWork(): Result {
        // 위젯 갱신
        val intent = Intent(applicationContext, GoNowWidgetReceiver::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        applicationContext.sendBroadcast(intent)

        return Result.success()
    }

    companion object {
        fun schedule(context: Context) {
            val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                15, TimeUnit.MINUTES
            )
                .setConstraints(
                    Constraints.Builder()
                        .setRequiresBatteryNotLow(true)
                        .build()
                )
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "widget_update",
                    ExistingPeriodicWorkPolicy.REPLACE,
                    workRequest
                )
        }
    }
}
```

**Application 클래스에서 워커 시작**:
```kotlin
class GoNowApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        WidgetUpdateWorker.schedule(this)
    }
}
```

---

## 🍎 Task 3.2: iOS 홈 위젯 구현

### SubTask 3.2.1: WidgetKit 위젯 기본 구조

**Xcode에서 Widget Extension 추가**:
1. Xcode에서 프로젝트 열기
2. File → New → Target
3. Widget Extension 선택
4. Target Name: "GoNowWidget"

**GoNowWidget.swift 기본 구조**:
```swift
import WidgetKit
import SwiftUI

struct GoNowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GoNowEntry {
        GoNowEntry(date: Date(), trip: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (GoNowEntry) -> Void) {
        let entry = GoNowEntry(date: Date(), trip: loadTripData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoNowEntry>) -> Void) {
        var entries: [GoNowEntry] = []
        let currentDate = Date()

        // 15분마다 업데이트
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 15, to: currentDate)!
            let entry = GoNowEntry(date: entryDate, trip: loadTripData())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func loadTripData() -> TripData? {
        // SharedUserDefaults에서 데이터 읽기
        let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.widget")
        guard let tripData = sharedDefaults?.dictionary(forKey: "widgetData") else {
            return nil
        }

        return TripData(
            title: tripData["title"] as? String ?? "",
            departureTime: tripData["departureTimeFormatted"] as? String ?? "",
            timeRemaining: tripData["timeRemainingText"] as? String ?? "",
            colorPhase: tripData["colorPhase"] as? String ?? "green"
        )
    }
}

struct GoNowEntry: TimelineEntry {
    let date: Date
    let trip: TripData?
}

struct TripData {
    let title: String
    let departureTime: String
    let timeRemaining: String
    let colorPhase: String
}
```

---

### SubTask 3.2.2: Flutter ↔ iOS 데이터 공유

**App Groups 설정** (Xcode):
1. Runner Target → Signing & Capabilities
2. "+ Capability" → App Groups
3. Group ID: `group.com.gonow.widget`
4. Widget Extension Target에도 동일하게 추가

**AppDelegate.swift 수정**:
```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let widgetChannel = FlutterMethodChannel(
            name: "com.gonow.widget",
            binaryMessenger: controller.binaryMessenger
        )

        widgetChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "updateWidget":
                if let args = call.arguments as? [String: Any] {
                    self.saveWidgetData(args)
                    self.reloadWidget()
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_DATA", message: "Widget data is null", details: nil))
                }
            case "clearWidget":
                self.clearWidgetData()
                self.reloadWidget()
                result(true)
            case "forceRefresh":
                self.reloadWidget()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func saveWidgetData(_ data: [String: Any]) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.widget")
        sharedDefaults?.set(data, forKey: "widgetData")
        sharedDefaults?.synchronize()
    }

    private func clearWidgetData() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.widget")
        sharedDefaults?.removeObject(forKey: "widgetData")
        sharedDefaults?.synchronize()
    }

    private func reloadWidget() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
```

---

### SubTask 3.2.3: 위젯 UI 구현

**GoNowWidgetView.swift**:
```swift
struct GoNowWidgetView: View {
    var entry: GoNowEntry

    var body: some View {
        if let trip = entry.trip {
            TripView(trip: trip)
        } else {
            EmptyView()
        }
    }
}

struct TripView: View {
    var trip: TripData

    var backgroundColor: Color {
        switch trip.colorPhase {
        case "green": return Color.green
        case "orange": return Color.orange
        case "red": return Color.red
        case "dark_red": return Color(red: 0.83, green: 0.18, blue: 0.18)
        default: return Color.green
        }
    }

    var body: some View {
        ZStack {
            backgroundColor

            VStack(spacing: 8) {
                Text(trip.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(trip.timeRemaining)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("\(trip.departureTime)까지 출발")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

struct EmptyView: View {
    var body: some View {
        ZStack {
            Color.gray

            VStack {
                Image(systemName: "calendar.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("일정 없음")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

@main
struct GoNowWidget: Widget {
    let kind: String = "GoNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GoNowWidgetProvider()) { entry in
            GoNowWidgetView(entry: entry)
        }
        .configurationDisplayName("GoNow")
        .description("다음 일정 출발 시간 카운트다운")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

---

## 🔔 Task 3.3: 로컬 푸시 알림

### SubTask 3.3.1: flutter_local_notifications 설정

**✅ 이미 pubspec.yaml에 추가됨**: `flutter_local_notifications: ^16.0.0`

**NotificationService 생성** (`lib/services/notification_service.dart`):
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/trip.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.payload}');
    // 앱 열기 및 대시보드로 이동
  }

  Future<void> scheduleNotifications(Trip trip) async {
    // 30분 전 알림
    await _schedule30MinuteNotification(trip);

    // 10분 전 긴급 알림
    await _schedule10MinuteNotification(trip);
  }

  Future<void> _schedule30MinuteNotification(Trip trip) async {
    final notificationTime = trip.departureTime.subtract(const Duration(minutes: 30));

    await _notifications.zonedSchedule(
      trip.id.hashCode,
      '${trip.title} - 30분 전',
      '$timeFormatted까지 출발하세요',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Trip Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _schedule10MinuteNotification(Trip trip) async {
    final notificationTime = trip.departureTime.subtract(const Duration(minutes: 10));

    await _notifications.zonedSchedule(
      trip.id.hashCode + 1,
      '🚨 ${trip.title} - 긴급!',
      '10분 후 출발! 지금 나가세요!',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_urgent',
          'Urgent Reminders',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotifications(Trip trip) async {
    await _notifications.cancel(trip.id.hashCode);
    await _notifications.cancel(trip.id.hashCode + 1);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
```

---

## 📝 다음 단계 / Next Steps

### 1. Flutter 플랫폼 폴더 생성
```bash
cd /Users/t/021_DEV/GoNow-theTimeSaver
flutter create .
```

### 2. Android 구현
- `android/app/src/main/kotlin/com/gonow/widget/` 폴더 생성
- GoNowWidget.kt, WidgetUpdateWorker.kt 파일 추가
- MainActivity.kt 수정 (MethodChannel 추가)
- build.gradle 의존성 추가
- AndroidManifest.xml 위젯 등록

### 3. iOS 구현
- Xcode에서 Widget Extension 추가
- GoNowWidget.swift 파일 작성
- App Groups 설정
- AppDelegate.swift 수정

### 4. 알림 구현
- NotificationService 생성
- TripProvider에서 알림 스케줄링 연동
- 권한 요청 UI 추가

### 5. 통합 테스트
- 위젯 업데이트 테스트
- 알림 전송 테스트
- 배터리 소모 테스트

---

## ⚠️ 주의사항 / Notes

1. **flutter create 명령 실행 시 기존 파일 유지됨**
   - `lib/` 폴더의 코드는 그대로 유지됩니다
   - 단, `main.dart`는 템플릿으로 덮어쓰일 수 있으니 백업 권장
   - 또는 `--org com.gonow` 옵션으로 패키지명 지정

2. **네이티브 코드는 수동 작성 필요**
   - 이 가이드의 코드를 참고하여 각 플랫폼별로 구현
   - Android: Kotlin + Jetpack Glance
   - iOS: Swift + WidgetKit

3. **권한 설정 필수**
   - Android: `AndroidManifest.xml`에 알림 권한 추가
   - iOS: `Info.plist`에 알림 권한 추가

4. **테스트 환경**
   - Android: 실제 기기 또는 에뮬레이터 (API 31+)
   - iOS: 실제 기기 또는 시뮬레이터 (iOS 14+)

---

**작성자**: Claude
**업데이트**: Phase 3 Task 3.1.2 완료 시점
