import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';

/// TMAP Public Transit API를 사용한 대중교통 경로 탐색 서비스 / Public Transit Route Service
///
/// **기능 / Features**:
/// - TMAP Public Transit API 연동 (버스/지하철 통합)
/// - 실시간 대중교통 경로 탐색 (GTFS 기반)
/// - 환승 정보 파싱
/// - 에러 핸들링 및 폴백 로직
/// - 경로 캐싱 (5분 유효)
///
/// **Context**: 사용자가 대중교통 이동 수단 선택 시
/// **Business Rule**: 환승 시간 자동 반영 (도보 5분, 버스 3분)
class TransitService {
  /// Singleton instance
  static final TransitService _instance = TransitService._internal();
  factory TransitService() => _instance;
  TransitService._internal();

  /// Dio HTTP 클라이언트 / HTTP client
  late final Dio _dio;

  /// 초기화 상태 플래그 / Initialization flag
  bool _isInitialized = false;

  /// 캐시 서비스 / Cache service
  final CacheService<TransitResult> _cache = CacheService<TransitResult>();

  /// 초기화 메서드 / Initialize Dio client
  ///
  /// **Context**: 앱 시작 시 호출 (main.dart)
  /// **Note**: 중복 호출 시 무시 (테스트 환경 고려)
  void initialize() {
    // 이미 초기화된 경우 스킵 / Skip if already initialized
    if (_isInitialized) {
      print('TransitService: Already initialized, skipping');
      return;
    }

    final appKey = dotenv.env['TMAP_APP_KEY'];

    if (appKey == null) {
      throw Exception('TMAP API key not configured in .env file');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://apis.openapi.sk.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'appKey': appKey,
        },
      ),
    );

    _isInitialized = true;
    print('TransitService: Initialized successfully with TMAP Public Transit API');
  }

  /// 대중교통 경로 탐색 및 소요 시간 계산 / Calculate public transit route
  ///
  /// **비즈니스 규칙 / Business Rule**: 환승 시간 자동 반영 필수
  /// **Context**: 사용자가 목적지 입력 및 대중교통 선택 시 자동 호출
  ///
  /// @param originLat 출발지 위도 (latitude)
  /// @param originLng 출발지 경도 (longitude)
  /// @param destLat 목적지 위도 (latitude)
  /// @param destLng 목적지 경도 (longitude)
  /// @param useCache 캐시 사용 여부 (default: true)
  /// @returns List<TransitResult> 대중교통 경로 목록 (최대 5개)
  ///
  /// @example
  /// final routes = await TransitService().calculateTransitRoute(
  ///   originLat: 37.5665,
  ///   originLng: 126.9780,
  ///   destLat: 37.4979,
  ///   destLng: 127.0276,
  /// );
  Future<List<TransitResult>> calculateTransitRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    bool useCache = true, // 캐시 사용 여부
  }) async {
    // 캐시 키 생성 / Generate cache key
    final cacheKey = CacheService.generateRouteKey(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      option: 'transit',
    );

    // 캐시 조회 / Check cache
    if (useCache) {
      final cachedResult = _cache.get(cacheKey);
      if (cachedResult != null && cachedResult.durationMinutes > 0) {
        // 유효한 캐시만 사용 (durationMinutes > 0)
        print('TransitService: Using cached route (key: $cacheKey)');
        return [cachedResult];
      } else if (cachedResult != null && cachedResult.durationMinutes == 0) {
        // 잘못된 캐시 제거
        print('TransitService: Removing invalid cache (durationMinutes = 0)');
        _cache.invalidate(cacheKey);
      }
    }

    try {
      // TMAP Public Transit API 호출
      // https://openapi.sk.com/products/tmap/detail
      final response = await _dio.post(
        '/transit/routes',
        data: {
          'startX': originLng.toString(), // 출발지 경도
          'startY': originLat.toString(), // 출발지 위도
          'endX': destLng.toString(), // 목적지 경도
          'endY': destLat.toString(), // 목적지 위도
          'lang': 0, // 0: 한국어, 1: 영어
          'format': 'json', // 응답 형식
          'count': 5, // 최대 경로 개수
        },
      );

      // 응답 파싱 / Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // 디버깅: API 응답 로그
        print('✅ TransitService: API response received');
        print('📊 Response keys: ${data.keys.toList()}');

        // TMAP API 응답 검증
        if (data['metaData'] == null || data['metaData']['plan'] == null) {
          print('❌ TransitService: No route found in response');
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'TMAP API Error: No route found',
            type: DioExceptionType.badResponse,
          );
        }

        final plan = data['metaData']['plan'];
        final itineraries = plan['itineraries'] as List<dynamic>;

        if (itineraries.isEmpty) {
          print('❌ TransitService: No itineraries found');
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'TMAP API Error: No itineraries found',
            type: DioExceptionType.badResponse,
          );
        }

        print('🚌 TransitService: Found ${itineraries.length} routes');

        final results = itineraries.map((itinerary) {
          final legs = itinerary['legs'] as List<dynamic>;

          // 총 소요 시간 및 거리 계산
          int totalDuration = 0;
          double totalDistance = 0.0;
          int busCount = 0;
          int subwayCount = 0;
          int totalFare = itinerary['fare']?['regular']?['totalFare'] ?? 0;

          for (final leg in legs) {
            // TMAP API는 'sectionTime' 필드 사용 (초 단위)
            totalDuration += (leg['sectionTime'] ?? 0) as int;
            totalDistance += ((leg['distance'] ?? 0) as num).toDouble();

            final mode = leg['mode'] as String?;
            if (mode == 'BUS') busCount++;
            if (mode == 'SUBWAY') subwayCount++;
          }

          final result = TransitResult(
            durationMinutes: (totalDuration / 60).ceil(), // 초 → 분
            distanceKm: (totalDistance / 1000).toDouble(), // 미터 → km
            busTransitCount: busCount > 0 ? busCount - 1 : 0, // 환승 횟수 계산
            subwayTransitCount: subwayCount > 0 ? subwayCount - 1 : 0,
            totalFare: totalFare,
            subPaths: _parseSubPaths(legs),
          );

          print('🚇 Route: ${result.durationMinutes}분, 환승 ${result.totalTransitCount}회, ${result.totalFare}원');

          return result;
        }).toList();

        // 첫 번째 경로를 캐시에 저장 / Save first route to cache (5분 유효)
        if (useCache && results.isNotEmpty) {
          _cache.set(cacheKey, results.first);
          print('TransitService: Cached route (key: $cacheKey)');
        }

        return results;
      } else {
        throw Exception('대중교통 경로 탐색 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Dio 에러 처리 / Handle Dio errors
      final errorType = _handleDioError(e);
      throw TransitServiceException(
        message: errorType.message,
        type: errorType.type,
        originalError: e,
      );
    } catch (e) {
      throw TransitServiceException(
        message: '예상치 못한 오류가 발생했습니다: $e',
        type: TransitErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 세부 경로 파싱 (버스, 지하철, 도보) - TMAP legs 형식
  List<SubPath> _parseSubPaths(List<dynamic> legs) {
    return legs.map((leg) {
      final mode = leg['mode'] as String?;
      final transitType = _parseTransitMode(mode);

      return SubPath(
        trafficType: transitType,
        durationMinutes: ((leg['sectionTime'] ?? 0) / 60).ceil(), // 초 → 분
        distanceKm: ((leg['distance'] ?? 0) / 1000).toDouble(), // 미터 → km

        // 버스 정보
        busNo: leg['route'],
        startStationName: leg['start']?['name'],
        endStationName: leg['end']?['name'],
        stationCount: leg['passStopList']?['stations']?.length ?? 0,

        // 지하철 정보
        subwayLine: leg['route'], // TMAP에서는 route에 노선명 포함
        subwayColor: leg['routeColor'], // TMAP API routeColor 필드 사용
      );
    }).toList();
  }

  /// 교통 수단 타입 파싱 - TMAP mode 형식
  TransitType _parseTransitMode(String? mode) {
    switch (mode?.toUpperCase()) {
      case 'SUBWAY':
        return TransitType.subway; // 지하철
      case 'BUS':
        return TransitType.bus; // 버스
      case 'WALK':
        return TransitType.walk; // 도보
      default:
        return TransitType.walk;
    }
  }

  /// Dio 에러 핸들링 / Handle Dio errors
  ///
  /// **Context**: 네트워크, API 키, Rate Limit 에러 처리
  _ErrorInfo _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return _ErrorInfo(
          type: TransitErrorType.networkTimeout,
          message: '연결 시간이 초과되었습니다. 네트워크 상태를 확인하세요.',
        );
      case DioExceptionType.receiveTimeout:
        return _ErrorInfo(
          type: TransitErrorType.networkTimeout,
          message: '응답 시간이 초과되었습니다. 잠시 후 다시 시도하세요.',
        );
      case DioExceptionType.sendTimeout:
        return _ErrorInfo(
          type: TransitErrorType.networkTimeout,
          message: '요청 전송 시간이 초과되었습니다.',
        );
      case DioExceptionType.cancel:
        return _ErrorInfo(
          type: TransitErrorType.cancelled,
          message: '요청이 취소되었습니다.',
        );
      case DioExceptionType.badResponse:
        // HTTP 상태 코드 기반 에러 처리
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return _ErrorInfo(
            type: TransitErrorType.invalidApiKey,
            message: 'API 인증에 실패했습니다. .env 파일의 API 키를 확인하세요.',
          );
        } else if (statusCode == 429) {
          return _ErrorInfo(
            type: TransitErrorType.rateLimitExceeded,
            message: 'API 호출 한도를 초과했습니다. 잠시 후 다시 시도하세요.',
          );
        } else if (statusCode == 400) {
          return _ErrorInfo(
            type: TransitErrorType.invalidRequest,
            message: '잘못된 요청입니다. 출발지와 도착지를 확인하세요.',
          );
        } else {
          return _ErrorInfo(
            type: TransitErrorType.apiError,
            message: 'API 오류가 발생했습니다 (HTTP $statusCode).',
          );
        }
      case DioExceptionType.connectionError:
        return _ErrorInfo(
          type: TransitErrorType.networkError,
          message: '네트워크 연결에 실패했습니다. 인터넷 연결을 확인하세요.',
        );
      default:
        return _ErrorInfo(
          type: TransitErrorType.unknown,
          message: '알 수 없는 오류가 발생했습니다: ${e.message}',
        );
    }
  }

  /// 재시도 로직을 포함한 경로 조회 / Calculate route with retry
  ///
  /// **비즈니스 규칙 / Business Rule**: Rate Limit 시 3초 대기 후 재시도
  ///
  /// @param maxRetries 최대 재시도 횟수 (default: 2)
  Future<List<TransitResult>> calculateTransitRouteWithRetry({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    int maxRetries = 2,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        return await calculateTransitRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );
      } on TransitServiceException catch (e) {
        // Rate Limit 에러 시 재시도
        if (e.type == TransitErrorType.rateLimitExceeded &&
            retryCount < maxRetries) {
          retryCount++;
          print(
              'Rate limit hit, retrying in 3 seconds... (attempt $retryCount/$maxRetries)');
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        // 다른 에러는 즉시 throw
        rethrow;
      }
    }

    return [];
  }

  /// 캐시 무효화 / Invalidate cache
  ///
  /// **Context**: 사용자가 강제 새로고침하거나 설정 변경 시
  void invalidateCache({
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
  }) {
    if (originLat != null &&
        originLng != null &&
        destLat != null &&
        destLng != null) {
      // 특정 경로 캐시 무효화 / Invalidate specific route
      final cacheKey = CacheService.generateRouteKey(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        option: 'transit',
      );
      _cache.invalidate(cacheKey);
    } else {
      // 모든 캐시 무효화 / Invalidate all cache
      _cache.invalidateAll();
    }
  }

  /// 만료된 캐시 정리 / Clean up expired cache
  ///
  /// **Context**: 주기적으로 호출하여 메모리 관리
  void cleanExpiredCache() {
    _cache.cleanExpired();
  }

  /// 캐시 통계 조회 / Get cache statistics
  ///
  /// **Context**: 디버깅 및 모니터링
  CacheStats getCacheStats() {
    return _cache.getStats();
  }
}

/// 대중교통 경로 결과 / Transit route result
class TransitResult {
  final int durationMinutes; // 총 소요 시간 (분)
  final double distanceKm; // 총 거리 (km)
  final int busTransitCount; // 버스 환승 횟수
  final int subwayTransitCount; // 지하철 환승 횟수
  final int totalFare; // 총 요금 (원)
  final List<SubPath> subPaths; // 세부 경로 목록

  TransitResult({
    required this.durationMinutes,
    required this.distanceKm,
    required this.busTransitCount,
    required this.subwayTransitCount,
    required this.totalFare,
    required this.subPaths,
  });

  /// 총 환승 횟수
  int get totalTransitCount => busTransitCount + subwayTransitCount;

  /// JSON으로 변환 / Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'busTransitCount': busTransitCount,
      'subwayTransitCount': subwayTransitCount,
      'totalFare': totalFare,
      'subPaths': subPaths.map((subPath) => subPath.toJson()).toList(),
    };
  }

  /// JSON에서 생성 / Create from JSON
  factory TransitResult.fromJson(Map<String, dynamic> json) {
    return TransitResult(
      durationMinutes: json['durationMinutes'] as int,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      busTransitCount: json['busTransitCount'] as int,
      subwayTransitCount: json['subwayTransitCount'] as int,
      totalFare: json['totalFare'] as int,
      subPaths: (json['subPaths'] as List<dynamic>)
          .map((item) => SubPath.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'TransitResult(duration: ${durationMinutes}분, distance: ${distanceKm.toStringAsFixed(1)}km, '
        'transfers: $totalTransitCount, fare: ${totalFare}원)';
  }
}

/// 세부 경로 (버스, 지하철, 도보) / Sub-path segment
class SubPath {
  final TransitType trafficType; // 교통 수단 타입
  final int durationMinutes; // 구간 소요 시간 (분)
  final double distanceKm; // 구간 거리 (km)

  // 버스/지하철 공통
  final String? startStationName; // 승차 정류장/역
  final String? endStationName; // 하차 정류장/역
  final int stationCount; // 정류장/역 개수

  // 버스 전용
  final String? busNo; // 버스 번호 (예: "472")

  // 지하철 전용
  final String? subwayLine; // 지하철 노선명 (예: "2호선")
  final String? subwayColor; // 지하철 노선 색상 (예: "#00A84D")

  SubPath({
    required this.trafficType,
    required this.durationMinutes,
    required this.distanceKm,
    this.startStationName,
    this.endStationName,
    this.stationCount = 0,
    this.busNo,
    this.subwayLine,
    this.subwayColor,
  });

  /// 아이콘 이모지 반환
  String get icon {
    switch (trafficType) {
      case TransitType.bus:
        return '🚌';
      case TransitType.subway:
        return '🚇';
      case TransitType.walk:
        return '🚶';
    }
  }

  /// UI용 표시 텍스트
  String get displayText {
    switch (trafficType) {
      case TransitType.bus:
        return '버스 $busNo ($stationCount정류장, ${durationMinutes}분)';
      case TransitType.subway:
        return '$subwayLine ($stationCount역, ${durationMinutes}분)';
      case TransitType.walk:
        return '도보 (${distanceKm.toStringAsFixed(1)}km, ${durationMinutes}분)';
    }
  }

  /// JSON으로 변환 / Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'trafficType': trafficType.toString().split('.').last,
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'startStationName': startStationName,
      'endStationName': endStationName,
      'stationCount': stationCount,
      'busNo': busNo,
      'subwayLine': subwayLine,
      'subwayColor': subwayColor,
    };
  }

  /// JSON에서 생성 / Create from JSON
  factory SubPath.fromJson(Map<String, dynamic> json) {
    return SubPath(
      trafficType: _transitTypeFromString(json['trafficType'] as String),
      durationMinutes: json['durationMinutes'] as int,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      startStationName: json['startStationName'] as String?,
      endStationName: json['endStationName'] as String?,
      stationCount: json['stationCount'] as int? ?? 0,
      busNo: json['busNo'] as String?,
      subwayLine: json['subwayLine'] as String?,
      subwayColor: json['subwayColor'] as String?,
    );
  }

  /// 문자열을 TransitType으로 변환 / Convert string to TransitType
  static TransitType _transitTypeFromString(String type) {
    switch (type) {
      case 'subway':
        return TransitType.subway;
      case 'bus':
        return TransitType.bus;
      case 'walk':
        return TransitType.walk;
      default:
        return TransitType.walk;
    }
  }
}

/// 교통 수단 타입 / Transit type
enum TransitType {
  subway, // 지하철
  bus, // 버스
  walk, // 도보
}

/// 대중교통 서비스 에러 타입 / Transit service error types
enum TransitErrorType {
  networkError, // 네트워크 연결 실패
  networkTimeout, // 네트워크 타임아웃
  invalidApiKey, // API 키 오류 (401, 403)
  rateLimitExceeded, // API 호출 한도 초과 (429)
  invalidRequest, // 잘못된 요청 (400)
  apiError, // 기타 API 오류
  cancelled, // 요청 취소
  unknown, // 알 수 없는 오류
}

/// 대중교통 서비스 예외 / Transit service exception
///
/// **Context**: TransitService에서 발생하는 모든 에러를 래핑
class TransitServiceException implements Exception {
  /// 에러 메시지 / Error message
  final String message;

  /// 에러 타입 / Error type
  final TransitErrorType type;

  /// 원본 에러 / Original error
  final Object? originalError;

  TransitServiceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  /// 사용자 친화적인 에러 메시지 / User-friendly error message
  String get userMessage {
    switch (type) {
      case TransitErrorType.networkError:
      case TransitErrorType.networkTimeout:
        return '네트워크 연결이 불안정합니다.\n인터넷 연결을 확인해주세요.';
      case TransitErrorType.invalidApiKey:
        return '서비스 인증에 실패했습니다.\n잠시 후 다시 시도해주세요.';
      case TransitErrorType.rateLimitExceeded:
        return 'API 호출 한도를 초과했습니다.\n잠시 후 다시 시도해주세요.';
      case TransitErrorType.invalidRequest:
        return '잘못된 요청입니다.\n출발지와 도착지를 확인해주세요.';
      case TransitErrorType.apiError:
        return '대중교통 경로 탐색 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      case TransitErrorType.cancelled:
        return '요청이 취소되었습니다.';
      case TransitErrorType.unknown:
        return '예상치 못한 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
    }
  }

  /// 재시도 가능 여부 / Can retry
  bool get canRetry {
    return type == TransitErrorType.networkError ||
        type == TransitErrorType.networkTimeout ||
        type == TransitErrorType.rateLimitExceeded;
  }

  @override
  String toString() {
    return 'TransitServiceException: $message (type: $type)';
  }
}

/// 에러 정보 내부 클래스 / Internal error info class
class _ErrorInfo {
  final TransitErrorType type;
  final String message;

  _ErrorInfo({
    required this.type,
    required this.message,
  });
}
