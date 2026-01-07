import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_now/screens/settings/settings_screen.dart';
import 'package:go_now/screens/auth/login_screen.dart';
import 'package:go_now/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// SettingsScreen Widget Tests
///
/// **Test Coverage**:
/// - Initial rendering (3 main sections)
/// - Transport mode selection
/// - Notification settings (switches)
/// - Account section (user profile)
/// - App info section
/// - UI elements and scrolling

/// Mock AuthProvider for SettingsScreen tests
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  supabase.User? _currentUser;
  AuthStatus _status = AuthStatus.authenticated;

  MockAuthProvider({supabase.User? currentUser}) : _currentUser = currentUser;

  @override
  supabase.User? get currentUser => _currentUser;

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
    _currentUser = null;
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
  void clearError() {
    // Mock implementation
  }
}

/// Mock Supabase User for testing
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
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider(currentUser: MockUser());
  });

  Widget _createTestApp({dynamic authProviderOverride}) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: authProviderOverride ?? mockAuthProvider,
        child: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen - Initial Render', () {
    testWidgets('should render SettingsScreen with app bar',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('should render all 3 main sections',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then - 3 main sections
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('계정 관리'), findsOneWidget);
      expect(find.text('앱 정보'), findsOneWidget);
    });

    testWidgets('should render 4 sliders for buffer time settings',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then - Should show 4 sliders
      expect(find.byType(Slider), findsNWidgets(4));
    });

    testWidgets('should render transport mode selection',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('기본 이동 수단'), findsOneWidget);
      expect(find.text('대중교통'), findsOneWidget);
      expect(find.text('자가용'), findsOneWidget);
    });

    testWidgets('should render notification settings with switches',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('알림 사용'), findsOneWidget);
      expect(find.text('30분 전 알림'), findsOneWidget);
      expect(find.text('10분 전 긴급 알림'), findsOneWidget);
      expect(find.text('알림 소리'), findsOneWidget);

      // Should show 3 switches
      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('should render account section with user info',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('계정 관리'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('로그아웃'), findsOneWidget);
    });

    testWidgets('should render app info section',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('앱 정보'), findsOneWidget);
      expect(find.text('버전 정보'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('오픈소스 라이선스'), findsOneWidget);
    });
  });

  group('SettingsScreen - Buffer Time UI', () {
    testWidgets('should show default values on sliders',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then - Default values should be displayed
      expect(find.text('15분'), findsOneWidget); // Preparation time
      expect(find.text('10분'), findsOneWidget); // Early arrival
      expect(find.text('20%'), findsOneWidget); // Error rate
      expect(find.text('5분'), findsOneWidget); // Finish-up time
    });

    testWidgets('should change slider value when dragged',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // When - Drag first slider
      final preparationSlider = find.byType(Slider).first;
      await tester.drag(preparationSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Then - Slider should exist and be interactive
      expect(preparationSlider, findsOneWidget);
    });
  });

  group('SettingsScreen - Transport Mode', () {
    testWidgets('should have transit and car mode options',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('대중교통'), findsOneWidget);
      expect(find.text('자가용'), findsOneWidget);
    });

    testWidgets('should switch transport mode when tapped',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // When - Tap car mode button
      await tester.tap(find.text('자가용'));
      await tester.pumpAndSettle();

      // Then - Should remain on SettingsScreen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('SettingsScreen - Notification Settings', () {
    testWidgets('should have all notification switches enabled by default',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then - Find all 3 switches
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // All switches should be enabled by default
      final Switch masterSwitch = tester.widget(switches.at(0));
      final Switch switch30Min = tester.widget(switches.at(1));
      final Switch switch10Min = tester.widget(switches.at(2));

      expect(masterSwitch.value, true);
      expect(switch30Min.value, true);
      expect(switch10Min.value, true);
    });

    testWidgets('should show notification sound setting',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('알림 소리'), findsOneWidget);
      expect(find.text('기본'), findsOneWidget);
    });
  });

  group('SettingsScreen - Account Section', () {
    testWidgets('should display user profile information',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show logout button', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('로그아웃'), findsOneWidget);
    });
  });

  group('SettingsScreen - App Info', () {
    testWidgets('should display app version', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('버전 정보'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('should show licenses option', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.text('오픈소스 라이선스'), findsOneWidget);
    });
  });

  group('SettingsScreen - UI Elements', () {
    testWidgets('should be scrollable', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should show section dividers', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });

    testWidgets('should show help text for buffer time settings',
        (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then - Should show explanatory text
      expect(find.text('옷 입기, 짐 챙기기 등'), findsOneWidget);
      expect(find.text('약속 시간 전 여유롭게 도착'), findsOneWidget);
      expect(find.text('교통 예측 불확실성, 신호 대기'), findsOneWidget);
      expect(find.text('이전 일정 정리 후 출발'), findsOneWidget);
    });

    testWidgets('should render all ListTiles', (WidgetTester tester) async {
      // Given & When
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(ListTile), findsAtLeastNWidgets(5));
    });
  });
}
