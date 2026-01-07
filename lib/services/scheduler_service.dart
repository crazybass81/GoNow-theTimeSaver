import 'package:flutter/foundation.dart';

/// 역산 스케줄링 서비스 / Backward Scheduling Service
///
/// **기능 / Features**:
/// - 도착 시간에서 출발 시간 역산 계산
/// - 4가지 독립 버퍼 시간 시스템
/// - 이동 오차율 자동 반영
///
/// **비즈니스 규칙 / Business Rule**:
/// - 출발 시간 = 도착 시간 - (일정 마무리 + 일찍 도착 + 이동시간 + 오차율 + 외출 준비)
///
/// **Context**: MVP 핵심 기능 - ADHD 사용자의 시간 맹목 해결
class SchedulerService {
  // Singleton pattern
  static final SchedulerService _instance = SchedulerService._internal();
  factory SchedulerService() => _instance;
  SchedulerService._internal();

  bool _initialized = false;

  /// 서비스 초기화 / Initialize service
  void initialize() {
    if (_initialized) {
      debugPrint('⚠️ SchedulerService already initialized');
      return;
    }

    debugPrint('✅ SchedulerService initialized');
    _initialized = true;
  }

  /// 역산 스케줄링: 도착 시간에서 출발 시간 계산 / Calculate departure time from arrival time
  ///
  /// **알고리즘 / Algorithm**:
  /// 출발 시간 = 도착 시간 - (일정 마무리 + 일찍 도착 + 이동시간 + 오차율 + 외출 준비)
  ///
  /// **4가지 버퍼 시간 / 4 Buffer Times**:
  /// 1. previousTaskWrapUpMinutes: 이전 일정 마무리 시간 (기본 5분, 범위 0-20분)
  /// 2. earlyArrivalBufferMinutes: 일찍 도착 버퍼 (기본 10분, 범위 0-30분)
  /// 3. travelUncertaintyRate: 이동 오차율 (기본 20%, 범위 0-50%)
  /// 4. preparationMinutes: 외출 준비 시간 (기본 15분, 범위 5-60분)
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 모든 버퍼 시간은 독립적으로 설정 가능
  /// - 이동 오차율은 이동 시간에 비례하여 자동 계산
  /// - 최소 출발 시간은 현재 시간보다 과거일 수 없음 (검증은 호출자 책임)
  ///
  /// @param arrivalTime 도착 시간 (목표 시간)
  /// @param travelDurationMinutes 이동 시간 (분) - API로부터 받은 실시간 교통 정보
  /// @param preparationMinutes 외출 준비 시간 (분) - 사용자 설정 값
  /// @param previousTaskWrapUpMinutes 이전 일정 마무리 시간 (분) - 사용자 설정 값, 기본 5분
  /// @param earlyArrivalBufferMinutes 일찍 도착 버퍼 (분) - 사용자 설정 값, 기본 10분
  /// @param travelUncertaintyRate 이동 오차율 (0.0-0.5) - 사용자 설정 값, 기본 0.2 (20%)
  /// @returns 계산된 출발 시간
  ///
  /// @example
  /// final departureTime = SchedulerService().calculateDepartureTime(
  ///   arrivalTime: DateTime(2025, 1, 6, 14, 0), // 오후 2시 도착
  ///   travelDurationMinutes: 30,                 // 이동 시간 30분
  ///   preparationMinutes: 15,                    // 외출 준비 15분
  ///   previousTaskWrapUpMinutes: 5,              // 일정 마무리 5분
  ///   earlyArrivalBufferMinutes: 10,             // 일찍 도착 10분
  ///   travelUncertaintyRate: 0.2,                // 이동 오차율 20%
  /// );
  /// // 결과: 오후 12:59 (14:00 - 5분 - 10분 - 30분 - 6분(20%) - 15분)
  DateTime calculateDepartureTime({
    required DateTime arrivalTime,
    required int travelDurationMinutes,
    required int preparationMinutes,
    int previousTaskWrapUpMinutes = 5,
    int earlyArrivalBufferMinutes = 10,
    double travelUncertaintyRate = 0.2,
  }) {
    // 입력 검증 / Input validation
    if (!_initialized) {
      throw StateError('SchedulerService not initialized. Call initialize() first.');
    }

    if (travelDurationMinutes < 0) {
      throw ArgumentError('travelDurationMinutes must be non-negative');
    }

    if (preparationMinutes < 5 || preparationMinutes > 60) {
      throw ArgumentError('preparationMinutes must be between 5 and 60 minutes');
    }

    if (previousTaskWrapUpMinutes < 0 || previousTaskWrapUpMinutes > 20) {
      throw ArgumentError('previousTaskWrapUpMinutes must be between 0 and 20 minutes');
    }

    if (earlyArrivalBufferMinutes < 0 || earlyArrivalBufferMinutes > 30) {
      throw ArgumentError('earlyArrivalBufferMinutes must be between 0 and 30 minutes');
    }

    if (travelUncertaintyRate < 0.0 || travelUncertaintyRate > 0.5) {
      throw ArgumentError('travelUncertaintyRate must be between 0.0 and 0.5');
    }

    // 3. 이동 시간 + 오차율 계산 / Calculate travel time with uncertainty
    final uncertaintyMinutes = (travelDurationMinutes * travelUncertaintyRate).ceil();
    final travelWithUncertainty = travelDurationMinutes + uncertaintyMinutes;

    // 총 소요 시간 계산 / Calculate total duration
    // 역산 순서: 일정 마무리 → 일찍 도착 → 이동 시간(오차율 포함) → 외출 준비
    final totalMinutes = previousTaskWrapUpMinutes +  // 1. 이전 일정 마무리
        earlyArrivalBufferMinutes +                   // 2. 일찍 도착 버퍼
        travelWithUncertainty +                       // 3. 이동 시간 + 오차율
        preparationMinutes;                           // 4. 외출 준비

    // 출발 시간 계산 / Calculate departure time
    final departureTime = arrivalTime.subtract(Duration(minutes: totalMinutes));

    debugPrint('📅 Backward Scheduling Calculation:');
    debugPrint('  Arrival Time: $arrivalTime');
    debugPrint('  1️⃣ Previous Task Wrap-up: $previousTaskWrapUpMinutes min');
    debugPrint('  2️⃣ Early Arrival Buffer: $earlyArrivalBufferMinutes min');
    debugPrint('  3️⃣ Travel Time: $travelDurationMinutes min + $uncertaintyMinutes min (${(travelUncertaintyRate * 100).toStringAsFixed(0)}% uncertainty)');
    debugPrint('  4️⃣ Preparation Time: $preparationMinutes min');
    debugPrint('  ⏰ Total Duration: $totalMinutes min');
    debugPrint('  🚀 Departure Time: $departureTime');

    return departureTime;
  }

  /// 버퍼 시간 설정 검증 / Validate buffer time settings
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 모든 버퍼 시간은 유효한 범위 내에 있어야 함
  /// - 검증 실패 시 구체적인 에러 메시지 반환
  ///
  /// @param preparationMinutes 외출 준비 시간 (5-60분)
  /// @param previousTaskWrapUpMinutes 이전 일정 마무리 시간 (0-20분)
  /// @param earlyArrivalBufferMinutes 일찍 도착 버퍼 (0-30분)
  /// @param travelUncertaintyRate 이동 오차율 (0.0-0.5)
  /// @returns 검증 결과 (null이면 성공, String이면 에러 메시지)
  String? validateBufferSettings({
    required int preparationMinutes,
    required int previousTaskWrapUpMinutes,
    required int earlyArrivalBufferMinutes,
    required double travelUncertaintyRate,
  }) {
    if (preparationMinutes < 5 || preparationMinutes > 60) {
      return '외출 준비 시간은 5분에서 60분 사이여야 합니다.';
    }

    if (previousTaskWrapUpMinutes < 0 || previousTaskWrapUpMinutes > 20) {
      return '일정 마무리 시간은 0분에서 20분 사이여야 합니다.';
    }

    if (earlyArrivalBufferMinutes < 0 || earlyArrivalBufferMinutes > 30) {
      return '일찍 도착 버퍼는 0분에서 30분 사이여야 합니다.';
    }

    if (travelUncertaintyRate < 0.0 || travelUncertaintyRate > 0.5) {
      return '이동 오차율은 0%에서 50% 사이여야 합니다.';
    }

    return null; // 검증 성공
  }

  /// 현재 시간 기준으로 출발 시간이 과거인지 확인 / Check if departure time is in the past
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 출발 시간이 현재 시간보다 과거이면 사용자에게 경고 표시
  /// - UI에서 빨간색 경고 상태로 표시
  /// - Edge case: 출발 시간 == 현재 시간 → 과거 아님 (아직 출발 가능)
  /// - Tolerance: 1초 이내 차이는 "현재"로 간주 (timing race condition 방지)
  ///
  /// @param departureTime 계산된 출발 시간
  /// @returns true이면 출발 시간이 과거 (경고 필요)
  bool isDepartureTimeInPast(DateTime departureTime) {
    final now = DateTime.now();

    // 1초 이내 차이는 "현재"로 간주하여 과거 아님
    // 이는 timing race condition 방지 및 사용자 경험 개선
    const tolerance = Duration(seconds: 1);
    return departureTime.add(tolerance).isBefore(now);
  }

  /// 출발까지 남은 시간 계산 / Calculate time remaining until departure
  ///
  /// **Context**: UI 카운트다운 표시용
  ///
  /// @param departureTime 출발 시간
  /// @returns 남은 시간 (Duration) - 음수이면 이미 출발 시간 지남
  Duration getTimeUntilDeparture(DateTime departureTime) {
    final now = DateTime.now();
    return departureTime.difference(now);
  }

  /// 이동 오차율에 따른 추가 시간 계산 / Calculate additional time based on uncertainty rate
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 이동 오차율은 이동 시간에 비례하여 추가 시간 계산
  /// - 반올림하여 정수 분으로 반환
  ///
  /// @param travelDurationMinutes 이동 시간 (분)
  /// @param uncertaintyRate 이동 오차율 (0.0-0.5)
  /// @returns 추가 시간 (분)
  int calculateUncertaintyMinutes({
    required int travelDurationMinutes,
    required double uncertaintyRate,
  }) {
    return (travelDurationMinutes * uncertaintyRate).ceil();
  }

  /// 총 버퍼 시간 계산 (이동 시간 제외) / Calculate total buffer time (excluding travel time)
  ///
  /// **Context**: UI에서 "총 버퍼 시간" 표시용
  ///
  /// @param preparationMinutes 외출 준비 시간
  /// @param previousTaskWrapUpMinutes 이전 일정 마무리 시간
  /// @param earlyArrivalBufferMinutes 일찍 도착 버퍼
  /// @param travelDurationMinutes 이동 시간
  /// @param travelUncertaintyRate 이동 오차율
  /// @returns 총 버퍼 시간 (분) - 이동 시간 포함
  int getTotalBufferMinutes({
    required int preparationMinutes,
    required int previousTaskWrapUpMinutes,
    required int earlyArrivalBufferMinutes,
    required int travelDurationMinutes,
    required double travelUncertaintyRate,
  }) {
    final uncertaintyMinutes = calculateUncertaintyMinutes(
      travelDurationMinutes: travelDurationMinutes,
      uncertaintyRate: travelUncertaintyRate,
    );

    return previousTaskWrapUpMinutes +
        earlyArrivalBufferMinutes +
        uncertaintyMinutes +
        preparationMinutes;
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
