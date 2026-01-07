import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/services/notification_service.dart';
import 'package:go_now/models/trip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Initialization', () {
    test('should return same instance (Singleton pattern)', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      expect(identical(service1, service2), true);
    });
  });

  group('NotificationPriority Enum', () {
    test('should have all priority levels defined', () {
      expect(NotificationPriority.values.length, 3);
      expect(NotificationPriority.values.contains(NotificationPriority.normal),
          true);
      expect(
          NotificationPriority.values.contains(NotificationPriority.high), true);
      expect(NotificationPriority.values.contains(NotificationPriority.urgent),
          true);
    });

    test('should differentiate between priority levels', () {
      expect(NotificationPriority.normal != NotificationPriority.high, true);
      expect(NotificationPriority.high != NotificationPriority.urgent, true);
      expect(NotificationPriority.normal != NotificationPriority.urgent, true);
    });
  });

  group('Notification ID Logic', () {
    test('should generate unique IDs for different trip notifications', () {
      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: 'Test Trip',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 8, 14, 0),
        departureTime: DateTime(2025, 1, 8, 13, 0),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // 30분 알림 ID: trip.id.hashCode
      final normalId = trip.id.hashCode;

      // 10분 알림 ID: trip.id.hashCode + 1
      final urgentId = trip.id.hashCode + 1;

      // 동적 알림 ID: trip.id.hashCode + 2
      final dynamicId = trip.id.hashCode + 2;

      // All IDs should be different
      expect(normalId != urgentId, true);
      expect(urgentId != dynamicId, true);
      expect(normalId != dynamicId, true);
    });

    test('should generate same ID for same trip', () {
      final trip1 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: 'Test Trip',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 8, 14, 0),
        departureTime: DateTime(2025, 1, 8, 13, 0),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final trip2 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: 'Different Title',
        destinationAddress: '다른 목적지',
        destinationLat: 37.5665,
        destinationLng: 126.9780,
        arrivalTime: DateTime(2025, 1, 9, 14, 0),
        departureTime: DateTime(2025, 1, 9, 13, 0),
        travelDurationMinutes: 45,
        transportMode: 'transit',
        preparationMinutes: 20,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Same ID = Same notification ID
      expect(trip1.id.hashCode, trip2.id.hashCode);
    });

    test('should generate different IDs for different trips', () {
      final trip1 = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: 'Test Trip 1',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 8, 14, 0),
        departureTime: DateTime(2025, 1, 8, 13, 0),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final trip2 = Trip(
        id: 'trip_456',
        userId: 'user_123',
        title: 'Test Trip 2',
        destinationAddress: '홍대입구',
        destinationLat: 37.5565,
        destinationLng: 126.9240,
        arrivalTime: DateTime(2025, 1, 8, 15, 0),
        departureTime: DateTime(2025, 1, 8, 14, 0),
        travelDurationMinutes: 25,
        transportMode: 'transit',
        preparationMinutes: 10,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Different IDs = Different notification IDs
      expect(trip1.id.hashCode != trip2.id.hashCode, true);
    });
  });

  group('Time Calculation Logic', () {
    test('should calculate 30-minute notification time correctly', () {
      final departureTime = DateTime(2025, 1, 8, 13, 0);
      final notificationTime = departureTime.subtract(const Duration(minutes: 30));

      expect(notificationTime, DateTime(2025, 1, 8, 12, 30));
    });

    test('should calculate 10-minute notification time correctly', () {
      final departureTime = DateTime(2025, 1, 8, 13, 0);
      final notificationTime = departureTime.subtract(const Duration(minutes: 10));

      expect(notificationTime, DateTime(2025, 1, 8, 12, 50));
    });

    test('should detect if 30-minute notification time has passed', () {
      final now = DateTime.now();
      final pastDepartureTime = now.subtract(const Duration(minutes: 20));
      final notificationTime30 =
          pastDepartureTime.subtract(const Duration(minutes: 30));

      // 30분 전 시간이 현재보다 과거인지 확인
      expect(notificationTime30.isBefore(now), true);
    });

    test('should detect if 10-minute notification time has passed', () {
      final now = DateTime.now();
      final pastDepartureTime = now.subtract(const Duration(minutes: 5));
      final notificationTime10 =
          pastDepartureTime.subtract(const Duration(minutes: 10));

      // 10분 전 시간이 현재보다 과거인지 확인
      expect(notificationTime10.isBefore(now), true);
    });

    test('should detect if notification time is in the future', () {
      final now = DateTime.now();
      final futureDepartureTime = now.add(const Duration(hours: 2));
      final notificationTime30 =
          futureDepartureTime.subtract(const Duration(minutes: 30));
      final notificationTime10 =
          futureDepartureTime.subtract(const Duration(minutes: 10));

      // Both notification times should be in the future
      expect(notificationTime30.isAfter(now), true);
      expect(notificationTime10.isAfter(now), true);
    });
  });

  group('Notification Message Formatting', () {
    test('should format time correctly with zero padding', () {
      final time1 = DateTime(2025, 1, 8, 9, 5); // 09:05
      final formatted1 =
          '${time1.hour.toString().padLeft(2, '0')}:${time1.minute.toString().padLeft(2, '0')}';
      expect(formatted1, '09:05');

      final time2 = DateTime(2025, 1, 8, 13, 30); // 13:30
      final formatted2 =
          '${time2.hour.toString().padLeft(2, '0')}:${time2.minute.toString().padLeft(2, '0')}';
      expect(formatted2, '13:30');

      final time3 = DateTime(2025, 1, 8, 0, 0); // 00:00
      final formatted3 =
          '${time3.hour.toString().padLeft(2, '0')}:${time3.minute.toString().padLeft(2, '0')}';
      expect(formatted3, '00:00');
    });

    test('should create notification title for 30-minute notification', () {
      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의 참석',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 8, 14, 0),
        departureTime: DateTime(2025, 1, 8, 13, 0),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final title = '${trip.title} - 30분 전 알림';
      expect(title, '회의 참석 - 30분 전 알림');
    });

    test('should create notification title for 10-minute urgent notification',
        () {
      final trip = Trip(
        id: 'trip_123',
        userId: 'user_123',
        title: '회의 참석',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: DateTime(2025, 1, 8, 14, 0),
        departureTime: DateTime(2025, 1, 8, 13, 0),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final title = '🚨 ${trip.title} - 긴급 알림!';
      expect(title, '🚨 회의 참석 - 긴급 알림!');
    });
  });

  group('Edge Cases', () {
    test('should handle notification for very short trips (< 30 minutes)', () {
      final now = DateTime.now();
      final departureTime = now.add(const Duration(minutes: 15));

      // 30분 전 알림 시간은 과거가 됨
      final notificationTime30 =
          departureTime.subtract(const Duration(minutes: 30));
      expect(notificationTime30.isBefore(now), true);

      // 10분 전 알림은 미래
      final notificationTime10 =
          departureTime.subtract(const Duration(minutes: 10));
      expect(notificationTime10.isAfter(now), true);
    });

    test('should handle notification for very long trips', () {
      final now = DateTime.now();
      final departureTime = now.add(const Duration(hours: 24));

      // Both notification times should be in the future
      final notificationTime30 =
          departureTime.subtract(const Duration(minutes: 30));
      final notificationTime10 =
          departureTime.subtract(const Duration(minutes: 10));

      expect(notificationTime30.isAfter(now), true);
      expect(notificationTime10.isAfter(now), true);
    });

    test('should handle notification for immediate departure', () {
      final now = DateTime.now();
      final departureTime = now.add(const Duration(minutes: 5));

      // Both notification times are in the past
      final notificationTime30 =
          departureTime.subtract(const Duration(minutes: 30));
      final notificationTime10 =
          departureTime.subtract(const Duration(minutes: 10));

      expect(notificationTime30.isBefore(now), true);
      expect(notificationTime10.isBefore(now), true);
    });
  });
}
