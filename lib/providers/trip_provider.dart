import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import '../services/scheduler_service.dart';
import '../services/real_time_updater.dart';
import '../services/polling_service.dart';

/// 일정 상태 관리 Provider / Trip State Management Provider
///
/// **기능 / Features**:
/// - 일정 CRUD 작업
/// - 실시간 출발 시간 업데이트
/// - 적응형 폴링 (15/5/3분)
/// - UI 상태 관리
///
/// **비즈니스 규칙 / Business Rule**:
/// - 다가오는 일정만 실시간 업데이트
/// - 변화율 5% 미만이면 스킵 (배터리 효율)
/// - 시간대별 색상 시스템
///
/// **Context**: MVP 상태 관리 핵심
class TripProvider with ChangeNotifier {
  // Services
  final TripService _tripService = TripService();
  final SchedulerService _schedulerService = SchedulerService();
  final RealTimeUpdater _realTimeUpdater = RealTimeUpdater();
  final PollingService _pollingService = PollingService();

  // State
  List<Trip> _trips = [];
  Trip? _upcomingTrip;
  bool _isLoading = false;
  String? _error;

  // Realtime update state
  DateTime? _currentDepartureTime;
  String? _currentTimePhase; // 'green', 'orange', 'red', 'dark_red'
  Timer? _pollingTimer;

  // Getters
  List<Trip> get trips => _trips;
  Trip? get upcomingTrip => _upcomingTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get currentDepartureTime => _currentDepartureTime;
  String? get currentTimePhase => _currentTimePhase;

  /// 초기화 / Initialize
  Future<void> initialize(String userId) async {
    _realTimeUpdater.initialize();
    await loadTrips(userId);
  }

  /// 사용자의 일정 로드 / Load user trips
  Future<void> loadTrips(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint('📋 Loading trips for user: $userId');

      // 활성 일정만 로드 / Load active trips only
      final trips =
          await _tripService.getActiveTrips(userId);

      _trips = trips;

      // 다가오는 일정 찾기 / Find upcoming trip
      _findUpcomingTrip();

      // 실시간 업데이트 시작 / Start real-time updates
      if (_upcomingTrip != null) {
        _startRealTimeUpdates(_upcomingTrip!);
      }

      debugPrint('✅ Loaded ${_trips.length} trips');

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to load trips: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 일정 추가 / Add trip
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 역산 스케줄링으로 출발 시간 자동 계산
  /// - 이동 시간은 Naver API에서 받아옴
  Future<Trip> addTrip({
    required String userId,
    required String title,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required DateTime arrivalTime,
    required String transportMode,
    required int travelDurationMinutes,
    Map<String, dynamic>? routeData,
    int preparationMinutes = 15,
    int earlyArrivalBufferMinutes = 10,
    double travelUncertaintyRate = 0.2,
    int previousTaskWrapupMinutes = 5,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint('➕ Adding trip: $title');

      // 역산 스케줄링으로 출발 시간 계산 / Calculate departure time
      final departureTime = _schedulerService.calculateDepartureTime(
        arrivalTime: arrivalTime,
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: preparationMinutes,
        previousTaskWrapUpMinutes: previousTaskWrapupMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
      );

      // Trip 생성 / Create trip
      final trip = Trip(
        userId: userId,
        title: title,
        destinationAddress: destinationAddress,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        transportMode: transportMode,
        travelDurationMinutes: travelDurationMinutes,
        routeData: routeData,
        preparationMinutes: preparationMinutes,
        earlyArrivalBufferMinutes: earlyArrivalBufferMinutes,
        travelUncertaintyRate: travelUncertaintyRate,
        previousTaskWrapupMinutes: previousTaskWrapupMinutes,
      );

      // DB에 저장 / Save to database
      final createdTrip = await _tripService.createTrip(trip);

      // 로컬 상태 업데이트 / Update local state
      _trips.add(createdTrip);
      _findUpcomingTrip();

      // 다가오는 일정이면 실시간 업데이트 시작
      if (_upcomingTrip?.id == createdTrip.id) {
        _startRealTimeUpdates(createdTrip);
      }

      debugPrint('✅ Trip added: ${createdTrip.id}');

      notifyListeners();

      return createdTrip;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to add trip: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 일정 완료 처리 / Mark trip as completed
  Future<void> completeTrip(String tripId) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint('✔️ Completing trip: $tripId');

      await _tripService.completeTrip(tripId);

      // 로컬 상태에서 제거 / Remove from local state
      _trips.removeWhere((trip) => trip.id == tripId);

      // 다음 일정으로 전환 / Switch to next trip
      _findUpcomingTrip();

      if (_upcomingTrip != null) {
        _startRealTimeUpdates(_upcomingTrip!);
      } else {
        _stopRealTimeUpdates();
      }

      debugPrint('✅ Trip completed');

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to complete trip: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 일정 취소 / Cancel trip
  Future<void> cancelTrip(String tripId) async {
    try {
      _setLoading(true);
      _error = null;

      debugPrint('❌ Cancelling trip: $tripId');

      await _tripService.cancelTrip(tripId);

      // 로컬 상태에서 제거 / Remove from local state
      _trips.removeWhere((trip) => trip.id == tripId);

      // 다음 일정으로 전환 / Switch to next trip
      _findUpcomingTrip();

      if (_upcomingTrip != null) {
        _startRealTimeUpdates(_upcomingTrip!);
      } else {
        _stopRealTimeUpdates();
      }

      debugPrint('✅ Trip cancelled');

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Failed to cancel trip: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ========================================
  // Private Methods
  // ========================================

  /// 다가오는 일정 찾기 / Find upcoming trip
  void _findUpcomingTrip() {
    if (_trips.isEmpty) {
      _upcomingTrip = null;
      return;
    }

    // 가장 가까운 일정 / Find nearest trip
    _trips.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    _upcomingTrip = _trips.first;

    debugPrint('🔜 Upcoming trip: ${_upcomingTrip?.title}');
  }

  /// 실시간 업데이트 시작 / Start real-time updates
  void _startRealTimeUpdates(Trip trip) {
    debugPrint('🔄 Starting real-time updates for: ${trip.title}');

    // 기존 타이머 정리 / Stop existing timer
    _pollingTimer?.cancel();

    // 초기 상태 설정 / Set initial state
    _currentDepartureTime = trip.departureTime;
    _updateTimePhase(trip.departureTime);

    // 폴링 간격 계산 / Calculate polling interval
    final now = DateTime.now();
    final timeUntilDeparture = trip.departureTime.difference(now);
    final pollingInterval =
        _pollingService.getPollingInterval(timeUntilDeparture: timeUntilDeparture);

    debugPrint('⏰ Polling interval: ${pollingInterval.inMinutes} minutes');

    // 주기적으로 출발 시간 재계산 / Recalculate periodically
    _pollingTimer = Timer.periodic(pollingInterval, (_) async {
      await _updateDepartureTime(trip);
    });

    notifyListeners();
  }

  /// 출발 시간 업데이트 / Update departure time
  Future<void> _updateDepartureTime(Trip trip) async {
    try {
      debugPrint('🔄 Updating departure time...');

      // RealTimeUpdater를 사용한 스마트 업데이트
      // Note: 실제로는 Naver API를 호출해서 최신 이동 시간을 받아와야 함
      // 여기서는 기존 값을 사용 (추후 통합)

      final now = DateTime.now();
      final timeUntilDeparture = trip.departureTime.difference(now);

      // 시간대 업데이트 / Update time phase
      _updateTimePhase(trip.departureTime);

      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Failed to update departure time: $e');
    }
  }

  /// 시간대 색상 업데이트 / Update time phase color
  void _updateTimePhase(DateTime departureTime) {
    final now = DateTime.now();
    final timeUntilDeparture = departureTime.difference(now);

    _currentTimePhase = _pollingService.getTimePhase(
      timeUntilDeparture: timeUntilDeparture,
    );

    debugPrint('🎨 Time phase: $_currentTimePhase');
  }

  /// 실시간 업데이트 중지 / Stop real-time updates
  void _stopRealTimeUpdates() {
    debugPrint('⏹️ Stopping real-time updates');

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentDepartureTime = null;
    _currentTimePhase = null;

    notifyListeners();
  }

  /// 로딩 상태 설정 / Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Provider 정리 / Dispose provider
  @override
  void dispose() {
    _pollingTimer?.cancel();
    _realTimeUpdater.dispose();
    super.dispose();
  }

  /// 디버그 정보 / Debug info
  String getDebugInfo() {
    return '''
🔍 TripProvider Debug Info:
- Total trips: ${_trips.length}
- Upcoming trip: ${_upcomingTrip?.title ?? 'None'}
- Departure time: $_currentDepartureTime
- Time phase: $_currentTimePhase
- Is loading: $_isLoading
- Error: ${_error ?? 'None'}
- Polling active: ${_pollingTimer?.isActive ?? false}
''';
  }
}
