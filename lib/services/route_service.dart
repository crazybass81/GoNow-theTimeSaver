import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Naver Maps API를 사용한 경로 탐색 서비스 / Route Service
///
/// **기능 / Features**:
/// - Naver Directions API 5.0 연동 (자차 경로)
/// - 실시간 교통 정보 반영
/// - 에러 핸들링 및 폴백 로직
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
  }) async {
    try {
      // Naver Directions API 호출
      // https://api.ncloud-docs.com/docs/ai-naver-mapsdirections-driving
      final response = await _dio.get(
        '/map-direction/v1/driving',
        queryParameters: {
          'start': '$originLng,$originLat', // 네이버는 lng,lat 순서
          'goal': '$destLng,$destLat',
          'option': option,
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

        final route = data['route'][option][0];
        final summary = route['summary'];

        return RouteResult(
          durationMinutes: (summary['duration'] / 1000 / 60).ceil(), // 밀리초 → 분
          distanceKm: (summary['distance'] / 1000).toDouble(), // 미터 → km
          trafficLevel: _parseTrafficLevel(summary['trafficColor'] ?? 0),
          path: route['path'] as List<dynamic>?,
          tollFare: summary['tollFare'] ?? 0,
          taxiFare: summary['taxiFare'] ?? 0,
          fuelPrice: summary['fuelPrice'] ?? 0,
        );
      } else {
        throw Exception('경로 탐색 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Dio 에러 처리 / Handle Dio errors
      print('RouteService.calculateRoute DioException: ${e.type}, ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        print('Connection timeout - check your network');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print('Receive timeout - server is slow');
      } else if (e.response?.statusCode == 401) {
        print('Invalid API keys - check .env file');
      } else if (e.response?.statusCode == 429) {
        print('Rate limit exceeded - try again later');
      }

      return null; // SubTask 2.1.2에서 에러 핸들링 개선 예정
    } catch (e) {
      print('RouteService.calculateRoute error: $e');
      return null;
    }
  }

  /// 교통 상황 코드를 TrafficLevel enum으로 변환
  static TrafficLevel _parseTrafficLevel(int colorCode) {
    switch (colorCode) {
      case 1:
        return TrafficLevel.smooth; // 원활 (초록)
      case 2:
        return TrafficLevel.slow; // 지체 (주황)
      case 3:
        return TrafficLevel.congested; // 정체 (빨강)
      default:
        return TrafficLevel.unknown;
    }
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
