import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Naver Transit API를 사용한 대중교통 경로 탐색 서비스
///
/// **Context**: 버스/지하철 경로 탐색 및 실시간 도착 정보
/// **Business Rule**: 실시간 정보 반영 필수
class TransitService {
  static const String _baseUrl =
      'https://naveropenapi.apigw.ntruss.com/map-direction/v1/transit';

  static final String _clientId = dotenv.env['NAVER_CLIENT_ID']!;
  static final String _clientSecret = dotenv.env['NAVER_CLIENT_SECRET']!;

  /// 대중교통 경로 탐색 / Calculate transit route
  ///
  /// **비즈니스 규칙 / Business Rule**: 실시간 버스/지하철 정보 반영
  /// **Context**: 사용자가 대중교통 모드 선택 시 자동 호출
  ///
  /// @param originLat 출발지 위도
  /// @param originLng 출발지 경도
  /// @param destLat 목적지 위도
  /// @param destLng 목적지 경도
  /// @returns List<TransitResult> 대중교통 경로 목록 (최대 5개)
  static Future<List<TransitResult>> calculateTransitRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?start=$originLng,$originLat&goal=$destLng,$destLat',
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
          throw Exception('Naver Transit API Error: ${data['message']}');
        }

        final routes = data['route']['traoptimal'] as List<dynamic>;

        return routes.map((route) {
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
      } else {
        throw Exception('대중교통 경로 탐색 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('TransitService.calculateTransitRoute error: $e');
      return [];
    }
  }

  /// 세부 경로 파싱 (버스, 지하철, 도보)
  static List<SubPath> _parseSubPaths(List<dynamic> subPaths) {
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
  static TransitType _parseTrafficType(int type) {
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
