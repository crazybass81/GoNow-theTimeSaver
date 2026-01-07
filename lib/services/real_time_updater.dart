import 'dart:async';
import 'package:flutter/foundation.dart';
import 'scheduler_service.dart';
import 'polling_service.dart';
import 'route_service.dart';
import 'transit_service.dart';

/// 실시간 업데이트 서비스 / Real-Time Update Service
///
/// **기능 / Features**:
/// - 출발 시간까지 실시간 카운트다운
/// - 적응형 폴링을 사용한 API 자동 갱신
/// - 변화율 기반 최적화 (5% 미만 스킵)
/// - UI 자동 업데이트 (콜백 방식)
///
/// **비즈니스 규칙 / Business Rule**:
/// - 변화율 5% 미만이면 API 재호출 스킵 (배터리 효율)
/// - 출발 시간이 지나면 자동 정지
/// - 타이머는 적응형 간격 (15분/5분/3분)
///
/// **Context**: ADHD 사용자의 실시간 정보 업데이트 필요성과 배터리 효율의 균형
class RealTimeUpdater {
  // Singleton pattern
  static final RealTimeUpdater _instance = RealTimeUpdater._internal();
  factory RealTimeUpdater() => _instance;
  RealTimeUpdater._internal();

  bool _initialized = false;
  Timer? _timer;
  DateTime? _lastDepartureTime;
  int? _lastTravelDuration;

  /// 변화율 임계값 (5%) / Change rate threshold
  static const double changeThreshold = 0.05;

  /// 서비스 초기화 / Initialize service
  void initialize() {
    if (_initialized) {
      debugPrint('⚠️ RealTimeUpdater already initialized');
      return;
    }

    debugPrint('✅ RealTimeUpdater initialized');
    _initialized = true;
  }

  /// 실시간 업데이트 시작 / Start real-time updates
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 적응형 폴링 간격 사용 (PollingService)
  /// - 변화율 5% 미만 시 API 재호출 스킵
  /// - 출발 시간 지나면 자동 정지
  ///
  /// **Context**: 대시보드 화면 진입 시 호출
  ///
  /// @param departureTime 출발 시간
  /// @param arrivalTime 도착 시간
  /// @param origin 출발지 좌표
  /// @param destination 도착지 좌표
  /// @param transportMode 이동 수단 ('car' 또는 'transit')
  /// @param preparationMinutes 외출 준비 시간
  /// @param previousTaskWrapUpMinutes 일정 마무리 시간
  /// @param earlyArrivalBufferMinutes 일찍 도착 버퍼
  /// @param travelUncertaintyRate 이동 오차율
  /// @param onUpdate 업데이트 콜백 (departureTime, timePhase)
  ///
  /// @example
  /// RealTimeUpdater().startUpdating(
  ///   departureTime: DateTime(2025, 1, 6, 13, 0),
  ///   arrivalTime: DateTime(2025, 1, 6, 14, 0),
  ///   origin: LatLng(37.5665, 126.9780),
  ///   destination: LatLng(37.4979, 127.0276),
  ///   transportMode: 'car',
  ///   preparationMinutes: 15,
  ///   onUpdate: (departureTime, timePhase) {
  ///     setState(() {
  ///       this.departureTime = departureTime;
  ///       this.timePhase = timePhase;
  ///     });
  ///   },
  /// );
  void startUpdating({
    required DateTime departureTime,
    required DateTime arrivalTime,
    required Map<String, double> origin,
    required Map<String, double> destination,
    required String transportMode,
    required int preparationMinutes,
    int previousTaskWrapUpMinutes = 5,
    int earlyArrivalBufferMinutes = 10,
    double travelUncertaintyRate = 0.2,
    required Function(DateTime departureTime, String timePhase) onUpdate,
  }) {
    if (!_initialized) {
      throw StateError('RealTimeUpdater not initialized. Call initialize() first.');
    }

    // 기존 타이머 정리
    stopUpdating();

    // 초기 값 저장
    _lastDepartureTime = departureTime;

    debugPrint('🔄 Real-Time Update Started');
    debugPrint('  Departure Time: $departureTime');
    debugPrint('  Arrival Time: $arrivalTime');

    // 타이머 시작
    _scheduleNextUpdate(
      arrivalTime: arrivalTime,
      origin: origin,
      destination: destination,
      transportMode: transportMode,
      preparationMinutes: preparationMinutes,
      previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
      earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
      travelUncertaintyRate: travelUncertaintyRate,
      onUpdate: onUpdate,
    );
  }

  /// 다음 업데이트 스케줄링 / Schedule next update
  void _scheduleNextUpdate({
    required DateTime arrivalTime,
    required Map<String, double> origin,
    required Map<String, double> destination,
    required String transportMode,
    required int preparationMinutes,
    required int previousTaskWrapUpMinutes,
    required int earlyArrivalBufferMinutes,
    required double travelUncertaintyRate,
    required Function(DateTime departureTime, String timePhase) onUpdate,
  }) {
    final now = DateTime.now();
    final timeUntilDeparture = arrivalTime.difference(now);

    // 출발 시간이 이미 지났으면 정지
    if (timeUntilDeparture.isNegative && timeUntilDeparture.abs() > const Duration(hours: 1)) {
      debugPrint('⏹️ Departure time passed. Stopping real-time update.');
      stopUpdating();
      return;
    }

    // 적응형 폴링 간격 계산
    final pollingInterval = PollingService().getPollingInterval(
      timeUntilDeparture: timeUntilDeparture,
    );

    // 타이머 설정
    _timer = Timer(pollingInterval, () async {
      await _performUpdate(
        arrivalTime: arrivalTime,
        origin: origin,
        destination: destination,
        transportMode: transportMode,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
        onUpdate: onUpdate,
      );

      // 다음 업데이트 스케줄링 (재귀 호출)
      _scheduleNextUpdate(
        arrivalTime: arrivalTime,
        origin: origin,
        destination: destination,
        transportMode: transportMode,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
        onUpdate: onUpdate,
      );
    });
  }

  /// 업데이트 수행 / Perform update
  Future<void> _performUpdate({
    required DateTime arrivalTime,
    required Map<String, double> origin,
    required Map<String, double> destination,
    required String transportMode,
    required int preparationMinutes,
    required int previousTaskWrapUpMinutes,
    required int earlyArrivalBufferMinutes,
    required double travelUncertaintyRate,
    required Function(DateTime departureTime, String timePhase) onUpdate,
  }) async {
    try {
      debugPrint('🔄 Performing update...');

      // 1. API 호출하여 최신 이동 시간 가져오기
      int? newTravelDuration;

      if (transportMode == 'car') {
        // 자동차 경로
        final result = await RouteService().calculateRoute(
          originLat: origin['lat']!,
          originLng: origin['lng']!,
          destLat: destination['lat']!,
          destLng: destination['lng']!,
        );

        if (result != null) {
          newTravelDuration = result.durationMinutes;
        }
      } else if (transportMode == 'transit') {
        // 대중교통 경로
        final result = await TransitService().calculateTransitRoute(
          originLat: origin['lat']!,
          originLng: origin['lng']!,
          destLat: destination['lat']!,
          destLng: destination['lng']!,
        );

        if (result.isNotEmpty) {
          newTravelDuration = result.first.durationMinutes;
        }
      }

      // API 호출 실패 시 이전 값 사용
      if (newTravelDuration == null) {
        debugPrint('⚠️ API call failed. Using previous duration.');
        if (_lastTravelDuration == null) {
          debugPrint('⚠️ No previous duration. Skipping update.');
          return;
        }
        newTravelDuration = _lastTravelDuration!;
      }

      // 2. 변화율 계산 (5% 미만 시 스킵)
      if (_lastTravelDuration != null) {
        final changeRate = (newTravelDuration - _lastTravelDuration!).abs() / _lastTravelDuration!;

        if (changeRate < changeThreshold) {
          debugPrint('⏭️ Change rate < 5%. Skipping update.');
          debugPrint('  Previous: $_lastTravelDuration min, New: $newTravelDuration min');
          debugPrint('  Change Rate: ${(changeRate * 100).toStringAsFixed(2)}%');
          return;
        }

        debugPrint('✅ Change rate >= 5%. Updating...');
        debugPrint('  Previous: $_lastTravelDuration min, New: $newTravelDuration min');
        debugPrint('  Change Rate: ${(changeRate * 100).toStringAsFixed(2)}%');
      }

      // 3. 출발 시간 재계산
      final newDepartureTime = SchedulerService().calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: newTravelDuration,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
      );

      // 4. 시간대 계산
      final now = DateTime.now();
      final timeUntilDeparture = newDepartureTime.difference(now);
      final timePhase = PollingService().getTimePhase(
        timeUntilDeparture: timeUntilDeparture,
      );

      // 5. 값 저장
      _lastDepartureTime = newDepartureTime;
      _lastTravelDuration = newTravelDuration;

      // 6. UI 업데이트 콜백 호출
      onUpdate(newDepartureTime, timePhase);

      debugPrint('✅ Update completed. New departure time: $newDepartureTime');
    } catch (e) {
      debugPrint('❌ Update failed: $e');
    }
  }

  /// 실시간 업데이트 정지 / Stop real-time updates
  ///
  /// **Context**: 대시보드 화면 이탈 시 또는 일정 삭제 시 호출
  void stopUpdating() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      debugPrint('⏹️ Real-Time Update Stopped');
    }

    // 저장된 값 초기화
    _lastDepartureTime = null;
    _lastTravelDuration = null;
  }

  /// 현재 실행 중인지 확인 / Check if currently updating
  bool get isUpdating => _timer != null && _timer!.isActive;

  /// 마지막 출발 시간 / Last calculated departure time
  DateTime? get lastDepartureTime => _lastDepartureTime;

  /// 마지막 이동 시간 / Last travel duration
  int? get lastTravelDuration => _lastTravelDuration;

  /// 변화율 계산 / Calculate change rate
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 변화율 = |새로운 값 - 이전 값| / 이전 값
  /// - 5% 미만이면 업데이트 스킵
  ///
  /// @param previousValue 이전 값
  /// @param newValue 새로운 값
  /// @returns 변화율 (0.0 ~ 1.0)
  static double calculateChangeRate({
    required int previousValue,
    required int newValue,
  }) {
    if (previousValue == 0) {
      return 1.0; // 이전 값이 0이면 100% 변화로 간주
    }

    return (newValue - previousValue).abs() / previousValue;
  }

  /// 변화율이 임계값 이상인지 확인 / Check if change rate exceeds threshold
  ///
  /// @param previousValue 이전 값
  /// @param newValue 새로운 값
  /// @returns true이면 업데이트 필요
  static bool shouldUpdate({
    required int previousValue,
    required int newValue,
  }) {
    final changeRate = calculateChangeRate(
      previousValue: previousValue,
      newValue: newValue,
    );

    return changeRate >= changeThreshold;
  }

  /// 디버그 정보 출력 / Print debug information
  String getDebugInfo() {
    return '''
RealTimeUpdater Debug Info:
- Initialized: $_initialized
- Is Updating: $isUpdating
- Last Departure Time: $_lastDepartureTime
- Last Travel Duration: $_lastTravelDuration
- Change Threshold: ${(changeThreshold * 100).toStringAsFixed(0)}%
''';
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

  /// 리소스 정리 / Clean up resources
  ///
  /// **Context**: 앱 종료 시 호출
  void dispose() {
    stopUpdating();
    debugPrint('🗑️ RealTimeUpdater disposed');
  }
}
