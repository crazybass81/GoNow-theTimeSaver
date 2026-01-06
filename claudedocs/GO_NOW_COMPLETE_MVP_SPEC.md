# Go Now: The Time Saver - 완결된 MVP 마스터 문서
# Complete MVP Master Specification

**문서 버전**: 3.0 FINAL
**작성일**: 2026-01-06
**최종 업데이트**: 2026-01-06
**프로젝트 타입**: ADHD 특화 시간 관리 앱 (Flutter 기반)
**MVP 출시일**: 2026년 1월 31일 (25일 개발 기간)

---

## 📋 Executive Summary / 요약

### 핵심 가치 제안 / Core Value Proposition

**"절대 안 늦는 습관 만들기"**

- **문제**: ADHD 성향 사용자의 시간맹(Time Blindness) - 시간 흐름을 감각적으로 인지하지 못하는 증상
- **해결**: 역산 스케줄링 + 실시간 교통 데이터 + 시각적 카운트다운 + 대중교통 + 홈 위젯
- **차별점**: Tiimo(시각화) + Waze(실시간 교통) + 대중교통 통합 솔루션

### 최종 결정사항 (All Finalized)

✅ **제품 포지셔닝**: 생산성 앱 (의료 기기 아님)
✅ **타깃 시장**: 20~40대 직장인, 프리랜서
✅ **핵심 기능**: 역산 스케줄링 + 실시간 교통 + 대중교통 + 홈 위젯
✅ **수익 모델**: Freemium 구독 (월 4,900원)
✅ **기술 스택**: Flutter 3.x + Naver Maps/Transit API + WidgetKit + Jetpack Glance
✅ **개발 기간**: 25일 (2026.01.31까지)
✅ **개발 팀**: 바이브코딩 개발자 2명

❌ **폐기된 기능**: 패널티 시스템 (법적 리스크, 사용자 반발)

---

## 🎯 1. Product Specification / 제품 명세

### 1.1 Phase 1 MVP 핵심 기능

#### ✅ 1. 역산 스케줄링 (Backward Planning)

**기능**: 도착 시간으로부터 출발 시간 자동 계산 (4가지 버퍼 시간 반영)

```
[사용자 입력] "오후 2시 회의 장소 도착"
         ↓
[시스템 자동 계산 - 4단계 역산]
4️⃣ 일정 마무리 시간: 5분 (이전 일정 정리 후 출발)
3️⃣ 일찍 도착 버퍼: 10분 (회의 시작 전 여유)
2️⃣ 이동 시간 + 오차율: 25분 + 5분 = 30분 (실시간 교통 + 불확실성)
1️⃣ 외출 준비 시간: 15분 (옷 입기, 짐 챙기기)
         ↓
[총 소요 시간] 60분 (5 + 10 + 30 + 15)
         ↓
[최종 출력] "🚨 1시 00분까지 집을 나가야 합니다"
```

**4가지 버퍼 시간 설계**:
1. **일정 마무리 시간** (5분): 이전 일정을 끝내고 나가는 시간
2. **일찍 도착 버퍼** (10분): 약속 시간보다 일찍 도착해서 여유 갖기
3. **이동 오차율** (이동시간의 20%): 교통 예측 불확실성, 신호 대기, 주차 시간
4. **외출 준비 시간** (15분): 옷 입기, 짐 챙기기 등 집에서 나오기까지

**가치**: ADHD 사용자의 전두엽 기능 대체 - 복잡한 시간 계산을 시스템이 대신 수행

#### ✅ 2. 실시간 교통 반영

**기능**: Adaptive Polling으로 교통 상황 변화 모니터링

| 시간대 | 호출 주기 | 이유 |
|--------|-----------|------|
| 1시간 전 | 15분 간격 | 대략적 트래픽 모니터링 |
| 30분 전 | 5분 간격 | 정밀 계산 시작 |
| 10분 전 | 3분 간격 | 크리티컬 모드 |

**가치**: 정적 알림(기존 캘린더 앱)의 한계 극복 - 교통 변화에 따라 출발 시간 동적 조정

#### ✅ 3. 대중교통 지원 (Phase 1 MVP)

**기능**: 버스/지하철 실시간 경로 탐색 및 환승 정보

- **네이버 Transit API**: 버스/지하철 통합 경로
- **서울시 공공데이터**: 실시간 버스 도착 정보
- **환승 버퍼**: 도보 환승 5분, 버스 환승 3분 자동 반영

**UI 예시**:
```
🚇 대중교통 경로 (32분)
├─ 🚌 버스 472번 (15분)
│   └─ 현재 위치 → 강남역
├─ 🚶 도보 환승 (3분)
└─ 🚇 지하철 2호선 (12분)
    └─ 강남역 → 삼성역
```

#### ✅ 4. 홈 위젯 (Android/iOS) (Phase 1 MVP)

**기능**: 앱을 열지 않아도 홈 화면에서 다음 일정 확인

**Android Widget (Jetpack Glance)**:
```
┌─────────────────────┐
│  Go Now        ⚙️   │
│  출근               │
│  15분 남음          │
│  08:25까지 출발     │
└─────────────────────┘
```

**iOS Widget (WidgetKit)**:
```
┌─────────────────────┐
│  Go Now             │
│  🏢 회의            │
│  ⏰ 32분 남음       │
│  13:28까지 출발     │
│  🚇 지하철 2호선    │
└─────────────────────┘
```

**업데이트 주기**:
- Android: WorkManager로 15분마다 자동 업데이트
- iOS: Timeline Provider로 15분마다 자동 업데이트

#### ✅ 5. 시각적 카운트다운

**기능**: ADHD 사용자에게 직관적인 시간 시각화

```
┌─────────────────────────────────────┐
│                                     │
│           🚨 15분 남음              │
│         ●●●●●●●●○○                 │
│                                     │
│    08:25까지 집을 나가세요          │
│                                     │
│    [출발했어요] [5분만 더]          │
└─────────────────────────────────────┘
```

**색상 시스템**:
- 초록색: 30분 이상 → 여유
- 주황색: 10~30분 → 주의
- 빨간색: 10분 미만 → 긴급

#### ✅ 6. 로컬 푸시 알림

**기능**: 서버 없이 Flutter에서 직접 알림 전송

```dart
// 알림 스케줄링 예시
void scheduleNotification(Trip trip) {
  final notifications = FlutterLocalNotificationsPlugin();

  // 30분 전 알림
  notifications.zonedSchedule(
    0,
    '출발 준비하세요! 🏃',
    '${trip.destination}까지 30분 남았습니다',
    trip.departureTime.subtract(Duration(minutes: 30)),
    notificationDetails,
  );

  // 10분 전 긴급 알림
  notifications.zonedSchedule(
    1,
    '🚨 긴급! 지금 나가세요!',
    '${trip.destination}까지 10분 남았습니다',
    trip.departureTime.subtract(Duration(minutes: 10)),
    notificationDetails,
    androidAllowWhileIdle: true,
  );
}
```

### 1.2 폐기된 기능 (Abandoned Features)

❌ **패널티 시스템**: 완전 폐기
- 이유: 법적 리스크 (앱스토어 IAP 정책 위반, 사행성 규제), 사용자 반발
- 대안: 긍정적 강화 (게임화) - Streak, 배지, 아바타 성장

❌ **외부 PG 연동 (Stripe/토스페이먼츠)**: 폐기
- 이유: 앱스토어 정책 위반 (IAP 우회)
- 대안: In-App Purchase (IAP) 사용

❌ **지오펜싱**: Phase 2로 연기
- 이유: 배터리 소모, GPS 오차 문제
- Phase 1은 수동 "출발했어요" 버튼으로 대체

---

## 🏗️ 2. Technical Architecture / 기술 아키텍처

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer (Flutter)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  iOS App     │  │ Android App  │  │  iOS Widget  │      │
│  │ (Flutter)    │  │ (Flutter)    │  │ (SwiftUI)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌──────────────┐                                           │
│  │Android Widget│                                           │
│  │(Jetpack)     │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
                            ▲ │
                            │ ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Naver Maps   │  │Naver Transit │  │  Seoul Bus   │      │
│  │     API      │  │     API      │  │     API      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌──────────────┐                                           │
│  │   SQLite     │ (로컬 데이터베이스, 서버 불필요)         │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 핵심 기술 스택

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Frontend** | Flutter 3.x (Dart) | 크로스 플랫폼 개발 효율성, 빠른 UI 렌더링 |
| **iOS Widget** | SwiftUI + WidgetKit | 홈 화면 위젯 (iOS 14+) |
| **Android Widget** | Jetpack Glance | 홈 화면 위젯 (Flutter 호환성 우수) |
| **Maps (자차)** | Naver Directions API | 한국 시장 정확도 최우선, 실시간 교통 |
| **Maps (대중교통)** | Naver Transit API | 버스/지하철 실시간 경로 |
| **Database** | Supabase (PostgreSQL) | 실시간 동기화, 확장성, Row Level Security |
| **Notifications** | flutter_local_notifications | 로컬 푸시 알림 |
| **State Management** | Provider / Riverpod | 반응형 상태 관리 |

### 2.3 API 연동 예시 코드

#### Naver Maps - 자차 경로 탐색

```dart
// lib/services/route_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  static const String _baseUrl = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving';

  /// 자차 경로 탐색 및 소요 시간 계산
  ///
  /// **비즈니스 규칙**: 실시간 교통 반영 필수
  /// **Context**: 사용자가 목적지 입력 시 자동 호출
  static Future<RouteResult> calculateRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?start=${origin.longitude},${origin.latitude}'
          '&goal=${destination.longitude},${destination.latitude}'
          '&option=trafast'), // 실시간 빠른길
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['route']['trafast'][0];

      return RouteResult(
        duration: route['summary']['duration'] ~/ 1000, // 초 → 분
        distance: route['summary']['distance'] ~/ 1000, // 미터 → km
        trafficLevel: _parseTrafficLevel(route['summary']['trafficColor']),
        path: route['path'], // 경로 좌표
      );
    } else {
      throw Exception('경로 탐색 실패: ${response.statusCode}');
    }
  }

  static TrafficLevel _parseTrafficLevel(int colorCode) {
    switch (colorCode) {
      case 1: return TrafficLevel.smooth; // 원활
      case 2: return TrafficLevel.slow; // 지체
      case 3: return TrafficLevel.congested; // 정체
      default: return TrafficLevel.unknown;
    }
  }
}
```

#### Naver Transit - 대중교통 경로 탐색

```dart
// lib/services/transit_service.dart
class TransitService {
  static const String _baseUrl = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/transit';

  /// 대중교통 경로 탐색 (버스/지하철 통합)
  ///
  /// **비즈니스 규칙**: 환승 시간 자동 반영 (도보 5분, 버스 3분)
  static Future<TransitRoute> getTransitRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?start=${origin.longitude},${origin.latitude}'
          '&goal=${destination.longitude},${destination.latitude}'),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['route']['trafast'][0];

      return TransitRoute(
        totalDuration: route['summary']['duration'] ~/ 60, // 초 → 분
        segments: _parseSegments(route['legs']),
      );
    } else {
      throw Exception('대중교통 경로 탐색 실패');
    }
  }

  static List<TransitSegment> _parseSegments(List<dynamic> legs) {
    return legs.map((leg) {
      return TransitSegment(
        type: leg['mode'], // 'BUS', 'SUBWAY', 'WALK'
        name: leg['route']?['name'], // '버스 472번', '지하철 2호선'
        duration: leg['duration'] ~/ 60,
        distance: leg['distance'],
      );
    }).toList();
  }
}
```

### 2.4 역산 스케줄링 알고리즘

```dart
// lib/services/scheduler_service.dart
class SchedulerService {
  /// 역산 스케줄링: 도착 시간 → 출발 시간 계산 (4가지 버퍼 반영)
  ///
  /// **알고리즘**:
  /// 출발 시간 = 도착 시간 - (일정 마무리 + 일찍 도착 + 이동시간 + 오차율 + 외출 준비)
  ///
  /// **4가지 버퍼 시간**:
  /// 1. previousTaskWrapUpMinutes: 이전 일정 마무리 시간 (기본 5분)
  /// 2. earlyArrivalBufferMinutes: 일찍 도착하고 싶은 시간 (기본 10분)
  /// 3. travelUncertaintyRate: 이동 오차율 (기본 20%, 이동시간에 비례)
  /// 4. preparationMinutes: 외출 준비 시간 (사용자 설정, 기본 15분)
  static DateTime calculateDepartureTime({
    required DateTime arrivalTime,
    required int travelDurationMinutes,
    required int preparationMinutes,
    int previousTaskWrapUpMinutes = 5,      // 1. 일정 마무리
    int earlyArrivalBufferMinutes = 10,     // 2. 일찍 도착 버퍼
    double travelUncertaintyRate = 0.2,     // 3. 이동 오차율 (20%)
  }) {
    // 3. 이동 시간 + 오차율
    final travelWithUncertainty = travelDurationMinutes +
                                   (travelDurationMinutes * travelUncertaintyRate).ceil();

    // 총 소요 시간 계산
    final totalMinutes = previousTaskWrapUpMinutes +      // 1. 이전 일정 마무리
                         earlyArrivalBufferMinutes +      // 2. 일찍 도착 버퍼
                         travelWithUncertainty +          // 3. 이동 시간 + 오차율
                         preparationMinutes;              // 4. 외출 준비

    return arrivalTime.subtract(Duration(minutes: totalMinutes));
  }

  /// Adaptive Polling: 시간대별 API 호출 주기 조정
  ///
  /// **최적화 전략**:
  /// - 1시간 전: 15분 간격
  /// - 30분 전: 5분 간격
  /// - 10분 전: 3분 간격
  static Duration getPollingInterval(DateTime departureTime) {
    final timeUntilDeparture = departureTime.difference(DateTime.now());

    if (timeUntilDeparture.inMinutes > 60) {
      return Duration(minutes: 15);
    } else if (timeUntilDeparture.inMinutes > 30) {
      return Duration(minutes: 5);
    } else {
      return Duration(minutes: 3);
    }
  }
}
```

### 2.5 홈 위젯 구현

#### Android Widget (Jetpack Glance)

```kotlin
// android/app/src/main/kotlin/com/gonow/widget/GoNowWidget.kt
@Composable
fun GoNowWidgetContent(context: Context) {
    val nextSchedule = getNextScheduleFromDB(context)

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color.White)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Horizontal.SpaceBetween
        ) {
            Text("Go Now", style = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.Bold))
            Image(provider = ImageProvider(R.drawable.ic_settings), contentDescription = "Settings")
        }

        Spacer(modifier = GlanceModifier.height(8.dp))

        Text(
            text = nextSchedule.title,
            style = TextStyle(fontSize = 14.sp)
        )

        Text(
            text = "${nextSchedule.remainingMinutes}분 남음",
            style = TextStyle(fontSize = 24.sp, fontWeight = FontWeight.Bold, color = getTimeColor(nextSchedule.remainingMinutes))
        )

        Text(
            text = "${nextSchedule.departureTime.format('HH:mm')}까지 출발",
            style = TextStyle(fontSize = 12.sp, color = Color.Gray)
        )
    }
}

// WorkManager로 15분마다 자동 업데이트
class WidgetUpdateWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        GoNowWidget().update(applicationContext)
        return Result.success()
    }
}
```

#### iOS Widget (WidgetKit)

```swift
// ios/Runner/GoNowWidget/GoNowWidget.swift
struct GoNowWidgetProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<GoNowWidgetEntry>) -> Void) {
        // SharedUserDefaults에서 일정 데이터 가져오기
        let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.app")
        let nextSchedule = sharedDefaults?.dictionary(forKey: "nextSchedule")

        var entries: [GoNowWidgetEntry] = []
        let currentDate = Date()

        // 15분마다 업데이트 스케줄 생성
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 15, to: currentDate)!
            let entry = GoNowWidgetEntry(date: entryDate, schedule: nextSchedule)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct GoNowWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Go Now")
                    .font(.headline)
                Spacer()
                Image(systemName: "gearshape")
                    .font(.caption)
            }

            Text(entry.schedule.title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(entry.schedule.remainingMinutes)분 남음")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(getTimeColor(entry.schedule.remainingMinutes))

            Text("\(entry.schedule.departureTime)까지 출발")
                .font(.caption)
                .foregroundColor(.secondary)

            if entry.schedule.isTransit {
                Text("🚇 \(entry.schedule.transitInfo)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    func getTimeColor(_ minutes: Int) -> Color {
        if minutes > 30 { return .green }
        else if minutes > 10 { return .orange }
        else { return .red }
    }
}
```

#### Flutter ↔ Widget 데이터 공유

```dart
// lib/services/widget_service.dart
import 'package:flutter/services.dart';

class WidgetService {
  static const platform = MethodChannel('com.gonow.app/widget');

  /// 위젯에 다음 일정 데이터 전달
  ///
  /// **플랫폼별 구현**:
  /// - Android: SharedPreferences
  /// - iOS: SharedUserDefaults (App Groups)
  static Future<void> updateWidget(Trip nextTrip) async {
    final data = {
      'title': nextTrip.title,
      'departureTime': nextTrip.departureTime.toIso8601String(),
      'remainingMinutes': nextTrip.departureTime.difference(DateTime.now()).inMinutes,
      'isTransit': nextTrip.isTransit,
      'transitInfo': nextTrip.transitInfo,
    };

    try {
      await platform.invokeMethod('updateWidget', data);
    } on PlatformException catch (e) {
      print("Failed to update widget: '${e.message}'.");
    }
  }
}
```

### 2.6 Database Schema (Supabase PostgreSQL)

#### ER Diagram 개념도

```
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│ auth.users  │──1:1─│    users     │──1:N─│   schedules     │
│ (Supabase)  │      │ (프로필)     │      │   (일정)        │
└─────────────┘      └──────────────┘      └─────────────────┘
                            │                       │
                           1:N                     N:1
                            │                       │
                     ┌──────────────┐      ┌──────────────┐
                     │buffer_settings│      │    places    │
                     │ (버퍼 설정)   │      │  (자주 가는  │
                     └──────────────┘      │    장소)     │
                                            └──────────────┘
                     ┌──────────────┐
                     │notifications │
                     │ (알림 이력)  │
                     └──────────────┘
```

#### 테이블 구조

##### 1. users (사용자 프로필)
```sql
-- Supabase의 auth.users와 1:1 관계
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  avatar_url TEXT,

  -- 구독 정보
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
  subscription_expires_at TIMESTAMPTZ,

  -- 앱 설정
  preferred_transport TEXT DEFAULT 'transit' CHECK (preferred_transport IN ('car', 'transit', 'auto')),
  default_home_location JSONB, -- {lat: number, lng: number, address: string}

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW()
);

-- 자동 updated_at 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription ON users(subscription_tier, subscription_expires_at);
```

##### 2. schedules (일정)
```sql
-- 사용자의 일정 정보
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 일정 기본 정보
  title TEXT NOT NULL,
  destination_address TEXT NOT NULL,
  destination_lat DOUBLE PRECISION NOT NULL,
  destination_lng DOUBLE PRECISION NOT NULL,

  -- 시간 정보
  arrival_time TIMESTAMPTZ NOT NULL, -- 도착 목표 시간
  departure_time TIMESTAMPTZ NOT NULL, -- 역산된 출발 시간

  -- 경로 정보
  transport_mode TEXT NOT NULL CHECK (transport_mode IN ('car', 'transit')),
  route_data JSONB, -- Naver API 응답 저장 {duration, distance, path, transitInfo 등}
  travel_duration_minutes INTEGER NOT NULL, -- 이동 소요 시간

  -- 버퍼 시간 (분 단위)
  preparation_minutes INTEGER DEFAULT 15, -- 외출 준비 시간
  early_arrival_buffer_minutes INTEGER DEFAULT 10, -- 일찍 도착 버퍼
  travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2, -- 이동 오차율 (20%)
  previous_task_wrapup_minutes INTEGER DEFAULT 5, -- 일정 마무리 시간

  -- 상태 관리
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  is_cancelled BOOLEAN DEFAULT FALSE,

  -- 알림 설정
  notification_enabled BOOLEAN DEFAULT TRUE,
  notification_sent_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_schedules_user_id ON schedules(user_id);
CREATE INDEX idx_schedules_arrival_time ON schedules(arrival_time);
CREATE INDEX idx_schedules_user_arrival ON schedules(user_id, arrival_time) WHERE is_completed = FALSE AND is_cancelled = FALSE;
CREATE INDEX idx_schedules_notification ON schedules(notification_enabled, notification_sent_at) WHERE is_completed = FALSE;

-- updated_at 트리거
CREATE TRIGGER update_schedules_updated_at
BEFORE UPDATE ON schedules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

##### 3. places (자주 가는 장소)
```sql
-- 사용자의 즐겨찾기 장소
CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 장소 정보
  name TEXT NOT NULL, -- "회사", "집", "헬스장" 등
  address TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,

  -- 카테고리
  category TEXT CHECK (category IN ('home', 'work', 'gym', 'cafe', 'hospital', 'etc')),

  -- 사용 통계
  visit_count INTEGER DEFAULT 0,
  last_visited_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_places_user_id ON places(user_id);
CREATE INDEX idx_places_category ON places(category);
CREATE UNIQUE INDEX idx_places_user_name ON places(user_id, name); -- 같은 이름 중복 방지

-- updated_at 트리거
CREATE TRIGGER update_places_updated_at
BEFORE UPDATE ON places
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

##### 4. buffer_settings (버퍼 설정 프리셋)
```sql
-- 사용자의 4가지 버퍼 시간 프리셋
CREATE TABLE buffer_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 프리셋 정보
  preset_name TEXT NOT NULL, -- "평일 출근", "주말 여유", "긴급" 등
  is_default BOOLEAN DEFAULT FALSE,

  -- 4가지 버퍼 시간 (분 단위)
  preparation_minutes INTEGER DEFAULT 15 CHECK (preparation_minutes BETWEEN 5 AND 60),
  early_arrival_buffer_minutes INTEGER DEFAULT 10 CHECK (early_arrival_buffer_minutes BETWEEN 0 AND 30),
  travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2 CHECK (travel_uncertainty_rate BETWEEN 0 AND 0.5),
  previous_task_wrapup_minutes INTEGER DEFAULT 5 CHECK (previous_task_wrapup_minutes BETWEEN 0 AND 20),

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_buffer_settings_user_id ON buffer_settings(user_id);
CREATE UNIQUE INDEX idx_buffer_settings_user_name ON buffer_settings(user_id, preset_name);
CREATE INDEX idx_buffer_settings_default ON buffer_settings(user_id, is_default) WHERE is_default = TRUE;

-- 사용자당 기본 프리셋 1개만 허용
CREATE UNIQUE INDEX idx_buffer_settings_single_default ON buffer_settings(user_id) WHERE is_default = TRUE;

-- updated_at 트리거
CREATE TRIGGER update_buffer_settings_updated_at
BEFORE UPDATE ON buffer_settings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

##### 5. notifications (알림 이력)
```sql
-- 발송된 알림 로그
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  schedule_id UUID REFERENCES schedules(id) ON DELETE SET NULL,

  -- 알림 정보
  notification_type TEXT NOT NULL CHECK (notification_type IN ('departure_reminder', 'traffic_alert', 'early_warning')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,

  -- 발송 정보
  scheduled_at TIMESTAMPTZ NOT NULL, -- 발송 예정 시간
  sent_at TIMESTAMPTZ, -- 실제 발송 시간
  is_sent BOOLEAN DEFAULT FALSE,

  -- 사용자 반응
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  is_clicked BOOLEAN DEFAULT FALSE,
  clicked_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_schedule_id ON notifications(schedule_id);
CREATE INDEX idx_notifications_sent ON notifications(is_sent, scheduled_at);
CREATE INDEX idx_notifications_pending ON notifications(is_sent, scheduled_at) WHERE is_sent = FALSE;
```

##### 6. usage_stats (사용 통계 - AI 학습용)
```sql
-- Phase 2/3에서 AI 개인화에 사용할 데이터
CREATE TABLE usage_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  schedule_id UUID REFERENCES schedules(id) ON DELETE SET NULL,

  -- 실제 이동 데이터
  actual_departure_time TIMESTAMPTZ,
  actual_arrival_time TIMESTAMPTZ,
  actual_travel_duration_minutes INTEGER,

  -- 예측 vs 실제 비교
  predicted_duration_minutes INTEGER,
  duration_diff_minutes INTEGER, -- 실제 - 예측

  -- 버퍼 사용률
  buffer_used_minutes INTEGER, -- 실제로 사용한 버퍼 시간
  was_late BOOLEAN DEFAULT FALSE,
  late_by_minutes INTEGER,

  -- 환경 요인
  weather_condition TEXT, -- Phase 3에서 추가
  traffic_level TEXT CHECK (traffic_level IN ('smooth', 'slow', 'congested')),
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
  time_of_day TEXT CHECK (time_of_day IN ('morning', 'afternoon', 'evening', 'night')),

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_usage_stats_user_id ON usage_stats(user_id);
CREATE INDEX idx_usage_stats_schedule_id ON usage_stats(schedule_id);
CREATE INDEX idx_usage_stats_late ON usage_stats(was_late, created_at);
CREATE INDEX idx_usage_stats_analysis ON usage_stats(user_id, day_of_week, time_of_day);
```

#### Row Level Security (RLS) 정책

```sql
-- 1. users 테이블: 본인만 조회/수정 가능
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- 2. schedules 테이블: 본인 일정만 CRUD
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own schedules"
ON schedules FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own schedules"
ON schedules FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own schedules"
ON schedules FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own schedules"
ON schedules FOR DELETE
USING (auth.uid() = user_id);

-- 3. places 테이블: 본인 장소만 CRUD
ALTER TABLE places ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own places"
ON places FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. buffer_settings 테이블: 본인 설정만 CRUD
ALTER TABLE buffer_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own buffer settings"
ON buffer_settings FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. notifications 테이블: 본인 알림만 조회/수정
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);

-- 6. usage_stats 테이블: 본인 통계만 조회 (INSERT는 서버/앱에서만)
ALTER TABLE usage_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usage stats"
ON usage_stats FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage stats"
ON usage_stats FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

#### Supabase Storage Buckets

```sql
-- 프로필 이미지 저장용 버킷
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- 프로필 이미지 RLS 정책
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Flutter + Supabase 연동 예시

```dart
// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  /// 사용자 프로필 가져오기
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  /// 다음 일정 가져오기 (도착 시간 기준 오름차순)
  static Future<List<Map<String, dynamic>>> getUpcomingSchedules(String userId) async {
    final now = DateTime.now().toIso8601String();

    final response = await client
        .from('schedules')
        .select()
        .eq('user_id', userId)
        .eq('is_completed', false)
        .eq('is_cancelled', false)
        .gte('arrival_time', now)
        .order('arrival_time', ascending: true)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 일정 추가
  static Future<Map<String, dynamic>> createSchedule({
    required String userId,
    required String title,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String transportMode,
    required int travelDurationMinutes,
    Map<String, dynamic>? routeData,
  }) async {
    final response = await client
        .from('schedules')
        .insert({
          'user_id': userId,
          'title': title,
          'destination_address': destinationAddress,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'arrival_time': arrivalTime.toIso8601String(),
          'departure_time': departureTime.toIso8601String(),
          'transport_mode': transportMode,
          'travel_duration_minutes': travelDurationMinutes,
          'route_data': routeData,
        })
        .select()
        .single();

    return response;
  }

  /// 자주 가는 장소 저장
  static Future<void> saveFavoritePlace({
    required String userId,
    required String name,
    required String address,
    required double lat,
    required double lng,
    String? category,
  }) async {
    await client.from('places').upsert({
      'user_id': userId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'category': category ?? 'etc',
      'visit_count': 1,
      'last_visited_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,name');
  }

  /// 실시간 일정 변경 감지 (Realtime Subscription)
  static Stream<List<Map<String, dynamic>>> watchSchedules(String userId) {
    return client
        .from('schedules')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('arrival_time');
  }
}
```

---

## 📱 3. MVP Screens / 화면 설계

### 3.1 대시보드 (Main Screen)

**목적**: 다음 일정의 출발 시간 카운트다운 표시

```
┌─────────────────────────────────────┐
│  [☰]    Go Now           [👤]       │
│                                     │
│       🏢 강남역 오피스               │
│      오전 10:00 도착 목표            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │        🚨 15분 남음         │   │
│  │      ●●●●●●●●○○             │   │
│  │                             │   │
│  │   09:25까지 집을 나가세요   │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │     [출발했어요] 버튼         │ │
│  └───────────────────────────────┘ │
│                                     │
│  ─── 선택한 경로 ───                │
│                                     │
│  🚇 대중교통 (32분)                 │
│  ├─ 🚌 버스 472번 (15분)            │
│  │   └─ 3분 후 도착                │
│  ├─ 🚶 도보 환승 (3분)              │
│  └─ 🚇 지하철 2호선 (12분)          │
│                                     │
│  [경로 변경]                        │
│                                     │
│  ─── 이후 일정 ───                  │
│                                     │
│  14:00 📞 클라이언트 미팅           │
│  16:30 💻 팀 회의                   │
│                                     │
└─────────────────────────────────────┘
```

**기능 요구사항**:
- 다음 일정의 출발 시간 카운트다운
- 시간대별 색상 변경 (초록→주황→빨강)
- 대중교통 경로 표시 (버스 도착 시간 실시간 반영)
- "출발했어요" 버튼 (Phase 1에서는 수동 체크인)
- 이후 일정 3개 미리보기

### 3.2 스케줄 추가 화면

**목적**: 새로운 일정 등록

```
┌─────────────────────────────────────┐
│  [← 뒤로]    일정 추가               │
│                                     │
│  단계 1/3: 목적지 입력              │
│  ●○○                                │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🔍 목적지 검색                │ │
│  └───────────────────────────────┘ │
│                                     │
│  📍 최근 장소:                      │
│  - 강남역 오피스                    │
│  - 서울대학교                       │
│  - 코엑스                           │
│                                     │
│  🏷️ 즐겨찾기:                       │
│  - 🏠 집                            │
│  - 🏢 회사                          │
│  - 💪 헬스장                        │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        다음 단계 →            │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  [← 뒤로]    일정 추가               │
│                                     │
│  단계 2/3: 시간 설정                │
│  ●●○                                │
│                                     │
│  도착 시간                           │
│  ┌───────────────────────────────┐ │
│  │  2026-01-15    10:00 AM       │ │
│  └───────────────────────────────┘ │
│                                     │
│  ⭐ 이동 수단 선택                  │
│  ┌───────────────────────────────┐ │
│  │  [🚗 자차]  [🚇 대중교통]      │ │
│  └───────────────────────────────┘ │
│                                     │
│  이동 시간 (자동 계산)              │
│  🚗 자차: 25분 (실시간 교통)        │
│  또는                               │
│  🚇 대중교통: 32분                  │
│     - 버스 472번: 15분              │
│     - 지하철 2호선: 12분            │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        다음 단계 →            │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  [← 뒤로]    일정 추가               │
│                                     │
│  단계 3/3: 버퍼 시간 설정 (4가지)   │
│  ●●●                                │
│                                     │
│  1️⃣ 외출 준비 시간                  │
│  ┌───────────────────────────────┐ │
│  │      15분                     │ │
│  │  ◀────────────●──────▶        │ │
│  │  (5분 ~ 60분)                 │ │
│  └───────────────────────────────┘ │
│  💡 옷 입기, 짐 챙기기 등           │
│                                     │
│  2️⃣ 이동 오차율                     │
│  ┌───────────────────────────────┐ │
│  │      20%                      │ │
│  │  ◀────────●──────────▶        │ │
│  │  (0% ~ 50%)                   │ │
│  └───────────────────────────────┘ │
│  💡 교통 예측 불확실성, 신호 대기   │
│                                     │
│  3️⃣ 일찍 도착 버퍼                  │
│  ┌───────────────────────────────┐ │
│  │      10분                     │ │
│  │  ◀────────●──────────▶        │ │
│  │  (0분 ~ 30분)                 │ │
│  └───────────────────────────────┘ │
│  💡 약속 시간 전 여유롭게 도착      │
│                                     │
│  4️⃣ 일정 마무리 시간                │
│  ┌───────────────────────────────┐ │
│  │      5분                      │ │
│  │  ◀──●────────────────▶        │ │
│  │  (0분 ~ 20분)                 │ │
│  └───────────────────────────────┘ │
│  💡 이전 일정 정리 후 출발          │
│                                     │
│  ─── 최종 계산 ───                  │
│                                     │
│  📍 강남역 오피스                   │
│  🕐 도착 시간: 10:00 AM             │
│  🚇 이동 시간: 32분 (대중교통)      │
│  📊 오차율: +6분 (20%)              │
│  👕 외출 준비: 15분                 │
│  ⏰ 일찍 도착: 10분                 │
│  📝 일정 마무리: 5분                │
│                                     │
│  ⭐ 출발 시간: 08:52 AM             │
│  (총 소요: 68분)                    │
│                                     │
│  ┌───────────────────────────────┐ │
│  │        일정 저장 ✅           │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 3.3 월간 캘린더

**목적**: 한 달 일정 한눈에 보기

```
┌─────────────────────────────────────┐
│  [☰]    2026년 1월          [+]     │
│                                     │
│  일  월  화  수  목  금  토          │
│           1   2   3   4   5         │
│   6   7   8   9  10  11  12         │
│  13  14  15  16  17  18  19         │
│  20  21  22  23  24  25  26         │
│  27  28  29  30  31                 │
│                                     │
│  ● 15일 (수) - 3개 일정             │
│                                     │
│  09:00 🏢 출근                      │
│  14:00 📞 클라이언트 미팅           │
│  16:30 💻 팀 회의                   │
│                                     │
└─────────────────────────────────────┘
```

### 3.4 설정 화면

**목적**: 사용자 기본 설정

```
┌─────────────────────────────────────┐
│  [← 뒤로]    설정                    │
│                                     │
│  기본 버퍼 시간 설정 (4가지)        │
│  ├─ 1️⃣ 외출 준비 시간: 15분         │
│  ├─ 2️⃣ 이동 오차율: 20%             │
│  ├─ 3️⃣ 일찍 도착 버퍼: 10분         │
│  ├─ 4️⃣ 일정 마무리 시간: 5분        │
│  └─ 기본 이동 수단: 대중교통        │
│                                     │
│  알림 설정                           │
│  ├─ 30분 전 알림: ✅                │
│  ├─ 10분 전 긴급 알림: ✅           │
│  └─ 알림 소리: 기본                 │
│                                     │
│  계정 관리                           │
│  ├─ 프로필 수정                     │
│  ├─ 비밀번호 변경                   │
│  └─ 로그아웃                        │
│                                     │
│  앱 정보                             │
│  ├─ 버전: 1.0.0                     │
│  ├─ 이용약관                        │
│  └─ 개인정보 처리방침               │
│                                     │
└─────────────────────────────────────┘
```

---

## 💼 4. Business Model / 비즈니스 모델

### 4.1 수익 구조 (Freemium)

#### 무료 플랜 (Free Tier)

- 일 3개 일정 제한
- 기본 알림
- 광고 표시 (비침해적)

#### 프리미엄 플랜 (Premium Tier)

**가격**: 월 4,900원 / 연 49,000원 (17% 할인)

**기능**:
- ✅ 무제한 일정 관리
- ✅ 광고 제거
- ✅ 고급 통계 및 패턴 분석
- ✅ AI 기반 준비 시간 추천
- ✅ 우선 고객 지원
- ✅ 데이터 백업 및 동기화

#### 부가 수익

- **제휴 수수료**: 카카오 택시/T맵 호출 딥링크 커미션
- **B2B 라이선스**: 기업 출퇴근 관리 솔루션
- **데이터 인사이트**: 익명화된 교통 패턴 데이터 판매 (선택적)

### 4.2 수익 예측 (Phase 2 기준)

**MAU 10,000명 기준**:
- 유료 전환율 10% = 1,000명
- 월 구독 수익: 4,900원 × 1,000명 = 4,900,000원/월
- 연간 수익: 58,800,000원

**MAU 50,000명 기준** (Phase 3 목표):
- 유료 전환율 15% = 7,500명
- 월 구독 수익: 4,900원 × 7,500명 = 36,750,000원/월
- 연간 수익: 441,000,000원

### 4.3 앱스토어 정책 준수

✅ **Apple/Google 정책 완전 준수**:
- In-App Purchase (IAP) 사용
- 앱스토어 30% 수수료 수용
- 외부 PG 사용 없음 → 심사 리스크 제로
- 사행성 규제 해당 없음
- 소비자 보호법 이슈 없음

❌ **폐기된 외부 PG 방식**:
- Stripe/토스페이먼츠 연동 (앱스토어 정책 위반)
- 페널티 결제 시스템 (법적 리스크)
- 외부 웹사이트 결제 우회 (Apple 정책 위반)

---

## 📅 5. Development Plan / 개발 계획

### 5.1 계층적 실행 계획 (Phase → Task → SubTask)

**MVP 출시일**: 2026년 1월 31일 (25일 개발 기간)
**시작일**: 2026년 1월 7일

---

## 📊 Phase 1: Foundation & UI (Day 1~5)

**목표**: 프로젝트 기반 구축 및 6개 핵심 화면 UI 완성
**기간**: 5일
**담당**: 개발자 1, 개발자 2, PM, 디자이너

### Task 1.1: 프로젝트 초기 설정 (Day 1)
**담당**: 개발자 1 + PM
**소요**: 1일

#### SubTask 1.1.1: API 키 발급 (Critical Path)
- [x] Naver Cloud Platform 회원가입
- [x] Naver API 키 발급 (Maps + Transit 공통)
- **담당**: PM
- **소요**: 1시간
- **산출물**: API 키 문서 (.env 파일)
- **완료 기준**: Naver API 키 정상 작동 확인

#### SubTask 1.1.2: Supabase 프로젝트 설정 (Critical Path)
- [x] Supabase 계정 생성 (https://supabase.com)
- [x] 로컬 개발 환경 설정 (`supabase start`)
- [x] 데이터베이스 스키마 생성 (Section 2.6 참조)
  - [x] users 테이블
  - [x] schedules 테이블
  - [x] places 테이블
  - [x] buffer_settings 테이블
  - [x] notifications 테이블
  - [x] usage_stats 테이블
- [x] Row Level Security (RLS) 정책 설정
- [x] Storage 버킷 생성 (avatars)
- [x] API 키 및 URL 저장 (.env 파일)
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: 없음
- **산출물**: Supabase 프로젝트 + SQL 스크립트 파일
- **완료 기준**:
  - 모든 테이블 생성 완료
  - RLS 정책 활성화
  - Supabase Studio에서 데이터 삽입/조회 테스트 성공

#### SubTask 1.1.3: Flutter 프로젝트 생성
- [x] Flutter SDK 3.x 설치 확인
- [x] `flutter create go_now` 실행
- [x] 프로젝트 구조 설정 (lib/screens, lib/services, lib/models)
- [x] pubspec.yaml 초기 의존성 추가
  - [x] supabase_flutter
  - [x] provider
  - [x] flutter_local_notifications
  - [x] http
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: 없음
- **산출물**: 기본 Flutter 프로젝트
- **완료 기준**: `flutter run` 성공

#### SubTask 1.1.4: Git 저장소 설정
- [x] GitHub 저장소 생성
- [x] .gitignore 설정 (Flutter 템플릿 + .env)
- [x] README.md 작성
- [x] 첫 커밋 및 푸시
- **담당**: 개발자 1
- **소요**: 30분
- **의존성**: SubTask 1.1.3
- **산출물**: Git 저장소
- **완료 기준**: 원격 저장소에 코드 푸시 완료

#### SubTask 1.1.5: 디자인 시스템 정의
- [ ] Figma 프로젝트 생성 (디자이너 작업 대기 중)
- [x] 색상 팔레트 정의 (초록/주황/빨강 시스템) - `app_theme.dart`로 구현
- [x] 타이포그래피 설정 - Material Design 3 적용
- [x] 컴포넌트 라이브러리 구성 - 버튼/입력 필드 스타일 정의
- **담당**: 디자이너 (개발자가 임시 구현)
- **소요**: 4시간
- **산출물**: `lib/utils/app_theme.dart` (Figma는 추후 통합)
- **완료 기준**: 개발자가 디자인 토큰 추출 가능 (✅ 부분 완료)

---

### Task 1.2: 인증 화면 UI 구현 (Day 2)
**담당**: 개발자 1
**소요**: 1일

#### SubTask 1.2.1: 로그인 화면 UI
- [x] 이메일/비밀번호 입력 폼 (유효성 검사 포함)
- [x] 소셜 로그인 버튼 (Google, Apple, Kakao)
- [x] "비밀번호 찾기" 링크
- [x] "회원가입" 링크
- [x] AuthProvider 연동
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: Task 1.1.5 (디자인 시스템)
- **산출물**: `lib/screens/auth/login_screen.dart`
- **완료 기준**: ✅ Material Design 3 기반 구현 완료

#### SubTask 1.2.2: 회원가입 화면 UI (3단계)
- [x] Step 1: 이메일/비밀번호 입력 + 소셜 회원가입 버튼
- [x] Step 2: 이름/전화번호 입력 (선택사항)
- [x] Step 3: 약관 동의 (필수/선택)
- [x] 단계 표시 인디케이터 프로그레스 바
- [x] AuthProvider 연동
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: SubTask 1.2.1
- **산출물**: `lib/screens/auth/signup_screen.dart`
- **완료 기준**: ✅ 3단계 네비게이션 및 폼 유효성 검사 완료

#### SubTask 1.2.3: 인증 상태 관리
- [x] Provider 설정 (MultiProvider로 앱 전역 상태 관리)
- [x] AuthState 클래스 생성 (unauthenticated, authenticating, authenticated)
- [x] Supabase Auth 완전 연동
  - [x] 이메일/비밀번호 로그인 (`signInWithEmail`)
  - [x] 이메일/비밀번호 회원가입 (`signUpWithEmail`)
  - [x] 소셜 로그인 (`signInWithProvider` - Google, Apple)
  - [x] 로그아웃 (`signOut`)
  - [x] 비밀번호 재설정 (`resetPassword`)
  - [x] 프로필 업데이트 (`updateProfile`)
- [x] 한글 에러 메시지 처리
- [x] 실시간 인증 상태 변경 감지
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: SubTask 1.2.2
- **산출물**: `lib/providers/auth_provider.dart`
- **완료 기준**: ✅ Supabase Auth 완전 통합 완료

---

### Task 1.3: 대시보드 UI 구현 (Day 3)
**담당**: 개발자 2
**소요**: 1일

#### SubTask 1.3.1: 카운트다운 컴포넌트
- [x] 시간 표시 (시/분/초)
- [x] 프로그레스 바 (선형 + 도트 10개)
- [x] 색상 시스템 (초록→주황→빨강)
- [x] 애니메이션 효과 (긴급 상태 펄스 애니메이션)
- [x] 시간 상태 메시지 ("여유 있어요", "서둘러야 해요", "지금 출발하세요!")
- [x] 출발/도착 시간 표시
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: Task 1.1.5 (디자인 시스템)
- **산출물**: `lib/widgets/countdown_widget.dart`
- **완료 기준**: ✅ 실시간 카운트다운 및 색상 전환 애니메이션 완료

#### SubTask 1.3.2: 경로 표시 컴포넌트
- [x] 대중교통 경로 리스트 (버스/지하철/도보)
- [x] 교통수단별 아이콘 및 색상
- [x] 노선 정보 표시 (버스 번호, 지하철 호선)
- [x] 실시간 버스 도착 정보 표시 (UI 구현)
- [x] 경로 변경 버튼
- [x] 총 이동 시간 및 거리 표시
- [x] RouteStep 모델 생성 (`lib/models/route_step.dart`)
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: SubTask 1.3.1
- **산출물**: `lib/widgets/route_display_widget.dart`, `lib/models/route_step.dart`
- **완료 기준**: ✅ 정적 데이터로 UI 렌더링 완료

#### SubTask 1.3.3: 대시보드 메인 화면
- [x] 환영 메시지 (사용자 이름 표시)
- [x] 다음 일정 정보 카드
- [x] 카운트다운 위젯 통합
- [x] 경로 위젯 통합
- [x] "출발했어요" 버튼 (출발 확인 다이얼로그)
- [x] 이후 일정 3개 미리보기
- [x] 일정 추가 FAB (Floating Action Button)
- [x] Pull-to-refresh 지원
- [x] AppBar (설정 아이콘)
- [x] 로그인/회원가입 성공 시 대시보드로 네비게이션
- **담당**: 개발자 1
- **소요**: 1시간
- **의존성**: SubTask 1.3.1, 1.3.2
- **산출물**: `lib/screens/dashboard/dashboard_screen.dart`
- **완료 기준**: ✅ Material Design 3 기반 대시보드 UI 완료

---

### Task 1.4: 스케줄 추가 화면 UI 구현 (Day 4)
**담당**: 개발자 2
**소요**: 1일

#### SubTask 1.4.1: Step 1 - 목적지 입력
- [x] 검색 입력창
- [x] 최근 장소 리스트
- [x] 즐겨찾기 리스트
- [x] 다음 단계 버튼
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: Task 1.1.5
- **산출물**: `lib/screens/schedule/add_schedule_screen.dart` (4-step integrated)
- **완료 기준**: 장소 선택 시 다음 단계 이동

#### SubTask 1.4.2: Step 2 - 시간 및 이동 수단 설정
- [x] 날짜/시간 선택 위젯
- [x] 이동 수단 선택 (자차/대중교통)
- [x] 이동 시간 자동 계산 표시 (정적)
- [x] 다음 단계 버튼
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 1.4.1
- **산출물**: `lib/screens/schedule/add_schedule_screen.dart` (4-step integrated)
- **완료 기준**: 시간 선택 및 화면 전환

#### SubTask 1.4.3: Step 3 - 4가지 버퍼 시간 설정
- [x] 외출 준비 시간 슬라이더
- [x] 이동 오차율 슬라이더
- [x] 일찍 도착 버퍼 슬라이더
- [x] 일정 마무리 시간 슬라이더
- [x] 최종 계산 요약 표시 (Step 4)
- [x] 저장 버튼 (Step 4)
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 1.4.2
- **산출물**: `lib/screens/schedule/add_schedule_screen.dart` (4-step integrated)
- **완료 기준**: 모든 슬라이더 작동, 계산 요약 표시, 저장 버튼 구현

---

### Task 1.5: 캘린더 및 설정 화면 UI 구현 (Day 5)
**담당**: 개발자 1
**소요**: 1일

#### SubTask 1.5.1: 월간 캘린더 UI
- [ ] 캘린더 그리드 (table_calendar 패키지)
- [ ] 날짜별 일정 개수 표시
- [ ] 선택된 날짜의 일정 리스트
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: Task 1.1.5
- **산출물**: `lib/screens/calendar/calendar_screen.dart`
- **완료 기준**: 캘린더 렌더링 및 날짜 선택

#### SubTask 1.5.2: 설정 화면 UI
- [ ] 4가지 버퍼 시간 기본값 설정
- [ ] 알림 설정 (30분 전, 10분 전)
- [ ] 계정 관리 (프로필, 비밀번호 변경, 로그아웃)
- [ ] 앱 정보 (버전, 약관, 개인정보 처리방침)
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: SubTask 1.5.1
- **산출물**: `lib/screens/settings/settings_screen.dart`
- **완료 기준**: 모든 설정 항목 렌더링

#### SubTask 1.5.3: UI 통합 테스트
- [ ] 모든 화면 네비게이션 테스트
- [ ] 디자인 시스템 일관성 확인
- [ ] 반응형 레이아웃 테스트 (iOS/Android)
- **담당**: 개발자 1 + 개발자 2
- **소요**: 1시간
- **의존성**: 모든 UI Task 완료
- **산출물**: UI 테스트 체크리스트
- **완료 기준**: 모든 화면 작동, 버그 0개

---

## 📊 Phase 2: Core Logic & API Integration (Day 6~10)

**목표**: 역산 스케줄링, API 연동, 로컬 DB 구현
**기간**: 5일
**담당**: 개발자 1, 개발자 2

### Task 2.1: Naver Maps API 연동 (Day 6)
**담당**: 개발자 1
**소요**: 1일

#### SubTask 2.1.1: Directions API 연동 (자차)
- [ ] HTTP 클라이언트 설정 (dio 패키지)
- [ ] API 키 환경 변수 설정
- [ ] `RouteService` 클래스 생성
- [ ] `calculateRoute()` 메서드 구현
- [ ] 실시간 교통 데이터 파싱
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: SubTask 1.1.1 (API 키)
- **산출물**: `lib/services/route_service.dart`
- **완료 기준**: 실제 API 호출 성공, 이동 시간 반환

#### SubTask 2.1.2: API 에러 핸들링
- [ ] 네트워크 오류 처리
- [ ] API 키 오류 처리
- [ ] Rate Limit 처리
- [ ] Google Maps 폴백 로직
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: SubTask 2.1.1
- **산출물**: `lib/services/route_service.dart` (에러 핸들링 추가)
- **완료 기준**: 모든 에러 케이스 테스트 통과

#### SubTask 2.1.3: 캐싱 전략 구현
- [ ] 최근 경로 캐싱 (5분 유효)
- [ ] 중복 요청 방지
- [ ] 캐시 무효화 로직
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: SubTask 2.1.2
- **산출물**: `lib/services/cache_service.dart`
- **완료 기준**: 동일 경로 재요청 시 캐시 사용

---

### Task 2.2: Naver Transit API 연동 (Day 7)
**담당**: 개발자 1
**소요**: 1일

#### SubTask 2.2.1: Transit API 연동
- [ ] `TransitService` 클래스 생성
- [ ] `getTransitRoute()` 메서드 구현
- [ ] 버스/지하철 경로 파싱
- [ ] 환승 정보 파싱
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: SubTask 2.1.3
- **산출물**: `lib/services/transit_service.dart`
- **완료 기준**: 대중교통 경로 데이터 반환

#### SubTask 2.2.2: 환승 버퍼 시간 자동 계산
- [ ] 도보 환승: 5분 자동 추가
- [ ] 버스 환승: 3분 자동 추가
- [ ] 환승역 거리 기반 조정 로직
- **담당**: 개발자 1
- **소요**: 1시간
- **의존성**: SubTask 2.2.1
- **산출물**: `lib/utils/transfer_buffer.dart`
- **완료 기준**: 환승 시간 자동 계산 테스트 통과

---

### Task 2.3: 역산 스케줄링 알고리즘 (Day 8)
**담당**: 개발자 2
**소요**: 1일

#### SubTask 2.3.1: SchedulerService 기본 구현
- [ ] `calculateDepartureTime()` 메서드
- [ ] 4가지 버퍼 시간 반영 알고리즘
- [ ] 이동 오차율 계산 (20% 기본)
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: 없음
- **산출물**: `lib/services/scheduler_service.dart`
- **완료 기준**: 단위 테스트 100% 통과

#### SubTask 2.3.2: Adaptive Polling 로직
- [ ] `getPollingInterval()` 메서드
- [ ] 1시간 전: 15분 간격
- [ ] 30분 전: 5분 간격
- [ ] 10분 전: 3분 간격
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 2.3.1
- **산출물**: `lib/services/polling_service.dart`
- **완료 기준**: 시간대별 간격 자동 조정

#### SubTask 2.3.3: 실시간 업데이트 로직
- [ ] Timer 설정
- [ ] API 호출 및 출발 시간 재계산
- [ ] 변화율 5% 미만 시 스킵
- [ ] UI 자동 업데이트
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 2.3.2
- **산출물**: `lib/services/real_time_updater.dart`
- **완료 기준**: 실시간 카운트다운 작동

---

### Task 2.4: 로컬 데이터베이스 구현 (Day 9)
**담당**: 개발자 2
**소요**: 1일

#### SubTask 2.4.1: SQLite 데이터베이스 설정
- [ ] sqflite 패키지 설정
- [ ] 데이터베이스 초기화
- [ ] 마이그레이션 전략
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: 없음
- **산출물**: `lib/database/database_helper.dart`
- **완료 기준**: DB 생성 및 연결 성공

#### SubTask 2.4.2: Trip 모델 및 DAO
- [ ] Trip 모델 클래스 (title, destination, arrivalTime 등)
- [ ] CRUD 메서드 (insert, update, delete, query)
- [ ] 4가지 버퍼 시간 필드 저장
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 2.4.1
- **산출물**: `lib/models/trip.dart`, `lib/database/trip_dao.dart`
- **완료 기준**: CRUD 테스트 통과

#### SubTask 2.4.3: User 설정 모델
- [ ] UserSettings 모델 (기본 버퍼 시간, 알림 설정 등)
- [ ] CRUD 메서드
- [ ] 기본값 설정 로직
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 2.4.2
- **산출물**: `lib/models/user_settings.dart`, `lib/database/settings_dao.dart`
- **완료 기준**: 설정 저장/불러오기 성공

#### SubTask 2.4.4: 데이터 통합 테스트
- [ ] Trip 저장 → 역산 스케줄링 → 결과 표시
- [ ] 설정 변경 → DB 저장 → 재시작 시 로드
- **담당**: 개발자 2
- **소요**: 1시간
- **의존성**: SubTask 2.4.3
- **산출물**: 통합 테스트 코드
- **완료 기준**: E2E 시나리오 테스트 통과

---

### Task 2.5: API 및 로직 통합 (Day 10)
**담당**: 개발자 1 + 개발자 2
**소요**: 1일

#### SubTask 2.5.1: 대시보드 - 실제 데이터 연동
- [ ] DB에서 다음 일정 로드
- [ ] 역산 스케줄링 계산 연동
- [ ] Naver API로 이동 시간 실시간 조회
- [ ] 카운트다운 실제 작동
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: Task 2.1~2.4 완료
- **산출물**: `lib/screens/dashboard/dashboard_screen.dart` (데이터 연동)
- **완료 기준**: 실제 일정 데이터로 카운트다운 작동

#### SubTask 2.5.2: 스케줄 추가 - API 연동
- [ ] Step 1: 장소 검색 (Naver Places API)
- [ ] Step 2: 이동 수단 선택 시 실시간 경로 조회
- [ ] Step 3: 최종 계산 결과를 DB에 저장
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: Task 2.1~2.4 완료
- **산출물**: 스케줄 추가 화면 API 연동
- **완료 기준**: 일정 추가 → DB 저장 → 대시보드 표시

#### SubTask 2.5.3: 통합 테스트
- [ ] 전체 플로우 테스트 (일정 추가 → 카운트다운 → 출발)
- [ ] 대중교통 vs 자차 비교
- [ ] 4가지 버퍼 시간 변경 시 재계산
- **담당**: 개발자 1 + 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 2.5.1, 2.5.2
- **산출물**: 통합 테스트 리포트
- **완료 기준**: 모든 핵심 기능 작동

---

## 📊 Phase 3: Widgets & Notifications (Day 11~15)

**목표**: Android/iOS 홈 위젯 구현 및 푸시 알림
**기간**: 5일
**담당**: 개발자 1 (Android), 개발자 2 (iOS)

### Task 3.1: Android 홈 위젯 (Day 11~13)
**담당**: 개발자 1
**소요**: 3일

#### SubTask 3.1.1: Jetpack Glance 위젯 기본 구조 (Day 11)
- [ ] Kotlin 코드 작성 (`android/app/src/main/kotlin/`)
- [ ] `GoNowWidget` 클래스 생성
- [ ] 2x2 위젯 레이아웃
- [ ] 위젯 Provider 등록
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: 없음
- **산출물**: `android/.../widget/GoNowWidget.kt`
- **완료 기준**: 홈 화면에 위젯 추가 가능

#### SubTask 3.1.2: Flutter ↔ Android 데이터 공유 (Day 11)
- [ ] SharedPreferences 설정
- [ ] MethodChannel 구현
- [ ] `updateWidget()` 메서드 (Flutter에서 호출)
- [ ] 다음 일정 데이터 전달
- **담당**: 개발자 1
- **소요**: 3시간
- **의존성**: SubTask 3.1.1
- **산출물**: `lib/services/widget_service.dart`
- **완료 기준**: Flutter에서 위젯 업데이트 성공

#### SubTask 3.1.3: 위젯 UI 구현 (Day 12)
- [ ] 일정 제목 표시
- [ ] 남은 시간 표시 (15분 남음)
- [ ] 출발 시간 표시 (08:25까지 출발)
- [ ] 색상 시스템 (초록/주황/빨강)
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: SubTask 3.1.2
- **산출물**: 위젯 UI 완성
- **완료 기준**: Figma 디자인과 일치

#### SubTask 3.1.4: WorkManager 자동 업데이트 (Day 13)
- [ ] `WidgetUpdateWorker` 클래스
- [ ] 15분 주기 스케줄링
- [ ] 배터리 최적화 설정
- [ ] Foreground Service 권한
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: SubTask 3.1.3
- **산출물**: 자동 업데이트 로직
- **완료 기준**: 15분마다 위젯 자동 갱신

---

### Task 3.2: iOS 홈 위젯 (Day 11~13)
**담당**: 개발자 2
**소요**: 3일

#### SubTask 3.2.1: WidgetKit 위젯 기본 구조 (Day 11)
- [ ] SwiftUI 코드 작성 (`ios/Runner/GoNowWidget/`)
- [ ] `GoNowWidgetProvider` 클래스
- [ ] Small/Medium 위젯 크기 지원
- [ ] Widget Extension Target 생성
- **담당**: 개발자 2
- **소요**: 4시간
- **의존성**: 없음
- **산출물**: `ios/Runner/GoNowWidget/GoNowWidget.swift`
- **완료 기준**: 홈 화면에 위젯 추가 가능

#### SubTask 3.2.2: Flutter ↔ iOS 데이터 공유 (Day 11)
- [ ] App Groups 설정
- [ ] SharedUserDefaults 구현
- [ ] MethodChannel 구현
- [ ] `updateWidget()` 메서드
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 3.2.1
- **산출물**: `lib/services/widget_service.dart` (iOS 지원 추가)
- **완료 기준**: Flutter에서 위젯 업데이트 성공

#### SubTask 3.2.3: 위젯 UI 구현 (Day 12)
- [ ] VStack 레이아웃
- [ ] 일정 정보 표시
- [ ] 남은 시간 + 출발 시간
- [ ] 대중교통 정보 (선택적)
- [ ] 색상 시스템
- **담당**: 개발자 2
- **소요**: 4시간
- **의존성**: SubTask 3.2.2
- **산출물**: 위젯 UI 완성
- **완료 기준**: Figma 디자인과 일치

#### SubTask 3.2.4: Timeline Provider 구현 (Day 13)
- [ ] `getTimeline()` 메서드
- [ ] 15분 주기 엔트리 생성
- [ ] 위젯 리로드 정책 설정
- **담당**: 개발자 2
- **소요**: 4시간
- **의존성**: SubTask 3.2.3
- **산출물**: Timeline Provider 완성
- **완료 기준**: 15분마다 위젯 자동 갱신

---

### Task 3.3: 로컬 푸시 알림 (Day 14~15)
**담당**: 개발자 2 (Day 14), 개발자 1 (Day 15)
**소요**: 2일

#### SubTask 3.3.1: flutter_local_notifications 설정 (Day 14)
- [ ] 패키지 설치 및 초기화
- [ ] Android 알림 채널 설정
- [ ] iOS 알림 권한 요청
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: 없음
- **산출물**: `lib/services/notification_service.dart`
- **완료 기준**: 테스트 알림 전송 성공

#### SubTask 3.3.2: 알림 스케줄링 로직 (Day 14)
- [ ] 30분 전 알림
- [ ] 10분 전 긴급 알림
- [ ] 알림 취소 로직
- [ ] 알림 클릭 시 앱 열기
- **담당**: 개발자 2
- **소요**: 4시간
- **의존성**: SubTask 3.3.1
- **산출물**: `scheduleNotification()` 메서드
- **완료 기준**: 예약된 시간에 알림 전송

#### SubTask 3.3.3: 동적 알림 메시지 (Day 14)
- [ ] 교통 상황 변화 시 알림 업데이트
- [ ] 지연 위험 시 긴급 알림
- [ ] 대중교통 버스 도착 알림
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 3.3.2
- **산출물**: 동적 알림 로직
- **완료 기준**: 실시간 상황에 따라 알림 변경

#### SubTask 3.3.4: 위젯 + 알림 통합 테스트 (Day 15)
- [ ] 위젯 업데이트와 알림 동기화
- [ ] 알림 클릭 → 앱 열기 → 대시보드 이동
- [ ] 배터리 소모 테스트
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: Task 3.1, 3.2, 3.3 완료
- **산출물**: 통합 테스트 리포트
- **완료 기준**: 위젯 + 알림 모두 정상 작동

---

## 📊 Phase 4: Integration & QA (Day 16~20)

**목표**: 전체 기능 통합, 버그 수정, 성능 최적화
**기간**: 5일
**담당**: 개발자 1, 개발자 2, PM

### Task 4.1: 전체 기능 통합 테스트 (Day 16)
**담당**: 개발자 1 + 개발자 2
**소요**: 1일

#### SubTask 4.1.1: E2E 시나리오 테스트
- [ ] 시나리오 1: 신규 사용자 온보딩 → 첫 일정 추가
- [ ] 시나리오 2: 대중교통 경로 → 실시간 버스 도착 → 출발
- [ ] 시나리오 3: 자차 경로 → 교통 변화 → 출발 시간 재계산
- [ ] 시나리오 4: 위젯에서 일정 확인 → 알림 받기 → 출발
- **담당**: 개발자 1, 개발자 2
- **소요**: 4시간
- **의존성**: Phase 1~3 완료
- **산출물**: E2E 테스트 리포트
- **완료 기준**: 모든 시나리오 성공

#### SubTask 4.1.2: 버그 리스트 작성
- [ ] 발견된 버그 분류 (Critical/High/Medium/Low)
- [ ] 재현 방법 문서화
- [ ] 우선순위 지정
- **담당**: 개발자 1, 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 4.1.1
- **산출물**: 버그 리스트 (Notion/Jira)
- **완료 기준**: 모든 버그 문서화

#### SubTask 4.1.3: Critical 버그 긴급 수정
- [ ] Critical 버그 즉시 수정
- [ ] 수정 후 재테스트
- **담당**: 개발자 1, 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 4.1.2
- **산출물**: 버그 수정 커밋
- **완료 기준**: Critical 버그 0개

---

### Task 4.2: 버그 수정 및 UX 개선 (Day 17)
**담당**: 개발자 1 + 개발자 2
**소요**: 1일

#### SubTask 4.2.1: High 우선순위 버그 수정
- [ ] High 버그 리스트 처리
- [ ] 각 버그 수정 및 테스트
- **담당**: 개발자 1, 개발자 2
- **소요**: 4시간
- **의존성**: Task 4.1
- **산출물**: 버그 수정 커밋
- **완료 기준**: High 버그 0개

#### SubTask 4.2.2: UX 개선
- [ ] 로딩 상태 표시 개선
- [ ] 에러 메시지 사용자 친화적으로 변경
- [ ] 버튼 크기/위치 조정
- [ ] 애니메이션 부드럽게 개선
- **담당**: 개발자 2
- **소요**: 3시간
- **의존성**: SubTask 4.2.1
- **산출물**: UX 개선 커밋
- **완료 기준**: 사용성 테스트 통과

#### SubTask 4.2.3: Medium/Low 버그 트리아지
- [ ] Medium/Low 버그 재평가
- [ ] 출시 전 수정 vs Phase 2 이관 결정
- **담당**: PM + 개발자 1, 2
- **소요**: 1시간
- **의존성**: SubTask 4.2.2
- **산출물**: 최종 버그 리스트
- **완료 기준**: 모든 버그 분류 완료

---

### Task 4.3: 실제 시나리오 테스트 (Day 18)
**담당**: 개발자 1 + 개발자 2 + PM
**소요**: 1일

#### SubTask 4.3.1: 실제 출퇴근 테스트
- [ ] 실제 출근 경로로 테스트 (대중교통)
- [ ] 실제 퇴근 경로로 테스트 (자차)
- [ ] 교통 혼잡 시간대 테스트
- **담당**: 개발자 1, 개발자 2
- **소요**: 4시간 (실제 이동 포함)
- **의존성**: Task 4.2
- **산출물**: 실사용 테스트 리포트
- **완료 기준**: 실제 환경에서 정상 작동

#### SubTask 4.3.2: 엣지 케이스 테스트
- [ ] 네트워크 끊김 시나리오
- [ ] GPS 오차 시나리오
- [ ] 배터리 절약 모드 시나리오
- [ ] 앱 백그라운드 시나리오
- **담당**: 개발자 1, 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 4.3.1
- **산출물**: 엣지 케이스 테스트 리포트
- **완료 기준**: 모든 엣지 케이스 처리

#### SubTask 4.3.3: QA 리포트 작성
- [ ] 테스트 결과 종합
- [ ] 발견된 이슈 정리
- [ ] 개선 권장 사항
- **담당**: PM
- **소요**: 2시간
- **의존성**: SubTask 4.3.2
- **산출물**: QA 최종 리포트
- **완료 기준**: 리포트 팀 공유

---

### Task 4.4: 성능 최적화 (Day 19)
**담당**: 개발자 1
**소요**: 1일

#### SubTask 4.4.1: 배터리 소모 최적화
- [ ] Adaptive Polling 간격 조정
- [ ] 백그라운드 작업 최소화
- [ ] Wake Lock 사용 최소화
- [ ] 배터리 소모 측정
- **담당**: 개발자 1
- **소요**: 4시간
- **의존성**: Task 4.3
- **산출물**: 배터리 최적화 리포트
- **완료 기준**: 1일 사용 시 배터리 소모 <10%

#### SubTask 4.4.2: 메모리 사용 최적화
- [ ] 이미지 캐싱 최적화
- [ ] 메모리 누수 체크
- [ ] 불필요한 객체 제거
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: SubTask 4.4.1
- **산출물**: 메모리 프로파일링 리포트
- **완료 기준**: 메모리 사용량 <100MB

#### SubTask 4.4.3: 앱 시작 속도 최적화
- [ ] 초기 로딩 최적화
- [ ] Lazy Loading 적용
- [ ] 스플래시 화면 시간 단축
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: SubTask 4.4.2
- **산출물**: 앱 시작 시간 <2초
- **완료 기준**: Cold Start <2초, Warm Start <1초

---

### Task 4.5: Alpha 사용자 테스트 (Day 20)
**담당**: PM + 개발자 1, 2
**소요**: 1일

#### SubTask 4.5.1: Alpha 테스터 모집
- [ ] 테스터 5~10명 모집
- [ ] TestFlight/Google Play 내부 테스트 초대
- [ ] 테스트 가이드 문서 작성
- **담당**: PM
- **소요**: 2시간
- **의존성**: Task 4.4
- **산출물**: Alpha 테스터 리스트
- **완료 기준**: 테스터 10명 확보

#### SubTask 4.5.2: 사용자 피드백 수집
- [ ] Google Forms 설문지 작성
- [ ] 테스터에게 배포
- [ ] 1일 사용 후 피드백 수집
- **담당**: PM
- **소요**: 4시간 (대기 시간 포함)
- **의존성**: SubTask 4.5.1
- **산출물**: 사용자 피드백 리포트
- **완료 기준**: 피드백 10개 이상 수집

#### SubTask 4.5.3: 피드백 반영 계획
- [ ] 피드백 분석
- [ ] 긴급 수정 vs Phase 2 이관 결정
- [ ] 최종 개선 사항 리스트
- **담당**: PM + 개발자 1, 2
- **소요**: 2시간
- **의존성**: SubTask 4.5.2
- **산출물**: 최종 개선 계획
- **완료 기준**: 출시 전 필수 개선 사항 확정

---

## 📊 Phase 5: Launch Preparation (Day 21~25)

**목표**: 앱스토어 제출 및 공식 출시
**기간**: 5일
**담당**: 전체 팀

### Task 5.1: 앱스토어 심사 준비 (Day 21)
**담당**: PM + 디자이너
**소요**: 1일

#### SubTask 5.1.1: 스크린샷 제작
- [ ] iPhone 스크린샷 (6.7", 6.5")
- [ ] iPad 스크린샷 (12.9")
- [ ] Android 스크린샷 (Phone, Tablet)
- [ ] 각 화면별 5장씩
- **담당**: 디자이너
- **소요**: 4시간
- **의존성**: Phase 4 완료
- **산출물**: 스크린샷 30장
- **완료 기준**: 앱스토어 규격 준수

#### SubTask 5.1.2: 앱 설명 작성
- [ ] 짧은 설명 (80자)
- [ ] 상세 설명 (4000자)
- [ ] 키워드 설정 (100자)
- [ ] 프로모션 텍스트 (170자)
- **담당**: PM
- **소요**: 3시간
- **의존성**: 없음
- **산출물**: 앱 스토어 리스팅 텍스트
- **완료 기준**: 마케팅 메시지 일관성

#### SubTask 5.1.3: 앱 아이콘 및 에셋
- [ ] 앱 아이콘 (1024x1024)
- [ ] 런처 아이콘 (Android)
- [ ] 스플래시 화면
- **담당**: 디자이너
- **소요**: 1시간
- **의존성**: 없음
- **산출물**: 아이콘 에셋
- **완료 기준**: 모든 크기 준비 완료

---

### Task 5.2: 법적 문서 작성 (Day 22)
**담당**: PM
**소요**: 1일

#### SubTask 5.2.1: 개인정보 처리방침
- [ ] 수집 항목 명시
- [ ] 수집 목적 명시
- [ ] 보유 기간 명시
- [ ] 제3자 제공 명시 (Naver API)
- **담당**: PM
- **소요**: 3시간
- **의존성**: 없음
- **산출물**: 개인정보 처리방침 (웹 페이지)
- **완료 기준**: 법무 검토 완료

#### SubTask 5.2.2: 이용약관
- [ ] 서비스 정의
- [ ] 이용자 권리/의무
- [ ] 서비스 중단/변경 조항
- [ ] 면책 조항
- **담당**: PM
- **소요**: 3시간
- **의존성**: SubTask 5.2.1
- **산출물**: 이용약관 (웹 페이지)
- **완료 기준**: 법무 검토 완료

#### SubTask 5.2.3: 법적 문서 앱 연동
- [ ] 웹뷰로 약관 표시
- [ ] 회원가입 시 동의 체크
- [ ] 설정 화면에 약관 링크
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 5.2.2
- **산출물**: 약관 연동 완료
- **완료 기준**: 앱에서 약관 확인 가능

---

### Task 5.3: 베타 테스트 (Day 23)
**담당**: 전체 팀
**소요**: 1일

#### SubTask 5.3.1: TestFlight 배포 (iOS)
- [ ] Archive 빌드
- [ ] TestFlight 업로드
- [ ] 내부 테스터 초대
- [ ] 테스트 정보 작성
- **담당**: 개발자 2
- **소요**: 2시간
- **의존성**: Task 5.2
- **산출물**: TestFlight 베타 빌드
- **완료 기준**: 테스터가 다운로드 가능

#### SubTask 5.3.2: Google Play 내부 테스트 (Android)
- [ ] Release 빌드 (AAB)
- [ ] Google Play Console 업로드
- [ ] 내부 테스터 트랙 설정
- [ ] 테스터 초대
- **담당**: 개발자 1
- **소요**: 2시간
- **의존성**: Task 5.2
- **산출물**: Google Play 베타 빌드
- **완료 기준**: 테스터가 다운로드 가능

#### SubTask 5.3.3: 베타 테스트 실시
- [ ] 테스터에게 테스트 요청
- [ ] Crash 리포트 모니터링
- [ ] 긴급 버그 수정
- **담당**: PM + 개발자 1, 2
- **소요**: 4시간
- **의존성**: SubTask 5.3.1, 5.3.2
- **산출물**: 베타 테스트 리포트
- **완료 기준**: Critical 버그 0개

---

### Task 5.4: 최종 빌드 및 제출 (Day 24)
**담당**: 개발자 1 + 개발자 2
**소요**: 1일

#### SubTask 5.4.1: 최종 버그 수정
- [ ] 베타 테스트에서 발견된 버그 수정
- [ ] 코드 리뷰
- [ ] 최종 테스트
- **담당**: 개발자 1, 개발자 2
- **소요**: 4시간
- **의존성**: Task 5.3
- **산출물**: 버그 수정 커밋
- **완료 기준**: 버그 0개

#### SubTask 5.4.2: Production 빌드
- [ ] iOS Production 빌드 (Archive)
- [ ] Android Production 빌드 (AAB)
- [ ] 빌드 번호 및 버전 확인 (1.0.0)
- [ ] 서명 및 암호화
- **담당**: 개발자 1, 개발자 2
- **소요**: 2시간
- **의존성**: SubTask 5.4.1
- **산출물**: Production 빌드 파일
- **완료 기준**: 빌드 성공, 테스트 통과

#### SubTask 5.4.3: 앱스토어 정보 입력
- [ ] App Store Connect 정보 입력
- [ ] Google Play Console 정보 입력
- [ ] 스크린샷 업로드
- [ ] 설명 및 키워드 입력
- **담당**: PM
- **소요**: 2시간
- **의존성**: Task 5.1, SubTask 5.4.2
- **산출물**: 스토어 리스팅 완성
- **완료 기준**: 모든 정보 입력 완료

---

### Task 5.5: 앱스토어 제출 및 출시 (Day 25)
**담당**: PM + 전체 팀
**소요**: 1일

#### SubTask 5.5.1: 앱스토어 제출
- [ ] App Store Connect에 빌드 제출
- [ ] Google Play Console에 빌드 제출
- [ ] 심사 요청 메모 작성
- **담당**: PM
- **소요**: 1시간
- **의존성**: Task 5.4
- **산출물**: 앱스토어 제출 완료
- **완료 기준**: "심사 대기 중" 상태

#### SubTask 5.5.2: 심사 모니터링
- [ ] 심사 상태 확인
- [ ] 거절 시 즉시 대응
- [ ] 승인 대기
- **담당**: PM
- **소요**: 4시간 (대기 시간)
- **의존성**: SubTask 5.5.1
- **산출물**: 심사 진행 상황
- **완료 기준**: 심사 통과

#### SubTask 5.5.3: 공식 출시 🎉
- [ ] App Store 출시
- [ ] Google Play Store 출시
- [ ] 출시 공지 (SNS, 블로그)
- [ ] 모니터링 시작 (Crash, 리뷰)
- **담당**: 전체 팀
- **소요**: 1시간
- **의존성**: SubTask 5.5.2
- **산출물**: 공식 출시 완료
- **완료 기준**: 두 스토어 모두 "공개" 상태

#### SubTask 5.5.4: 출시 기념 회고
- [ ] 팀 회고 미팅
- [ ] 잘한 점 / 개선점 정리
- [ ] Phase 2 계획 논의
- [ ] 축하 🎉
- **담당**: 전체 팀
- **소요**: 2시간
- **의존성**: SubTask 5.5.3
- **산출물**: 회고 문서
- **완료 기준**: Phase 2 킥오프 준비 완료

---

## 📋 Phase/Task/SubTask 요약 통계

| Phase | Task 수 | SubTask 수 | 총 소요 일수 |
|-------|---------|------------|--------------|
| Phase 1: Foundation & UI | 5 | 15 | 5일 |
| Phase 2: Core Logic & API | 5 | 15 | 5일 |
| Phase 3: Widgets & Notifications | 3 | 12 | 5일 |
| Phase 4: Integration & QA | 5 | 15 | 5일 |
| Phase 5: Launch Preparation | 5 | 15 | 5일 |
| **총계** | **23** | **72** | **25일** |

---

## 🎯 Critical Path (가장 중요한 의존성 체인)

```
Day 1: API 키 발급 (1.1.1)
  ↓
Day 6: Naver Maps API 연동 (2.1.1)
  ↓
Day 7: Naver Transit API 연동 (2.2.1)
  ↓
Day 8: 역산 스케줄링 알고리즘 (2.3.1)
  ↓
Day 10: API 및 로직 통합 (2.5.1)
  ↓
Day 16: 전체 기능 통합 테스트 (4.1.1)
  ↓
Day 20: Alpha 사용자 테스트 (4.5.1)
  ↓
Day 24: Production 빌드 (5.4.2)
  ↓
Day 25: 앱스토어 제출 (5.5.1)
```

**Critical Path 총 소요**: 25일 (전체 기간과 동일)

---

## 📌 일일 체크리스트 템플릿

```markdown
# Day X 작업 체크리스트

## 오늘의 목표 (Phase X, Task X.X)
- [ ] SubTask X.X.1: [제목]
- [ ] SubTask X.X.2: [제목]
- [ ] SubTask X.X.3: [제목]

## 완료 기준
- [ ] 산출물: [파일명/기능명]
- [ ] 테스트: [테스트 항목]
- [ ] 리뷰: [리뷰어]

## 블로커 (있다면)
- 없음 / [블로커 내용]

## 내일 계획
- Task X.X+1: [제목]
```

### 5.2 팀 구성

**개발팀** (바이브코딩 2명):
- **개발자 1** (Flutter + Android 전문)
  - Flutter 앱 개발
  - Android 위젯 구현
  - Naver Maps/Transit API 연동
- **개발자 2** (Flutter + iOS 전문)
  - Flutter 앱 개발
  - iOS 위젯 구현
  - 역산 스케줄링 알고리즘

**지원**:
- **PM** (프로젝트 관리)
  - 일정 관리, 우선순위 결정
  - 법적 문서 작성
  - 앱스토어 제출
- **디자이너** (외주 가능)
  - UI/UX 디자인
  - 앱 아이콘, 스플래시 화면
  - 스토어 스크린샷

### 5.3 개발 환경

**필수 도구**:
- Flutter SDK 3.x
- Android Studio / Xcode
- Git + GitHub
- Figma (디자인)

**필수 API 키 발급**:
- ✅ Naver Cloud Platform (NCP)
  - Maps API (Directions)
  - Transit API
- ✅ 서울시 공공데이터 포털
  - 버스 도착 정보 API
- ✅ Apple Developer Account (99$/년)
- ✅ Google Play Console (25$ 일회성)

**예산**:
- 개발자 2명: 2,000만 원 (월 1,000만 원 × 2명 × 1개월)
- 외주 디자이너: 500만 원 (UI/UX + 그래픽)
- API 비용: 50만 원 (Naver + 서울시)
- 스토어 등록: 15만 원 (Apple 99$ + Google 25$)
- **총 예산**: 약 2,565만 원

---

## 🎯 6. Success Metrics / 성공 지표

### 6.1 Phase 1 목표 (MVP 출시 후 1개월)

| 지표 | 목표 | 측정 방법 |
|------|------|-----------|
| **DAU** | 200명 | Firebase Analytics |
| **MAU** | 500명 | Firebase Analytics |
| **D7 리텐션** | 40%+ | Cohort 분석 |
| **앱스토어 평점** | 4.5+ | 최소 50개 리뷰 |
| **정시 출발 성공률** | 75%+ | "출발했어요" 버튼 기록 |
| **앱 삭제율** | <30% | 설치 vs 활성 사용자 |

### 6.2 Phase 2 목표 (MVP 출시 후 3개월)

| 지표 | 목표 | 측정 방법 |
|------|------|-----------|
| **MAU** | 1,000명 | Firebase Analytics |
| **유료 전환율** | 10% | IAP 구매 수 |
| **월 구독 수익** | 490,000원 | 100명 × 4,900원 |
| **D30 리텐션** | 25%+ | Cohort 분석 |
| **NPS** | 30+ | 사용자 설문조사 |

### 6.3 Phase 3 목표 (MVP 출시 후 6개월)

| 지표 | 목표 | 측정 방법 |
|------|------|-----------|
| **MAU** | 10,000명 | Firebase Analytics |
| **유료 전환율** | 15% | 1,500명 프리미엄 |
| **월 구독 수익** | 7,350,000원 | 1,500명 × 4,900원 |
| **앱스토어 평점** | 4.7+ | 1,000+ 리뷰 |
| **정시 출발 성공률** | 85%+ | 장기 사용자 데이터 |

---

## ⚠️ 7. Risk Management / 리스크 관리

### 7.1 기술적 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| 배터리 과다 소모로 앱 삭제 | 중간 | 높음 | Adaptive Polling으로 API 호출 최소화 |
| Naver API 비용 폭증 | 낮음 | 중간 | Adaptive Polling + 캐싱 전략 |
| iOS Live Activities 제한 | 낮음 | 낮음 | Phase 2 기능, 우선순위 낮음 |
| Widget 업데이트 누락 | 중간 | 중간 | WorkManager로 안정적 스케줄링 |

### 7.2 비즈니스 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| 유료 전환율 저조 | 중간 | 높음 | 무료 기능 제한 강화 + 프리미엄 가치 강조 |
| 경쟁사 복제 | 높음 | 중간 | 특허 출원 + 한국 시장 선점 |
| 사용자 이탈 | 중간 | 높음 | 게임화 강화 + 긍정적 강화 |

### 7.3 법적 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| 앱스토어 심사 거절 | 낮음 | 치명적 | IAP 정책 준수 + 사전 검토 |
| 개인정보 보호법 위반 | 낮음 | 높음 | 최소 정보 수집 + 명확한 동의 |
| 저작권 이슈 | 낮음 | 중간 | 자체 디자인 + 라이선스 확인 |

---

## 📚 8. Final Decisions Summary / 최종 결정사항 요약

### 8.1 전체 결정사항 (18개 항목 모두 완료)

#### A. 비즈니스 모델 (3개)

**A-1. ✅ 수익 모델 (최종 결정)**
- **결정**: Freemium 구독 모델 (월 4,900원)
- **폐기**: 패널티 수익 배분 (법적 리스크, 사용자 반발)
- **수익 구조**:
  - 무료: 일 3개 일정 제한 + 광고
  - 프리미엄: 무제한 일정 + 광고 제거 + 고급 통계
  - 부가: 제휴 수수료 (택시 호출), B2B 라이선스
- **근거**: 앱스토어 정책 준수, 안정적 수익 모델

**A-2. ✅ 환불 정책 (최종 결정)**
- **결정**: N/A (패널티 시스템 폐기로 환불 정책 불필요)
- **대신**: 프리미엄 구독 취소는 앱스토어 기본 정책 따름

**A-3. ✅ PG사 선정 (최종 결정)**
- **결정**: In-App Purchase (IAP) 사용
- **폐기**: Stripe/토스페이먼츠 (앱스토어 정책 위반)
- **근거**: Apple/Google 정책 완전 준수, 심사 리스크 제로

#### B. 기능 우선순위 (3개)

**B-1. ✅ 버퍼 시간 입력 방식 (최종 결정)**
- **결정**: 4가지 버퍼 시간 독립 설정
  - 1️⃣ 외출 준비 시간 (5~60분, 기본 15분)
  - 2️⃣ 이동 오차율 (0~50%, 기본 20%)
  - 3️⃣ 일찍 도착 버퍼 (0~30분, 기본 10분)
  - 4️⃣ 일정 마무리 시간 (0~20분, 기본 5분)
- **근거**: 각 버퍼의 목적이 명확히 구분되어 사용자가 이해하기 쉬움
- **추가**: AI 기반 개인화 추천 (Phase 3)

**B-2. ✅ 소셜 프레셔 기능 (최종 결정)**
- **결정**: Phase 2로 연기
- **기능**: 카카오톡 자동 전송 (지각 위기 시 친구 알림)
- **근거**: Phase 1은 핵심 기능 검증 우선

**B-3. ✅ 운전 중 안전장치 (최종 결정)**
- **결정**: Phase 1 적용 불필요 (수동 "출발했어요" 버튼)
- **Phase 2**: 자동 내비 모드 + 음성 안내
- **근거**: Phase 1은 지오펜싱 없음

#### C. 기술 구현 (3개)

**C-1. ✅ 지오펜스 반경 (최종 결정)**
- **결정**: Phase 2로 연기 (Phase 1은 수동 체크인)
- **Phase 2 권장**: 100m (GPS 오차 고려)
- **근거**: 배터리 소모 최소화, MVP 복잡도 감소

**C-2. ✅ 배터리 소모 허용치 (최종 결정)**
- **결정**: Balanced Mode (Adaptive Polling)
- **전략**:
  - 1시간 전: 15분 간격
  - 30분 전: 5분 간격
  - 10분 전: 3분 간격
- **근거**: 정확도와 배터리 절약 균형

**C-3. ✅ 홈 위젯 (Android/iOS) (최종 결정) ⭐**
- **결정**: Phase 1 MVP 필수 기능
- **구현**:
  - iOS: WidgetKit (SwiftUI)
  - Android: Jetpack Glance (Compose)
  - 업데이트: 15분 주기 (WorkManager/Timeline Provider)
- **근거**: 사용자 편의성 극대화, 앱 진입 장벽 감소
- **개발 공수**: +3일 (Week 3 집중)

#### D. 지도 및 API (3개)

**D-1. ✅ 지도 API 선택 (최종 결정)**
- **결정**: Naver Cloud Platform (NCP)
- **API 구성**:
  - 자차: Naver Directions API (실시간 교통)
  - 대중교통: Naver Transit API (버스/지하철)
  - 실시간 버스: 서울시 공공데이터
- **폴백**: Google Routes API (Naver 실패 시)
- **근거**: 한국 시장 정확도 최우선, 비용 효율성
- **즉시 필요**: API 키 발급 (Week 1 Day 1)

**D-2. ✅ 대중교통 지원 (최종 결정) ⭐**
- **결정**: Phase 1 MVP 필수 기능
- **기능**:
  - 버스/지하철 통합 경로 (Naver Transit API)
  - 실시간 버스 도착 정보 (서울시 API)
  - 환승 시간 자동 반영 (도보 5분, 버스 3분)
- **근거**: 타깃 사용자 (20~40대 직장인)는 대중교통 사용 비율 높음
- **개발 공수**: +2일 (Week 2 집중)

**D-3. ✅ 카카오 택시 연동 (최종 결정)**
- **결정**: Phase 2+ (우선순위 낮음)
- **기능**: 지각 위기 시 카카오 T 딥링크 호출
- **근거**: Phase 1은 핵심 기능 검증 우선

#### E. 마케팅 및 포지셔닝 (3개)

**E-1. ✅ 핵심 포지셔닝 (최종 결정)**
- **결정**: 생산성 앱 (의료 기기 아님)
- **메시지**: "절대 안 늦는 습관 만들기"
- **타깃**:
  - 주 타깃: 20~40대 직장인, 프리랜서
  - 부 타깃: ADHD 성향 사용자 (자연 유입)
- **근거**: 규제 회피, 대중 시장 확대

**E-2. ✅ 초기 사용자 확보 (최종 결정)**
- **결정**: Reddit/커뮤니티 + 유튜버 협찬
- **채널**:
  - Reddit r/ADHD, r/productivity
  - 블라인드, 디씨 직장인 갤러리
  - 생산성 유튜버 협찬
- **예산**: 500만 원 (Phase 1 출시 후)

**E-3. ✅ 브랜드 네이밍 (최종 결정)**
- **결정**: "Go Now: The Time Saver"
- **한글**: "고 나우: 더 타임 세이버"
- **캐치프레이즈**: "절대 안 늦는 습관 만들기"

#### F. 개발 팀 및 일정 (3개)

**F-1. ✅ 팀 구성 (최종 결정)**
- **결정**: 바이브코딩 개발자 2명
- **구성**:
  - 개발자 1: Flutter + Android (위젯)
  - 개발자 2: Flutter + iOS (위젯)
  - PM: 프로젝트 관리 + 법적 문서
  - 디자이너: 외주 (UI/UX + 그래픽)
- **예산**: 약 2,565만 원
  - 개발자: 2,000만 원
  - 디자이너: 500만 원
  - API + 스토어: 65만 원

**F-2. ✅ MVP 일정 (최종 결정)**
- **결정**: 25일 (2026.01.31까지)
- **마일스톤**:
  - Week 1 (Day 1~5): UI 구현
  - Week 2 (Day 6~10): 핵심 로직 + API 연동
  - Week 3 (Day 11~15): 위젯 + 알림
  - Week 4 (Day 16~20): 통합 테스트 + 버그 수정
  - Week 5 (Day 21~25): 앱스토어 제출 + 출시
- **시작일**: 2026.01.07

**F-3. ✅ 개발 환경 (최종 결정)**
- **기술 스택**: Flutter 3.x
- **IDE**: Android Studio + Xcode
- **버전 관리**: Git + GitHub
- **디자인**: Figma

#### G. 성과 측정 (3개)

**G-1. ✅ 성공 지표 (최종 결정)**
- **Phase 1 목표 (1개월)**:
  - DAU: 200명
  - MAU: 500명
  - D7 리텐션: 40%+
  - 앱스토어 평점: 4.5+ (50+ 리뷰)
  - 정시 출발 성공률: 75%+
- **Phase 2 목표 (3개월)**:
  - MAU: 1,000명
  - 유료 전환율: 10%
  - 월 구독 수익: 490,000원
- **Phase 3 목표 (6개월)**:
  - MAU: 10,000명
  - 유료 전환율: 15%
  - 월 구독 수익: 7,350,000원

**G-2. ✅ Go/No-Go 기준 (최종 결정)**
- **Phase 1 → Phase 2 진행 조건**:
  - MAU 300명 이상
  - D7 리텐션 30% 이상
  - 앱스토어 평점 4.0 이상
  - 치명적 버그 없음
- **실패 시 대응**: 피벗 또는 프로젝트 중단

**G-3. ✅ 사용자 피드백 수집 (최종 결정)**
- **방법**:
  - 인앱 피드백 폼
  - 앱스토어 리뷰 모니터링
  - 사용자 인터뷰 (10명, 월 1회)
- **주기**: 주 1회 검토

### 8.2 의사결정 진행 상황

**전체 진행률**:
```
P0 (긴급): 10/10 완료 (100%) ✅
P1 (중요): 5/5 완료 (100%) ✅
P2 (참고): 3/3 완료 (100%) ✅

전체: 18/18 완료 (100%) ✅
```

**폐기된 항목**:
- ❌ 패널티 수익 배분 (A-1)
- ❌ 환불 정책 (A-2)
- ❌ 외부 PG 연동 (A-3)
- ❌ 지오펜싱 (C-1, Phase 2로 연기)

**새로 추가된 Phase 1 기능**:
- ✅ 홈 위젯 (C-3)
- ✅ 대중교통 지원 (D-2)

---

## 🚀 9. Next Steps / 다음 단계

### 9.1 즉시 실행 (Week 1 Day 1)

1. **API 키 발급** (Critical Path):
   - [ ] Naver Cloud Platform 회원가입
   - [ ] Naver Maps API 키 발급
   - [ ] Naver Transit API 키 발급
   - [ ] 서울시 공공데이터 포털 회원가입
   - [ ] 버스 도착 정보 API 키 발급

2. **개발 환경 셋업**:
   - [ ] Flutter SDK 3.x 설치
   - [ ] Android Studio 설치 + Android SDK
   - [ ] Xcode 설치 (macOS)
   - [ ] Git 저장소 생성 (GitHub)
   - [ ] Figma 디자인 파일 준비

3. **스토어 계정 생성**:
   - [ ] Apple Developer Program 가입 (99$/년)
   - [ ] Google Play Console 가입 (25$ 일회성)

### 9.2 Week 1 준비

1. **디자인 외주**:
   - [ ] UI/UX 디자이너 섭외
   - [ ] Figma 디자인 가이드 전달
   - [ ] 6개 화면 + 위젯 디자인 요청
   - [ ] 앱 아이콘 + 스플래시 화면 제작

2. **법적 문서**:
   - [ ] 개인정보 처리방침 초안 작성
   - [ ] 이용약관 초안 작성
   - [ ] 약관 검토 (법무 자문)

3. **프로젝트 관리**:
   - [ ] Notion/Jira 프로젝트 생성
   - [ ] 25일 일정표 공유
   - [ ] 일일 스탠드업 미팅 일정 수립

### 9.3 리스크 모니터링

1. **주간 체크리스트**:
   - [ ] 개발 진행률 80% 이상 유지
   - [ ] API 호출 횟수 모니터링 (비용 관리)
   - [ ] 배터리 소모 테스트 (주 1회)
   - [ ] 사용자 피드백 수집 (Alpha 테스트)

2. **Go/No-Go 체크포인트**:
   - Week 2 종료: 핵심 로직 완성 여부
   - Week 3 종료: 위젯 동작 검증
   - Week 4 종료: 버그 수 10개 이하

---

## 📄 Appendix / 부록

### A. 주요 API 문서 링크

- **Naver Cloud Platform**:
  - [Maps API 문서](https://api.ncloud-docs.com/docs/ai-naver-mapsgeocoding)
  - [Transit API 문서](https://api.ncloud-docs.com/docs/ai-naver-mapsdirections15)
- **서울시 공공데이터**:
  - [버스 도착 정보 API](http://data.seoul.go.kr)
- **Flutter**:
  - [WidgetKit 연동 가이드](https://docs.flutter.dev/platform-integration/ios/app-extensions)
  - [Jetpack Glance 가이드](https://developer.android.com/jetpack/compose/glance)

### B. 참고 앱

- **Tiimo**: 시각적 타임라인 (ADHD 특화)
- **Forfeit**: 습관 형성 앱 (패널티 시스템)
- **Waze**: 실시간 교통 내비게이션
- **Google Calendar**: 기본 캘린더 (비교 대상)

### C. 용어 사전

- **시간맹 (Time Blindness)**: 시간 흐름을 감각적으로 인지하지 못하는 증상 (ADHD 주요 증상)
- **역산 스케줄링 (Backward Planning)**: 도착 시간으로부터 출발 시간을 역으로 계산
- **Adaptive Polling**: 시간대별로 API 호출 주기를 동적으로 조정하는 기법
- **Geofencing**: GPS로 특정 지역 진입/이탈 감지
- **IAP (In-App Purchase)**: 앱 내 구매 (앱스토어 정책 준수)

---

**문서 관리**:
- 작성자: Claude + 사용자
- 최종 승인: [TBD]
- 다음 리뷰: 2026-01-14 (Week 2 종료 시)
- 문서 버전: 3.0 FINAL

**문서 히스토리**:
- v1.0 (2026-01-06): 초안 작성
- v2.0 (2026-01-06): 의사결정 18개 항목 반영
- v3.0 (2026-01-06): 패널티 폐기, 홈 위젯/대중교통 추가, 최종 통합 완료

---

**🎯 이 문서는 Go Now MVP 개발의 모든 정보를 담은 완결판입니다.**
**팀원들은 이 문서만 읽으면 프로젝트 전체를 이해할 수 있습니다.**

