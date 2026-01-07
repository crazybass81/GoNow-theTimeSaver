import 'package:flutter/foundation.dart';

/// 적응형 폴링 서비스 / Adaptive Polling Service
///
/// **기능 / Features**:
/// - 출발 시간까지 남은 시간에 따라 API 호출 주기 자동 조정
/// - 배터리 효율성 및 실시간성 균형 유지
///
/// **비즈니스 규칙 / Business Rule**:
/// - 1시간 이상 전: 15분 간격 (배터리 효율 우선)
/// - 30분~1시간 전: 5분 간격 (균형)
/// - 10분 이내: 3분 간격 (실시간성 우선)
///
/// **Context**: ADHD 사용자의 실시간 정보 업데이트 요구와 배터리 효율의 균형
class PollingService {
  // Singleton pattern
  static final PollingService _instance = PollingService._internal();
  factory PollingService() => _instance;
  PollingService._internal();

  bool _initialized = false;

  /// 폴링 간격 상수 정의 / Polling interval constants
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - Long interval: 배터리 효율 우선 (15분)
  /// - Medium interval: 균형 (5분)
  /// - Short interval: 실시간성 우선 (3분)
  static const Duration longInterval = Duration(minutes: 15);
  static const Duration mediumInterval = Duration(minutes: 5);
  static const Duration shortInterval = Duration(minutes: 3);

  /// 시간대별 임계값 / Time threshold constants
  static const Duration oneHourThreshold = Duration(hours: 1);
  static const Duration thirtyMinutesThreshold = Duration(minutes: 30);
  static const Duration tenMinutesThreshold = Duration(minutes: 10);

  /// 서비스 초기화 / Initialize service
  void initialize() {
    if (_initialized) {
      debugPrint('⚠️ PollingService already initialized');
      return;
    }

    debugPrint('✅ PollingService initialized');
    _initialized = true;
  }

  /// 적응형 폴링 간격 계산 / Calculate adaptive polling interval
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 1시간 이상 전: 15분 간격 (배터리 효율)
  /// - 30분~1시간 전: 5분 간격 (균형)
  /// - 10분 이내: 3분 간격 (실시간성)
  ///
  /// **Context**: ADHD 사용자는 출발 시간이 가까워질수록 더 자주 확인하려는 경향
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 적절한 폴링 간격
  ///
  /// @example
  /// final interval1 = PollingService().getPollingInterval(
  ///   timeUntilDeparture: Duration(hours: 2), // 2시간 전
  /// );
  /// // 결과: Duration(minutes: 15)
  ///
  /// final interval2 = PollingService().getPollingInterval(
  ///   timeUntilDeparture: Duration(minutes: 45), // 45분 전
  /// );
  /// // 결과: Duration(minutes: 5)
  ///
  /// final interval3 = PollingService().getPollingInterval(
  ///   timeUntilDeparture: Duration(minutes: 5), // 5분 전
  /// );
  /// // 결과: Duration(minutes: 3)
  Duration getPollingInterval({required Duration timeUntilDeparture}) {
    if (!_initialized) {
      throw StateError('PollingService not initialized. Call initialize() first.');
    }

    // 음수 시간 처리 (출발 시간이 이미 지남)
    if (timeUntilDeparture.isNegative) {
      // 출발 시간이 지났지만 여전히 업데이트 필요 (지각 경고용)
      return shortInterval;
    }

    // 시간대별 간격 결정
    if (timeUntilDeparture >= oneHourThreshold) {
      // 1시간 이상 전: 15분 간격 (배터리 효율 우선)
      debugPrint('⏰ Polling Interval: 15 minutes (${timeUntilDeparture.inMinutes} min until departure)');
      return longInterval;
    } else if (timeUntilDeparture >= tenMinutesThreshold) {
      // 10분~1시간 전: 5분 간격 (균형)
      debugPrint('⏰ Polling Interval: 5 minutes (${timeUntilDeparture.inMinutes} min until departure)');
      return mediumInterval;
    } else {
      // 10분 이내: 3분 간격 (실시간성 우선)
      debugPrint('⏰ Polling Interval: 3 minutes (${timeUntilDeparture.inMinutes} min until departure)');
      return shortInterval;
    }
  }

  /// 다음 폴링 시간 계산 / Calculate next polling time
  ///
  /// **Context**: 타이머 설정용
  ///
  /// @param currentTime 현재 시간
  /// @param departureTime 출발 시간
  /// @returns 다음 폴링을 수행할 시간
  DateTime getNextPollingTime({
    required DateTime currentTime,
    required DateTime departureTime,
  }) {
    if (!_initialized) {
      throw StateError('PollingService not initialized. Call initialize() first.');
    }

    final timeUntilDeparture = departureTime.difference(currentTime);
    final interval = getPollingInterval(timeUntilDeparture: timeUntilDeparture);

    return currentTime.add(interval);
  }

  /// 폴링 간격을 초 단위로 변환 / Convert polling interval to seconds
  ///
  /// **Context**: Timer.periodic() 파라미터용
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 폴링 간격 (초)
  int getPollingIntervalInSeconds({required Duration timeUntilDeparture}) {
    final interval = getPollingInterval(timeUntilDeparture: timeUntilDeparture);
    return interval.inSeconds;
  }

  /// 폴링 간격을 밀리초 단위로 변환 / Convert polling interval to milliseconds
  ///
  /// **Context**: Future.delayed() 파라미터용
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 폴링 간격 (밀리초)
  int getPollingIntervalInMilliseconds({required Duration timeUntilDeparture}) {
    final interval = getPollingInterval(timeUntilDeparture: timeUntilDeparture);
    return interval.inMilliseconds;
  }

  /// 현재 시간대 확인 / Check current time phase
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - critical: 10분 이내 (빨간색 경고)
  /// - warning: 10분~30분 전 (주황색 주의)
  /// - normal: 30분 이상 전 (초록색 안전)
  ///
  /// **Context**: UI 색상 표시 및 알림 우선순위 결정
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 시간대 (critical, warning, normal)
  String getTimePhase({required Duration timeUntilDeparture}) {
    if (!_initialized) {
      throw StateError('PollingService not initialized. Call initialize() first.');
    }

    if (timeUntilDeparture.isNegative) {
      return 'late'; // 지각
    } else if (timeUntilDeparture < tenMinutesThreshold) {
      return 'critical'; // 빨간색
    } else if (timeUntilDeparture < thirtyMinutesThreshold) {
      return 'warning'; // 주황색
    } else {
      return 'normal'; // 초록색
    }
  }

  /// 시간대별 색상 코드 반환 / Get color code for time phase
  ///
  /// **Context**: UI 색상 표시용
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 16진수 색상 코드 (예: 0xFFFF0000)
  int getTimePhaseColor({required Duration timeUntilDeparture}) {
    final phase = getTimePhase(timeUntilDeparture: timeUntilDeparture);

    switch (phase) {
      case 'late':
        return 0xFFB71C1C; // Material Red 900 (어두운 빨강)
      case 'critical':
        return 0xFFF44336; // Material Red 500 (빨강)
      case 'warning':
        return 0xFFFF9800; // Material Orange 500 (주황)
      case 'normal':
        return 0xFF4CAF50; // Material Green 500 (초록)
      default:
        return 0xFF9E9E9E; // Material Grey 500 (회색)
    }
  }

  /// 폴링 간격 변경이 필요한지 확인 / Check if polling interval should change
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 시간대가 바뀌면 폴링 간격도 변경 필요
  /// - 예: 1시간 전 → 30분 전으로 전환될 때 15분 → 5분으로 변경
  ///
  /// **Context**: 타이머 재설정 필요 여부 판단
  ///
  /// @param previousTimeUntilDeparture 이전 체크 시점의 남은 시간
  /// @param currentTimeUntilDeparture 현재 남은 시간
  /// @returns true이면 폴링 간격 변경 필요
  bool shouldChangePollingInterval({
    required Duration previousTimeUntilDeparture,
    required Duration currentTimeUntilDeparture,
  }) {
    if (!_initialized) {
      throw StateError('PollingService not initialized. Call initialize() first.');
    }

    final previousPhase = getTimePhase(timeUntilDeparture: previousTimeUntilDeparture);
    final currentPhase = getTimePhase(timeUntilDeparture: currentTimeUntilDeparture);

    final shouldChange = previousPhase != currentPhase;

    if (shouldChange) {
      debugPrint('⏰ Polling Interval Change: $previousPhase → $currentPhase');
    }

    return shouldChange;
  }

  /// 배터리 효율 모드 확인 / Check if battery-efficient mode
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 1시간 이상 전이면 배터리 효율 모드 (15분 간격)
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns true이면 배터리 효율 모드
  bool isBatteryEfficientMode({required Duration timeUntilDeparture}) {
    return timeUntilDeparture >= oneHourThreshold;
  }

  /// 실시간 모드 확인 / Check if real-time mode
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 10분 이내면 실시간 모드 (3분 간격)
  /// - 음수 시간(지각)은 실시간 모드가 아님
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns true이면 실시간 모드
  bool isRealTimeMode({required Duration timeUntilDeparture}) {
    return !timeUntilDeparture.isNegative && timeUntilDeparture < tenMinutesThreshold;
  }

  /// 폴링 통계 정보 반환 / Get polling statistics
  ///
  /// **Context**: 디버깅 및 모니터링용
  ///
  /// @param timeUntilDeparture 출발 시간까지 남은 시간
  /// @returns 폴링 통계 맵
  Map<String, dynamic> getPollingStats({required Duration timeUntilDeparture}) {
    return {
      'timeUntilDeparture': timeUntilDeparture.inMinutes,
      'pollingInterval': getPollingInterval(timeUntilDeparture: timeUntilDeparture).inMinutes,
      'timePhase': getTimePhase(timeUntilDeparture: timeUntilDeparture),
      'colorCode': getTimePhaseColor(timeUntilDeparture: timeUntilDeparture),
      'batteryEfficientMode': isBatteryEfficientMode(timeUntilDeparture: timeUntilDeparture),
      'realTimeMode': isRealTimeMode(timeUntilDeparture: timeUntilDeparture),
    };
  }

  /// 서비스 상태 확인 / Check service status
  bool get isInitialized => _initialized;

  /// 테스트용 리셋 메서드 / Reset method for testing
  ///
  /// **Context**: 테스트에서 초기화되지 않은 상태를 시뮬레이션하기 위해 사용
  /// **Warning**: 프로덕션 코드에서는 사용하지 말 것
  @visibleForTesting
  void resetForTesting() {
    _initialized = false;
  }
}
