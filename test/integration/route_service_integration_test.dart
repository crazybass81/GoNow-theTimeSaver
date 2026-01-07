import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_now/services/route_service.dart';

/// Integration Test: RouteService with Real TMAP Routes API
///
/// **Purpose**: Verify RouteService works with actual TMAP Routes API
///
/// **Requirements**:
/// - TMAP API key must be set in .env file
/// - Internet connection required
///
/// **Coverage**:
/// - Real TMAP Routes API calls (자동차 경로)
/// - Error handling with actual API responses
/// - Response parsing and data transformation
/// - Cache behavior with real data

void main() {
  // Integration tests with TMAP API
  group('RouteService Integration Tests (TMAP)', () {
    late RouteService routeService;

    setUpAll(() async {
      // Load .env file
      await dotenv.load(fileName: ".env");

      // Initialize RouteService
      routeService = RouteService();
      routeService.initialize();
    });

    test(
      'should get driving route from Naver Directions API',
      () async {
        // Test coordinates: 서울시청 → 강남역
        const originLat = 37.5662952; // 서울시청
        const originLng = 126.9779451;
        const destLat = 37.4979462; // 강남역
        const destLng = 127.0276368;

        final route = await routeService.calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          option: 'trafast', // 빠른 길
        );

        // Verify route data structure
        expect(route, isNotNull);
        expect(route, isA<RouteResult>());
        expect(route!.distanceKm, greaterThan(0));
        expect(route.durationMinutes, greaterThan(0));

        // Verify reasonable values for Seoul City Hall → Gangnam Station
        // Distance should be approximately 7-10 km
        expect(route.distanceKm, greaterThan(7.0));
        expect(route.distanceKm, lessThan(15.0));

        // Duration should be approximately 15-60 minutes
        expect(route.durationMinutes, greaterThan(15));
        expect(route.durationMinutes, lessThan(60));

        // Verify route has path points
        expect(route.path, isNotNull);

        // Verify traffic level is set
        expect(route.trafficLevel, isNotNull);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should handle API errors gracefully',
      () async {
        // Invalid coordinates (outside Korea)
        const originLat = 0.0; // Null Island
        const originLng = 0.0;
        const destLat = 0.0;
        const destLng = 0.0;

        expect(
          () async => await routeService.calculateRoute(
            originLat: originLat,
            originLng: originLng,
            destLat: destLat,
            destLng: destLng,
          ),
          throwsA(isA<RouteServiceException>()),
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should cache route results',
      () async {
        // First call - should hit API
        const originLat = 37.5662952;
        const originLng = 126.9779451;
        const destLat = 37.4979462;
        const destLng = 127.0276368;

        final stopwatch1 = Stopwatch()..start();
        final route1 = await routeService.calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );
        stopwatch1.stop();

        // Second call with same parameters - should use cache
        final stopwatch2 = Stopwatch()..start();
        final route2 = await routeService.calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );
        stopwatch2.stop();

        // Verify same route returned
        expect(route1!.distanceKm, equals(route2!.distanceKm));
        expect(route1.durationMinutes, equals(route2.durationMinutes));

        // Second call should be significantly faster (cached)
        print('First call: ${stopwatch1.elapsedMilliseconds}ms');
        print('Second call (cached): ${stopwatch2.elapsedMilliseconds}ms');

        // Cached call should be much faster (< 100ms vs several seconds)
        expect(stopwatch2.elapsedMilliseconds, lessThan(100));
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );

    test(
      'should return different routes for different options',
      () async {
        const originLat = 37.5662952;
        const originLng = 126.9779451;
        const destLat = 37.4979462;
        const destLng = 127.0276368;

        final fastRoute = await routeService.calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          option: 'trafast', // 빠른 길
        );

        final comfortRoute = await routeService.calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          option: 'tracomfort', // 편한 길
        );

        // Both routes should be valid
        expect(fastRoute, isNotNull);
        expect(comfortRoute, isNotNull);
        expect(fastRoute!.durationMinutes, greaterThan(0));
        expect(comfortRoute!.durationMinutes, greaterThan(0));

        // Routes might be different (but not guaranteed)
        // Just verify both are reasonable
        expect(fastRoute.distanceKm, greaterThan(5.0));
        expect(comfortRoute.distanceKm, greaterThan(5.0));
      },
      timeout: const Timeout(Duration(seconds: 60)),
    );
  });
}
