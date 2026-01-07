import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';

/// TMAP API를 사용한 경로 탐색 서비스 / Route Service
///
/// **기능 / Features**:
/// - TMAP Routes API 연동 (자차 경로)
/// - 실시간 교통 정보 반영
/// - 에러 핸들링 및 폴백 로직
/// - 경로 캐싱 (5분 유효)
///
/// **Context**: 일정 추가 시 이동 시간 계산
/// **Business Rule**: 실시간 교통 정보 반영 필수
class RouteService {
  /// Singleton instance
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  /// Dio HTTP 클라이언트 / HTTP client
  late final Dio _dio;

  /// 초기화 상태 플래그 / Initialization flag
  bool _isInitialized = false;

  /// 캐시 서비스 / Cache service
  final CacheService<RouteResult> _cache = CacheService<RouteResult>();

  /// 초기화 메서드 / Initialize Dio client
  ///
  /// **Context**: 앱 시작 시 호출 (main.dart)
  /// **Note**: 중복 호출 시 무시 (테스트 환경 고려)
  void initialize() {
    // 이미 초기화된 경우 스킵 / Skip if already initialized
    if (_isInitialized) {
      print('RouteService: Already initialized, skipping');
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
          'appKey': appKey,
        },
      ),
    );

    _isInitialized = true;
    print('RouteService: Initialized successfully with TMAP API');
  }

  /// 자차 경로 탐색 및 소요 시간 계산 / Calculate driving route
  ///
  /// **비즈니스 규칙 / Business Rule**: 실시간 교통 반영 필수
  /// **Context**: 사용자가 목적지 입력 시 자동 호출
  ///
  /// @param originLat 출발지 위도 (latitude)
  /// @param originLng 출발지 경도 (longitude)
  /// @param destLat 목적지 위도 (latitude)
  /// @param destLng 목적지 경도 (longitude)
  /// @param option 경로 옵션 (trafast/tracomfort/traoptimal)
  /// @returns RouteResult with duration, distance, traffic level
  ///
  /// @example
  /// final route = await RouteService().calculateRoute(
  ///   originLat: 37.5665,
  ///   originLng: 126.9780,
  ///   destLat: 37.4979,
  ///   destLng: 127.0276,
  /// );
  Future<RouteResult?> calculateRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String option = 'trafast', // trafast (빠른 길), tracomfort (편한 길), traoptimal (최적)
    bool useCache = true, // 캐시 사용 여부
  }) async {
    // 캐시 키 생성 / Generate cache key
    final cacheKey = CacheService.generateRouteKey(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      option: option,
    );

    // 캐시 조회 / Check cache
    if (useCache) {
      final cachedResult = _cache.get(cacheKey);
      if (cachedResult != null) {
        print('RouteService: Using cached route (key: $cacheKey)');
        return cachedResult;
      }
    }

    try {
      // TMAP 경로 옵션 매핑 / Map route option to TMAP searchOption
      // 0: 추천 (교통최적+거리), 1: 최단거리, 2: 최단시간, 10: 고속도로우선
      final searchOption = _mapRouteOption(option);

      // TMAP Routes API 호출
      // https://openapi.sk.com/products/detail?svcSeq=59
      final response = await _dio.post(
        '/tmap/routes?version=1',
        data: {
          'startX': originLng.toString(), // 출발지 경도
          'startY': originLat.toString(), // 출발지 위도
          'endX': destLng.toString(), // 목적지 경도
          'endY': destLat.toString(), // 목적지 위도
          'reqCoordType': 'WGS84GEO', // 요청 좌표계
          'resCoordType': 'WGS84GEO', // 응답 좌표계
          'searchOption': searchOption.toString(),
          'trafficInfo': 'Y', // 실시간 교통정보 반영
        },
      );

      // 응답 파싱 / Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // TMAP API 응답 검증
        if (data['features'] == null || (data['features'] as List).isEmpty) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'TMAP API Error: No route found',
            type: DioExceptionType.badResponse,
          );
        }

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

        // 캐시에 저장 / Save to cache (5분 유효)
        if (useCache) {
          _cache.set(cacheKey, result);
          print('RouteService: Cached route (key: $cacheKey)');
        }

        return result;
      } else {
        throw Exception('경로 탐색 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Dio 에러 처리 / Handle Dio errors
      final errorType = _handleDioError(e);
      throw RouteServiceException(
        message: errorType.message,
        type: errorType.type,
        originalError: e,
      );
    } catch (e) {
      throw RouteServiceException(
        message: '예상치 못한 오류가 발생했습니다: $e',
        type: RouteErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 경로 옵션을 TMAP searchOption으로 매핑 / Map route option to TMAP searchOption
  int _mapRouteOption(String option) {
    switch (option) {
      case 'trafast': // 빠른 길 (최단시간)
        return 2;
      case 'tracomfort': // 편한 길 (추천)
        return 0;
      case 'traoptimal': // 최적 (추천)
        return 0;
      default:
        return 0; // 기본값: 추천
    }
  }

  /// TMAP API 응답에서 경로 좌표 추출 / Extract path coordinates from TMAP response
  List<dynamic>? _extractPath(List<dynamic> features) {
    final paths = <Map<String, double>>[];

    for (final feature in features) {
      if (feature['geometry'] != null && feature['geometry']['type'] == 'LineString') {
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

  /// Dio 에러 핸들링 / Handle Dio errors
  ///
  /// **Context**: 네트워크, API 키, Rate Limit 에러 처리
  _ErrorInfo _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return _ErrorInfo(
          type: RouteErrorType.networkTimeout,
          message: '연결 시간이 초과되었습니다. 네트워크 상태를 확인하세요.',
        );
      case DioExceptionType.receiveTimeout:
        return _ErrorInfo(
          type: RouteErrorType.networkTimeout,
          message: '응답 시간이 초과되었습니다. 잠시 후 다시 시도하세요.',
        );
      case DioExceptionType.sendTimeout:
        return _ErrorInfo(
          type: RouteErrorType.networkTimeout,
          message: '요청 전송 시간이 초과되었습니다.',
        );
      case DioExceptionType.cancel:
        return _ErrorInfo(
          type: RouteErrorType.cancelled,
          message: '요청이 취소되었습니다.',
        );
      case DioExceptionType.badResponse:
        // HTTP 상태 코드 기반 에러 처리
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return _ErrorInfo(
            type: RouteErrorType.invalidApiKey,
            message: 'API 인증에 실패했습니다. .env 파일의 TMAP API 키를 확인하세요.',
          );
        } else if (statusCode == 429) {
          return _ErrorInfo(
            type: RouteErrorType.rateLimitExceeded,
            message: 'API 호출 한도를 초과했습니다. 잠시 후 다시 시도하세요.',
          );
        } else if (statusCode == 400) {
          return _ErrorInfo(
            type: RouteErrorType.invalidRequest,
            message: '잘못된 요청입니다. 출발지와 도착지를 확인하세요.',
          );
        } else {
          return _ErrorInfo(
            type: RouteErrorType.apiError,
            message: 'API 오류가 발생했습니다 (HTTP $statusCode).',
          );
        }
      case DioExceptionType.connectionError:
        return _ErrorInfo(
          type: RouteErrorType.networkError,
          message: '네트워크 연결에 실패했습니다. 인터넷 연결을 확인하세요.',
        );
      default:
        return _ErrorInfo(
          type: RouteErrorType.unknown,
          message: '알 수 없는 오류가 발생했습니다: ${e.message}',
        );
    }
  }

  /// 재시도 로직을 포함한 경로 조회 / Calculate route with retry
  ///
  /// **비즈니스 규칙 / Business Rule**: Rate Limit 시 3초 대기 후 재시도
  ///
  /// @param maxRetries 최대 재시도 횟수 (default: 2)
  Future<RouteResult?> calculateRouteWithRetry({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String option = 'trafast',
    int maxRetries = 2,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        return await calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          option: option,
        );
      } on RouteServiceException catch (e) {
        // Rate Limit 에러 시 재시도
        if (e.type == RouteErrorType.rateLimitExceeded && retryCount < maxRetries) {
          retryCount++;
          print('Rate limit hit, retrying in 3 seconds... (attempt $retryCount/$maxRetries)');
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        // 다른 에러는 즉시 throw
        rethrow;
      }
    }

    return null;
  }

  /// 캐시 무효화 / Invalidate cache
  ///
  /// **Context**: 사용자가 강제 새로고침하거나 설정 변경 시
  void invalidateCache({
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    String? option,
  }) {
    if (originLat != null &&
        originLng != null &&
        destLat != null &&
        destLng != null &&
        option != null) {
      // 특정 경로 캐시 무효화 / Invalidate specific route
      final cacheKey = CacheService.generateRouteKey(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        option: option,
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

/// 경로 탐색 결과 / Route calculation result
class RouteResult {
  final int durationMinutes; // 소요 시간 (분)
  final double distanceKm; // 거리 (km)
  final TrafficLevel trafficLevel; // 교통 상황
  final List<dynamic>? path; // 경로 좌표 배열
  final int tollFare; // 통행료 (원)
  final int taxiFare; // 택시 요금 (원)
  final int fuelPrice; // 유류비 (원)

  RouteResult({
    required this.durationMinutes,
    required this.distanceKm,
    required this.trafficLevel,
    this.path,
    this.tollFare = 0,
    this.taxiFare = 0,
    this.fuelPrice = 0,
  });

  /// 총 비용 계산 (통행료 + 유류비)
  int get totalCost => tollFare + fuelPrice;

  @override
  String toString() {
    return 'RouteResult(duration: ${durationMinutes}분, distance: ${distanceKm.toStringAsFixed(1)}km, traffic: $trafficLevel)';
  }
}

/// 교통 상황 레벨 / Traffic congestion level
enum TrafficLevel {
  smooth, // 원활 (초록)
  slow, // 지체 (주황)
  congested, // 정체 (빨강)
  unknown, // 알 수 없음
}

/// 경로 서비스 에러 타입 / Route service error types
enum RouteErrorType {
  networkError, // 네트워크 연결 실패
  networkTimeout, // 네트워크 타임아웃
  invalidApiKey, // API 키 오류 (401, 403)
  rateLimitExceeded, // API 호출 한도 초과 (429)
  invalidRequest, // 잘못된 요청 (400)
  apiError, // 기타 API 오류
  cancelled, // 요청 취소
  unknown, // 알 수 없는 오류
}

/// 경로 서비스 예외 / Route service exception
///
/// **Context**: RouteService에서 발생하는 모든 에러를 래핑
class RouteServiceException implements Exception {
  /// 에러 메시지 / Error message
  final String message;

  /// 에러 타입 / Error type
  final RouteErrorType type;

  /// 원본 에러 / Original error
  final Object? originalError;

  RouteServiceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  /// 사용자 친화적인 에러 메시지 / User-friendly error message
  String get userMessage {
    switch (type) {
      case RouteErrorType.networkError:
      case RouteErrorType.networkTimeout:
        return '네트워크 연결이 불안정합니다.\n인터넷 연결을 확인해주세요.';
      case RouteErrorType.invalidApiKey:
        return '서비스 인증에 실패했습니다.\n잠시 후 다시 시도해주세요.';
      case RouteErrorType.rateLimitExceeded:
        return 'API 호출 한도를 초과했습니다.\n잠시 후 다시 시도해주세요.';
      case RouteErrorType.invalidRequest:
        return '잘못된 요청입니다.\n출발지와 도착지를 확인해주세요.';
      case RouteErrorType.apiError:
        return '경로 탐색 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      case RouteErrorType.cancelled:
        return '요청이 취소되었습니다.';
      case RouteErrorType.unknown:
        return '예상치 못한 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
    }
  }

  /// 재시도 가능 여부 / Can retry
  bool get canRetry {
    return type == RouteErrorType.networkError ||
        type == RouteErrorType.networkTimeout ||
        type == RouteErrorType.rateLimitExceeded;
  }

  @override
  String toString() {
    return 'RouteServiceException: $message (type: $type)';
  }
}

/// 에러 정보 내부 클래스 / Internal error info class
class _ErrorInfo {
  final RouteErrorType type;
  final String message;

  _ErrorInfo({
    required this.type,
    required this.message,
  });
}
