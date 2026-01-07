import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/services/scheduler_service.dart';

void main() {
  late SchedulerService schedulerService;

  setUp(() {
    schedulerService = SchedulerService();
    schedulerService.initialize();
  });

  group('SchedulerService Initialization', () {
    test('should initialize service successfully', () {
      final service = SchedulerService();
      service.initialize();
      expect(service.isInitialized, true);
    });

    test('should not throw error when initializing multiple times', () {
      final service = SchedulerService();
      service.initialize();
      expect(() => service.initialize(), returnsNormally);
    });

    test('should return same instance (Singleton pattern)', () {
      final service1 = SchedulerService();
      final service2 = SchedulerService();
      expect(identical(service1, service2), true);
    });
  });

  group('calculateDepartureTime - Core Algorithm', () {
    test('should calculate departure time correctly with default buffers', () {
      // 도착 시간: 2025-01-06 14:00 (오후 2시)
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 30; // 이동 시간 30분
      final preparationMinutes = 15; // 외출 준비 15분

      // 예상 계산:
      // - 일정 마무리: 5분 (기본값)
      // - 일찍 도착: 10분 (기본값)
      // - 이동 시간: 30분 + 6분(20% 오차율) = 36분
      // - 외출 준비: 15분
      // 총: 5 + 10 + 36 + 15 = 66분
      // 출발 시간: 14:00 - 66분 = 12:54

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
      );

      expect(departureTime, DateTime(2025, 1, 6, 12, 54));
    });

    test('should calculate departure time with custom buffers', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 45;
      final preparationMinutes = 20;
      final previousTaskWrapUpMinutes = 10;
      final earlyArrivalBufferMinutes = 15;
      final travelUncertaintyRate = 0.3; // 30%

      // 예상 계산:
      // - 일정 마무리: 10분
      // - 일찍 도착: 15분
      // - 이동 시간: 45분 + 14분(30% 오차율, ceil) = 59분
      // - 외출 준비: 20분
      // 총: 10 + 15 + 59 + 20 = 104분
      // 출발 시간: 14:00 - 104분 = 12:16

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
      );

      expect(departureTime, DateTime(2025, 1, 6, 12, 16));
    });

    test('should handle zero travel time', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 0;
      final preparationMinutes = 15;

      // 예상 계산:
      // - 일정 마무리: 5분
      // - 일찍 도착: 10분
      // - 이동 시간: 0분 + 0분(오차율) = 0분
      // - 외출 준비: 15분
      // 총: 5 + 10 + 0 + 15 = 30분

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
      );

      expect(departureTime, DateTime(2025, 1, 6, 13, 30));
    });

    test('should handle zero uncertainty rate', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 30;
      final preparationMinutes = 15;
      final travelUncertaintyRate = 0.0;

      // 예상 계산:
      // - 일정 마무리: 5분
      // - 일찍 도착: 10분
      // - 이동 시간: 30분 + 0분(0% 오차율) = 30분
      // - 외출 준비: 15분
      // 총: 5 + 10 + 30 + 15 = 60분

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
      );

      expect(departureTime, DateTime(2025, 1, 6, 13, 0));
    });

    test('should handle zero early arrival buffer', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 30;
      final preparationMinutes = 15;
      final earlyArrivalBufferMinutes = 0;

      // 예상 계산:
      // - 일정 마무리: 5분
      // - 일찍 도착: 0분
      // - 이동 시간: 30분 + 6분(20% 오차율) = 36분
      // - 외출 준비: 15분
      // 총: 5 + 0 + 36 + 15 = 56분

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
      );

      expect(departureTime, DateTime(2025, 1, 6, 13, 4));
    });

    test('should handle zero previous task wrap-up', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 30;
      final preparationMinutes = 15;
      final previousTaskWrapUpMinutes = 0;

      // 예상 계산:
      // - 일정 마무리: 0분
      // - 일찍 도착: 10분
      // - 이동 시간: 30분 + 6분(20% 오차율) = 36분
      // - 외출 준비: 15분
      // 총: 0 + 10 + 36 + 15 = 61분

      final departureTime = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapUpMinutes,
      );

      expect(departureTime, DateTime(2025, 1, 6, 12, 59));
    });

    test('should ceil uncertainty minutes (fractional rounding)', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);
      final travelDurationMinutes = 10; // 10분 * 20% = 2분 정확히
      final preparationMinutes = 15;

      final departureTime1 = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
      );

      // 10분 * 20% = 2.0분 → ceil = 2분
      // 총: 5 + 10 + 12 + 15 = 42분
      expect(departureTime1, DateTime(2025, 1, 6, 13, 18));

      // 11분 * 20% = 2.2분 → ceil = 3분
      final departureTime2 = schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: 11,
        preparationMinutes: preparationMinutes,
      );

      // 총: 5 + 10 + 14 + 15 = 44분
      expect(departureTime2, DateTime(2025, 1, 6, 13, 16));
    });
  });

  group('calculateDepartureTime - Input Validation', () {
    test('should throw StateError if not initialized', () {
      final uninitializedService = SchedulerService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
        ),
        throwsStateError,
      );
    });

    test('should throw ArgumentError for negative travel duration', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: -10,
          preparationMinutes: 15,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for preparation time < 5 minutes', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 4,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for preparation time > 60 minutes', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 61,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for negative previous task wrap-up', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          previousTaskWrapUpMinutes: -1,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for previous task wrap-up > 20 minutes', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          previousTaskWrapUpMinutes: 21,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for negative early arrival buffer', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          earlyArrivalBufferMinutes: -1,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for early arrival buffer > 30 minutes', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          earlyArrivalBufferMinutes: 31,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for negative uncertainty rate', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          travelUncertaintyRate: -0.1,
        ),
        throwsArgumentError,
      );
    });

    test('should throw ArgumentError for uncertainty rate > 0.5', () {
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: DateTime.now(),
          travelDurationMinutes: 30,
          preparationMinutes: 15,
          travelUncertaintyRate: 0.51,
        ),
        throwsArgumentError,
      );
    });

    test('should accept boundary values', () {
      final arrivalTime = DateTime(2025, 1, 6, 14, 0);

      // 모든 boundary 값 테스트
      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: arrivalTime,
          travelDurationMinutes: 0, // min
          preparationMinutes: 5, // min
          previousTaskWrapUpMinutes: 0, // min
          earlyArrivalBufferMinutes: 0, // min
          travelUncertaintyRate: 0.0, // min
        ),
        returnsNormally,
      );

      expect(
        () => schedulerService.calculateDepartureTime(
          arrivalTime: arrivalTime,
          travelDurationMinutes: 999, // max (no upper limit specified)
          preparationMinutes: 60, // max
          previousTaskWrapUpMinutes: 20, // max
          earlyArrivalBufferMinutes: 30, // max
          travelUncertaintyRate: 0.5, // max
        ),
        returnsNormally,
      );
    });
  });

  group('validateBufferSettings', () {
    test('should return null for valid settings', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.2,
      );

      expect(result, null);
    });

    test('should return error for preparation time < 5 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 4,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('외출 준비 시간'));
    });

    test('should return error for preparation time > 60 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 61,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('외출 준비 시간'));
    });

    test('should return error for previous task wrap-up < 0 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: -1,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('일정 마무리 시간'));
    });

    test('should return error for previous task wrap-up > 20 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 21,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('일정 마무리 시간'));
    });

    test('should return error for early arrival buffer < 0 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: -1,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('일찍 도착 버퍼'));
    });

    test('should return error for early arrival buffer > 30 minutes', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 31,
        travelUncertaintyRate: 0.2,
      );

      expect(result, isNotNull);
      expect(result, contains('일찍 도착 버퍼'));
    });

    test('should return error for uncertainty rate < 0%', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: -0.1,
      );

      expect(result, isNotNull);
      expect(result, contains('이동 오차율'));
    });

    test('should return error for uncertainty rate > 50%', () {
      final result = schedulerService.validateBufferSettings(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelUncertaintyRate: 0.51,
      );

      expect(result, isNotNull);
      expect(result, contains('이동 오차율'));
    });

    test('should accept boundary values', () {
      // Min values
      final result1 = schedulerService.validateBufferSettings(
        preparationMinutes: 5,
        previousTaskWrapUpMinutes: 0,
        earlyArrivalBufferMinutes: 0,
        travelUncertaintyRate: 0.0,
      );
      expect(result1, null);

      // Max values
      final result2 = schedulerService.validateBufferSettings(
        preparationMinutes: 60,
        previousTaskWrapUpMinutes: 20,
        earlyArrivalBufferMinutes: 30,
        travelUncertaintyRate: 0.5,
      );
      expect(result2, null);
    });
  });

  group('isDepartureTimeInPast', () {
    test('should return true if departure time is in the past', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 10));
      expect(schedulerService.isDepartureTimeInPast(pastTime), true);
    });

    test('should return false if departure time is in the future', () {
      final futureTime = DateTime.now().add(const Duration(minutes: 10));
      expect(schedulerService.isDepartureTimeInPast(futureTime), false);
    });

    test('should return false if departure time is now (edge case)', () {
      final now = DateTime.now();
      // This might be flaky depending on execution speed, but should pass in most cases
      expect(schedulerService.isDepartureTimeInPast(now), false);
    });
  });

  group('getTimeUntilDeparture', () {
    test('should return positive duration for future departure time', () {
      final futureTime = DateTime.now().add(const Duration(minutes: 30));
      final duration = schedulerService.getTimeUntilDeparture(futureTime);

      expect(duration.isNegative, false);
      expect(duration.inMinutes, greaterThanOrEqualTo(29)); // Allow 1 minute tolerance
      expect(duration.inMinutes, lessThanOrEqualTo(30));
    });

    test('should return negative duration for past departure time', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 15));
      final duration = schedulerService.getTimeUntilDeparture(pastTime);

      expect(duration.isNegative, true);
      expect(duration.inMinutes, lessThanOrEqualTo(-14)); // Allow 1 minute tolerance
    });

    test('should return approximately zero duration for current time', () {
      final now = DateTime.now();
      final duration = schedulerService.getTimeUntilDeparture(now);

      expect(duration.inSeconds.abs(), lessThan(2)); // Within 2 seconds
    });
  });

  group('calculateUncertaintyMinutes', () {
    test('should calculate uncertainty minutes correctly', () {
      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 30,
          uncertaintyRate: 0.2,
        ),
        6, // 30 * 0.2 = 6.0 → ceil = 6
      );
    });

    test('should ceil fractional minutes', () {
      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 25,
          uncertaintyRate: 0.2,
        ),
        5, // 25 * 0.2 = 5.0 → ceil = 5
      );

      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 27,
          uncertaintyRate: 0.2,
        ),
        6, // 27 * 0.2 = 5.4 → ceil = 6
      );
    });

    test('should return 0 for zero travel duration', () {
      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 0,
          uncertaintyRate: 0.2,
        ),
        0,
      );
    });

    test('should return 0 for zero uncertainty rate', () {
      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 30,
          uncertaintyRate: 0.0,
        ),
        0,
      );
    });

    test('should handle 50% uncertainty rate', () {
      expect(
        schedulerService.calculateUncertaintyMinutes(
          travelDurationMinutes: 30,
          uncertaintyRate: 0.5,
        ),
        15, // 30 * 0.5 = 15.0 → ceil = 15
      );
    });
  });

  group('getTotalBufferMinutes', () {
    test('should calculate total buffer minutes correctly', () {
      final totalBuffer = schedulerService.getTotalBufferMinutes(
        preparationMinutes: 15,
        previousTaskWrapUpMinutes: 5,
        earlyArrivalBufferMinutes: 10,
        travelDurationMinutes: 30,
        travelUncertaintyRate: 0.2,
      );

      // 5 + 10 + 6 + 15 = 36분
      expect(totalBuffer, 36);
    });

    test('should include uncertainty minutes in total', () {
      final totalBuffer = schedulerService.getTotalBufferMinutes(
        preparationMinutes: 20,
        previousTaskWrapUpMinutes: 10,
        earlyArrivalBufferMinutes: 15,
        travelDurationMinutes: 45,
        travelUncertaintyRate: 0.3,
      );

      // 10 + 15 + 14(45*0.3=13.5→14) + 20 = 59분
      expect(totalBuffer, 59);
    });

    test('should handle zero buffers', () {
      final totalBuffer = schedulerService.getTotalBufferMinutes(
        preparationMinutes: 5,
        previousTaskWrapUpMinutes: 0,
        earlyArrivalBufferMinutes: 0,
        travelDurationMinutes: 0,
        travelUncertaintyRate: 0.0,
      );

      // 0 + 0 + 0 + 5 = 5분
      expect(totalBuffer, 5);
    });

    test('should handle maximum buffers', () {
      final totalBuffer = schedulerService.getTotalBufferMinutes(
        preparationMinutes: 60,
        previousTaskWrapUpMinutes: 20,
        earlyArrivalBufferMinutes: 30,
        travelDurationMinutes: 60,
        travelUncertaintyRate: 0.5,
      );

      // 20 + 30 + 30(60*0.5) + 60 = 140분
      expect(totalBuffer, 140);
    });
  });

  group('isInitialized getter', () {
    test('should return true after initialization', () {
      expect(schedulerService.isInitialized, true);
    });

    test('should return false before initialization', () {
      final uninitializedService = SchedulerService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state
      expect(uninitializedService.isInitialized, false);
    });
  });
}
