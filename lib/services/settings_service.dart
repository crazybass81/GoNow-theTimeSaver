import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_settings.dart';

/// 설정 서비스 / Settings Service
///
/// **기능 / Features**:
/// - Supabase users 테이블 CRUD
/// - shared_preferences 로컬 캐싱
/// - RLS (Row Level Security) 정책 준수
///
/// **비즈니스 규칙 / Business Rule**:
/// - 사용자는 본인의 설정만 접근 가능 (RLS)
/// - 로컬 캐시 우선, 네트워크는 fallback
/// - 설정 변경 시 즉시 Supabase와 동기화
///
/// **Context**: MVP 설정 관리 서비스
class SettingsService {
  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'users';
  static const String _cacheKey = 'user_settings_cache';

  /// 설정 조회 (캐시 우선) / Get settings (cache-first)
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 1. 로컬 캐시 확인
  /// - 2. 없으면 Supabase에서 조회
  /// - 3. 조회 결과를 로컬 캐시에 저장
  ///
  /// @param userId 사용자 ID
  /// @returns 사용자 설정 또는 null
  Future<UserSettings?> getSettings(String userId) async {
    try {
      debugPrint('🔍 Fetching settings for user: $userId');

      // 1. 로컬 캐시 확인 / Check local cache first
      final cachedSettings = await _getCachedSettings(userId);
      if (cachedSettings != null) {
        debugPrint('✅ Settings loaded from cache');
        return cachedSettings;
      }

      // 2. Supabase에서 조회 / Fetch from Supabase
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Settings not found for user: $userId');
        return null;
      }

      final settings = UserSettings.fromJson(response);

      // 3. 캐시에 저장 / Save to cache
      await _cacheSettings(settings);

      debugPrint('✅ Settings fetched from Supabase and cached');
      return settings;
    } catch (e) {
      debugPrint('❌ Failed to fetch settings: $e');
      rethrow;
    }
  }

  /// 설정 업데이트 / Update settings
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 버퍼 시간 검증 필수
  /// - RLS에 의해 본인 설정만 수정 가능
  /// - 업데이트 후 캐시 갱신
  ///
  /// @param settings 업데이트할 설정
  /// @returns 업데이트된 설정
  ///
  /// @throws Exception if validation fails or update fails
  Future<UserSettings> updateSettings(UserSettings settings) async {
    try {
      // 버퍼 시간 검증 / Validate buffer times
      if (!settings.validateBufferTimes()) {
        throw Exception(
            'Invalid buffer times. Check ranges: preparation(5-60), early_arrival(0-30), uncertainty(0-0.5), wrapup(0-20)');
      }

      debugPrint('✏️ Updating settings for user: ${settings.userId}');

      final data = settings.toJson();
      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', settings.userId)
          .select()
          .single();

      final updatedSettings = UserSettings.fromJson(response);

      // 캐시 업데이트 / Update cache
      await _cacheSettings(updatedSettings);

      debugPrint('✅ Settings updated and cached');

      return updatedSettings;
    } catch (e) {
      debugPrint('❌ Failed to update settings: $e');
      rethrow;
    }
  }

  /// 교통 수단 선호도 변경 / Update preferred transport
  ///
  /// @param userId 사용자 ID
  /// @param transport 교통 수단 ('car', 'transit', 'auto')
  Future<UserSettings> updatePreferredTransport(
      String userId, String transport) async {
    try {
      if (!['car', 'transit', 'auto'].contains(transport)) {
        throw Exception(
            'Invalid transport mode. Must be: car, transit, or auto');
      }

      debugPrint('🚗 Updating preferred transport: $transport');

      final response = await _supabase
          .from(_tableName)
          .update({'preferred_transport': transport})
          .eq('id', userId)
          .select()
          .single();

      final settings = UserSettings.fromJson(response);
      await _cacheSettings(settings);

      debugPrint('✅ Preferred transport updated');

      return settings;
    } catch (e) {
      debugPrint('❌ Failed to update preferred transport: $e');
      rethrow;
    }
  }

  /// 기본 집 위치 설정 / Set default home location
  ///
  /// @param userId 사용자 ID
  /// @param location 집 위치
  Future<UserSettings> setHomeLocation(
      String userId, HomeLocation location) async {
    try {
      debugPrint('🏠 Setting home location: ${location.address}');

      final response = await _supabase
          .from(_tableName)
          .update({'default_home_location': location.toJson()})
          .eq('id', userId)
          .select()
          .single();

      final settings = UserSettings.fromJson(response);
      await _cacheSettings(settings);

      debugPrint('✅ Home location set');

      return settings;
    } catch (e) {
      debugPrint('❌ Failed to set home location: $e');
      rethrow;
    }
  }

  /// 알림 설정 변경 / Update notification settings
  ///
  /// @param userId 사용자 ID
  /// @param enabled 알림 활성화 여부
  /// @param sound 소리 활성화 여부
  /// @param vibration 진동 활성화 여부
  Future<UserSettings> updateNotificationSettings({
    required String userId,
    required bool enabled,
    required bool sound,
    required bool vibration,
  }) async {
    try {
      debugPrint(
          '🔔 Updating notification settings: enabled=$enabled, sound=$sound, vibration=$vibration');

      final response = await _supabase
          .from(_tableName)
          .update({
            'notification_enabled': enabled,
            'sound_enabled': sound,
            'vibration_enabled': vibration,
          })
          .eq('id', userId)
          .select()
          .single();

      final settings = UserSettings.fromJson(response);
      await _cacheSettings(settings);

      debugPrint('✅ Notification settings updated');

      return settings;
    } catch (e) {
      debugPrint('❌ Failed to update notification settings: $e');
      rethrow;
    }
  }

  /// 기본 버퍼 시간 설정 / Set default buffer times
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - preparation: 5-60분
  /// - earlyArrival: 0-30분
  /// - uncertainty: 0-50% (0.0-0.5)
  /// - wrapup: 0-20분
  ///
  /// @param userId 사용자 ID
  /// @param preparation 외출 준비 시간 (분)
  /// @param earlyArrival 일찍 도착 버퍼 (분)
  /// @param uncertainty 이동 오차율 (0.0-0.5)
  /// @param wrapup 일정 마무리 시간 (분)
  Future<UserSettings> setDefaultBufferTimes({
    required String userId,
    required int preparation,
    required int earlyArrival,
    required double uncertainty,
    required int wrapup,
  }) async {
    try {
      // 검증 / Validation
      if (preparation < 5 || preparation > 60) {
        throw Exception('Preparation time must be between 5 and 60 minutes');
      }
      if (earlyArrival < 0 || earlyArrival > 30) {
        throw Exception('Early arrival buffer must be between 0 and 30 minutes');
      }
      if (uncertainty < 0 || uncertainty > 0.5) {
        throw Exception('Uncertainty rate must be between 0 and 0.5 (0-50%)');
      }
      if (wrapup < 0 || wrapup > 20) {
        throw Exception('Wrap-up time must be between 0 and 20 minutes');
      }

      debugPrint('⏱️ Setting default buffer times');

      final response = await _supabase
          .from(_tableName)
          .update({
            'default_preparation_minutes': preparation,
            'default_early_arrival_buffer_minutes': earlyArrival,
            'default_travel_uncertainty_rate': uncertainty,
            'default_previous_task_wrapup_minutes': wrapup,
          })
          .eq('id', userId)
          .select()
          .single();

      final settings = UserSettings.fromJson(response);
      await _cacheSettings(settings);

      debugPrint('✅ Default buffer times set');

      return settings;
    } catch (e) {
      debugPrint('❌ Failed to set default buffer times: $e');
      rethrow;
    }
  }

  /// 로컬 캐시 삭제 / Clear local cache
  ///
  /// **Context**: 로그아웃 시 호출
  Future<void> clearCache() async {
    try {
      debugPrint('🗑️ Clearing settings cache');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);

      debugPrint('✅ Cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
      // 캐시 삭제 실패는 무시 (중요하지 않음)
    }
  }

  // ========================================
  // Private Methods (로컬 캐싱)
  // ========================================

  /// 로컬 캐시에서 설정 조회 / Get settings from local cache
  Future<UserSettings?> _getCachedSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);

      if (cachedJson == null) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(cachedJson);

      // userId 검증 / Validate userId
      if (json['id'] != userId) {
        debugPrint('⚠️ Cached settings userId mismatch. Clearing cache.');
        await clearCache();
        return null;
      }

      return UserSettings.fromJson(json);
    } catch (e) {
      debugPrint('⚠️ Failed to load cached settings: $e');
      return null;
    }
  }

  /// 설정을 로컬 캐시에 저장 / Save settings to local cache
  Future<void> _cacheSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'id': settings.userId,
        'preferred_transport': settings.preferredTransport,
        if (settings.defaultHomeLocation != null)
          'default_home_location': settings.defaultHomeLocation!.toJson(),
        'default_preparation_minutes': settings.defaultPreparationMinutes,
        'default_early_arrival_buffer_minutes':
            settings.defaultEarlyArrivalBufferMinutes,
        'default_travel_uncertainty_rate':
            settings.defaultTravelUncertaintyRate,
        'default_previous_task_wrapup_minutes':
            settings.defaultPreviousTaskWrapupMinutes,
        'notification_enabled': settings.notificationEnabled,
        'sound_enabled': settings.soundEnabled,
        'vibration_enabled': settings.vibrationEnabled,
        'subscription_tier': settings.subscriptionTier,
        if (settings.subscriptionExpiresAt != null)
          'subscription_expires_at':
              settings.subscriptionExpiresAt!.toIso8601String(),
        if (settings.createdAt != null)
          'created_at': settings.createdAt!.toIso8601String(),
        if (settings.updatedAt != null)
          'updated_at': settings.updatedAt!.toIso8601String(),
        if (settings.lastActiveAt != null)
          'last_active_at': settings.lastActiveAt!.toIso8601String(),
      };

      await prefs.setString(_cacheKey, jsonEncode(json));

      debugPrint('💾 Settings cached locally');
    } catch (e) {
      debugPrint('⚠️ Failed to cache settings: $e');
      // 캐싱 실패는 무시 (중요하지 않음)
    }
  }
}
