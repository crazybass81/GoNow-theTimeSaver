import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/services/polling_service.dart';

void main() {
  late PollingService pollingService;

  setUp(() {
    pollingService = PollingService();
    pollingService.initialize();
  });

  group('PollingService Initialization', () {
    test('should initialize service successfully', () {
      final service = PollingService();
      service.initialize();
      expect(service.isInitialized, true);
    });

    test('should not throw error when initializing multiple times', () {
      final service = PollingService();
      service.initialize();
      expect(() => service.initialize(), returnsNormally);
    });

    test('should return same instance (Singleton pattern)', () {
      final service1 = PollingService();
      final service2 = PollingService();
      expect(identical(service1, service2), true);
    });
  });

  group('getPollingInterval - Core Logic', () {
    test('should return 15 minutes for time >= 1 hour', () {
      final interval = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(hours: 1),
      );

      expect(interval, const Duration(minutes: 15));
    });

    test('should return 15 minutes for time > 1 hour', () {
      final interval = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(hours: 2),
      );

      expect(interval, const Duration(minutes: 15));
    });

    test('should return 5 minutes for time between 10 and 60 minutes', () {
      final interval1 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 30),
      );
      expect(interval1, const Duration(minutes: 5));

      final interval2 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 59),
      );
      expect(interval2, const Duration(minutes: 5));

      final interval3 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 10),
      );
      expect(interval3, const Duration(minutes: 5));
    });

    test('should return 3 minutes for time < 10 minutes', () {
      final interval1 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 9),
      );
      expect(interval1, const Duration(minutes: 3));

      final interval2 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 5),
      );
      expect(interval2, const Duration(minutes: 3));

      final interval3 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 1),
      );
      expect(interval3, const Duration(minutes: 3));
    });

    test('should return 3 minutes for negative time (late)', () {
      final interval = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: -10),
      );

      expect(interval, const Duration(minutes: 3));
    });

    test('should handle zero time', () {
      final interval = pollingService.getPollingInterval(
        timeUntilDeparture: Duration.zero,
      );

      expect(interval, const Duration(minutes: 3));
    });

    test('should handle boundary at 1 hour', () {
      // 정확히 1시간: 15분 간격
      final interval1 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(hours: 1),
      );
      expect(interval1, const Duration(minutes: 15));

      // 1시간 - 1초: 5분 간격
      final interval2 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(hours: 1, seconds: -1),
      );
      expect(interval2, const Duration(minutes: 5));
    });

    test('should handle boundary at 10 minutes', () {
      // 정확히 10분: 5분 간격
      final interval1 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 10),
      );
      expect(interval1, const Duration(minutes: 5));

      // 10분 - 1초: 3분 간격
      final interval2 = pollingService.getPollingInterval(
        timeUntilDeparture: const Duration(minutes: 9, seconds: 59),
      );
      expect(interval2, const Duration(minutes: 3));
    });
  });

  group('getPollingInterval - Input Validation', () {
    test('should throw StateError if not initialized', () {
      final uninitializedService = PollingService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedService.getPollingInterval(
          timeUntilDeparture: const Duration(minutes: 30),
        ),
        throwsStateError,
      );
    });
  });

  group('getNextPollingTime', () {
    test('should calculate next polling time correctly for long interval', () {
      final currentTime = DateTime(2025, 1, 6, 12, 0);
      final departureTime = DateTime(2025, 1, 6, 14, 0); // 2시간 후

      final nextTime = pollingService.getNextPollingTime(
        currentTime: currentTime,
        departureTime: departureTime,
      );

      // 2시간 전 → 15분 간격
      expect(nextTime, DateTime(2025, 1, 6, 12, 15));
    });

    test('should calculate next polling time correctly for medium interval', () {
      final currentTime = DateTime(2025, 1, 6, 13, 30);
      final departureTime = DateTime(2025, 1, 6, 14, 0); // 30분 후

      final nextTime = pollingService.getNextPollingTime(
        currentTime: currentTime,
        departureTime: departureTime,
      );

      // 30분 전 → 5분 간격
      expect(nextTime, DateTime(2025, 1, 6, 13, 35));
    });

    test('should calculate next polling time correctly for short interval', () {
      final currentTime = DateTime(2025, 1, 6, 13, 55);
      final departureTime = DateTime(2025, 1, 6, 14, 0); // 5분 후

      final nextTime = pollingService.getNextPollingTime(
        currentTime: currentTime,
        departureTime: departureTime,
      );

      // 5분 전 → 3분 간격
      expect(nextTime, DateTime(2025, 1, 6, 13, 58));
    });

    test('should throw StateError if not initialized', () {
      final uninitializedService = PollingService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedService.getNextPollingTime(
          currentTime: DateTime.now(),
          departureTime: DateTime.now(),
        ),
        throwsStateError,
      );
    });
  });

  group('getPollingIntervalInSeconds', () {
    test('should return correct seconds for long interval', () {
      final seconds = pollingService.getPollingIntervalInSeconds(
        timeUntilDeparture: const Duration(hours: 2),
      );

      expect(seconds, 900); // 15분 = 900초
    });

    test('should return correct seconds for medium interval', () {
      final seconds = pollingService.getPollingIntervalInSeconds(
        timeUntilDeparture: const Duration(minutes: 30),
      );

      expect(seconds, 300); // 5분 = 300초
    });

    test('should return correct seconds for short interval', () {
      final seconds = pollingService.getPollingIntervalInSeconds(
        timeUntilDeparture: const Duration(minutes: 5),
      );

      expect(seconds, 180); // 3분 = 180초
    });
  });

  group('getPollingIntervalInMilliseconds', () {
    test('should return correct milliseconds for long interval', () {
      final ms = pollingService.getPollingIntervalInMilliseconds(
        timeUntilDeparture: const Duration(hours: 2),
      );

      expect(ms, 900000); // 15분 = 900,000 밀리초
    });

    test('should return correct milliseconds for medium interval', () {
      final ms = pollingService.getPollingIntervalInMilliseconds(
        timeUntilDeparture: const Duration(minutes: 30),
      );

      expect(ms, 300000); // 5분 = 300,000 밀리초
    });

    test('should return correct milliseconds for short interval', () {
      final ms = pollingService.getPollingIntervalInMilliseconds(
        timeUntilDeparture: const Duration(minutes: 5),
      );

      expect(ms, 180000); // 3분 = 180,000 밀리초
    });
  });

  group('getTimePhase', () {
    test('should return "late" for negative time', () {
      final phase = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: -10),
      );

      expect(phase, 'late');
    });

    test('should return "critical" for time < 10 minutes', () {
      final phase1 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 9),
      );
      expect(phase1, 'critical');

      final phase2 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 5),
      );
      expect(phase2, 'critical');

      final phase3 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 1),
      );
      expect(phase3, 'critical');
    });

    test('should return "warning" for time between 10 and 30 minutes', () {
      final phase1 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 10),
      );
      expect(phase1, 'warning');

      final phase2 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 20),
      );
      expect(phase2, 'warning');

      final phase3 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 29),
      );
      expect(phase3, 'warning');
    });

    test('should return "normal" for time >= 30 minutes', () {
      final phase1 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 30),
      );
      expect(phase1, 'normal');

      final phase2 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(hours: 1),
      );
      expect(phase2, 'normal');

      final phase3 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(hours: 2),
      );
      expect(phase3, 'normal');
    });

    test('should handle boundary at 10 minutes', () {
      // 정확히 10분: warning
      final phase1 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 10),
      );
      expect(phase1, 'warning');

      // 10분 - 1초: critical
      final phase2 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 9, seconds: 59),
      );
      expect(phase2, 'critical');
    });

    test('should handle boundary at 30 minutes', () {
      // 정확히 30분: normal
      final phase1 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 30),
      );
      expect(phase1, 'normal');

      // 30분 - 1초: warning
      final phase2 = pollingService.getTimePhase(
        timeUntilDeparture: const Duration(minutes: 29, seconds: 59),
      );
      expect(phase2, 'warning');
    });

    test('should throw StateError if not initialized', () {
      final uninitializedService = PollingService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedService.getTimePhase(
          timeUntilDeparture: const Duration(minutes: 30),
        ),
        throwsStateError,
      );
    });
  });

  group('getTimePhaseColor', () {
    test('should return dark red for late phase', () {
      final color = pollingService.getTimePhaseColor(
        timeUntilDeparture: const Duration(minutes: -10),
      );

      expect(color, 0xFFB71C1C); // Material Red 900
    });

    test('should return red for critical phase', () {
      final color = pollingService.getTimePhaseColor(
        timeUntilDeparture: const Duration(minutes: 5),
      );

      expect(color, 0xFFF44336); // Material Red 500
    });

    test('should return orange for warning phase', () {
      final color = pollingService.getTimePhaseColor(
        timeUntilDeparture: const Duration(minutes: 15),
      );

      expect(color, 0xFFFF9800); // Material Orange 500
    });

    test('should return green for normal phase', () {
      final color = pollingService.getTimePhaseColor(
        timeUntilDeparture: const Duration(hours: 1),
      );

      expect(color, 0xFF4CAF50); // Material Green 500
    });
  });

  group('shouldChangePollingInterval', () {
    test('should return true when phase changes from normal to warning', () {
      final shouldChange = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(minutes: 31),
        currentTimeUntilDeparture: const Duration(minutes: 29),
      );

      expect(shouldChange, true);
    });

    test('should return true when phase changes from warning to critical', () {
      final shouldChange = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(minutes: 11),
        currentTimeUntilDeparture: const Duration(minutes: 9),
      );

      expect(shouldChange, true);
    });

    test('should return true when phase changes from critical to late', () {
      final shouldChange = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(minutes: 1),
        currentTimeUntilDeparture: const Duration(minutes: -1),
      );

      expect(shouldChange, true);
    });

    test('should return false when phase stays the same', () {
      final shouldChange1 = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(hours: 2),
        currentTimeUntilDeparture: const Duration(hours: 1),
      );
      expect(shouldChange1, false); // normal → normal

      final shouldChange2 = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(minutes: 25),
        currentTimeUntilDeparture: const Duration(minutes: 15),
      );
      expect(shouldChange2, false); // warning → warning

      final shouldChange3 = pollingService.shouldChangePollingInterval(
        previousTimeUntilDeparture: const Duration(minutes: 9),
        currentTimeUntilDeparture: const Duration(minutes: 5),
      );
      expect(shouldChange3, false); // critical → critical
    });

    test('should throw StateError if not initialized', () {
      final uninitializedService = PollingService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedService.shouldChangePollingInterval(
          previousTimeUntilDeparture: const Duration(minutes: 30),
          currentTimeUntilDeparture: const Duration(minutes: 20),
        ),
        throwsStateError,
      );
    });
  });

  group('isBatteryEfficientMode', () {
    test('should return true for time >= 1 hour', () {
      final result1 = pollingService.isBatteryEfficientMode(
        timeUntilDeparture: const Duration(hours: 1),
      );
      expect(result1, true);

      final result2 = pollingService.isBatteryEfficientMode(
        timeUntilDeparture: const Duration(hours: 2),
      );
      expect(result2, true);
    });

    test('should return false for time < 1 hour', () {
      final result1 = pollingService.isBatteryEfficientMode(
        timeUntilDeparture: const Duration(minutes: 59),
      );
      expect(result1, false);

      final result2 = pollingService.isBatteryEfficientMode(
        timeUntilDeparture: const Duration(minutes: 30),
      );
      expect(result2, false);

      final result3 = pollingService.isBatteryEfficientMode(
        timeUntilDeparture: const Duration(minutes: 5),
      );
      expect(result3, false);
    });
  });

  group('isRealTimeMode', () {
    test('should return true for time < 10 minutes', () {
      final result1 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(minutes: 9),
      );
      expect(result1, true);

      final result2 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(minutes: 5),
      );
      expect(result2, true);

      final result3 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(minutes: 1),
      );
      expect(result3, true);
    });

    test('should return false for time >= 10 minutes', () {
      final result1 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(minutes: 10),
      );
      expect(result1, false);

      final result2 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(minutes: 30),
      );
      expect(result2, false);

      final result3 = pollingService.isRealTimeMode(
        timeUntilDeparture: const Duration(hours: 1),
      );
      expect(result3, false);
    });
  });

  group('getPollingStats', () {
    test('should return complete stats for normal phase', () {
      final stats = pollingService.getPollingStats(
        timeUntilDeparture: const Duration(hours: 2),
      );

      expect(stats['timeUntilDeparture'], 120);
      expect(stats['pollingInterval'], 15);
      expect(stats['timePhase'], 'normal');
      expect(stats['colorCode'], 0xFF4CAF50);
      expect(stats['batteryEfficientMode'], true);
      expect(stats['realTimeMode'], false);
    });

    test('should return complete stats for warning phase', () {
      final stats = pollingService.getPollingStats(
        timeUntilDeparture: const Duration(minutes: 20),
      );

      expect(stats['timeUntilDeparture'], 20);
      expect(stats['pollingInterval'], 5);
      expect(stats['timePhase'], 'warning');
      expect(stats['colorCode'], 0xFFFF9800);
      expect(stats['batteryEfficientMode'], false);
      expect(stats['realTimeMode'], false);
    });

    test('should return complete stats for critical phase', () {
      final stats = pollingService.getPollingStats(
        timeUntilDeparture: const Duration(minutes: 5),
      );

      expect(stats['timeUntilDeparture'], 5);
      expect(stats['pollingInterval'], 3);
      expect(stats['timePhase'], 'critical');
      expect(stats['colorCode'], 0xFFF44336);
      expect(stats['batteryEfficientMode'], false);
      expect(stats['realTimeMode'], true);
    });

    test('should return complete stats for late phase', () {
      final stats = pollingService.getPollingStats(
        timeUntilDeparture: const Duration(minutes: -10),
      );

      expect(stats['timeUntilDeparture'], -10);
      expect(stats['pollingInterval'], 3);
      expect(stats['timePhase'], 'late');
      expect(stats['colorCode'], 0xFFB71C1C);
      expect(stats['batteryEfficientMode'], false);
      expect(stats['realTimeMode'], false);
    });
  });

  group('isInitialized getter', () {
    test('should return true after initialization', () {
      expect(pollingService.isInitialized, true);
    });

    test('should return false before initialization', () {
      final uninitializedService = PollingService();
      uninitializedService.resetForTesting(); // Reset singleton to uninitialized state
      expect(uninitializedService.isInitialized, false);
    });
  });
}
