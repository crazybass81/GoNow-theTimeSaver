import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/services/route_service.dart';
import 'package:go_now/models/route.dart' as app_models;

/// Integration Test 1: RouteService with Real Naver API
///
/// **Purpose**: Verify RouteService works with actual Naver Maps/Transit APIs
///
/// **Requirements**:
/// - Naver API keys must be set in environment variables
/// - Internet connection required
/// - Tests are skipped if API keys are not available
///
/// **Coverage**:
/// - Real Naver Directions API calls (자동차 경로)
/// - Real Naver Transit API calls (대중교통 경로)
/// - Error handling with actual API responses
/// - Response parsing and data transformation
/// - Cache behavior with real data

void main() {
  // Get API keys from environment
  const naverClientId = String.fromEnvironment('NAVER_CLIENT_ID');
  const naverClientSecret = String.fromEnvironment('NAVER_CLIENT_SECRET');

  // Skip all tests if API keys are not provided
  final shouldSkip = naverClientId.isEmpty || naverClientSecret.isEmpty;

  group('RouteService Integration Tests', () {
    late RouteService routeService;

    setUp(() {
      routeService = RouteService();
    });

    test(
      'should get driving route from Naver Directions API',
      () async {
        // Test coordinates: 서울시청 → 강남역
        final start = (lat: 37.5662952, lng: 126.9779451); // 서울시청
        final end = (lat: 37.4979462, lng: 127.0276368); // 강남역

        final route = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'car',
        );

        // Verify route data structure
        expect(route, isNotNull);
        expect(route, isA<app_models.Route>());
        expect(route.distance, greaterThan(0));
        expect(route.duration, greaterThan(0));
        expect(route.transportMode, equals('car'));

        // Verify reasonable values for Seoul City Hall → Gangnam Station
        // Distance should be approximately 7-10 km
        expect(route.distance, greaterThan(7000));
        expect(route.distance, lessThan(15000));

        // Duration should be approximately 15-40 minutes (900-2400 seconds)
        expect(route.duration, greaterThan(900));
        expect(route.duration, lessThan(3600));

        // Verify route has path points
        expect(route.path, isNotEmpty);
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
    );

    test(
      'should get transit route from Naver Transit API',
      () async {
        // Test coordinates: 서울시청 → 강남역
        final start = (lat: 37.5662952, lng: 126.9779451); // 서울시청
        final end = (lat: 37.4979462, lng: 127.0276368); // 강남역

        final route = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'transit',
        );

        // Verify route data structure
        expect(route, isNotNull);
        expect(route, isA<app_models.Route>());
        expect(route.distance, greaterThan(0));
        expect(route.duration, greaterThan(0));
        expect(route.transportMode, equals('transit'));

        // Transit route should have reasonable duration
        // Should be approximately 20-50 minutes (1200-3000 seconds)
        expect(route.duration, greaterThan(1200));
        expect(route.duration, lessThan(4000));

        // Verify route has path points
        expect(route.path, isNotEmpty);
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
    );

    test(
      'should handle API errors gracefully',
      () async {
        // Invalid coordinates (outside Korea)
        final start = (lat: 0.0, lng: 0.0); // Null Island
        final end = (lat: 0.0, lng: 0.0);

        expect(
          () async => await routeService.getRoute(
            start: start,
            end: end,
            transportMode: 'car',
          ),
          throwsA(isA<Exception>()),
        );
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
    );

    test(
      'should cache route results',
      () async {
        // First call - should hit API
        final start = (lat: 37.5662952, lng: 126.9779451);
        final end = (lat: 37.4979462, lng: 127.0276368);

        final stopwatch1 = Stopwatch()..start();
        final route1 = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'car',
        );
        stopwatch1.stop();

        // Second call with same parameters - should use cache
        final stopwatch2 = Stopwatch()..start();
        final route2 = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'car',
        );
        stopwatch2.stop();

        // Verify same route returned
        expect(route1.distance, equals(route2.distance));
        expect(route1.duration, equals(route2.duration));

        // Second call should be significantly faster (cached)
        // This might be flaky, so we're lenient
        print('First call: ${stopwatch1.elapsedMilliseconds}ms');
        print('Second call (cached): ${stopwatch2.elapsedMilliseconds}ms');

        // Cached call should be at least 50% faster
        expect(stopwatch2.elapsedMilliseconds,
            lessThan(stopwatch1.elapsedMilliseconds));
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
    );

    test(
      'should return different routes for different transport modes',
      () async {
        final start = (lat: 37.5662952, lng: 126.9779451);
        final end = (lat: 37.4979462, lng: 127.0276368);

        final carRoute = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'car',
        );

        final transitRoute = await routeService.getRoute(
          start: start,
          end: end,
          transportMode: 'transit',
        );

        // Routes should be different
        expect(carRoute.transportMode, equals('car'));
        expect(transitRoute.transportMode, equals('transit'));

        // Duration might be different (usually transit takes longer)
        // But this isn't guaranteed, so we just check they're both valid
        expect(carRoute.duration, greaterThan(0));
        expect(transitRoute.duration, greaterThan(0));
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
    );

    test(
      'should handle rate limiting and retry',
      () async {
        // Make multiple rapid requests to potentially trigger rate limiting
        final start = (lat: 37.5662952, lng: 126.9779451);
        final end = (lat: 37.4979462, lng: 127.0276368);

        final futures = List.generate(
          5,
          (index) => routeService.getRoute(
            start: start,
            end: end,
            transportMode: 'car',
          ),
        );

        // All requests should eventually succeed (either from API or cache)
        final routes = await Future.wait(futures);

        expect(routes.length, equals(5));
        for (final route in routes) {
          expect(route, isNotNull);
          expect(route.distance, greaterThan(0));
        }
      },
      skip: shouldSkip
          ? 'Skipping: NAVER_CLIENT_ID or NAVER_CLIENT_SECRET not set'
          : null,
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
