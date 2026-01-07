# Go Now: Technical Architecture
# Go Now: 기술 아키텍처 상세 설계서

**문서 버전**: 2.0
**작성일**: 2026-01-06
**최종 업데이트**: 2026-01-06 (Phase 1 MVP 반영)
**기술 스택**: Flutter 3.x, Naver Maps/Transit API, WidgetKit, Jetpack Glance

**⭐ Phase 1 MVP (2026.01.31까지)**:
- 역산 스케줄링, 실시간 교통, 대중교통, 홈 위젯
- 페널티 시스템 제외 (Phase 2로 연기)

**Phase 2 (MVP 이후)**:
- Stripe 결제, 지오펜싱, Live Activities

---

## 📐 1. 시스템 아키텍처 개요 / System Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer (Flutter)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  iOS App     │  │ Android App  │  │   Web App    │      │
│  │ (SwiftUI)    │  │ (Jetpack)    │  │  (Optional)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ▲ │
                            │ ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway / Load Balancer               │
└─────────────────────────────────────────────────────────────┘
                            ▲ │
                            │ ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend Services (Node.js)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Trip       │  │  Penalty     │  │  User Auth   │      │
│  │  Scheduler   │  │  Validator   │  │   Service    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ▲ │
                            │ ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Naver Maps   │  │   Stripe     │  │  Kakao Talk  │      │
│  │     API      │  │   Payment    │  │   API        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 핵심 기술 스택

| Layer | Technology | Phase | Rationale |
|-------|------------|-------|-----------|
| **Frontend** | Flutter 3.x (Dart) | 1 | 크로스 플랫폼 개발 효율성, 빠른 UI 렌더링 |
| **iOS Widget** | SwiftUI + WidgetKit | 1 ⭐ | 홈 화면 위젯 (iOS 14+) |
| **Android Widget** | Jetpack Glance | 1 ⭐ | 홈 화면 위젯 (Flutter 호환성 우수) |
| **Maps (자차)** | Naver Directions API | 1 | 한국 시장 정확도 최우선 |
| **Maps (대중교통)** | Naver Transit API | 1 ⭐ | 버스/지하철 실시간 경로 |
| **실시간 버스** | 서울시 공공데이터 | 1 ⭐ | 버스 도착 정보 |
| **Backend** | Node.js (Express) | 1 | 비동기 I/O, API 호출 최적화 |
| **Database** | SQLite (로컬) | 1 | Phase 1은 서버 불필요 |
| **iOS Native (고급)** | ActivityKit | 2 | Live Activities (Dynamic Island) |
| **Payment** | Stripe / 토스페이먼츠 | 2 | 페널티 결제 시스템 |
| **Messaging** | Kakao Developers API | 2+ | 소셜 프레셔 기능 |

---

## 🗺️ 2. 지도 및 경로 탐색 / Maps & Navigation

### 2.1 API 비용 최적화 전략

**Google Maps Platform 2025년 가격 정책 변화**:
- 기존: 월 $200 통합 크레딧
- 신규 (2025.03.01~): 제품군별(Maps, Routes, Places) 무료 사용량 분리
- 리스크: Routes API 트래픽 포함 시 비용 급증

**대응 전략: 네이버 API 우선 사용**

```typescript
/**
 * 경로 탐색 API 호출 전략 / Route Search API Strategy
 *
 * **비즈니스 규칙 / Business Rule**:
 * - 네이버 API를 기본으로 사용 (한국 데이터 품질 + 비용 효율)
 * - Google은 폴백(Fallback)으로만 활용
 *
 * **Context**: 사용자의 출발 시간 계산 엔진
 */
async function calculateDepartureTime(
  origin: LatLng,
  destination: LatLng,
  arrivalTime: DateTime
): Promise<DepartureTimeResult> {
  try {
    // 1차 시도: 네이버 Directions API
    const naverResult = await naverMapsAPI.getDrivingRoute(origin, destination);
    const travelDuration = naverResult.duration; // 초 단위

    // 역산 계산: 도착 시간 - 이동 시간 - 준비 시간
    const preparationTime = user.settings.preparationMinutes * 60;
    const bufferTime = 5 * 60; // 5분 여유

    const departureTimestamp = arrivalTime.unix()
      - travelDuration
      - preparationTime
      - bufferTime;

    return {
      departureTime: DateTime.fromUnix(departureTimestamp),
      travelDuration,
      trafficCondition: naverResult.trafficLevel, // '원활', '지체', '정체'
    };
  } catch (error) {
    // 2차 시도: Google Routes API (폴백)
    console.warn('Naver API failed, using Google fallback');
    return await googleMapsAPI.getRouteWithTraffic(origin, destination);
  }
}
```

### 2.2 Adaptive Polling (적응형 API 호출)

**목표**: API 호출 횟수를 최소화하여 비용 절감

| 시간대 | 호출 주기 | API 타입 | 이유 |
|--------|-----------|----------|------|
| **D-Day 이전** | 호출 없음 | - | 통계 데이터만 사용 |
| **1시간 전** | 15분 간격 | Summary API | 대략적 트래픽 모니터링 |
| **30분 전** | 5분 간격 | Full Route API | 정밀 계산 시작 |
| **10분 전** | 3분 간격 | Full Route API | 크리티컬 모드 |

```dart
// Flutter - Adaptive Polling Service
class AdaptivePollingService {
  Timer? _pollingTimer;

  /// 약속까지 남은 시간에 따라 API 호출 주기 조정
  void startAdaptivePolling(Trip trip) {
    final timeUntilDeparture = trip.departureTime.difference(DateTime.now());

    Duration interval;
    if (timeUntilDeparture.inMinutes > 60) {
      interval = Duration(minutes: 15); // 느긋하게
    } else if (timeUntilDeparture.inMinutes > 30) {
      interval = Duration(minutes: 5); // 주의 단계
    } else {
      interval = Duration(minutes: 3); // 긴급 모드
    }

    _pollingTimer = Timer.periodic(interval, (_) async {
      final updatedRoute = await RouteService.calculateRoute(
        origin: trip.origin,
        destination: trip.destination,
      );

      // 이전 호출 대비 변화율 계산
      final changeRate = _calculateChangeRate(trip.lastRoute, updatedRoute);

      // 변화가 미미하면 호출 스킵 (캐싱 효과)
      if (changeRate < 0.05) { // 5% 미만 변화
        print('Traffic stable, skipping next poll');
        return;
      }

      // 출발 시간 업데이트 및 알림
      _updateDepartureTime(updatedRoute);
    });
  }
}
```

### 2.3 네이버 vs 카카오 API 하이브리드 전략

| 기능 | 사용 API | Phase | 이유 |
|------|----------|-------|------|
| **경로 탐색 (자차)** | 네이버 Directions API | 1 | 실시간 교통 정보 정확도 최고 |
| **대중교통 경로** | 네이버 Transit API | 1 ⭐ | 버스/지하철 통합 경로 |
| **실시간 버스** | 서울시 공공데이터 | 1 ⭐ | 버스 도착 정보 |
| **소셜 공유** | 카카오톡 메시지 API | 2+ | 친구에게 지각 알림 전송 |
| **택시 호출** | 카카오 T 딥링크 | 2+ | 긴급 상황 대응 |

---

## 🚇 2.4 대중교통 지원 / Public Transportation Support (⭐ Phase 1 MVP)

### 2.4.1 네이버 Transit API 연동

**기능**: 버스/지하철 통합 경로 탐색

```dart
// lib/services/transit_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransitService {
  static const String _baseUrl = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/transit';

  /// 대중교통 경로 탐색 / Public Transit Route Search
  ///
  /// **Context**: 사용자가 대중교통 모드 선택 시
  /// **API**: 네이버 Transit API (대중교통)
  Future<TransitRoute> getTransitRoute({
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
      return TransitRoute.fromJson(data['route']['traoptimal'][0]);
    } else {
      throw Exception('Failed to load transit route');
    }
  }
}

class TransitRoute {
  final int duration; // 소요 시간 (초)
  final int fare; // 요금
  final List<TransitSegment> segments; // 구간 정보

  TransitRoute({
    required this.duration,
    required this.fare,
    required this.segments,
  });

  factory TransitRoute.fromJson(Map<String, dynamic> json) {
    return TransitRoute(
      duration: json['summary']['duration'],
      fare: json['summary']['fare']['regular'],
      segments: (json['path'] as List)
          .map((segment) => TransitSegment.fromJson(segment))
          .toList(),
    );
  }
}

class TransitSegment {
  final String mode; // "BUS", "SUBWAY", "WALK"
  final String? routeName; // 버스 번호 또는 지하철 호선
  final int duration; // 구간 소요 시간

  TransitSegment({
    required this.mode,
    this.routeName,
    required this.duration,
  });

  factory TransitSegment.fromJson(Map<String, dynamic> json) {
    return TransitSegment(
      mode: json['mode'],
      routeName: json['routeName'],
      duration: json['duration'],
    );
  }
}
```

### 2.4.2 실시간 버스 도착 정보 (서울시 공공데이터)

**API**: 서울시 버스도착정보조회 서비스

```dart
// lib/services/seoul_bus_service.dart
class SeoulBusService {
  static const String _baseUrl = 'http://ws.bus.go.kr/api/rest/arrive';

  /// 버스 도착 정보 조회 / Real-time Bus Arrival Info
  ///
  /// **Context**: 사용자가 버스 정류장 대기 중
  /// **API**: 서울시 공공데이터 - 버스도착정보
  Future<List<BusArrival>> getBusArrival(String stationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/getArrInfoByStId'
          '?serviceKey=$seoulApiKey'
          '&stId=$stationId'
          '&resultType=json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final arrivals = data['msgBody']['itemList'] as List;
      return arrivals.map((item) => BusArrival.fromJson(item)).toList();
    }
    throw Exception('Failed to load bus arrival info');
  }
}

class BusArrival {
  final String busNumber; // 버스 번호
  final int arrivalTime; // 도착 예정 시간 (초)
  final int remainingStops; // 남은 정류장 수
  final String congestion; // 혼잡도 ("여유", "보통", "혼잡")

  BusArrival({
    required this.busNumber,
    required this.arrivalTime,
    required this.remainingStops,
    required this.congestion,
  });

  factory BusArrival.fromJson(Map<String, dynamic> json) {
    return BusArrival(
      busNumber: json['rtNm'],
      arrivalTime: json['arrmsg1'].contains('분')
          ? int.parse(json['arrmsg1'].replaceAll('분후[', '').split('번째')[0]) * 60
          : 0,
      remainingStops: json['stOrd'],
      congestion: json['reride_Num1'] ?? '정보없음',
    );
  }
}
```

### 2.4.3 대중교통 모드 UI 구현

```dart
// lib/screens/schedule_add_screen.dart
class ScheduleAddScreen extends StatefulWidget {
  @override
  _ScheduleAddScreenState createState() => _ScheduleAddScreenState();
}

class _ScheduleAddScreenState extends State<ScheduleAddScreen> {
  TransportMode _selectedMode = TransportMode.driving;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// 이동 수단 선택 / Transportation Mode Selector
          SegmentedButton<TransportMode>(
            segments: const [
              ButtonSegment(
                value: TransportMode.driving,
                icon: Icon(Icons.directions_car),
                label: Text('자차'),
              ),
              ButtonSegment(
                value: TransportMode.transit,
                icon: Icon(Icons.directions_transit),
                label: Text('대중교통'),
              ),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (Set<TransportMode> newSelection) {
              setState(() {
                _selectedMode = newSelection.first;
              });
            },
          ),

          /// 경로 정보 표시
          if (_selectedMode == TransportMode.transit)
            FutureBuilder<TransitRoute>(
              future: TransitService().getTransitRoute(
                origin: userLocation,
                destination: destinationLocation,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TransitRouteCard(route: snapshot.data!);
                }
                return CircularProgressIndicator();
              },
            ),
        ],
      ),
    );
  }
}

enum TransportMode { driving, transit }
```

### 2.4.4 대중교통 역산 스케줄링

```dart
/// 대중교통 이용 시 출발 시간 계산 / Transit Departure Time Calculation
///
/// **비즈니스 규칙 / Business Rule**:
/// - 첫차/막차 시간 체크
/// - 배차 간격 고려 (평균 대기 시간 추가)
/// - 환승 시간 버퍼 추가
Future<DateTime> calculateTransitDepartureTime({
  required LatLng origin,
  required LatLng destination,
  required DateTime arrivalTime,
  required int preparationMinutes,
}) async {
  // 1. 대중교통 경로 조회
  final route = await TransitService().getTransitRoute(
    origin: origin,
    destination: destination,
  );

  // 2. 소요 시간 계산
  int totalDuration = route.duration; // 이동 시간

  // 3. 배차 간격 고려 (평균 대기 시간)
  int averageWaitTime = 5 * 60; // 5분 (보수적 추정)
  totalDuration += averageWaitTime;

  // 4. 환승 버퍼 시간 (환승 2회 이상 시)
  int transferCount = route.segments.where((s) => s.mode != 'WALK').length - 1;
  if (transferCount > 0) {
    totalDuration += transferCount * 3 * 60; // 환승당 3분 추가
  }

  // 5. 역산 계산
  final departureTime = arrivalTime.subtract(
    Duration(
      seconds: totalDuration + (preparationMinutes * 60) + (5 * 60), // 5분 여유
    ),
  );

  // 6. 첫차/막차 체크
  if (departureTime.hour < 5 || departureTime.hour > 24) {
    throw Exception('대중교통 운행 시간이 아닙니다. 택시 이용을 권장합니다.');
  }

  return departureTime;
}
```

---

## 📍 3. 백그라운드 위치 추적 / Background Geofencing (⚠️ Phase 2)

### 3.1 배터리 최적화 아키텍처

**문제**: 실시간 GPS 추적 → 배터리 광탈 → 앱 삭제

**해결**: Motion Detection + Adaptive Geofencing

```yaml
# flutter_background_geolocation 설정
bg_geo:
  desiredAccuracy: MEDIUM # HIGH는 배터리 과다 소모
  distanceFilter: 50 # 50m 이동 시에만 위치 업데이트

  # 핵심: Motion Detection
  stopTimeout: 5 # 정지 5분 후 GPS 완전 OFF
  stopOnTerminate: false # 앱 종료 시에도 지오펜스 모니터링 유지
  startOnBoot: true # 기기 재부팅 시 자동 시작

  # Android Doze Mode 대응
  enableHeadless: true # 백그라운드에서도 Dart 코드 실행
  foregroundService: true # 안드로이드 포그라운드 서비스 (알림 표시)

  # iOS 최적화
  pausesLocationUpdatesAutomatically: true # 정지 시 자동 일시정지
  activityType: OTHER # 자동차, 도보 등에 따라 최적화
```

### 3.2 지오펜스 이탈 감지 로직

```dart
/**
 * 지오펜스 이탈 이벤트 핸들러 / Geofence Exit Handler
 *
 * **법적 근거 / Legal Basis**:
 * - Grace Period 5분 필수 (안드로이드 배터리 세이버로 인한 지연 고려)
 * - 억울한 페널티 방지 위한 안전장치
 *
 * **Context**: 사용자가 집을 나가는 순간 감지
 */
class GeofenceHandler {
  static const GRACE_PERIOD_SECONDS = 300; // 5분 유예

  Future<void> onGeofenceExit(GeofenceEvent event) async {
    if (event.identifier != 'home_geofence') return;

    final trip = await TripService.getCurrentActiveTrip();
    if (trip == null) return;

    final now = DateTime.now();
    final deadline = trip.departureTime;

    // 유예 시간 적용 (OS 지연 고려)
    final actualDeadline = deadline.add(Duration(seconds: GRACE_PERIOD_SECONDS));

    if (now.isBefore(actualDeadline)) {
      // ✅ 성공: 제시간 출발
      await _handleSuccess(trip);
    } else {
      // ❌ 실패: 페널티 발생
      final delaySeconds = now.difference(actualDeadline).inSeconds;
      await _handleFailure(trip, delaySeconds);
    }
  }

  Future<void> _handleSuccess(Trip trip) async {
    // Stripe PaymentIntent 취소 (수수료 0원)
    await StripeService.cancelPaymentIntent(trip.paymentIntentId);

    // 연속 성공(Streak) 카운트 증가
    await UserService.incrementStreak();

    // 긍정적 강화 알림
    await NotificationService.show(
      title: '🎉 성공!',
      body: '${trip.streakCount}일 연속 정시 출발 중!',
    );
  }

  Future<void> _handleFailure(Trip trip, int delaySeconds) async {
    // Stripe PaymentIntent 결제 확정 (Capture)
    await StripeService.capturePaymentIntent(
      trip.paymentIntentId,
      amount: trip.pledgeAmount,
    );

    // 실패 이력 저장 (소명 요청 대비)
    await PenaltyService.recordFailure(
      tripId: trip.id,
      delaySeconds: delaySeconds,
      exitTimestamp: DateTime.now(),
      gpsAccuracy: event.location.accuracy, // 분쟁 시 증거자료
    );

    // 알림
    await NotificationService.show(
      title: '😢 페널티 발생',
      body: '${delaySeconds}초 지각 → ${trip.pledgeAmount}원 차감',
    );
  }
}
```

### 3.3 지오펜스 반경 설정 전략

**기획 질문**: 집을 나섰다의 기준은?

| 반경 | 장점 | 단점 | 권장 시나리오 |
|------|------|------|---------------|
| **50m** | 정확한 감지 | GPS 오차로 오판 가능 | 아파트 단지 |
| **100m** | 안정적 | 집 앞 주차장에서도 "나갔다" 판정 가능 | 단독 주택 |
| **150m** | 오판 최소화 | 늦게 반응 (이미 운전 중) | 넓은 단지 |

**최종 권장**: **100m (사용자 조정 가능)**

```dart
// 사용자 설정에서 조정 가능하게
final geofenceRadius = user.settings.homeGeofenceRadius ?? 100.0;

bg_geo.BackgroundGeolocation.addGeofence({
  'identifier': 'home_geofence',
  'latitude': user.homeLocation.lat,
  'longitude': user.homeLocation.lng,
  'radius': geofenceRadius,
  'notifyOnExit': true, // 나갈 때만 감지
  'notifyOnEntry': false,
});
```

---

## 📱 4. 홈 위젯 구현 / Home Widget Implementation (⭐ Phase 1 MVP)

### 4.1 Android 홈 위젯 (Jetpack Glance)

**기술 선택 이유**:
- Jetpack Glance는 Flutter와 호환성이 좋음
- Compose UI 스타일로 선언적 개발 가능
- WorkManager와 통합이 쉬움

#### 4.1.1 Glance Widget 구현

```kotlin
// android/app/src/main/kotlin/widgets/GoNowWidget.kt
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import java.time.Duration
import java.time.Instant

class GoNowWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val nextSchedule = getNextScheduleFromDB(context)

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .padding(16.dp)
                    .background(Color.White)
            ) {
                // 다음 일정명
                Text(
                    text = nextSchedule?.title ?: "일정 없음",
                    style = TextStyle(
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(Color.Black)
                    )
                )

                Spacer(modifier = GlanceModifier.height(8.dp))

                // 출발까지 남은 시간
                if (nextSchedule != null) {
                    val timeUntilDeparture = Duration.between(
                        Instant.now(),
                        nextSchedule.departureTime
                    )

                    Text(
                        text = formatDuration(timeUntilDeparture),
                        style = TextStyle(
                            fontSize = 32.sp,
                            fontWeight = FontWeight.Bold,
                            color = getUrgencyColor(timeUntilDeparture)
                        )
                    )

                    Text(
                        text = "출발까지 남은 시간",
                        style = TextStyle(
                            fontSize = 12.sp,
                            color = ColorProvider(Color.Gray)
                        )
                    )
                }
            }
        }
    }

    private fun formatDuration(duration: Duration): String {
        val minutes = duration.toMinutes()
        return when {
            minutes < 60 -> "${minutes}분"
            else -> "${minutes / 60}시간 ${minutes % 60}분"
        }
    }

    private fun getUrgencyColor(duration: Duration): ColorProvider {
        return when {
            duration.toMinutes() < 10 -> ColorProvider(Color.Red)
            duration.toMinutes() < 30 -> ColorProvider(Color(0xFFFFA500)) // Orange
            else -> ColorProvider(Color(0xFF4CAF50)) // Green
        }
    }
}
```

#### 4.1.2 Widget Update with WorkManager

```kotlin
// android/app/src/main/kotlin/widgets/WidgetUpdateWorker.kt
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.glance.appwidget.updateAll

class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {

    override fun doWork(): Result {
        // Widget 업데이트 / Update Home Widget
        runBlocking {
            GoNowWidget().updateAll(applicationContext)
        }
        return Result.success()
    }
}

// Widget 자동 업데이트 스케줄링 (15분마다)
val updateRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(15, TimeUnit.MINUTES)
    .build()

WorkManager.getInstance(context).enqueueUniquePeriodicWork(
    "widget_update",
    ExistingPeriodicWorkPolicy.KEEP,
    updateRequest
)
```

#### 4.1.3 Flutter ↔ Android Widget 통신

```dart
// lib/services/widget_service.dart
import 'package:flutter/services.dart';

class WidgetService {
  static const _channel = MethodChannel('com.gonow.widget');

  /// Widget 업데이트 요청 / Request Widget Update
  ///
  /// **Context**: 사용자가 일정을 추가/수정할 때
  Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      print('Failed to update widget: ${e.message}');
    }
  }
}
```

---

### 4.2 iOS 홈 위젯 (WidgetKit)

**기술 요구사항**:
- iOS 14+ 필수
- SwiftUI 기반
- Timeline Provider로 자동 업데이트

#### 4.2.1 Widget Extension 생성

```swift
// ios/GoNowWidget/GoNowWidget.swift
import WidgetKit
import SwiftUI

struct GoNowWidgetEntry: TimelineEntry {
    let date: Date
    let scheduleName: String
    let departureTime: Date
}

struct GoNowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GoNowWidgetEntry {
        GoNowWidgetEntry(
            date: Date(),
            scheduleName: "로딩 중...",
            departureTime: Date()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GoNowWidgetEntry) -> Void) {
        let entry = loadNextSchedule()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GoNowWidgetEntry>) -> Void) {
        var entries: [GoNowWidgetEntry] = []
        let currentDate = Date()

        // 15분마다 업데이트 스케줄 생성
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 15, to: currentDate)!
            let entry = loadNextSchedule(for: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .after(entries.last!.date))
        completion(timeline)
    }

    private func loadNextSchedule(for date: Date = Date()) -> GoNowWidgetEntry {
        // SharedUserDefaults에서 다음 일정 로드
        let sharedDefaults = UserDefaults(suiteName: "group.com.gonow.app")
        let scheduleName = sharedDefaults?.string(forKey: "nextScheduleName") ?? "일정 없음"
        let departureTimestamp = sharedDefaults?.double(forKey: "nextDepartureTime") ?? 0

        return GoNowWidgetEntry(
            date: date,
            scheduleName: scheduleName,
            departureTime: Date(timeIntervalSince1970: departureTimestamp)
        )
    }
}

struct GoNowWidgetView: View {
    var entry: GoNowWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 일정명
            Text(entry.scheduleName)
                .font(.headline)
                .foregroundColor(.primary)

            // 출발까지 남은 시간 (자동 카운트다운)
            Text(entry.departureTime, style: .relative)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(urgencyColor)

            Text("출발까지 남은 시간")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
    }

    /// 긴급도에 따른 색상 / Urgency-based Color
    private var urgencyColor: Color {
        let timeUntil = entry.departureTime.timeIntervalSinceNow
        switch timeUntil {
        case ..<600: // 10분 미만
            return .red
        case 600..<1800: // 30분 미만
            return .orange
        default:
            return .green
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
        .configurationDisplayName("Go Now")
        .description("다음 일정까지 남은 시간을 표시합니다")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

#### 4.2.2 Flutter → iOS Widget 데이터 전달

```dart
// lib/services/widget_service.dart (iOS 확장)
class WidgetService {
  /// iOS Widget 데이터 업데이트 / Update iOS Widget Data
  ///
  /// **Context**: 일정 추가/수정 시 SharedUserDefaults에 저장
  Future<void> updateIOSWidget(Schedule schedule) async {
    if (!Platform.isIOS) return;

    final sharedDefaults = await SharedPreferences.getInstance();

    // App Group SharedUserDefaults 사용
    await sharedDefaults.setString(
      'nextScheduleName',
      schedule.title,
    );
    await sharedDefaults.setInt(
      'nextDepartureTime',
      schedule.departureTime.millisecondsSinceEpoch ~/ 1000,
    );

    // Widget 새로고침 요청
    await _channel.invokeMethod('reloadTimelines');
  }
}
```

```swift
// ios/Runner/AppDelegate.swift (Widget 새로고침 핸들러)
import WidgetKit

// Method Channel 핸들러 추가
channel.setMethodCallHandler { (call, result) in
    switch call.method {
    case "reloadTimelines":
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
}
```

---

## 📱 4.3 iOS Live Activities 구현 / iOS Live Activities (⚠️ Phase 2)

### 4.1 Flutter와 SwiftUI 연동

**기술적 제약**:
- Flutter는 Live Activities를 직접 지원하지 않음
- iOS 16.1+ ActivityKit은 Swift 전용

**해결책**: Method Channel로 Flutter ↔ Swift 통신

#### 4.1.1 Flutter (Dart) 측

```dart
// lib/services/live_activity_service.dart
import 'package:flutter/services.dart';

class LiveActivityService {
  static const _channel = MethodChannel('com.gonow.live_activity');

  /// Live Activity 시작 (출발 카운트다운)
  Future<void> startDepartureCountdown({
    required String tripName,
    required DateTime deadline,
  }) async {
    try {
      await _channel.invokeMethod('startActivity', {
        'tripName': tripName,
        'deadlineTimestamp': deadline.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      print('Failed to start Live Activity: ${e.message}');
    }
  }

  /// Live Activity 종료
  Future<void> endActivity() async {
    await _channel.invokeMethod('endActivity');
  }
}
```

#### 4.1.2 iOS (Swift) 측

**1. Activity Attributes 정의**

```swift
// ios/Runner/GoNowLiveActivity/GoNowAttributes.swift
import ActivityKit

struct GoNowAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var deadlineTimestamp: Int64 // Unix 타임스탬프
    }

    var tripName: String
}
```

**2. Widget Extension (잠금 화면 UI)**

```swift
// ios/GoNowLiveActivityExtension/GoNowLiveActivityView.swift
import SwiftUI
import WidgetKit

struct GoNowLiveActivityView: View {
    let context: ActivityViewContext<GoNowAttributes>

    var body: some View {
        VStack(spacing: 12) {
            Text(context.attributes.tripName)
                .font(.headline)
                .foregroundColor(.white)

            // 핵심: OS가 알아서 1초씩 줄어드는 타이머 렌더링
            Text(timerInterval: Date()...deadline, countsDown: true)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.red)
                .monospacedDigit() // 숫자 너비 고정 (깜빡임 방지)

            Text("남은 시간")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .activityBackgroundTint(.black)
    }

    var deadline: Date {
        Date(timeIntervalSince1970: TimeInterval(context.state.deadlineTimestamp) / 1000)
    }
}
```

**3. Method Channel 핸들러**

```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import ActivityKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var currentActivity: Activity<GoNowAttributes>?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.gonow.live_activity",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "startActivity":
                self?.startActivity(call: call, result: result)
            case "endActivity":
                self?.endActivity(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func startActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let tripName = args["tripName"] as? String,
              let deadlineTimestamp = args["deadlineTimestamp"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
            return
        }

        let attributes = GoNowAttributes(tripName: tripName)
        let state = GoNowAttributes.ContentState(deadlineTimestamp: deadlineTimestamp)

        do {
            currentActivity = try Activity<GoNowAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil // 서버 푸시 불필요 (OS가 알아서 카운트다운)
            )
            result(nil)
        } catch {
            result(FlutterError(code: "ACTIVITY_FAILED", message: error.localizedDescription, details: nil))
        }
    }

    private func endActivity(result: @escaping FlutterResult) {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            result(nil)
        }
    }
}
```

### 4.2 실시간 업데이트 전략

**잘못된 방식** ❌:
```dart
// Flutter에서 1초마다 Method Channel 호출 → 배터리 광탈
Timer.periodic(Duration(seconds: 1), (timer) {
  LiveActivityService.updateCountdown(remainingSeconds);
});
```

**올바른 방식** ✅:
```swift
// Swift에서 한 번만 deadline을 전달하면, iOS가 알아서 카운트다운 렌더링
Text(timerInterval: Date()...deadline, countsDown: true)
```

**교통 변화 시 업데이트**:
- 실시간 트래픽으로 도착 시간이 변하면?
- 서버에서 APNs(Apple Push Notification Service)로 새로운 deadline 전송
- 단, 너무 자주 업데이트하면 사용자 혼란 → **10분 이상 변화 시에만 업데이트**

---

## 🤖 5. 안드로이드 위젯 / Android Widget

### 5.1 홈 화면 위젯 구현

```kotlin
// android/app/src/main/kotlin/GoNowWidgetProvider.kt
class GoNowWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_countdown)

            // 카운트다운 시작 (Chronometer 사용)
            val deadline = getDeadlineFromPrefs(context)
            views.setChronometer(
                R.id.countdown_timer,
                deadline,
                null,
                true
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
```

### 5.2 포그라운드 서비스 (Foreground Service)

```dart
// Flutter에서 안드로이드 포그라운드 서비스 시작
await FlutterForegroundTask.startService(
  notificationTitle: 'Go Now 활성화',
  notificationText: '출발까지 ${remainingMinutes}분',
);
```

---

## 💳 6. 결제 시스템 / Payment Integration

### 6.1 Stripe PaymentIntent 생애주기

```typescript
/**
 * 페널티 결제 프로세스 / Penalty Payment Flow
 *
 * **비즈니스 규칙 / Business Rule**:
 * - 목표 설정 시: 승인만 (결제 X) → 수수료 0원
 * - 성공 시: 취소 → 수수료 0원
 * - 실패 시: 결제 확정 → 수수료 발생
 *
 * **Context**: 사용자가 "10,000원 걸기" 버튼 클릭
 */
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// 1단계: 목표 설정 시 (승인만)
async function createPledge(userId: string, amount: number): Promise<string> {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount * 100, // 10,000원 → 1,000,000 (cent 단위)
    currency: 'krw',
    customer: userId,
    capture_method: 'manual', // 핵심: 수동 결제 확정
    metadata: {
      type: 'penalty_pledge',
    },
  });

  return paymentIntent.id;
}

// 2단계-A: 성공 시 (취소)
async function cancelPledge(paymentIntentId: string): Promise<void> {
  await stripe.paymentIntents.cancel(paymentIntentId);
  // 수수료 0원, 카드 승인 해제
}

// 2단계-B: 실패 시 (결제 확정)
async function capturePenalty(paymentIntentId: string): Promise<void> {
  await stripe.paymentIntents.capture(paymentIntentId);
  // 이제 실제로 돈이 차감됨

  // 수익 배분 (예: 회사 70%, 자선 30%)
  const amount = (await stripe.paymentIntents.retrieve(paymentIntentId)).amount;
  await stripe.transfers.create({
    amount: Math.floor(amount * 0.3),
    currency: 'krw',
    destination: 'acct_charity_account', // 자선단체 Stripe 계정
  });
}
```

### 6.2 환불 및 소명 프로세스

```typescript
/**
 * 억울한 페널티 환불 처리 / Dispute Refund Handler
 *
 * **법적 근거 / Legal Basis**:
 * - 소비자 보호법: 시스템 오류 시 환불 의무
 * - GPS 정확도 < 20m 시 자동 승인
 *
 * **Context**: 사용자가 "억울해요!" 버튼 클릭
 */
async function handleDisputeRefund(penaltyId: string, reason: string): Promise<void> {
  const penalty = await db.penalties.findById(penaltyId);

  // 자동 승인 조건 체크
  if (penalty.gpsAccuracy > 20) {
    // GPS 오차가 20m 이상 → 자동 환불
    await stripe.refunds.create({
      payment_intent: penalty.paymentIntentId,
      reason: 'requested_by_customer',
    });

    await db.penalties.update(penaltyId, {
      status: 'refunded_auto',
      refundReason: 'GPS accuracy issue',
    });

    return;
  }

  // 수동 심사 큐에 추가
  await db.disputeQueue.create({
    penaltyId,
    reason,
    status: 'pending_review',
    createdAt: new Date(),
  });

  // CS 팀에게 알림
  await sendSlackNotification('#cs-team', `새로운 환불 요청: ${penaltyId}`);
}
```

---

## 🔒 7. 보안 및 프라이버시 / Security & Privacy

### 7.1 위치 데이터 보호

**법적 규제**:
- GDPR (유럽), CCPA (캘리포니아), 개인정보보호법 (한국)
- 위치 정보는 **민감 정보**로 분류

**구현 원칙**:
```yaml
위치_데이터_처리:
  수집_최소화: 지오펜스 이탈 순간만 기록, 이동 경로는 저장 안 함
  암호화:
    - 전송: TLS 1.3
    - 저장: AES-256 암호화
  보존_기간: 90일 후 자동 삭제
  사용자_권한:
    - 위치 데이터 다운로드 가능
    - 언제든지 삭제 요청 가능
```

### 7.2 Stripe 결제 보안

```typescript
// PCI DSS 준수: 카드 정보는 절대 서버에 저장하지 않음
// Stripe.js가 클라이언트에서 직접 토큰화

// Flutter → Stripe 직접 통신
const paymentMethod = await Stripe.instance.createPaymentMethod(
  PaymentMethodParams.card(
    paymentMethodData: PaymentMethodData(
      billingDetails: BillingDetails(name: userName),
    ),
  ),
);

// 서버는 토큰(paymentMethod.id)만 받음
await apiClient.post('/api/pledges', {
  'paymentMethodId': paymentMethod.id,
  'amount': 10000,
});
```

---

## 📊 8. 데이터베이스 스키마 / Database Schema

### 8.1 PostgreSQL ERD

```sql
-- 사용자 테이블
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100),
  home_location GEOGRAPHY(POINT, 4326), -- PostGIS 활용
  home_geofence_radius INTEGER DEFAULT 100, -- 미터
  preparation_minutes INTEGER DEFAULT 15,
  stripe_customer_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 약속/일정 테이블
CREATE TABLE trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  destination_location GEOGRAPHY(POINT, 4326),
  destination_address TEXT,
  arrival_time TIMESTAMP NOT NULL,
  departure_time TIMESTAMP NOT NULL, -- 역산된 출발 시간

  pledge_amount INTEGER, -- 서약금 (원 단위)
  payment_intent_id VARCHAR(255), -- Stripe PaymentIntent ID

  status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, success, failed

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 페널티 이력 테이블
CREATE TABLE penalties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,

  amount INTEGER NOT NULL,
  delay_seconds INTEGER, -- 몇 초 지각했는지
  exit_timestamp TIMESTAMP, -- 실제 지오펜스 이탈 시각
  gps_accuracy FLOAT, -- GPS 정확도 (미터)

  payment_intent_id VARCHAR(255),
  payment_status VARCHAR(20), -- captured, refunded, disputed

  dispute_reason TEXT,
  dispute_status VARCHAR(20), -- pending, approved, rejected

  created_at TIMESTAMP DEFAULT NOW()
);

-- 연속 성공(Streak) 테이블
CREATE TABLE user_streaks (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_success_date DATE,
  total_successes INTEGER DEFAULT 0,
  total_failures INTEGER DEFAULT 0
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_trips_user_status ON trips(user_id, status);
CREATE INDEX idx_penalties_user ON penalties(user_id);
CREATE INDEX idx_trips_departure_time ON trips(departure_time);
```

---

## 🚀 9. 배포 및 인프라 / Deployment & Infrastructure

### 9.1 클라우드 아키텍처 (AWS 기준)

```
┌─────────────────────────────────────────────────┐
│              Route 53 (DNS)                     │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│     CloudFront (CDN) + WAF                      │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│  Application Load Balancer (ALB)                │
└─────────────────────────────────────────────────┘
          │                          │
          ▼                          ▼
┌──────────────────┐       ┌──────────────────┐
│  ECS Fargate     │       │  ECS Fargate     │
│  (API Server)    │       │  (API Server)    │
│  Auto Scaling    │       │  Auto Scaling    │
└──────────────────┘       └──────────────────┘
          │                          │
          └──────────┬───────────────┘
                     ▼
        ┌──────────────────────────┐
        │   RDS PostgreSQL         │
        │   (Multi-AZ)             │
        └──────────────────────────┘
                     │
                     ▼
        ┌──────────────────────────┐
        │   ElastiCache Redis      │
        │   (Session, API Cache)   │
        └──────────────────────────┘
```

### 9.2 CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Flutter Tests
        run: |
          flutter pub get
          flutter test
      - name: Run Backend Tests
        run: |
          cd backend
          npm install
          npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker Image
        run: |
          docker build -t gonow-api:${{ github.sha }} .
          docker push $ECR_REGISTRY/gonow-api:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster gonow-prod \
            --service gonow-api \
            --force-new-deployment
```

---

## 📈 10. 모니터링 및 관찰성 / Monitoring & Observability

### 10.1 핵심 지표 모니터링

| 지표 | 목표 | 알림 임계값 | 도구 |
|------|------|-------------|------|
| **API 응답 시간** | < 200ms | > 500ms | CloudWatch |
| **지오펜스 감지 지연** | < 30초 | > 60초 | Custom Metric |
| **페널티 오판률** | < 5% | > 10% | Mixpanel |
| **배터리 소모** | < 10%/일 | > 15%/일 | Firebase Performance |
| **Stripe 결제 실패율** | < 2% | > 5% | Stripe Dashboard |

### 10.2 에러 추적

```typescript
// Sentry 연동 (에러 추적)
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1, // 10% 트랜잭션 추적
});

// 에러 발생 시 자동 리포팅
app.use(Sentry.Handlers.errorHandler());
```

---

## ✅ 11. 기술적 체크리스트 / Technical Checklist

### Phase 1 (MVP) - 필수 구현 항목

- [ ] Flutter 프로젝트 초기화 (iOS/Android)
- [ ] 네이버 Maps API 연동 (Directions)
- [ ] 역산 스케줄링 알고리즘 구현
- [ ] 로컬 푸시 알림 (flutter_local_notifications)
- [ ] 준비 시간 설정 UI
- [ ] 카운트다운 화면 (실시간 타이머)

### Phase 2 (페널티) - 결제 및 지오펜싱

- [ ] flutter_background_geolocation 설정 및 테스트
- [ ] 지오펜스 생성/모니터링 로직
- [ ] Stripe SDK 연동 (Flutter)
- [ ] PaymentIntent 생애주기 구현
- [ ] Node.js 백엔드 API 구축
- [ ] PostgreSQL 스키마 구현
- [ ] Grace Period 로직 (5분 유예)
- [ ] 환불/소명 프로세스 UI

### Phase 3 (고도화) - 네이티브 최적화

- [ ] iOS Live Activities (Swift + ActivityKit)
- [ ] Method Channel 구현 (Flutter ↔ Swift)
- [ ] 안드로이드 홈 위젯 (Kotlin)
- [ ] 카카오톡 API 연동 (알림톡)
- [ ] 대중교통 모드 (버스/지하철 실시간 정보)
- [ ] Apple Watch / Galaxy Watch 확장

---

## 🔗 12. 참고 자료 / Technical References

### Flutter 패키지
- [flutter_background_geolocation](https://pub.dev/packages/flutter_background_geolocation)
- [live_activities](https://pub.dev/packages/live_activities)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

### API 문서
- [Naver Cloud Platform - Directions API](https://api.ncloud-docs.com/docs/ai-naver-mapsgeocoding-geocode)
- [Kakao Developers - Mobility API](https://developers.kakao.com/docs/latest/ko/local/dev-guide)
- [Stripe API - PaymentIntents](https://stripe.com/docs/api/payment_intents)

### iOS 개발
- [Apple ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)
- [iOS Background Execution Limits](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/about_the_background_execution_sequence)

### Android 개발
- [Android Background Location Limits](https://developer.android.com/about/versions/oreo/background-location-limits)
- [Android Doze Mode](https://developer.android.com/training/monitoring-device-state/doze-standby)

---

**다음 단계**:
1. 개발 환경 설정 (Flutter 3.x, Xcode, Android Studio)
2. 네이버 API 키 발급 및 테스트
3. MVP 프로토타입 개발 시작 (2주 스프린트)

**문서 관리**:
- 업데이트 주기: 매 스프린트 종료 시
- 기술 리뷰: CTO/Lead Developer
