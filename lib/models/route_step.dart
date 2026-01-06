import 'package:flutter/material.dart';

/// 경로 단계 타입 / Route step type
enum RouteStepType {
  /// 도보 / Walking
  walk,

  /// 버스 / Bus
  bus,

  /// 지하철 / Subway
  subway,
}

/// 경로 단계 모델 / Route Step Model
///
/// **기능 / Features**:
/// - 교통수단 타입 (도보/버스/지하철)
/// - 노선 정보 (이름, 색상)
/// - 이동 시간 및 거리
/// - 실시간 도착 정보
///
/// **Context**: 경로 표시 위젯에서 사용
class RouteStep {
  /// 단계 ID / Step ID
  final String id;

  /// 교통수단 타입 / Transportation type
  final RouteStepType type;

  /// 노선 이름 (버스 번호, 지하철 호선) / Line name
  final String? lineName;

  /// 노선 색상 (지하철 호선 색상) / Line color
  final Color? lineColor;

  /// 이동 시간 (분) / Duration in minutes
  final int duration;

  /// 이동 거리 (미터) / Distance in meters
  final int? distance;

  /// 설명 (예: "3번 출구로 나와서") / Description
  final String? description;

  /// 실시간 도착 정보 (예: "2분 후 도착") / Real-time arrival info
  final String? arrivalInfo;

  /// 출발 정류장/역 / Departure station
  final String? departureStation;

  /// 도착 정류장/역 / Arrival station
  final String? arrivalStation;

  RouteStep({
    required this.id,
    required this.type,
    this.lineName,
    this.lineColor,
    required this.duration,
    this.distance,
    this.description,
    this.arrivalInfo,
    this.departureStation,
    this.arrivalStation,
  });

  /// JSON에서 생성 / Create from JSON
  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      id: json['id'] as String,
      type: RouteStepType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RouteStepType.walk,
      ),
      lineName: json['line_name'] as String?,
      lineColor: json['line_color'] != null
          ? Color(int.parse(json['line_color'].replaceFirst('#', '0xFF')))
          : null,
      duration: json['duration'] as int,
      distance: json['distance'] as int?,
      description: json['description'] as String?,
      arrivalInfo: json['arrival_info'] as String?,
      departureStation: json['departure_station'] as String?,
      arrivalStation: json['arrival_station'] as String?,
    );
  }

  /// JSON으로 변환 / Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'line_name': lineName,
      'line_color': lineColor != null
          ? '#${lineColor!.value.toRadixString(16).substring(2)}'
          : null,
      'duration': duration,
      'distance': distance,
      'description': description,
      'arrival_info': arrivalInfo,
      'departure_station': departureStation,
      'arrival_station': arrivalStation,
    };
  }

  /// 복사본 생성 / Create copy
  RouteStep copyWith({
    String? id,
    RouteStepType? type,
    String? lineName,
    Color? lineColor,
    int? duration,
    int? distance,
    String? description,
    String? arrivalInfo,
    String? departureStation,
    String? arrivalStation,
  }) {
    return RouteStep(
      id: id ?? this.id,
      type: type ?? this.type,
      lineName: lineName ?? this.lineName,
      lineColor: lineColor ?? this.lineColor,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      arrivalInfo: arrivalInfo ?? this.arrivalInfo,
      departureStation: departureStation ?? this.departureStation,
      arrivalStation: arrivalStation ?? this.arrivalStation,
    );
  }
}
