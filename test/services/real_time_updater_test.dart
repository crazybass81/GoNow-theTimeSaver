import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/services/real_time_updater.dart';
import 'package:go_now/services/polling_service.dart';

void main() {
  late RealTimeUpdater updater;

  setUp(() {
    updater = RealTimeUpdater();
    updater.initialize();
    // RealTimeUpdater depends on PollingService
    PollingService().initialize();
  });

  tearDown(() {
    updater.dispose();
  });

  group('RealTimeUpdater Initialization', () {
    test('should initialize service successfully', () {
      final service = RealTimeUpdater();
      service.initialize();
      expect(service.isInitialized, true);
    });

    test('should not throw error when initializing multiple times', () {
      final service = RealTimeUpdater();
      service.initialize();
      expect(() => service.initialize(), returnsNormally);
    });

    test('should return same instance (Singleton pattern)', () {
      final service1 = RealTimeUpdater();
      final service2 = RealTimeUpdater();
      expect(identical(service1, service2), true);
    });
  });

  group('calculateChangeRate', () {
    test('should calculate change rate correctly', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 100,
          newValue: 110,
        ),
        0.1, // 10% 변화
      );

      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 50,
          newValue: 55,
        ),
        0.1, // 10% 변화
      );

      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 100,
          newValue: 95,
        ),
        0.05, // 5% 변화
      );
    });

    test('should handle zero previous value', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 0,
          newValue: 50,
        ),
        1.0, // 100% 변화로 간주
      );
    });

    test('should handle no change', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 100,
          newValue: 100,
        ),
        0.0, // 변화 없음
      );
    });

    test('should handle decrease correctly', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 100,
          newValue: 90,
        ),
        0.1, // 10% 감소 = 10% 변화
      );
    });

    test('should use absolute value for change', () {
      final increaseRate = RealTimeUpdater.calculateChangeRate(
        previousValue: 100,
        newValue: 110,
      );

      final decreaseRate = RealTimeUpdater.calculateChangeRate(
        previousValue: 100,
        newValue: 90,
      );

      expect(increaseRate, decreaseRate); // 둘 다 10% 변화
    });
  });

  group('shouldUpdate', () {
    test('should return true for change >= 5%', () {
      // 정확히 5%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 105,
        ),
        true,
      );

      // 10%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 110,
        ),
        true,
      );

      // 20%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 50,
          newValue: 60,
        ),
        true,
      );
    });

    test('should return false for change < 5%', () {
      // 4%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 104,
        ),
        false,
      );

      // 2%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 50,
          newValue: 51,
        ),
        false,
      );

      // 1%
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 101,
        ),
        false,
      );
    });

    test('should handle boundary at 5%', () {
      // 정확히 5%: true
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 105,
        ),
        true,
      );

      // 4.9%: false
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 104,
        ),
        false,
      );
    });

    test('should return true for zero previous value', () {
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 0,
          newValue: 50,
        ),
        true, // 100% 변화
      );
    });

    test('should handle decrease correctly', () {
      // 10% 감소
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 90,
        ),
        true,
      );

      // 3% 감소
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 97,
        ),
        false,
      );
    });
  });

  group('isUpdating', () {
    test('should return false initially', () {
      expect(updater.isUpdating, false);
    });

    test('should return false after stopUpdating', () {
      updater.stopUpdating();
      expect(updater.isUpdating, false);
    });
  });

  group('lastDepartureTime', () {
    test('should return null initially', () {
      expect(updater.lastDepartureTime, null);
    });

    test('should return null after stopUpdating', () {
      updater.stopUpdating();
      expect(updater.lastDepartureTime, null);
    });
  });

  group('lastTravelDuration', () {
    test('should return null initially', () {
      expect(updater.lastTravelDuration, null);
    });

    test('should return null after stopUpdating', () {
      updater.stopUpdating();
      expect(updater.lastTravelDuration, null);
    });
  });

  group('stopUpdating', () {
    test('should not throw error when no timer is active', () {
      expect(() => updater.stopUpdating(), returnsNormally);
    });

    test('should clear last values', () {
      updater.stopUpdating();
      expect(updater.lastDepartureTime, null);
      expect(updater.lastTravelDuration, null);
    });

    test('should set isUpdating to false', () {
      updater.stopUpdating();
      expect(updater.isUpdating, false);
    });
  });

  group('getDebugInfo', () {
    test('should return debug information', () {
      final info = updater.getDebugInfo();

      expect(info, contains('Initialized'));
      expect(info, contains('Is Updating'));
      expect(info, contains('Last Departure Time'));
      expect(info, contains('Last Travel Duration'));
      expect(info, contains('Change Threshold'));
      expect(info, contains('5%'));
    });

    test('should show correct initialization status', () {
      final info = updater.getDebugInfo();
      expect(info, contains('Initialized: true'));
    });

    test('should show correct updating status initially', () {
      final info = updater.getDebugInfo();
      expect(info, contains('Is Updating: false'));
    });
  });

  group('isInitialized getter', () {
    test('should return true after initialization', () {
      expect(updater.isInitialized, true);
    });

    test('should return false before initialization', () {
      final uninitializedUpdater = RealTimeUpdater();
      uninitializedUpdater.resetForTesting(); // Reset singleton to uninitialized state
      expect(uninitializedUpdater.isInitialized, false);
    });
  });

  group('dispose', () {
    test('should stop updating when disposed', () {
      updater.dispose();
      expect(updater.isUpdating, false);
    });

    test('should clear values when disposed', () {
      updater.dispose();
      expect(updater.lastDepartureTime, null);
      expect(updater.lastTravelDuration, null);
    });

    test('should not throw error when disposed multiple times', () {
      updater.dispose();
      expect(() => updater.dispose(), returnsNormally);
    });
  });

  group('startUpdating - Input Validation', () {
    test('should throw StateError if not initialized', () {
      final uninitializedUpdater = RealTimeUpdater();
      uninitializedUpdater.resetForTesting(); // Reset singleton to uninitialized state

      expect(
        () => uninitializedUpdater.startUpdating(
          departureTime: DateTime.now(),
          arrivalTime: DateTime.now().add(const Duration(hours: 1)),
          origin: {'lat': 37.5665, 'lng': 126.9780},
          destination: {'lat': 37.4979, 'lng': 127.0276},
          transportMode: 'car',
          preparationMinutes: 15,
          onUpdate: (departureTime, timePhase) {},
        ),
        throwsStateError,
      );
    });

    test('should not throw error with valid parameters', () {
      expect(
        () => updater.startUpdating(
          departureTime: DateTime.now().add(const Duration(hours: 1)),
          arrivalTime: DateTime.now().add(const Duration(hours: 2)),
          origin: {'lat': 37.5665, 'lng': 126.9780},
          destination: {'lat': 37.4979, 'lng': 127.0276},
          transportMode: 'car',
          preparationMinutes: 15,
          onUpdate: (departureTime, timePhase) {},
        ),
        returnsNormally,
      );
    });
  });

  group('Change Threshold Constant', () {
    test('should be 5%', () {
      expect(RealTimeUpdater.changeThreshold, 0.05);
    });

    test('should be used consistently', () {
      final threshold = RealTimeUpdater.changeThreshold;

      // 4.9% 변화 = 임계값 미만
      final shouldUpdate1 = RealTimeUpdater.shouldUpdate(
        previousValue: 100,
        newValue: 104,
      );
      expect(shouldUpdate1, false);

      // 5.0% 변화 = 임계값 이상
      final shouldUpdate2 = RealTimeUpdater.shouldUpdate(
        previousValue: 100,
        newValue: 105,
      );
      expect(shouldUpdate2, true);

      // Verify threshold value
      expect((104 - 100) / 100 < threshold, true);
      expect((105 - 100) / 100 >= threshold, true);
    });
  });

  group('Edge Cases', () {
    test('should handle very small values', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 1,
          newValue: 2,
        ),
        1.0, // 100% 변화
      );

      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 1,
          newValue: 2,
        ),
        true,
      );
    });

    test('should handle very large values', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 10000,
          newValue: 10500,
        ),
        0.05, // 5% 변화
      );

      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 10000,
          newValue: 10500,
        ),
        true,
      );
    });

    test('should handle identical values', () {
      expect(
        RealTimeUpdater.calculateChangeRate(
          previousValue: 100,
          newValue: 100,
        ),
        0.0,
      );

      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 100,
          newValue: 100,
        ),
        false,
      );
    });

    test('should handle fractional change rates', () {
      // 4.5% 변화
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 200,
          newValue: 209,
        ),
        false, // 4.5% < 5%
      );

      // 5.5% 변화
      expect(
        RealTimeUpdater.shouldUpdate(
          previousValue: 200,
          newValue: 211,
        ),
        true, // 5.5% >= 5%
      );
    });
  });
}
