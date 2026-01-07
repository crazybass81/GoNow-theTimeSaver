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
// import 'screens/splash_screen.dart';

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
        // home: const SplashScreen(),
        home: const LoginScreen(),
      ),
    );
  }
}
