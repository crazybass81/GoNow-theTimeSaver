import '../services/transit_service.dart';

/// 일정 모델 / Trip Model
///
/// **Supabase 테이블**: schedules
///
/// **기능 / Features**:
/// - 역산 스케줄링 기반 일정 관리
/// - 4가지 독립 버퍼 시간 시스템
/// - 실시간 교통 데이터 반영
///
/// **비즈니스 규칙 / Business Rule**:
/// - arrival_time: 도착 목표 시간 (사용자 입력)
/// - departure_time: 역산된 출발 시간 (자동 계산)
/// - 4가지 버퍼: preparation, early_arrival, uncertainty, wrapup
///
/// **Context**: MVP 핵심 데이터 모델
class Trip {
  /// 일정 ID (UUID)
  final String? id;

  /// 사용자 ID
  final String userId;

  /// 일정 제목 / Title
  final String title;

  /// 스케줄 카테고리 색상 / Schedule category color
  /// (red, blue, green, orange, purple, teal)
  final String color;

  /// 일정 아이콘 이모지 / Schedule icon emoji
  final String emoji;

  /// 목적지 주소 / Destination address
  final String destinationAddress;

  /// 목적지 위도 / Destination latitude
  final double destinationLat;

  /// 목적지 경도 / Destination longitude
  final double destinationLng;

  /// 도착 목표 시간 / Arrival target time
  final DateTime arrivalTime;

  /// 역산된 출발 시간 / Calculated departure time
  final DateTime departureTime;

  /// 이동 수단 / Transport mode ('car' or 'transit')
  final String transportMode;

  /// 경로 데이터 (Naver API 응답) / Route data from Naver API
  final Map<String, dynamic>? routeData;

  /// 이동 소요 시간 (분) / Travel duration in minutes
  final int travelDurationMinutes;

  /// 1. 외출 준비 시간 (분) / Preparation time (5-60 min)
  final int preparationMinutes;

  /// 2. 일찍 도착 버퍼 (분) / Early arrival buffer (0-30 min)
  final int earlyArrivalBufferMinutes;

  /// 3. 이동 오차율 / Travel uncertainty rate (0-50%)
  final double travelUncertaintyRate;

  /// 4. 일정 마무리 시간 (분) / Previous task wrap-up (0-20 min)
  final int previousTaskWrapupMinutes;

  /// 완료 여부 / Is completed
  final bool isCompleted;

  /// 완료 시간 / Completed at
  final DateTime? completedAt;

  /// 취소 여부 / Is cancelled
  final bool isCancelled;

  /// 알림 활성화 / Notification enabled
  final bool notificationEnabled;

  /// 알림 발송 시간 / Notification sent at
  final DateTime? notificationSentAt;

  /// 생성 시간 / Created at
  final DateTime? createdAt;

  /// 수정 시간 / Updated at
  final DateTime? updatedAt;

  Trip({
    this.id,
    required this.userId,
    required this.title,
    this.color = 'blue',
    this.emoji = '🚗',
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.arrivalTime,
    required this.departureTime,
    required this.transportMode,
    this.routeData,
    required this.travelDurationMinutes,
    this.preparationMinutes = 15,
    this.earlyArrivalBufferMinutes = 10,
    this.travelUncertaintyRate = 0.2,
    this.previousTaskWrapupMinutes = 5,
    this.isCompleted = false,
    this.completedAt,
    this.isCancelled = false,
    this.notificationEnabled = true,
    this.notificationSentAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Supabase JSON으로부터 Trip 생성 / Create Trip from Supabase JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      color: json['color'] as String? ?? 'blue',
      emoji: json['emoji'] as String? ?? '🚗',
      destinationAddress: json['destination_address'] as String,
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLng: (json['destination_lng'] as num).toDouble(),
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
      departureTime: DateTime.parse(json['departure_time'] as String),
      transportMode: json['transport_mode'] as String,
      routeData: json['route_data'] as Map<String, dynamic>?,
      travelDurationMinutes: json['travel_duration_minutes'] as int,
      preparationMinutes: json['preparation_minutes'] as int? ?? 15,
      earlyArrivalBufferMinutes:
          json['early_arrival_buffer_minutes'] as int? ?? 10,
      travelUncertaintyRate:
          (json['travel_uncertainty_rate'] as num?)?.toDouble() ?? 0.2,
      previousTaskWrapupMinutes:
          json['previous_task_wrapup_minutes'] as int? ?? 5,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      notificationSentAt: json['notification_sent_at'] != null
          ? DateTime.parse(json['notification_sent_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Supabase JSON으로 변환 / Convert to Supabase JSON
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - id는 insert 시 생략 (Supabase가 자동 생성)
  /// - created_at, updated_at은 Supabase가 자동 관리
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'color': color,
      'emoji': emoji,
      'destination_address': destinationAddress,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'arrival_time': arrivalTime.toIso8601String(),
      'departure_time': departureTime.toIso8601String(),
      'transport_mode': transportMode,
      if (routeData != null) 'route_data': routeData,
      'travel_duration_minutes': travelDurationMinutes,
      'preparation_minutes': preparationMinutes,
      'early_arrival_buffer_minutes': earlyArrivalBufferMinutes,
      'travel_uncertainty_rate': travelUncertaintyRate,
      'previous_task_wrapup_minutes': previousTaskWrapupMinutes,
      'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'is_cancelled': isCancelled,
      'notification_enabled': notificationEnabled,
      if (notificationSentAt != null)
        'notification_sent_at': notificationSentAt!.toIso8601String(),
    };
  }

  /// Trip 복사 (불변성) / Copy Trip (immutability)
  Trip copyWith({
    String? id,
    String? userId,
    String? title,
    String? color,
    String? emoji,
    String? destinationAddress,
    double? destinationLat,
    double? destinationLng,
    DateTime? arrivalTime,
    DateTime? departureTime,
    String? transportMode,
    Map<String, dynamic>? routeData,
    int? travelDurationMinutes,
    int? preparationMinutes,
    int? earlyArrivalBufferMinutes,
    double? travelUncertaintyRate,
    int? previousTaskWrapupMinutes,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isCancelled,
    bool? notificationEnabled,
    DateTime? notificationSentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      transportMode: transportMode ?? this.transportMode,
      routeData: routeData ?? this.routeData,
      travelDurationMinutes:
          travelDurationMinutes ?? this.travelDurationMinutes,
      preparationMinutes: preparationMinutes ?? this.preparationMinutes,
      earlyArrivalBufferMinutes:
          earlyArrivalBufferMinutes ?? this.earlyArrivalBufferMinutes,
      travelUncertaintyRate:
          travelUncertaintyRate ?? this.travelUncertaintyRate,
      previousTaskWrapupMinutes:
          previousTaskWrapupMinutes ?? this.previousTaskWrapupMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isCancelled: isCancelled ?? this.isCancelled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationSentAt: notificationSentAt ?? this.notificationSentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 출발까지 남은 시간 / Time until departure
  Duration getTimeUntilDeparture() {
    final now = DateTime.now();
    return departureTime.difference(now);
  }

  /// 도착까지 남은 시간 / Time until arrival
  Duration getTimeUntilArrival() {
    final now = DateTime.now();
    return arrivalTime.difference(now);
  }

  /// 지각 여부 확인 / Check if late
  bool isLate() {
    final now = DateTime.now();
    return now.isAfter(departureTime) && !isCompleted;
  }

  /// 활성 일정 여부 / Check if active
  bool isActive() {
    return !isCompleted && !isCancelled;
  }

  /// 대중교통 상세 경로 추출 / Extract transit route details
  ///
  /// **Context**: routeData에 저장된 TransitResult를 파싱
  /// **Returns**: TransitResult 객체, 없으면 null
  TransitResult? get transitDetails {
    if (routeData == null || transportMode != 'transit') {
      return null;
    }

    try {
      return TransitResult.fromJson(routeData!);
    } catch (e) {
      print('⚠️ Failed to parse transit route data: $e');
      return null;
    }
  }

  @override
  String toString() {
    return 'Trip(id: $id, title: $title, arrivalTime: $arrivalTime, departureTime: $departureTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trip && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
