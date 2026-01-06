import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cache_service.dart';

/// Naver Transit API를 사용한 대중교통 경로 탐색 서비스 / Public Transit Route Service
///
/// **기능 / Features**:
/// - Naver Transit API 연동 (버스/지하철 통합)
/// - 실시간 대중교통 경로 탐색
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

  /// 캐시 서비스 / Cache service
  final CacheService<TransitResult> _cache = CacheService<TransitResult>();

  /// 초기화 메서드 / Initialize Dio client
  ///
  /// **Context**: 앱 시작 시 호출 (main.dart)
  void initialize() {
    final clientId = dotenv.env['NAVER_CLIENT_ID'];
    final clientSecret = dotenv.env['NAVER_CLIENT_SECRET'];

    if (clientId == null || clientSecret == null) {
      throw Exception('Naver API keys not configured in .env file');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://naveropenapi.apigw.ntruss.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'X-NCP-APIGW-API-KEY-ID': clientId,
          'X-NCP-APIGW-API-KEY': clientSecret,
        },
      ),
    );
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
      if (cachedResult != null) {
        print('TransitService: Using cached route (key: $cacheKey)');
        return [cachedResult];
      }
    }

    try {
      // Naver Transit API 호출
      // https://api.ncloud-docs.com/docs/ai-naver-mapstransit
      final response = await _dio.get(
        '/map-direction/v1/transit',
        queryParameters: {
          'start': '$originLng,$originLat', // 네이버는 lng,lat 순서
          'goal': '$destLng,$destLat',
        },
      );

      // 응답 파싱 / Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'] as int;

        // Naver API 응답 검증
        if (code != 0) {
          throw DioException(
            requestOptions: response.requestOptions,
            error: 'Naver API Error: ${data['message']}',
            type: DioExceptionType.badResponse,
          );
        }

        // traoptimal (최적 경로) 목록 파싱
        final routes = data['route']['traoptimal'] as List<dynamic>;

        final results = routes.map((route) {
          final summary = route['summary'];
          final subPaths = route['subPath'] as List<dynamic>;

          return TransitResult(
            durationMinutes: (summary['duration'] / 60).ceil(), // 초 → 분
            distanceKm: (summary['distance'] / 1000).toDouble(), // 미터 → km
            busTransitCount: summary['busTransitCount'] ?? 0,
            subwayTransitCount: summary['subwayTransitCount'] ?? 0,
            totalFare: summary['payment'] ?? 0,
            subPaths: _parseSubPaths(subPaths),
          );
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

  /// 세부 경로 파싱 (버스, 지하철, 도보)
  List<SubPath> _parseSubPaths(List<dynamic> subPaths) {
    return subPaths.map((subPath) {
      final trafficType = subPath['trafficType'] as int;

      return SubPath(
        trafficType: _parseTrafficType(trafficType),
        durationMinutes: ((subPath['sectionTime'] ?? 0) / 60).ceil(),
        distanceKm: ((subPath['distance'] ?? 0) / 1000).toDouble(),

        // 버스 정보
        busNo: subPath['lane']?[0]?['busNo'],
        startStationName: subPath['startName'],
        endStationName: subPath['endName'],
        stationCount: subPath['stationCount'] ?? 0,

        // 지하철 정보
        subwayLine: subPath['lane']?[0]?['name'],
        subwayColor: subPath['lane']?[0]?['color'],
      );
    }).toList();
  }

  /// 교통 수단 타입 파싱
  TransitType _parseTrafficType(int type) {
    switch (type) {
      case 1:
        return TransitType.subway; // 지하철
      case 2:
        return TransitType.bus; // 버스
      case 3:
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
