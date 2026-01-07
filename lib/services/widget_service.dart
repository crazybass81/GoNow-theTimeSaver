import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/trip.dart';

/// 홈 위젯 업데이트 서비스 / Home Widget Update Service
///
/// **기능 / Features**:
/// - Android Glance 위젯 업데이트
/// - iOS WidgetKit 업데이트
/// - 다음 일정 데이터 공유
/// - 플랫폼별 데이터 저장
///
/// **플랫폼 구현 / Platform Implementation**:
/// - Android: SharedPreferences + MethodChannel
/// - iOS: App Groups + SharedUserDefaults
///
/// **Context**: Phase 3 - 홈 위젯 통합
class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.gonow.widget');

  /// WidgetService 싱글톤 인스턴스 / Singleton instance
  static final WidgetService _instance = WidgetService._internal();

  factory WidgetService() {
    return _instance;
  }

  WidgetService._internal();

  /// 위젯 업데이트 (다음 일정 정보 전달) / Update widget with upcoming trip
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 다음 일정이 있으면 위젯에 표시
  /// - 일정이 없으면 빈 상태 표시
  /// - 시간대별 색상 적용 (초록/주황/빨강)
  ///
  /// **플랫폼 동작 / Platform Behavior**:
  /// - Android: WorkManager를 통해 15분마다 갱신
  /// - iOS: Timeline Provider로 15분마다 갱신
  Future<void> updateWidget({Trip? upcomingTrip}) async {
    try {
      if (upcomingTrip == null) {
        await _clearWidget();
        return;
      }

      // 위젯에 표시할 데이터 준비 / Prepare data for widget
      final widgetData = _formatWidgetData(upcomingTrip);

      debugPrint('📱 Updating widget with data: $widgetData');

      // 플랫폼별 위젯 업데이트 / Update widget on platform
      await _channel.invokeMethod('updateWidget', widgetData);

      debugPrint('✅ Widget updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update widget: $e');
    }
  }

  /// 위젯 데이터 포맷 / Format data for widget display
  Map<String, dynamic> _formatWidgetData(Trip trip) {
    final now = DateTime.now();
    final timeUntilDeparture = trip.departureTime.difference(now);
    final minutesRemaining = timeUntilDeparture.inMinutes;

    // 시간대별 색상 결정 / Determine color phase
    String colorPhase;
    if (minutesRemaining > 30) {
      colorPhase = 'green'; // 여유 있음
    } else if (minutesRemaining > 15) {
      colorPhase = 'orange'; // 준비 필요
    } else if (minutesRemaining > 0) {
      colorPhase = 'red'; // 긴급
    } else {
      colorPhase = 'dark_red'; // 지각 위험
    }

    return {
      'tripId': trip.id,
      'title': trip.title,
      'destinationAddress': trip.destinationAddress,
      'arrivalTime': trip.arrivalTime.toIso8601String(),
      'departureTime': trip.departureTime.toIso8601String(),
      'minutesRemaining': minutesRemaining,
      'colorPhase': colorPhase,
      'transportMode': trip.transportMode,
      'travelDurationMinutes': trip.travelDurationMinutes,
      // 포맷된 시간 문자열 / Formatted time strings
      'departureTimeFormatted':
          '${trip.departureTime.hour.toString().padLeft(2, '0')}:${trip.departureTime.minute.toString().padLeft(2, '0')}',
      'arrivalTimeFormatted':
          '${trip.arrivalTime.hour.toString().padLeft(2, '0')}:${trip.arrivalTime.minute.toString().padLeft(2, '0')}',
      'timeRemainingText': _formatTimeRemaining(minutesRemaining),
    };
  }

  /// 남은 시간 텍스트 포맷 / Format remaining time text
  String _formatTimeRemaining(int minutes) {
    if (minutes < 0) {
      return '지각 위험!';
    } else if (minutes == 0) {
      return '지금 출발!';
    } else if (minutes < 60) {
      return '$minutes분 남음';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours시간 남음';
      } else {
        return '$hours시간 $remainingMinutes분 남음';
      }
    }
  }

  /// 위젯 초기화 (일정 없을 때) / Clear widget when no trip
  Future<void> _clearWidget() async {
    try {
      debugPrint('📱 Clearing widget (no upcoming trip)');

      await _channel.invokeMethod('clearWidget');

      debugPrint('✅ Widget cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear widget: $e');
    }
  }

  /// 위젯 강제 갱신 / Force refresh widget
  ///
  /// **사용 시나리오 / Use Cases**:
  /// - 일정 추가/수정/삭제 시
  /// - 사용자가 수동으로 새로고침 요청 시
  /// - 앱이 포그라운드로 돌아올 때
  Future<void> forceRefreshWidget() async {
    try {
      debugPrint('🔄 Force refreshing widget');

      await _channel.invokeMethod('forceRefresh');

      debugPrint('✅ Widget force refreshed');
    } catch (e) {
      debugPrint('❌ Failed to force refresh widget: $e');
    }
  }

  /// 위젯 클릭 처리 / Handle widget click
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 위젯 클릭 시 앱을 열고 대시보드로 이동
  ///
  /// **구현 방법 / Implementation**:
  /// - Android: PendingIntent로 앱 실행
  /// - iOS: URL Scheme 또는 Deep Link
  Future<void> handleWidgetClick() async {
    try {
      debugPrint('👆 Widget clicked');

      // Native에서 앱 열기 로직 처리
      // Flutter 앱은 이미 실행되므로 특별한 처리 불필요
    } catch (e) {
      debugPrint('❌ Failed to handle widget click: $e');
    }
  }

  /// 디버그 정보 / Debug info
  String getDebugInfo() {
    return '''
🔍 WidgetService Debug Info:
- Platform: ${defaultTargetPlatform.name}
- Channel: ${_channel.name}
''';
  }
}
