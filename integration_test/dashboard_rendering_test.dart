import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:go_now/screens/dashboard/dashboard_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:go_now/providers/trip_provider.dart';
import 'package:go_now/utils/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// E2E Test 2: 대시보드 렌더링 테스트 (이미 로그인된 상태)
///
/// **Test Coverage**:
/// - 로그인된 사용자 상태에서 대시보드가 표시되는지 확인
/// - 대시보드의 주요 UI 요소들이 렌더링되는지 확인
/// - 일정이 없는 상태 (빈 상태) 처리 확인

/// Mock AuthProvider for testing
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  final supabase.User _mockUser;

  MockAuthProvider(this._mockUser);

  @override
  supabase.User? get currentUser => _mockUser;

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  bool get isAuthenticated => true;

  @override
  String? get errorMessage => null;

  @override
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
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
    // Uses ADB reverse port forwarding (adb reverse tcp:54321 tcp:54321)
    await supabase.Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    );
  });

  group('E2E Test 2: Dashboard Rendering (Logged In)', () {
    testWidgets('should show DashboardScreen when user is authenticated',
        (WidgetTester tester) async {
      // Given - Create mock authenticated user
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
      final mockTripProvider = TripProvider();

      // When - Build dashboard with providers
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

      // Then - DashboardScreen should be displayed
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display user welcome message',
        (WidgetTester tester) async {
      // Given
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
      final mockTripProvider = TripProvider();

      // When
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

    testWidgets('should show empty state when no trips',
        (WidgetTester tester) async {
      // Given - Empty trip list
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
      final mockTripProvider = TripProvider();

      // When
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

      // Then - Empty state should be shown
      expect(find.text('일정이 없습니다'), findsOneWidget);
      expect(find.textContaining('새 일정을 추가'), findsOneWidget);
    });

    testWidgets('should show FAB for adding new trip',
        (WidgetTester tester) async {
      // Given
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
      final mockTripProvider = TripProvider();

      // When
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

      // Then - FloatingActionButton should be present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should render dashboard UI elements',
        (WidgetTester tester) async {
      // Given
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
      final mockTripProvider = TripProvider();

      // When
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

      // Then - Basic dashboard elements should be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
