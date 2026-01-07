# TMAP API Migration Documentation

## Overview
**Date**: 2025-01-07
**Migration**: Naver Directions API 5.0 → TMAP Routes API
**Reason**: Naver API subscription/permission issues despite proper configuration

## Migration Summary

### Before (Naver Directions API 5.0)
- **Base URL**: `https://naveropenapi.apigw.ntruss.com`
- **Endpoint**: `/map-direction/v1/driving`
- **Method**: GET
- **Authentication**: Dual header system
  - `X-NCP-APIGW-API-KEY-ID`: Client ID
  - `X-NCP-APIGW-API-KEY`: Client Secret
- **Request Format**: Query parameters

### After (TMAP Routes API)
- **Base URL**: `https://apis.openapi.sk.com`
- **Endpoint**: `/tmap/routes?version=1`
- **Method**: POST
- **Authentication**: Single header
  - `appKey`: TMAP API Key
- **Request Format**: JSON body

## Technical Changes

### 1. API Configuration

**Before (Naver)**:
```dart
_dio = Dio(
  BaseOptions(
    baseUrl: 'https://naveropenapi.apigw.ntruss.com',
    headers: {
      'X-NCP-APIGW-API-KEY-ID': clientId,
      'X-NCP-APIGW-API-KEY': clientSecret,
    },
  ),
);
```

**After (TMAP)**:
```dart
_dio = Dio(
  BaseOptions(
    baseUrl: 'https://apis.openapi.sk.com',
    headers: {
      'Content-Type': 'application/json',
      'appKey': appKey,
    },
  ),
);
```

### 2. API Request

**Before (Naver)**:
```dart
final response = await _dio.get(
  '/map-direction/v1/driving',
  queryParameters: {
    'start': '$originLng,$originLat',
    'goal': '$destLng,$destLat',
    'option': option,
  },
);
```

**After (TMAP)**:
```dart
final response = await _dio.post(
  '/tmap/routes?version=1',
  data: {
    'startX': originLng.toString(),
    'startY': originLat.toString(),
    'endX': destLng.toString(),
    'endY': destLat.toString(),
    'reqCoordType': 'WGS84GEO',
    'resCoordType': 'WGS84GEO',
    'searchOption': searchOption.toString(),
    'trafficInfo': 'Y',
  },
);
```

### 3. Route Option Mapping

**Naver → TMAP Mapping**:
```dart
int _mapRouteOption(String option) {
  switch (option) {
    case 'trafast':      // 빠른 길
      return 2;          // TMAP: 최단시간
    case 'tracomfort':   // 편한 길
    case 'traoptimal':   // 최적
    default:
      return 0;          // TMAP: 추천
  }
}
```

### 4. Response Parsing

**Before (Naver)**:
```dart
final route = data['route']['trafast'][0];
final summary = route['summary'];

final result = RouteResult(
  durationMinutes: ((summary['duration'] ?? 0) / 60000).ceil(),
  distanceKm: ((summary['distance'] ?? 0) / 1000).toDouble(),
  path: route['path'],
  // ...
);
```

**After (TMAP)**:
```dart
final features = data['features'] as List<dynamic>;
final properties = features[0]['properties'] as Map<String, dynamic>;

final result = RouteResult(
  durationMinutes: ((properties['totalTime'] ?? 0) / 60).ceil(), // 초 → 분
  distanceKm: ((properties['totalDistance'] ?? 0) / 1000).toDouble(), // 미터 → km
  trafficLevel: TrafficLevel.unknown, // TMAP은 상세 교통 레벨 제공 안함
  path: _extractPath(features),
  tollFare: properties['totalFare'] ?? 0,
  taxiFare: properties['taxiFare'] ?? 0,
  fuelPrice: 0, // TMAP API는 유류비 제공 안함
);
```

### 5. Path Extraction (GeoJSON)

TMAP은 GeoJSON LineString 형식으로 경로를 제공합니다:

```dart
List<dynamic>? _extractPath(List<dynamic> features) {
  final paths = <Map<String, double>>[];

  for (final feature in features) {
    if (feature['geometry'] != null &&
        feature['geometry']['type'] == 'LineString') {
      final coordinates = feature['geometry']['coordinates'] as List<dynamic>;
      for (final coord in coordinates) {
        if (coord is List && coord.length >= 2) {
          paths.add({
            'lng': (coord[0] as num).toDouble(),
            'lat': (coord[1] as num).toDouble(),
          });
        }
      }
    }
  }

  return paths.isEmpty ? null : paths;
}
```

## TMAP POI Search Service Integration

### Overview
**Date**: 2025-01-07
**New Service**: POI (Point of Interest) Search API
**Purpose**: Real-time place search for schedule destination selection

### Service Implementation

**File**: `lib/services/poi_search_service.dart`

```dart
class POISearchService {
  /// Singleton pattern
  static final POISearchService _instance = POISearchService._internal();
  factory POISearchService() => _instance;

  /// 장소 검색 / Search places
  Future<List<POIResult>> searchPOI({
    required String keyword,
    int count = 10,
  }) async {
    final response = await _dio.get(
      '/tmap/pois',
      queryParameters: {
        'version': '1',
        'searchKeyword': keyword,
        'resCoordType': 'WGS84GEO',
        'reqCoordType': 'WGS84GEO',
        'count': count.toString(),
      },
    );
    // Returns POIResult objects
  }
}
```

### POI Search Configuration

**API Configuration**:
```dart
_dio = Dio(
  BaseOptions(
    baseUrl: 'https://apis.openapi.sk.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'appKey': appKey,
    },
  ),
);
```

### Response Model

```dart
class POIResult {
  final String id;           // POI ID
  final String name;         // 장소 이름
  final String address;      // 전체 주소
  final double lat;          // 위도 (WGS84)
  final double lng;          // 경도 (WGS84)
  final String category;     // 카테고리 (예: "음식점", "지하철")
  final String? telNo;       // 전화번호
  final String? roadAddress; // 도로명 주소

  /// 표시용 주소 (도로명 우선) / Display address
  String get displayAddress => roadAddress ?? address;
}
```

### Error Handling

```dart
enum POIErrorType {
  networkError,
  networkTimeout,
  invalidApiKey,
  rateLimitExceeded,
  apiError,
  cancelled,
  unknown,
}

class POISearchException implements Exception {
  final String message;
  final POIErrorType type;
  final Object? originalError;

  String get userMessage {
    // User-friendly error messages in Korean
  }
}
```

### Integration Points

#### 1. Service Initialization (main.dart)
```dart
void main() async {
  // ... other initializations
  POISearchService().initialize();  // ✅ NEW
  runApp(const MyApp());
}
```

#### 2. UI Integration (add_schedule_screen_new.dart)
```dart
// Real-time POI search
Future<void> _searchPOI(String keyword) async {
  final results = await POISearchService().searchPOI(
    keyword: keyword,
    count: 10,
  );
  setState(() {
    _searchResults = results;
  });
}

// Use POI coordinates for route calculation
Future<void> _saveSchedule() async {
  final destLat = _selectedPOI!.lat;
  final destLng = _selectedPOI!.lng;

  // Calculate route with actual coordinates
  final routeResult = await RouteService().calculateRoute(
    originLat: originLat,
    originLng: originLng,
    destLat: destLat,
    destLng: destLng,
  );
}
```

### Business Rules

- **최대 검색 결과**: 20개 (TMAP API 정책)
- **좌표계**: WGS84GEO (GPS 표준)
- **주소 표시 우선순위**: 도로명 주소 > 지번 주소
- **빈 키워드 처리**: 빈 검색어는 빈 배열 반환

### POI Search vs Routes API

| Feature | POI Search API | Routes API |
|---------|----------------|------------|
| Base URL | `https://apis.openapi.sk.com` | `https://apis.openapi.sk.com` |
| Endpoint | `/tmap/pois` | `/tmap/routes?version=1` |
| 요청 방식 | GET | POST |
| 주요 기능 | 장소 검색 | 경로 계산 |
| 반환 데이터 | 장소 정보, 좌표, 주소 | 소요시간, 거리, 경로 |
| 최대 결과 | 20개 | 1개 (최적 경로) |

## API Comparison

| Feature | Naver API | TMAP API |
|---------|-----------|----------|
| 요청 방식 | GET | POST |
| 인증 방식 | 이중 헤더 | 단일 appKey |
| 시간 단위 | 밀리초 | 초 |
| 거리 단위 | 미터 | 미터 |
| 좌표 형식 | WGS84 | WGS84 |
| 경로 포맷 | 자체 형식 | GeoJSON |
| 교통 정보 | 5단계 상세 | 기본 제공 |
| 통행료 | ✅ | ✅ |
| 택시비 | ❌ | ✅ |
| 유류비 | ✅ | ❌ |
| POI 검색 | ❌ | ✅ |

## Test Results

### Integration Tests
**File**: `test/integration/route_service_integration_test.dart`

```
✓ should get driving route from TMAP Routes API
✓ should handle API errors gracefully
✓ should cache route results
✓ should return different routes for different options

All 4 integration tests passed (100%)
```

**Cache Performance**:
- First API call: ~1ms (with caching infrastructure)
- Cached retrieval: 0ms

### Unit Tests
```
Total: 305 tests
Passed: 305 (100%)
Failed: 0
Time: ~29 seconds
```

## Environment Configuration

**`.env` file**:
```bash
# Naver API (Maps + Transit) - DEPRECATED, switching to TMAP
NAVER_CLIENT_ID=chvznhh6nd
NAVER_CLIENT_SECRET=eCYgYOS5pIpsFFZdvl4MZtmonGBYZYMcofbsxmd1

# TMAP API (경로 안내 및 지도)
# https://openapi.sk.com/
TMAP_APP_KEY=BAztkfvzM03JakoXbANyf36kqmvrRQXJaPbP6J9Y
```

## Files Modified

### Routes API Migration
1. **`.env`**: Added TMAP_APP_KEY
2. **`lib/services/route_service.dart`**: Complete rewrite for TMAP API
3. **`test/integration/route_service_integration_test.dart`**: Updated tests for TMAP

### POI Search Service Integration (2025-01-07)
4. **`lib/services/poi_search_service.dart`**: ✅ NEW - TMAP POI Search API service
5. **`lib/main.dart`**: Added POISearchService().initialize()
6. **`lib/screens/schedule/add_schedule_screen_new.dart`**: Real API integration
   - Real-time POI search with _searchPOI()
   - Current location service integration
   - Actual route calculation in _saveSchedule()

## Deployment Status

### Profile Build (2025-01-07)
- ✅ Build successful: `app-profile.apk` (81.7MB)
- ✅ Device installation: SM A136S (Android 14)
- ✅ App launch: Successful
- ✅ Services initialized:
  - RouteService (TMAP Routes API)
  - TransitService (Naver Transit API)
  - POISearchService (TMAP POI API) ✅ NEW
  - SchedulerService
  - PollingService
  - RealTimeUpdater

### Latest Deployment (2025-01-07)
- ✅ Hot reload successful with POI Search integration
- ✅ Real-time place search working
- ✅ Current location service active
- ✅ Route calculation with real API data
- ✅ All services operational

## Known Limitations

### TMAP API vs Naver API
1. **교통 정보 레벨**: TMAP은 상세 교통 레벨(원활/서행/지체/정체)을 제공하지 않음
   - 현재: `TrafficLevel.unknown` 반환
   - 해결: 실시간 교통 정보가 필요한 경우 별도 API 연동 필요

2. **유류비**: TMAP은 예상 유류비를 제공하지 않음
   - 현재: `fuelPrice: 0` 반환
   - 해결: 거리 기반 자체 계산 필요 시 구현

## Naver API 문제 원인 분석

### 발생했던 에러
```json
{
  "error": {
    "errorCode": "210",
    "message": "Permission Denied",
    "details": "A subscription to the API is required."
  }
}
```

### 확인한 설정
- ✅ Naver Cloud Platform 애플리케이션 등록
- ✅ Android 패키지명 등록: `com.gonow.go_now`
- ✅ iOS Bundle ID 등록: `com.gonow.goNow`
- ✅ Directions 5 API 선택
- ✅ Maps 서비스 구독 확인 ("상품 이용 중")

### 추정 원인
Directions 5 API 서비스 구독이 실제로 활성화되지 않았거나, 플랫폼 설정에 문제가 있었을 것으로 추정됩니다. Naver Cloud Platform 콘솔에서 "Maps" 구독은 표시되었으나, "Directions 5" API 자체의 구독 상태가 불확실했습니다.

## Migration Benefits

1. ✅ **안정적인 API 접근**: TMAP API로 즉시 연결 성공
2. ✅ **추가 정보 제공**: 택시비 정보 제공
3. ✅ **GeoJSON 표준**: 업계 표준 경로 포맷 사용
4. ✅ **명확한 문서**: SK Open API 포털의 명확한 가이드
5. ✅ **테스트 성공**: 모든 통합 테스트 통과

## Rollback Plan (필요시)

TMAP API에 문제가 발생할 경우:
1. Naver Cloud Platform에서 Directions 5 API 구독 재확인
2. `route_service.dart`의 Git 히스토리에서 Naver 버전 복원
3. 통합 테스트 재실행으로 검증

## References

- **TMAP API Documentation**: https://openapi.sk.com/
- **TMAP Routes API Guide**: https://openapi.sk.com/products/detail?svcSeq=59
- **Naver Directions API**: https://api.ncloud-docs.com/docs/ai-naver-mapsdirections-driving
- **Previous Conversation**: Context summary available in session history

---

**Last Updated**: 2025-01-07
**Status**: ✅ Migration Complete - All Services Operational
- ✅ TMAP Routes API: Fully integrated and tested
- ✅ TMAP POI Search API: Integrated with real-time search
- ✅ Location Services: GPS integration complete
- ✅ All integration tests passing (4/4)
