import '../services/transit_service.dart';

/// 환승 버퍼 시간 자동 계산 유틸리티 / Transfer buffer time calculator
///
/// **기능 / Features**:
/// - 도보 환승 시간 자동 추가 (5분)
/// - 버스 환승 시간 자동 추가 (3분)
/// - 환승역 거리 기반 조정 로직
///
/// **비즈니스 규칙 / Business Rule**:
/// - 도보 환승: 기본 5분 + 거리 기반 추가 시간
/// - 버스 환승: 기본 3분 (버스 대기 시간 포함)
/// - 지하철 ↔ 지하철: 5분 (플랫폼 이동 시간)
///
/// **Context**: 대중교통 경로 소요 시간 계산 시 사용
class TransferBuffer {
  /// 도보 환승 기본 버퍼 시간 (분) / Default walk transfer buffer time (minutes)
  static const int walkTransferMinutes = 5;

  /// 버스 환승 기본 버퍼 시간 (분) / Default bus transfer buffer time (minutes)
  static const int busTransferMinutes = 3;

  /// 지하철 환승 기본 버퍼 시간 (분) / Default subway transfer buffer time (minutes)
  static const int subwayTransferMinutes = 5;

  /// 환승 거리당 추가 시간 (분/km) / Additional time per km (minutes/km)
  static const double minutesPerKm = 12.0; // 평균 도보 속도: 5km/h = 12분/km

  /// 환승 버퍼 시간 계산 / Calculate transfer buffer time
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 도보 환승: 5분 + (거리 * 12분/km)
  /// - 버스 환승: 3분 (고정)
  /// - 지하철 환승: 5분 (고정)
  ///
  /// @param transferType 환승 유형 (도보/버스/지하철)
  /// @param distanceKm 환승 거리 (km), 도보 환승에만 적용
  /// @returns 환승 버퍼 시간 (분)
  ///
  /// @example
  /// // 도보 환승 (0.5km)
  /// final buffer = TransferBuffer.calculateBuffer(
  ///   transferType: TransitType.walk,
  ///   distanceKm: 0.5,
  /// ); // 결과: 5 + (0.5 * 12) = 11분
  ///
  /// // 버스 환승
  /// final buffer = TransferBuffer.calculateBuffer(
  ///   transferType: TransitType.bus,
  /// ); // 결과: 3분
  static int calculateBuffer({
    required TransitType transferType,
    double distanceKm = 0.0,
  }) {
    switch (transferType) {
      case TransitType.walk:
        // 도보 환승: 기본 5분 + 거리 기반 추가 시간
        final distanceTime = (distanceKm * minutesPerKm).ceil();
        return walkTransferMinutes + distanceTime;

      case TransitType.bus:
        // 버스 환승: 고정 3분 (버스 대기 시간 포함)
        return busTransferMinutes;

      case TransitType.subway:
        // 지하철 환승: 고정 5분 (플랫폼 이동 시간)
        return subwayTransferMinutes;
    }
  }

  /// TransitResult에 환승 버퍼 시간을 추가하여 총 소요 시간 계산 /
  /// Calculate total duration including transfer buffers
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 각 환승 구간마다 버퍼 시간 자동 추가
  /// - 최종 소요 시간 = API 응답 시간 + 모든 환승 버퍼 시간
  ///
  /// @param transitResult 대중교통 경로 결과
  /// @returns 환승 버퍼 시간이 포함된 총 소요 시간 (분)
  ///
  /// @example
  /// final result = await TransitService().calculateTransitRoute(...);
  /// final totalDuration = TransferBuffer.calculateTotalDuration(result);
  static int calculateTotalDuration(TransitResult transitResult) {
    int totalBuffer = 0;

    // 모든 환승 구간의 버퍼 시간 합산
    for (final subPath in transitResult.subPaths) {
      // 도보 또는 환승으로 간주되는 구간에만 버퍼 추가
      if (_isTransferSegment(subPath)) {
        final buffer = calculateBuffer(
          transferType: subPath.trafficType,
          distanceKm: subPath.distanceKm,
        );
        totalBuffer += buffer;
      }
    }

    // API 응답 시간 + 환승 버퍼 시간
    return transitResult.durationMinutes + totalBuffer;
  }

  /// 환승 구간 여부 판단 / Check if segment is a transfer
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 도보 구간: 환승으로 간주
  /// - 버스/지하철 구간 사이의 도보: 환승으로 간주
  ///
  /// @param subPath 세부 경로 구간
  /// @returns 환승 구간 여부
  static bool _isTransferSegment(SubPath subPath) {
    // 도보 구간은 환승으로 간주
    if (subPath.trafficType == TransitType.walk) {
      return true;
    }

    // 추가 조건: 짧은 버스/지하철 구간은 환승 대기 시간으로 간주
    // (예: 1정류장만 이동하는 경우)
    if (subPath.stationCount == 1) {
      return true;
    }

    return false;
  }

  /// 환승 정보 요약 생성 / Generate transfer summary
  ///
  /// **Context**: UI에서 환승 정보 표시용
  ///
  /// @param transitResult 대중교통 경로 결과
  /// @returns 환승 정보 텍스트
  ///
  /// @example
  /// "총 2회 환승 (도보 1회, 버스 1회)"
  static String getTransferSummary(TransitResult transitResult) {
    int walkCount = 0;
    int busCount = 0;
    int subwayCount = 0;

    for (final subPath in transitResult.subPaths) {
      if (_isTransferSegment(subPath)) {
        switch (subPath.trafficType) {
          case TransitType.walk:
            walkCount++;
            break;
          case TransitType.bus:
            busCount++;
            break;
          case TransitType.subway:
            subwayCount++;
            break;
        }
      }
    }

    final totalTransfers = walkCount + busCount + subwayCount;

    if (totalTransfers == 0) {
      return '환승 없음 (직행)';
    }

    final parts = <String>[];
    if (walkCount > 0) parts.add('도보 ${walkCount}회');
    if (busCount > 0) parts.add('버스 ${busCount}회');
    if (subwayCount > 0) parts.add('지하철 ${subwayCount}회');

    return '총 ${totalTransfers}회 환승 (${parts.join(', ')})';
  }

  /// 환승역 거리 기반 조정 로직 / Distance-based transfer time adjustment
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 100m 이내: 최소 버퍼 시간만 적용
  /// - 100m ~ 500m: 거리 비례 증가
  /// - 500m 이상: 거리 비례 + 추가 버퍼 (계단, 신호등 등)
  ///
  /// @param distanceKm 환승 거리 (km)
  /// @returns 조정된 버퍼 시간 (분)
  static int calculateWalkTransferWithAdjustment(double distanceKm) {
    if (distanceKm < 0.1) {
      // 100m 이내: 최소 시간 (3분)
      return 3;
    } else if (distanceKm < 0.5) {
      // 100m ~ 500m: 기본 로직
      return calculateBuffer(
        transferType: TransitType.walk,
        distanceKm: distanceKm,
      );
    } else {
      // 500m 이상: 거리 비례 + 추가 버퍼 (계단, 신호등 등)
      final baseTime = (distanceKm * minutesPerKm).ceil();
      final additionalBuffer = 3; // 계단, 신호등 등 추가 시간
      return walkTransferMinutes + baseTime + additionalBuffer;
    }
  }
}
