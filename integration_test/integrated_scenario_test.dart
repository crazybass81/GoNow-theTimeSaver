import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:go_now/screens/auth/login_screen.dart';
import 'package:go_now/screens/dashboard/dashboard_screen.dart';
import 'package:go_now/screens/schedule/add_schedule_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:go_now/providers/trip_provider.dart';
import 'package:go_now/utils/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// E2E Test 4: 통합 시나리오 (Complete User Journey)
///
/// **Test Coverage**:
/// - 앱 시작 및 LoginScreen 표시
/// - 로그인된 상태에서 대시보드 이동
/// - FAB 탭하여 일정 추가 화면 이동
/// - 목적지 선택 및 다음 단계 진행
/// - 대시보드로 복귀
/// - 전체 네비게이션 플로우 검증

/// Mock AuthProvider for testing
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  supabase.User? _mockUser;
  AuthStatus _status;

  MockAuthProvider({bool authenticated = false})
      : _mockUser = authenticated ? MockUser() : null,
        _status = authenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;

  @override
  supabase.User? get currentUser => _mockUser;

  @override
  AuthStatus get status => _status;

  @override
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  @override
  String? get errorMessage => null;

  @override
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _mockUser = MockUser();
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    return true;
  }

  @override
  Future<bool> signInWithProvider({
    required supabase.OAuthProvider provider,
  }) async {
    return true;
  }

  @override
  Future<bool> signOut() async {
    _mockUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> resetPassword({required String email}) async {
    return true;
  }

  @override
  Future<bool> updateProfile({String? name, String? phone}) async {
    return true;
  }

  @override
  void clearError() {}
}

/// Mock Supabase User
class MockUser implements supabase.User {
  @override
  final String id = 'test_user_id';

  @override
  final String? email = 'test@example.com';

  @override
  final Map<String, dynamic> userMetadata = {
    'name': 'Test User',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Supabase for E2E tests (local Docker environment)
    // Use PC's local network IP instead of localhost for device access
    await supabase.Supabase.initialize(
      url: 'http://192.168.45.54:54321',
      anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    );
  });

  group('E2E Test 4: Integrated Scenario', () {
    testWidgets('Complete user journey: Login -> Dashboard -> Add Schedule',
        (WidgetTester tester) async {
      // Given - Start with unauthenticated state
      final mockAuthProvider = MockAuthProvider(authenticated: false);
      final mockTripProvider = TripProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/add_schedule': (context) => const AddScheduleScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Verify LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);

      // Step 2: Simulate login (bypass actual authentication)
      // In real scenario, this would involve form input and button tap
      // For E2E test, we directly update provider state
      mockAuthProvider.signInWithEmail(
        email: 'test@example.com',
        password: 'password',
      );
      await tester.pumpAndSettle();

      // Note: In real app, login would navigate to dashboard
      // For testing, we'll manually navigate
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
            routes: {
              '/add_schedule': (context) => const AddScheduleScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 3: Verify Dashboard is displayed
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Step 4: Navigate to Add Schedule screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Step 5: Verify AddScheduleScreen is displayed
      expect(find.byType(AddScheduleScreen), findsOneWidget);
      expect(find.text('일정 추가'), findsOneWidget);
      expect(find.text('어디로 가시나요?'), findsOneWidget);

      // Step 6: Select a destination
      expect(find.text('강남역 스타벅스'), findsOneWidget);
      await tester.tap(find.text('강남역 스타벅스'));
      await tester.pumpAndSettle();

      // Step 7: Verify moved to Step 2
      expect(find.text('언제 도착하시나요?'), findsOneWidget);
      expect(find.text('강남역 스타벅스'), findsOneWidget);

      // Step 8: Navigate back to dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 9: Verify Step 1 is shown (back navigation)
      expect(find.text('어디로 가시나요?'), findsOneWidget);

      // Step 10: Navigate back again to dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 11: Verify back on dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(AddScheduleScreen), findsNothing);
    });

    testWidgets('Dashboard shows empty state when no trips',
        (WidgetTester tester) async {
      // Given - Authenticated user with no trips
      final mockAuthProvider = MockAuthProvider(authenticated: true);
      final mockTripProvider = TripProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Empty state should be displayed
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('일정이 없습니다'), findsOneWidget);
      expect(find.textContaining('새 일정을 추가'), findsOneWidget);
    });

    testWidgets('Authenticated user can see welcome message',
        (WidgetTester tester) async {
      // Given - Authenticated user
      final mockAuthProvider = MockAuthProvider(authenticated: true);
      final mockTripProvider = TripProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Welcome message should show user name
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('Add schedule flow maintains state during navigation',
        (WidgetTester tester) async {
      // Given - Dashboard with authenticated user
      final mockAuthProvider = MockAuthProvider(authenticated: true);
      final mockTripProvider = TripProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
            routes: {
              '/add_schedule': (context) => const AddScheduleScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When - Navigate to add schedule
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Then - Should show Step 1
      expect(find.text('어디로 가시나요?'), findsOneWidget);

      // When - Select destination
      await tester.tap(find.text('코엑스'));
      await tester.pumpAndSettle();

      // Then - Should show Step 2 with selected destination
      expect(find.text('언제 도착하시나요?'), findsOneWidget);
      expect(find.text('코엑스'), findsOneWidget);
      expect(find.text('서울시 강남구 영동대로'), findsOneWidget);
    });

    testWidgets('Multiple navigation cycles work correctly',
        (WidgetTester tester) async {
      // Given - Dashboard
      final mockAuthProvider = MockAuthProvider(authenticated: true);
      final mockTripProvider = TripProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(
                value: mockAuthProvider),
            ChangeNotifierProvider<TripProvider>.value(
                value: mockTripProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
            routes: {
              '/add_schedule': (context) => const AddScheduleScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cycle 1: Dashboard -> Add Schedule -> Back to Dashboard
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddScheduleScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Cycle 2: Dashboard -> Add Schedule -> Back to Dashboard
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(AddScheduleScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Verify final state
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
