import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Theme
import 'utils/app_theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';

// Services
import 'services/route_service.dart';
import 'services/transit_service.dart';
import 'services/poi_search_service.dart';
import 'services/scheduler_service.dart';
import 'services/polling_service.dart';
import 'services/real_time_updater.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize RouteService (TMAP Routes API)
  RouteService().initialize();

  // Initialize TransitService (Naver Transit API)
  TransitService().initialize();

  // Initialize POISearchService (TMAP POI Search API)
  POISearchService().initialize();

  // Initialize SchedulerService (Backward Scheduling Algorithm)
  SchedulerService().initialize();

  // Initialize PollingService (Adaptive Polling)
  PollingService().initialize();

  // Initialize RealTimeUpdater (Real-Time Updates)
  RealTimeUpdater().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        title: 'GoNow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// 인증 상태에 따라 화면 전환 / Route based on auth state
///
/// **로직 / Logic**:
/// - 로그인됨: MainWrapper (Dashboard/Calendar)
/// - 로그인 안 됨: LoginScreen
/// - 로딩 중: CircularProgressIndicator
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 로그인 상태에 따라 화면 결정 / Determine screen based on auth status
        if (authProvider.status == AuthStatus.authenticating) {
          // 로딩 중 / Loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (authProvider.isAuthenticated) {
          // 로그인됨 → 메인 화면 / Authenticated → Main screen
          return const MainWrapper();
        } else {
          // 로그인 안 됨 → 로그인 화면 / Not authenticated → Login screen
          return const LoginScreen();
        }
      },
    );
  }
}
