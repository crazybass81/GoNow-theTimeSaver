import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';

/// 일정 서비스 / Trip Service
///
/// **기능 / Features**:
/// - Supabase schedules 테이블 CRUD
/// - RLS (Row Level Security) 정책 준수
/// - 실시간 구독 지원
///
/// **비즈니스 규칙 / Business Rule**:
/// - 사용자는 본인의 일정만 접근 가능 (RLS)
/// - 완료/취소된 일정도 보관 (삭제하지 않음)
/// - 실시간 업데이트 지원 (Supabase Realtime)
///
/// **Context**: MVP 핵심 데이터 서비스
class TripService {
  // Singleton pattern
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'schedules';

  /// 일정 생성 / Create trip
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - userId는 현재 로그인된 사용자 ID로 자동 설정
  /// - RLS에 의해 본인 일정만 생성 가능
  ///
  /// @param trip 생성할 일정
  /// @returns 생성된 일정 (ID 포함)
  ///
  /// @throws Exception if creation fails
  Future<Trip> createTrip(Trip trip) async {
    try {
      debugPrint('📝 Creating trip: ${trip.title}');

      final data = trip.toJson();
      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      final createdTrip = Trip.fromJson(response);
      debugPrint('✅ Trip created: ${createdTrip.id}');

      return createdTrip;
    } catch (e) {
      debugPrint('❌ Failed to create trip: $e');
      rethrow;
    }
  }

  /// 일정 조회 (ID) / Get trip by ID
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - RLS에 의해 본인 일정만 조회 가능
  ///
  /// @param tripId 일정 ID
  /// @returns 일정 또는 null
  Future<Trip?> getTripById(String tripId) async {
    try {
      debugPrint('🔍 Fetching trip: $tripId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', tripId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Trip not found: $tripId');
        return null;
      }

      final trip = Trip.fromJson(response);
      debugPrint('✅ Trip fetched: ${trip.title}');

      return trip;
    } catch (e) {
      debugPrint('❌ Failed to fetch trip: $e');
      rethrow;
    }
  }

  /// 사용자의 모든 일정 조회 / Get all trips for user
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 완료/취소된 일정 포함
  /// - 도착 시간 순 정렬 (오름차순)
  ///
  /// @param userId 사용자 ID
  /// @returns 일정 목록
  Future<List<Trip>> getAllTrips(String userId) async {
    try {
      debugPrint('📋 Fetching all trips for user: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('arrival_time', ascending: true);

      final trips = (response as List)
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${trips.length} trips');

      return trips;
    } catch (e) {
      debugPrint('❌ Failed to fetch trips: $e');
      rethrow;
    }
  }

  /// 활성 일정 조회 (완료/취소 제외) / Get active trips
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - is_completed = false AND is_cancelled = false
  /// - 도착 시간 순 정렬 (오름차순)
  ///
  /// @param userId 사용자 ID
  /// @returns 활성 일정 목록
  Future<List<Trip>> getActiveTrips(String userId) async {
    try {
      debugPrint('📋 Fetching active trips for user: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .eq('is_cancelled', false)
          .order('arrival_time', ascending: true);

      final trips = (response as List)
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${trips.length} active trips');

      return trips;
    } catch (e) {
      debugPrint('❌ Failed to fetch active trips: $e');
      rethrow;
    }
  }

  /// 특정 날짜의 일정 조회 / Get trips for a specific date
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 해당 날짜 00:00 ~ 23:59 범위의 일정
  /// - 도착 시간 기준
  ///
  /// @param userId 사용자 ID
  /// @param date 날짜
  /// @returns 해당 날짜의 일정 목록
  Future<List<Trip>> getTripsByDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      debugPrint('📅 Fetching trips for date: ${date.toIso8601String()}');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('arrival_time', startOfDay.toIso8601String())
          .lte('arrival_time', endOfDay.toIso8601String())
          .order('arrival_time', ascending: true);

      final trips = (response as List)
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${trips.length} trips for date');

      return trips;
    } catch (e) {
      debugPrint('❌ Failed to fetch trips by date: $e');
      rethrow;
    }
  }

  /// 다가오는 일정 조회 (현재 시간 이후) / Get upcoming trips
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 현재 시간 이후 도착 예정
  /// - 활성 일정만 (완료/취소 제외)
  /// - 가장 가까운 순서대로
  ///
  /// @param userId 사용자 ID
  /// @param limit 최대 개수 (기본 10개)
  /// @returns 다가오는 일정 목록
  Future<List<Trip>> getUpcomingTrips(String userId, {int limit = 10}) async {
    try {
      final now = DateTime.now();
      debugPrint('🔜 Fetching upcoming trips for user: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .eq('is_cancelled', false)
          .gte('arrival_time', now.toIso8601String())
          .order('arrival_time', ascending: true)
          .limit(limit);

      final trips = (response as List)
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Fetched ${trips.length} upcoming trips');

      return trips;
    } catch (e) {
      debugPrint('❌ Failed to fetch upcoming trips: $e');
      rethrow;
    }
  }

  /// 일정 수정 / Update trip
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - RLS에 의해 본인 일정만 수정 가능
  /// - updated_at은 Supabase 트리거가 자동 갱신
  ///
  /// @param trip 수정할 일정
  /// @returns 수정된 일정
  ///
  /// @throws Exception if update fails
  Future<Trip> updateTrip(Trip trip) async {
    try {
      if (trip.id == null) {
        throw Exception('Trip ID is required for update');
      }

      debugPrint('✏️ Updating trip: ${trip.id}');

      final data = trip.toJson();
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', trip.id!)
          .select()
          .single();

      final updatedTrip = Trip.fromJson(response);
      debugPrint('✅ Trip updated: ${updatedTrip.id}');

      return updatedTrip;
    } catch (e) {
      debugPrint('❌ Failed to update trip: $e');
      rethrow;
    }
  }

  /// 일정 완료 처리 / Mark trip as completed
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - is_completed = true
  /// - completed_at = 현재 시간
  ///
  /// @param tripId 일정 ID
  /// @returns 완료 처리된 일정
  Future<Trip> completeTrip(String tripId) async {
    try {
      debugPrint('✔️ Completing trip: $tripId');

      final now = DateTime.now();
      final response = await _supabase
          .from(_tableName)
          .update({
            'is_completed': true,
            'completed_at': now.toIso8601String(),
          })
          .eq('id', tripId)
          .select()
          .single();

      final completedTrip = Trip.fromJson(response);
      debugPrint('✅ Trip completed: ${completedTrip.id}');

      return completedTrip;
    } catch (e) {
      debugPrint('❌ Failed to complete trip: $e');
      rethrow;
    }
  }

  /// 일정 취소 처리 / Mark trip as cancelled
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - is_cancelled = true
  /// - 삭제하지 않고 취소 상태로만 변경
  ///
  /// @param tripId 일정 ID
  /// @returns 취소 처리된 일정
  Future<Trip> cancelTrip(String tripId) async {
    try {
      debugPrint('❌ Cancelling trip: $tripId');

      final response = await _supabase
          .from(_tableName)
          .update({'is_cancelled': true})
          .eq('id', tripId)
          .select()
          .single();

      final cancelledTrip = Trip.fromJson(response);
      debugPrint('✅ Trip cancelled: ${cancelledTrip.id}');

      return cancelledTrip;
    } catch (e) {
      debugPrint('❌ Failed to cancel trip: $e');
      rethrow;
    }
  }

  /// 일정 삭제 (완전 삭제) / Delete trip permanently
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - RLS에 의해 본인 일정만 삭제 가능
  /// - 물리적 삭제 (복구 불가)
  /// - 통계 데이터는 CASCADE로 함께 삭제됨
  ///
  /// @param tripId 일정 ID
  ///
  /// @throws Exception if deletion fails
  Future<void> deleteTrip(String tripId) async {
    try {
      debugPrint('🗑️ Deleting trip: $tripId');

      await _supabase.from(_tableName).delete().eq('id', tripId);

      debugPrint('✅ Trip deleted: $tripId');
    } catch (e) {
      debugPrint('❌ Failed to delete trip: $e');
      rethrow;
    }
  }

  /// 일정 실시간 구독 / Subscribe to trip updates
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - Supabase Realtime 사용
  /// - INSERT, UPDATE, DELETE 이벤트 구독
  ///
  /// **Context**: 대시보드 실시간 업데이트용
  ///
  /// @param userId 사용자 ID
  /// @param onInsert INSERT 이벤트 콜백
  /// @param onUpdate UPDATE 이벤트 콜백
  /// @param onDelete DELETE 이벤트 콜백
  /// @returns RealtimeChannel (구독 해제용)
  RealtimeChannel subscribeToTrips({
    required String userId,
    Function(Trip trip)? onInsert,
    Function(Trip trip)? onUpdate,
    Function(String tripId)? onDelete,
  }) {
    debugPrint('👂 Subscribing to trips for user: $userId');

    final channel = _supabase
        .channel('trips:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (onInsert != null) {
              final trip = Trip.fromJson(payload.newRecord);
              onInsert(trip);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (onUpdate != null) {
              final trip = Trip.fromJson(payload.newRecord);
              onUpdate(trip);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: _tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (onDelete != null) {
              final tripId = payload.oldRecord['id'] as String;
              onDelete(tripId);
            }
          },
        )
        .subscribe();

    return channel;
  }

  /// 구독 해제 / Unsubscribe from trip updates
  ///
  /// @param channel 구독 해제할 채널
  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      debugPrint('🔇 Unsubscribing from trips');
      await _supabase.removeChannel(channel);
      debugPrint('✅ Unsubscribed successfully');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe: $e');
      rethrow;
    }
  }
}
