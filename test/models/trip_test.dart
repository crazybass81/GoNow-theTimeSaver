import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/models/trip.dart';

/// Trip 모델 단위 테스트 / Trip Model Unit Tests
///
/// **테스트 범위 / Test Coverage**:
/// - Trip 생성 및 초기화 / Trip creation and initialization
/// - JSON 직렬화/역직렬화 / JSON serialization/deserialization
/// - copyWith 불변성 / copyWith immutability
/// - 비즈니스 로직 메서드 / Business logic methods
///
/// **Context**: Phase 4 - Unit Test Extension
void main() {
  group('Trip Model - Creation and Initialization', () {
    test('should create Trip with required fields', () {
      final arrivalTime = DateTime(2025, 1, 7, 14, 0);
      final departureTime = DateTime(2025, 1, 7, 13, 0);

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip.userId, 'user_123');
      expect(trip.title, '회의');
      expect(trip.destinationAddress, '서울시청');
      expect(trip.destinationLat, 37.5665);
      expect(trip.destinationLng, 126.9780);
      expect(trip.arrivalTime, arrivalTime);
      expect(trip.departureTime, departureTime);
      expect(trip.transportMode, 'car');
      expect(trip.travelDurationMinutes, 30);
    });

    test('should create Trip with default buffer values', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      // 4가지 버퍼 기본값 확인 / Check 4 buffer defaults
      expect(trip.preparationMinutes, 15);
      expect(trip.earlyArrivalBufferMinutes, 10);
      expect(trip.travelUncertaintyRate, 0.2);
      expect(trip.previousTaskWrapupMinutes, 5);
    });

    test('should create Trip with custom buffer values', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
        preparationMinutes: 20,
        earlyArrivalBufferMinutes: 15,
        travelUncertaintyRate: 0.3,
        previousTaskWrapupMinutes: 10,
      );

      expect(trip.preparationMinutes, 20);
      expect(trip.earlyArrivalBufferMinutes, 15);
      expect(trip.travelUncertaintyRate, 0.3);
      expect(trip.previousTaskWrapupMinutes, 10);
    });

    test('should create Trip with default status flags', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip.isCompleted, false);
      expect(trip.completedAt, isNull);
      expect(trip.isCancelled, false);
      expect(trip.notificationEnabled, true);
      expect(trip.notificationSentAt, isNull);
    });

    test('should create Trip with optional route data', () {
      final routeData = {
        'distance': 15000,
        'duration': 1800000,
        'tollFare': 2000,
      };

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
        routeData: routeData,
      );

      expect(trip.routeData, isNotNull);
      expect(trip.routeData!['distance'], 15000);
      expect(trip.routeData!['duration'], 1800000);
      expect(trip.routeData!['tollFare'], 2000);
    });
  });

  group('Trip Model - JSON Serialization', () {
    test('should convert Trip to JSON correctly', () {
      final arrivalTime = DateTime(2025, 1, 7, 14, 0);
      final departureTime = DateTime(2025, 1, 7, 13, 0);

      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final json = trip.toJson();

      expect(json['id'], 'trip_123');
      expect(json['user_id'], 'user_123');
      expect(json['title'], '회의');
      expect(json['destination_address'], '서울시청');
      expect(json['destination_lat'], 37.5665);
      expect(json['destination_lng'], 126.9780);
      expect(json['arrival_time'], arrivalTime.toIso8601String());
      expect(json['departure_time'], departureTime.toIso8601String());
      expect(json['transport_mode'], 'car');
      expect(json['travel_duration_minutes'], 30);
    });

    test('should convert Trip to JSON without optional id', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final json = trip.toJson();

      expect(json.containsKey('id'), false);
    });

    test('should convert Trip to JSON with buffer values', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
        preparationMinutes: 20,
        earlyArrivalBufferMinutes: 15,
        travelUncertaintyRate: 0.3,
        previousTaskWrapupMinutes: 10,
      );

      final json = trip.toJson();

      expect(json['preparation_minutes'], 20);
      expect(json['early_arrival_buffer_minutes'], 15);
      expect(json['travel_uncertainty_rate'], 0.3);
      expect(json['previous_task_wrapup_minutes'], 10);
    });

    test('should create Trip from JSON correctly', () {
      final arrivalTime = DateTime(2025, 1, 7, 14, 0);
      final departureTime = DateTime(2025, 1, 7, 13, 0);

      final json = {
        'id': 'trip_123',
        'user_id': 'user_123',
        'title': '회의',
        'destination_address': '서울시청',
        'destination_lat': 37.5665,
        'destination_lng': 126.9780,
        'arrival_time': arrivalTime.toIso8601String(),
        'departure_time': departureTime.toIso8601String(),
        'transport_mode': 'car',
        'travel_duration_minutes': 30,
        'preparation_minutes': 15,
        'early_arrival_buffer_minutes': 10,
        'travel_uncertainty_rate': 0.2,
        'previous_task_wrapup_minutes': 5,
        'is_completed': false,
        'is_cancelled': false,
        'notification_enabled': true,
      };

      final trip = Trip.fromJson(json);

      expect(trip.id, 'trip_123');
      expect(trip.userId, 'user_123');
      expect(trip.title, '회의');
      expect(trip.destinationAddress, '서울시청');
      expect(trip.destinationLat, 37.5665);
      expect(trip.destinationLng, 126.9780);
      expect(trip.arrivalTime, arrivalTime);
      expect(trip.departureTime, departureTime);
      expect(trip.transportMode, 'car');
      expect(trip.travelDurationMinutes, 30);
    });

    test('should create Trip from JSON with default buffer values', () {
      final json = {
        'id': 'trip_123',
        'user_id': 'user_123',
        'title': '회의',
        'destination_address': '서울시청',
        'destination_lat': 37.5665,
        'destination_lng': 126.9780,
        'arrival_time': DateTime(2025, 1, 7, 14, 0).toIso8601String(),
        'departure_time': DateTime(2025, 1, 7, 13, 0).toIso8601String(),
        'transport_mode': 'car',
        'travel_duration_minutes': 30,
      };

      final trip = Trip.fromJson(json);

      // 누락된 필드는 기본값 사용 / Use defaults for missing fields
      expect(trip.preparationMinutes, 15);
      expect(trip.earlyArrivalBufferMinutes, 10);
      expect(trip.travelUncertaintyRate, 0.2);
      expect(trip.previousTaskWrapupMinutes, 5);
      expect(trip.isCompleted, false);
      expect(trip.isCancelled, false);
      expect(trip.notificationEnabled, true);
    });

    test('should handle completed trip JSON correctly', () {
      final completedAt = DateTime(2025, 1, 7, 14, 30);

      final json = {
        'id': 'trip_123',
        'user_id': 'user_123',
        'title': '회의',
        'destination_address': '서울시청',
        'destination_lat': 37.5665,
        'destination_lng': 126.9780,
        'arrival_time': DateTime(2025, 1, 7, 14, 0).toIso8601String(),
        'departure_time': DateTime(2025, 1, 7, 13, 0).toIso8601String(),
        'transport_mode': 'car',
        'travel_duration_minutes': 30,
        'is_completed': true,
        'completed_at': completedAt.toIso8601String(),
      };

      final trip = Trip.fromJson(json);

      expect(trip.isCompleted, true);
      expect(trip.completedAt, completedAt);
    });

    test('should handle roundtrip JSON serialization', () {
      final original = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
        preparationMinutes: 20,
      );

      final json = original.toJson();
      final reconstructed = Trip.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.preparationMinutes, original.preparationMinutes);
    });
  });

  group('Trip Model - copyWith Immutability', () {
    late Trip originalTrip;

    setUp(() {
      originalTrip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );
    });

    test('should create new Trip instance with copyWith', () {
      final updated = originalTrip.copyWith(title: '회의 변경');

      expect(updated.title, '회의 변경');
      expect(originalTrip.title, '회의'); // 원본 불변 / Original immutable
      expect(identical(originalTrip, updated), false);
    });

    test('should update multiple fields with copyWith', () {
      final updated = originalTrip.copyWith(
        title: '회의 변경',
        transportMode: 'transit',
        preparationMinutes: 25,
      );

      expect(updated.title, '회의 변경');
      expect(updated.transportMode, 'transit');
      expect(updated.preparationMinutes, 25);

      // 다른 필드는 유지 / Other fields preserved
      expect(updated.userId, originalTrip.userId);
      expect(updated.destinationAddress, originalTrip.destinationAddress);
    });

    test('should preserve original Trip when using copyWith with no changes', () {
      final updated = originalTrip.copyWith();

      expect(updated.title, originalTrip.title);
      expect(updated.userId, originalTrip.userId);
      expect(updated.transportMode, originalTrip.transportMode);
    });

    test('should update completion status with copyWith', () {
      final completed = originalTrip.copyWith(
        isCompleted: true,
        completedAt: DateTime(2025, 1, 7, 14, 30),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
      expect(originalTrip.isCompleted, false); // 원본 불변
    });

    test('should update cancellation status with copyWith', () {
      final cancelled = originalTrip.copyWith(isCancelled: true);

      expect(cancelled.isCancelled, true);
      expect(originalTrip.isCancelled, false);
    });
  });

  group('Trip Model - Business Logic Methods', () {
    test('should calculate time until departure correctly', () {
      final now = DateTime.now();
      final departureIn30Min = now.add(const Duration(minutes: 30));

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: departureIn30Min.add(const Duration(minutes: 30)),
        departureTime: departureIn30Min,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final timeUntilDeparture = trip.getTimeUntilDeparture();

      expect(timeUntilDeparture.inMinutes, greaterThanOrEqualTo(29));
      expect(timeUntilDeparture.inMinutes, lessThanOrEqualTo(30));
    });

    test('should calculate time until arrival correctly', () {
      final now = DateTime.now();
      final arrivalIn60Min = now.add(const Duration(minutes: 60));

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: arrivalIn60Min,
        departureTime: now.add(const Duration(minutes: 30)),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final timeUntilArrival = trip.getTimeUntilArrival();

      expect(timeUntilArrival.inMinutes, greaterThanOrEqualTo(59));
      expect(timeUntilArrival.inMinutes, lessThanOrEqualTo(60));
    });

    test('should detect late status correctly', () {
      final now = DateTime.now();
      final pastDeparture = now.subtract(const Duration(minutes: 10));

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: now.add(const Duration(minutes: 20)),
        departureTime: pastDeparture,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip.isLate(), true);
    });

    test('should not be late if before departure time', () {
      final now = DateTime.now();
      final futureDeparture = now.add(const Duration(minutes: 10));

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: futureDeparture.add(const Duration(minutes: 30)),
        departureTime: futureDeparture,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip.isLate(), false);
    });

    test('should not be late if trip is completed', () {
      final now = DateTime.now();
      final pastDeparture = now.subtract(const Duration(minutes: 10));

      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: now.add(const Duration(minutes: 20)),
        departureTime: pastDeparture,
        transportMode: 'car',
        travelDurationMinutes: 30,
        isCompleted: true,
      );

      expect(trip.isLate(), false);
    });

    test('should detect active status correctly', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime.now().add(const Duration(minutes: 60)),
        departureTime: DateTime.now().add(const Duration(minutes: 30)),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip.isActive(), true);
    });

    test('should not be active if completed', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime.now().add(const Duration(minutes: 60)),
        departureTime: DateTime.now().add(const Duration(minutes: 30)),
        transportMode: 'car',
        travelDurationMinutes: 30,
        isCompleted: true,
      );

      expect(trip.isActive(), false);
    });

    test('should not be active if cancelled', () {
      final trip = Trip(
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime.now().add(const Duration(minutes: 60)),
        departureTime: DateTime.now().add(const Duration(minutes: 30)),
        transportMode: 'car',
        travelDurationMinutes: 30,
        isCancelled: true,
      );

      expect(trip.isActive(), false);
    });
  });

  group('Trip Model - Equality and Hashing', () {
    test('should be equal if same id', () {
      final trip1 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final trip2 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '다른 회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 7, 15, 0),
        departureTime: DateTime(2025, 1, 7, 14, 0),
        transportMode: 'transit',
        travelDurationMinutes: 45,
      );

      expect(trip1, equals(trip2));
      expect(trip1.hashCode, equals(trip2.hashCode));
    });

    test('should not be equal if different id', () {
      final trip1 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final trip2 = Trip(
        id: 'trip_456',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip1, isNot(equals(trip2)));
    });

    test('should be identical if same instance', () {
      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 7, 14, 0),
        departureTime: DateTime(2025, 1, 7, 13, 0),
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      expect(trip, equals(trip));
      expect(identical(trip, trip), true);
    });
  });

  group('Trip Model - toString', () {
    test('should provide meaningful string representation', () {
      final arrivalTime = DateTime(2025, 1, 7, 14, 0);
      final departureTime = DateTime(2025, 1, 7, 13, 0);

      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의',
        destinationAddress: '서울시청',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        transportMode: 'car',
        travelDurationMinutes: 30,
      );

      final str = trip.toString();

      expect(str, contains('trip_123'));
      expect(str, contains('회의'));
      expect(str, contains(arrivalTime.toString()));
      expect(str, contains(departureTime.toString()));
    });
  });
}
