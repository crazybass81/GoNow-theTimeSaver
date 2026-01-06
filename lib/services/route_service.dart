import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Naver Maps API를 사용한 경로 탐색 서비스
///
/// **Context**: 자동차 경로 탐색 및 소요 시간 계산
/// **Business Rule**: 실시간 교통 정보 반영 필수
class RouteService {
  static const String _baseUrl =
      'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving';

  static final String _clientId = dotenv.env['NAVER_CLIENT_ID']!;
  static final String _clientSecret = dotenv.env['NAVER_CLIENT_SECRET']!;

  /// 자차 경로 탐색 및 소요 시간 계산 / Calculate driving route
  ///
  /// **비즈니스 규칙 / Business Rule**: 실시간 교통 반영 필수
  /// **Context**: 사용자가 목적지 입력 시 자동 호출
  ///
  /// @param originLat 출발지 위도 (latitude)
  /// @param originLng 출발지 경도 (longitude)
  /// @param destLat 목적지 위도 (latitude)
  /// @param destLng 목적지 경도 (longitude)
  /// @returns RouteResult with duration, distance, traffic level
  static Future<RouteResult?> calculateRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?start=$originLng,$originLat&goal=$destLng,$destLat&option=trafast',
      );

      final response = await http.get(
        uri,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': _clientId,
          'X-NCP-APIGW-API-KEY': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Naver API 응답 검증
        if (data['code'] != 0) {
          throw Exception('Naver API Error: ${data['message']}');
        }

        final route = data['route']['trafast'][0];
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
