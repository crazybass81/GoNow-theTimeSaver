import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트 및 데이터베이스 작업을 위한 서비스 클래스
///
/// **Context**: 모든 Supabase 관련 작업의 중앙 집중식 인터페이스
/// **Business Rule**: Row Level Security (RLS)에 의해 사용자는 본인 데이터만 접근 가능
class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // =============================================
  // User Profile (사용자 프로필)
  // =============================================

  /// 사용자 프로필 가져오기 / Get user profile
  ///
  /// **Context**: 앱 시작 시 또는 프로필 화면에서 호출
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// 사용자 프로필 업데이트 / Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? preferredTransport,
    Map<String, dynamic>? defaultHomeLocation,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (preferredTransport != null) updates['preferred_transport'] = preferredTransport;
      if (defaultHomeLocation != null) updates['default_home_location'] = defaultHomeLocation;

      await client
          .from('users')
          .update(updates)
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // =============================================
  // Schedules (일정)
  // =============================================

  /// 다가오는 일정 가져오기 (도착 시간 기준 오름차순) / Get upcoming schedules
  ///
  /// **Context**: 대시보드 메인 화면에서 호출
  /// **Business Rule**: 완료되지 않고 취소되지 않은 일정만 조회
  static Future<List<Map<String, dynamic>>> getUpcomingSchedules(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await client
          .from('schedules')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .eq('is_cancelled', false)
          .gte('arrival_time', now)
          .order('arrival_time', ascending: true)
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching upcoming schedules: $e');
      return [];
    }
  }

  /// 일정 추가 / Create schedule
  ///
  /// **Context**: "일정 추가" 화면에서 호출
  /// **Business Rule**: 4가지 버퍼 시간을 모두 저장
  static Future<Map<String, dynamic>?> createSchedule({
    required String userId,
    required String title,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String transportMode,
    required int travelDurationMinutes,
    Map<String, dynamic>? routeData,
    int preparationMinutes = 15,
    int earlyArrivalBufferMinutes = 10,
    double travelUncertaintyRate = 0.2,
    int previousTaskWrapupMinutes = 5,
  }) async {
    try {
      final response = await client
          .from('schedules')
          .insert({
            'user_id': userId,
            'title': title,
            'destination_address': destinationAddress,
            'destination_lat': destinationLat,
            'destination_lng': destinationLng,
            'arrival_time': arrivalTime.toIso8601String(),
            'departure_time': departureTime.toIso8601String(),
            'transport_mode': transportMode,
            'travel_duration_minutes': travelDurationMinutes,
            'route_data': routeData,
            'preparation_minutes': preparationMinutes,
            'early_arrival_buffer_minutes': earlyArrivalBufferMinutes,
            'travel_uncertainty_rate': travelUncertaintyRate,
            'previous_task_wrapup_minutes': previousTaskWrapupMinutes,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating schedule: $e');
      return null;
    }
  }

  /// 일정 삭제 / Delete schedule
  static Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await client
          .from('schedules')
          .delete()
          .eq('id', scheduleId);

      return true;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  // =============================================
  // Places (자주 가는 장소)
  // =============================================

  /// 자주 가는 장소 저장 / Save favorite place
  ///
  /// **Context**: 목적지 검색 시 자동 저장
  static Future<void> saveFavoritePlace({
    required String userId,
    required String name,
    required String address,
    required double lat,
    required double lng,
    String? category,
  }) async {
    try {
      await client.from('places').upsert({
        'user_id': userId,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'category': category ?? 'etc',
        'visit_count': 1,
        'last_visited_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,name');
    } catch (e) {
      print('Error saving favorite place: $e');
    }
  }

  /// 자주 가는 장소 목록 가져오기 / Get favorite places
  static Future<List<Map<String, dynamic>>> getFavoritePlaces(String userId) async {
    try {
      final response = await client
          .from('places')
          .select()
          .eq('user_id', userId)
          .order('visit_count', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching favorite places: $e');
      return [];
    }
  }

  // =============================================
  // Realtime Subscriptions (실시간 구독)
  // =============================================

  /// 실시간 일정 변경 감지 / Watch schedules in realtime
  ///
  /// **Context**: 대시보드에서 실시간 업데이트 필요 시
  static Stream<List<Map<String, dynamic>>> watchSchedules(String userId) {
    return client
        .from('schedules')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('arrival_time');
  }
}
