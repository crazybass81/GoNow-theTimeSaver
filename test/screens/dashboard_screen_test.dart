import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/screens/dashboard/dashboard_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:go_now/models/trip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dashboard Screen Widget Tests
///
/// **테스트 목적 / Test Purpose**:
/// - UI 렌더링 검증
/// - 상태별 화면 표시 (로딩, 에러, 빈 상태, 정상 데이터)
/// - 사용자 상호작용 검증
///
/// **비즈니스 규칙 / Business Rules**:
/// - 로그인 사용자 이름 표시
/// - upcomingTrip이 있을 때만 카운트다운 표시
/// - trips.length > 1일 때만 이후 일정 표시
/// - transportMode에 따라 다른 아이콘 표시

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardScreen - UI Rendering', () {
    testWidgets('should show loading indicator when loading', (tester) async {
      // Given: Loading state
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(isLoading: true);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pump();

      // Then: Should show CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error view when error occurs', (tester) async {
      // Given: Error state
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(
        isLoading: false,
        error: '네트워크 오류',
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show error message
      expect(find.text('데이터를 불러오는데 실패했습니다'), findsOneWidget);
      expect(find.text('네트워크 오류'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show empty state when no trips', (tester) async {
      // Given: No trips
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show empty state
      expect(find.text('일정이 없습니다'), findsOneWidget);
      expect(find.text('하단의 + 버튼을 눌러\n새 일정을 추가해보세요'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });

    testWidgets('should show upcoming trip when trips exist', (tester) async {
      // Given: Trips exist
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의 참석',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show trip information
      expect(find.text('다음 일정'), findsOneWidget);
      expect(find.text('🚗 회의 참석'), findsOneWidget);
      expect(find.text('강남역'), findsOneWidget);
      expect(find.text('이동 정보'), findsOneWidget);
      expect(find.text('출발했어요'), findsOneWidget);
    });
  });

  group('DashboardScreen - Welcome Message', () {
    testWidgets('should show user name when available', (tester) async {
      // Given: User with name
      final authProvider = MockAuthProvider(
        isAuthenticated: true,
        userName: '홍길동',
      );
      final tripProvider = MockTripProvider(isLoading: false, trips: []);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show user name
      expect(find.text('안녕하세요, 홍길동님'), findsOneWidget);
    });

    testWidgets('should show default name when user name not available',
        (tester) async {
      // Given: User without name
      final authProvider = MockAuthProvider(
        isAuthenticated: true,
        userName: null,
      );
      final tripProvider = MockTripProvider(isLoading: false, trips: []);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show default name
      expect(find.text('안녕하세요, 사용자님'), findsOneWidget);
    });
  });

  group('DashboardScreen - Transport Mode Icons', () {
    testWidgets('should show car icon for car transport mode', (tester) async {
      // Given: Trip with car transport
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show car icon and label
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      expect(find.text('자동차'), findsOneWidget);
    });

    testWidgets('should show transit icon for transit transport mode',
        (tester) async {
      // Given: Trip with transit transport
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'transit',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show transit icon and label
      expect(find.byIcon(Icons.directions_transit), findsOneWidget);
      expect(find.text('대중교통'), findsOneWidget);
    });
  });

  group('DashboardScreen - Upcoming Schedules', () {
    testWidgets('should NOT show upcoming schedules section when only 1 trip',
        (tester) async {
      // Given: Only 1 trip
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should NOT show "이후 일정" section
      expect(find.text('이후 일정'), findsNothing);
    });

    testWidgets('should show upcoming schedules section when trips > 1',
        (tester) async {
      // Given: Multiple trips
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trips = [
        Trip(
          id: 'trip1',
          userId: 'user1',
          title: '회의 1',
          destinationAddress: '강남역',
          destinationLat: 37.4979,
          destinationLng: 127.0276,
          arrivalTime: now.add(const Duration(hours: 2)),
          departureTime: now.add(const Duration(hours: 1)),
          travelDurationMinutes: 30,
          transportMode: 'car',
          preparationMinutes: 15,
          isCompleted: false,
          createdAt: now,
        ),
        Trip(
          id: 'trip2',
          userId: 'user1',
          title: '회의 2',
          destinationAddress: '홍대입구',
          destinationLat: 37.5565,
          destinationLng: 126.9240,
          arrivalTime: now.add(const Duration(hours: 4)),
          departureTime: now.add(const Duration(hours: 3)),
          travelDurationMinutes: 25,
          transportMode: 'transit',
          preparationMinutes: 10,
          isCompleted: false,
          createdAt: now,
        ),
      ];
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: trips,
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show "이후 일정" section with 2nd trip
      expect(find.text('이후 일정'), findsOneWidget);
      expect(find.text('🚗 회의 2'), findsOneWidget);
      expect(find.text('홍대입구'), findsOneWidget);
    });

    testWidgets('should show maximum 3 upcoming trips', (tester) async {
      // Given: 5 trips total
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trips = List.generate(
        5,
        (index) => Trip(
          id: 'trip${index + 1}',
          userId: 'user1',
          title: '회의 ${index + 1}',
          destinationAddress: '강남역 ${index + 1}',
          destinationLat: 37.4979,
          destinationLng: 127.0276,
          arrivalTime: now.add(Duration(hours: (index + 1) * 2)),
          departureTime: now.add(Duration(hours: (index + 1) * 2 - 1)),
          travelDurationMinutes: 30,
          transportMode: 'car',
          preparationMinutes: 15,
          isCompleted: false,
          createdAt: now,
        ),
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: trips,
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show only trips 2, 3, 4 (skip first, take 3)
      expect(find.text('🚗 회의 1'), findsOneWidget); // Current trip
      expect(find.text('🚗 회의 2'), findsOneWidget); // Upcoming 1
      expect(find.text('🚗 회의 3'), findsOneWidget); // Upcoming 2
      expect(find.text('🚗 회의 4'), findsOneWidget); // Upcoming 3
      expect(find.text('🚗 회의 5'), findsNothing); // Not shown (max 3)
    });
  });

  group('DashboardScreen - Navigation', () {
    testWidgets('should have FAB for adding schedule', (tester) async {
      // Given: Normal state
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(isLoading: false, trips: []);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show FAB with "일정 추가"
      expect(find.text('일정 추가'), findsOneWidget);
      expect(
          find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    });

    testWidgets('should have calendar button in AppBar', (tester) async {
      // Given: Normal state
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(isLoading: false, trips: []);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show calendar button
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byTooltip('캘린더'), findsOneWidget);
    });

    testWidgets('should have settings button in AppBar', (tester) async {
      // Given: Normal state
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final tripProvider = MockTripProvider(isLoading: false, trips: []);

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show settings button
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byTooltip('설정'), findsOneWidget);
    });
  });

  group('DashboardScreen - Departure Button', () {
    testWidgets('should show departure button when trip exists',
        (tester) async {
      // Given: Trip exists
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      // When: Render DashboardScreen
      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // Then: Should show "출발했어요" button
      // Note: Icons.directions_run appears twice - in CountdownWidget and departure button
      expect(find.text('출발했어요'), findsOneWidget);
      expect(
          find.widgetWithIcon(ElevatedButton, Icons.directions_run),
          findsOneWidget);
    });

    testWidgets('should show confirmation dialog when departure button tapped',
        (tester) async {
      // Given: Trip exists
      final authProvider = MockAuthProvider(isAuthenticated: true);
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip1',
        userId: 'user1',
        title: '회의',
        destinationAddress: '강남역',
        destinationLat: 37.4979,
        destinationLng: 127.0276,
        arrivalTime: now.add(const Duration(hours: 2)),
        departureTime: now.add(const Duration(hours: 1)),
        travelDurationMinutes: 30,
        transportMode: 'car',
        preparationMinutes: 15,
        isCompleted: false,
        createdAt: now,
      );
      final tripProvider = MockTripProvider(
        isLoading: false,
        trips: [trip],
      );

      await tester.pumpWidget(
        _createTestApp(authProvider, tripProvider),
      );
      await tester.pumpAndSettle();

      // When: Scroll to departure button and tap
      await tester.ensureVisible(
          find.widgetWithIcon(ElevatedButton, Icons.directions_run));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.directions_run));
      await tester.pumpAndSettle();

      // Then: Should show confirmation dialog
      expect(find.text('출발 확인'), findsOneWidget);
      expect(find.text('출발하셨나요?\n일정이 완료 처리됩니다.'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });
  });
}

/// Helper function to create test app with providers
/// 테스트용 Provider를 constructor로 주입 / Inject providers via constructor for testing
Widget _createTestApp(MockAuthProvider authProvider, MockTripProvider tripProvider) {
  return MaterialApp(
    home: DashboardScreen(
      authProviderOverride: authProvider,
      tripProviderOverride: tripProvider,
    ),
  );
}

/// Mock AuthProvider for testing
/// Note: Does not extend AuthProvider to avoid Supabase initialization requirement
class MockAuthProvider extends ChangeNotifier {
  final bool _isAuthenticated;
  final String? _userName;

  MockAuthProvider({
    required bool isAuthenticated,
    String? userName,
  })  : _isAuthenticated = isAuthenticated,
        _userName = userName;

  bool get isAuthenticated => _isAuthenticated;

  User? get currentUser => _isAuthenticated
      ? User(
          id: 'user123',
          appMetadata: const {},
          userMetadata: _userName != null ? {'name': _userName} : const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        )
      : null;

  AuthStatus get status =>
      _isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;

  String? get errorMessage => null;
}

/// Mock TripProvider for testing
/// Note: Does not extend TripProvider to avoid initialization issues
class MockTripProvider extends ChangeNotifier {
  final bool _isLoading;
  final String? _error;
  final List<Trip> _trips;

  MockTripProvider({
    required bool isLoading,
    String? error,
    List<Trip> trips = const [],
  })  : _isLoading = isLoading,
        _error = error,
        _trips = trips;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Trip> get trips => _trips;

  Trip? get upcomingTrip => _trips.isNotEmpty ? _trips.first : null;

  Future<void> initialize(String userId) async {
    // Mock implementation
  }

  Future<void> loadTrips(String userId) async {
    // Mock implementation
  }

  Future<void> completeTrip(String tripId) async {
    // Mock implementation
  }
}
