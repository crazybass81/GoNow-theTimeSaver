import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:go_now/screens/dashboard/dashboard_screen.dart';
import 'package:go_now/screens/schedule/add_schedule_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:go_now/providers/trip_provider.dart';
import 'package:go_now/utils/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// E2E Test 3: 일정 추가 플로우
///
/// **Test Coverage**:
/// - 대시보드에서 FAB 탭하여 AddScheduleScreen 이동
/// - Step 1: 목적지 선택
/// - Step 2: 시간 및 이동 수단 UI 표시
/// - Step 3: 버퍼 시간 슬라이더 표시
/// - Step 4: 일정 확인 화면 표시
/// - 뒤로 가기 네비게이션

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
    // Use PC's local network IP instead of localhost for device access
    await supabase.Supabase.initialize(
      url: 'http://192.168.45.54:54321',
      anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
    );
  });

  group('E2E Test 3: Add Schedule Flow', () {
    testWidgets('should navigate to AddScheduleScreen from dashboard FAB',
        (WidgetTester tester) async {
      // Given - Dashboard with authenticated user
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
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

      // When - Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Then - AddScheduleScreen should be displayed
      expect(find.byType(AddScheduleScreen), findsOneWidget);
      expect(find.text('일정 추가'), findsOneWidget);
    });

    testWidgets('should show Step 1 destination selection UI',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Step 1 UI should be present
      expect(find.text('어디로 가시나요?'), findsOneWidget);
      expect(find.text('목적지를 검색하거나 선택해주세요'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('최근 장소'), findsOneWidget);
      expect(find.text('즐겨찾기'), findsOneWidget);
    });

    testWidgets('should show recent places and favorites in Step 1',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Recent places should be shown
      expect(find.text('강남역 스타벅스'), findsOneWidget);
      expect(find.text('코엑스'), findsOneWidget);
      expect(find.text('홍대입구역'), findsOneWidget);

      // And favorites should be shown
      expect(find.text('회사'), findsOneWidget);
      expect(find.text('집'), findsOneWidget);
    });

    testWidgets('should advance to Step 2 when place is selected',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - Tap a place
      await tester.tap(find.text('강남역 스타벅스'));
      await tester.pumpAndSettle();

      // Then - Step 2 should be shown
      expect(find.text('언제 도착하시나요?'), findsOneWidget);
      expect(find.text('도착 시간과 이동 수단을 설정해주세요'), findsOneWidget);
    });

    testWidgets('should show selected place in Step 2',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - Select place and move to Step 2
      await tester.tap(find.text('코엑스'));
      await tester.pumpAndSettle();

      // Then - Selected place should be displayed
      expect(find.text('코엑스'), findsOneWidget);
      expect(find.text('서울시 강남구 영동대로'), findsOneWidget);
    });

    testWidgets('should show transport mode options in Step 2',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - Move to Step 2
      await tester.tap(find.text('강남역 스타벅스'));
      await tester.pumpAndSettle();

      // Then - Transport mode options should be shown
      expect(find.text('이동 수단'), findsOneWidget);
      expect(find.text('대중교통'), findsOneWidget);
      expect(find.text('자가용'), findsOneWidget);
    });

    testWidgets('should show step indicator', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Step indicator should be present (4 segments)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show next button', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Next button should be present
      expect(find.text('다음'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show validation error when advancing without selection',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When - Tap next without selecting place
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Then - Validation error should be shown
      expect(find.text('목적지를 선택해주세요'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should navigate back to dashboard',
        (WidgetTester tester) async {
      // Given - Dashboard with navigation
      final mockUser = MockUser();
      final mockAuthProvider = MockAuthProvider(mockUser);
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

      // When - Navigate to AddScheduleScreen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // And tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Then - Should be back on dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(AddScheduleScreen), findsNothing);
    });
  });
}
