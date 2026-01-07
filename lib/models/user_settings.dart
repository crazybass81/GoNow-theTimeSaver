/// 사용자 설정 모델 / User Settings Model
///
/// **Supabase 테이블**: users (설정 필드만)
///
/// **기능 / Features**:
/// - 교통 수단 선호도 설정
/// - 기본 집 위치 설정
/// - 기본 버퍼 시간 설정 (4가지)
/// - 알림 설정
///
/// **비즈니스 규칙 / Business Rule**:
/// - preferred_transport: 'car', 'transit', 'auto' 중 선택
/// - 버퍼 시간은 범위 검증 필요
/// - 로컬 캐시 (shared_preferences)와 Supabase 동기화
///
/// **Context**: MVP 사용자 설정 관리
class UserSettings {
  /// 사용자 ID (UUID)
  final String userId;

  /// 선호 교통 수단 / Preferred transport mode
  /// 'car', 'transit', 'auto'
  final String preferredTransport;

  /// 기본 집 위치 / Default home location
  final HomeLocation? defaultHomeLocation;

  /// 기본 버퍼 시간 설정 (4가지) / Default buffer times
  final int defaultPreparationMinutes;
  final int defaultEarlyArrivalBufferMinutes;
  final double defaultTravelUncertaintyRate;
  final int defaultPreviousTaskWrapupMinutes;

  /// 알림 설정 / Notification settings
  final bool notificationEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// 구독 정보 / Subscription info
  final String subscriptionTier; // 'free', 'premium'
  final DateTime? subscriptionExpiresAt;

  /// 메타데이터 / Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActiveAt;

  UserSettings({
    required this.userId,
    this.preferredTransport = 'transit',
    this.defaultHomeLocation,
    this.defaultPreparationMinutes = 15,
    this.defaultEarlyArrivalBufferMinutes = 10,
    this.defaultTravelUncertaintyRate = 0.2,
    this.defaultPreviousTaskWrapupMinutes = 5,
    this.notificationEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.subscriptionTier = 'free',
    this.subscriptionExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.lastActiveAt,
  });

  /// Supabase JSON으로부터 UserSettings 생성 / Create from Supabase JSON
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['id'] as String,
      preferredTransport: json['preferred_transport'] as String? ?? 'transit',
      defaultHomeLocation: json['default_home_location'] != null
          ? HomeLocation.fromJson(
              json['default_home_location'] as Map<String, dynamic>)
          : null,
      defaultPreparationMinutes:
          json['default_preparation_minutes'] as int? ?? 15,
      defaultEarlyArrivalBufferMinutes:
          json['default_early_arrival_buffer_minutes'] as int? ?? 10,
      defaultTravelUncertaintyRate:
          (json['default_travel_uncertainty_rate'] as num?)?.toDouble() ?? 0.2,
      defaultPreviousTaskWrapupMinutes:
          json['default_previous_task_wrapup_minutes'] as int? ?? 5,
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  /// Supabase JSON으로 변환 / Convert to Supabase JSON
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - users 테이블 업데이트용
  /// - 설정 필드만 포함
  Map<String, dynamic> toJson() {
    return {
      'preferred_transport': preferredTransport,
      if (defaultHomeLocation != null)
        'default_home_location': defaultHomeLocation!.toJson(),
      'default_preparation_minutes': defaultPreparationMinutes,
      'default_early_arrival_buffer_minutes': defaultEarlyArrivalBufferMinutes,
      'default_travel_uncertainty_rate': defaultTravelUncertaintyRate,
      'default_previous_task_wrapup_minutes':
          defaultPreviousTaskWrapupMinutes,
      'notification_enabled': notificationEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'last_active_at': DateTime.now().toIso8601String(),
    };
  }

  /// UserSettings 복사 (불변성) / Copy UserSettings (immutability)
  UserSettings copyWith({
    String? userId,
    String? preferredTransport,
    HomeLocation? defaultHomeLocation,
    int? defaultPreparationMinutes,
    int? defaultEarlyArrivalBufferMinutes,
    double? defaultTravelUncertaintyRate,
    int? defaultPreviousTaskWrapupMinutes,
    bool? notificationEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      preferredTransport: preferredTransport ?? this.preferredTransport,
      defaultHomeLocation: defaultHomeLocation ?? this.defaultHomeLocation,
      defaultPreparationMinutes:
          defaultPreparationMinutes ?? this.defaultPreparationMinutes,
      defaultEarlyArrivalBufferMinutes: defaultEarlyArrivalBufferMinutes ??
          this.defaultEarlyArrivalBufferMinutes,
      defaultTravelUncertaintyRate:
          defaultTravelUncertaintyRate ?? this.defaultTravelUncertaintyRate,
      defaultPreviousTaskWrapupMinutes: defaultPreviousTaskWrapupMinutes ??
          this.defaultPreviousTaskWrapupMinutes,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// 버퍼 시간 검증 / Validate buffer times
  bool validateBufferTimes() {
    // 1. Preparation: 5-60분
    if (defaultPreparationMinutes < 5 || defaultPreparationMinutes > 60) {
      return false;
    }

    // 2. Early Arrival: 0-30분
    if (defaultEarlyArrivalBufferMinutes < 0 ||
        defaultEarlyArrivalBufferMinutes > 30) {
      return false;
    }

    // 3. Uncertainty Rate: 0-50%
    if (defaultTravelUncertaintyRate < 0 ||
        defaultTravelUncertaintyRate > 0.5) {
      return false;
    }

    // 4. Wrap-up: 0-20분
    if (defaultPreviousTaskWrapupMinutes < 0 ||
        defaultPreviousTaskWrapupMinutes > 20) {
      return false;
    }

    return true;
  }

  /// 프리미엄 구독 여부 / Check if premium
  bool isPremium() {
    if (subscriptionTier != 'premium') return false;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  @override
  String toString() {
    return 'UserSettings(userId: $userId, preferredTransport: $preferredTransport, isPremium: ${isPremium()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// 집 위치 모델 / Home Location Model
class HomeLocation {
  final double lat;
  final double lng;
  final String address;

  HomeLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory HomeLocation.fromJson(Map<String, dynamic> json) {
    return HomeLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }

  @override
  String toString() => 'HomeLocation($address)';
}
