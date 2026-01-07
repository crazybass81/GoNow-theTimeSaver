import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/trip.dart';

/// 로컬 푸시 알림 서비스 / Local Push Notification Service
///
/// **기능 / Features**:
/// - 30분 전 알림
/// - 10분 전 긴급 알림
/// - 동적 알림 메시지 (교통 상황 변화)
/// - 알림 클릭 시 앱 열기
///
/// **비즈니스 규칙 / Business Rule**:
/// - 일정 추가 시 자동으로 알림 예약
/// - 일정 완료/취소 시 알림 자동 취소
/// - 교통 지연 시 동적 알림 업데이트
///
/// **Context**: Phase 3 - 알림 시스템 통합
class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.gonow.notifications');

  /// NotificationService 싱글톤 인스턴스 / Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 알림 서비스 초기화 / Initialize notification service
  ///
  /// **플랫폼 설정 / Platform Setup**:
  /// - Android: 알림 채널 생성 (일반/긴급)
  /// - iOS: 알림 권한 요청
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    // 타임존 초기화 / Initialize timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정 / Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정 / iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 알림 채널 생성 / Create Android notification channels
    await _createAndroidChannels();

    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }

  /// Android 알림 채널 생성 / Create Android notification channels
  Future<void> _createAndroidChannels() async {
    // 일반 알림 채널 (30분 전)
    const normalChannel = AndroidNotificationChannel(
      'trip_reminders',
      'Trip Reminders',
      description: '일정 30분 전 알림',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // 긴급 알림 채널 (10분 전)
    const urgentChannel = AndroidNotificationChannel(
      'trip_urgent',
      'Urgent Reminders',
      description: '일정 10분 전 긴급 알림',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    final plugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(normalChannel);
    await plugin?.createNotificationChannel(urgentChannel);
  }

  /// 알림 클릭 처리 / Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.payload}');

    // 알림 클릭 시 앱 열기 및 대시보드로 이동
    // Navigator를 사용하려면 BuildContext가 필요하므로
    // 여기서는 플래그만 설정하고 main.dart에서 처리
  }

  /// 일정 알림 예약 / Schedule trip notifications
  ///
  /// **비즈니스 규칙 / Business Rule**:
  /// - 30분 전: 일반 알림 (준비 시작 권장)
  /// - 10분 전: 긴급 알림 (즉시 출발 필요)
  ///
  /// **알림 ID 규칙 / Notification ID Rule**:
  /// - 30분 알림: trip.id.hashCode
  /// - 10분 알림: trip.id.hashCode + 1
  /// - 동적 알림: trip.id.hashCode + 2
  Future<void> scheduleNotifications(Trip trip) async {
    if (!_initialized) {
      debugPrint('⚠️ NotificationService not initialized, skipping scheduling');
      return;
    }

    try {
      debugPrint('⏰ Scheduling notifications for trip: ${trip.title}');

      // 30분 전 알림
      await _schedule30MinuteNotification(trip);

      // 10분 전 긴급 알림
      await _schedule10MinuteNotification(trip);

      debugPrint('✅ Notifications scheduled for trip: ${trip.title}');
    } catch (e) {
      debugPrint('❌ Failed to schedule notifications: $e');
    }
  }

  /// 30분 전 알림 예약 / Schedule 30-minute notification
  Future<void> _schedule30MinuteNotification(Trip trip) async {
    final notificationTime =
        trip.departureTime.subtract(const Duration(minutes: 30));

    // 이미 지난 시간이면 스킵 / Skip if time has passed
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ 30-minute notification time has passed, skipping');
      return;
    }

    final timeFormatted =
        '${trip.departureTime.hour.toString().padLeft(2, '0')}:${trip.departureTime.minute.toString().padLeft(2, '0')}';

    await _notifications.zonedSchedule(
      trip.id.hashCode,
      '${trip.title} - 30분 전 알림',
      '$timeFormatted까지 출발하세요. 준비 시작!',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Trip Reminders',
          channelDescription: '일정 30분 전 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: trip.id,
    );

    debugPrint('✅ 30-minute notification scheduled at $notificationTime');
  }

  /// 10분 전 긴급 알림 예약 / Schedule 10-minute urgent notification
  Future<void> _schedule10MinuteNotification(Trip trip) async {
    final notificationTime =
        trip.departureTime.subtract(const Duration(minutes: 10));

    // 이미 지난 시간이면 스킵 / Skip if time has passed
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ 10-minute notification time has passed, skipping');
      return;
    }

    await _notifications.zonedSchedule(
      trip.id.hashCode + 1,
      '🚨 ${trip.title} - 긴급 알림!',
      '10분 후 출발! 지금 나가세요!',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_urgent',
          'Urgent Reminders',
          channelDescription: '일정 10분 전 긴급 알림',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          enableLights: true,
          color: const Color(0xFFF44336), // 빨간색
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: trip.id,
    );

    debugPrint('✅ 10-minute urgent notification scheduled at $notificationTime');
  }

  /// 동적 알림 전송 (교통 상황 변화) / Send dynamic notification for traffic changes
  ///
  /// **사용 시나리오 / Use Cases**:
  /// - 교통 지연으로 이동 시간 증가 시
  /// - 대중교통 버스 도착 시간 변경 시
  /// - 지각 위험 발생 시
  Future<void> sendDynamicNotification({
    required Trip trip,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    if (!_initialized) {
      debugPrint('⚠️ NotificationService not initialized, skipping notification');
      return;
    }

    try {
      debugPrint('📢 Sending dynamic notification: $title');

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          priority == NotificationPriority.urgent
              ? 'trip_urgent'
              : 'trip_reminders',
          priority == NotificationPriority.urgent
              ? 'Urgent Reminders'
              : 'Trip Reminders',
          importance: priority == NotificationPriority.urgent
              ? Importance.max
              : Importance.high,
          priority: priority == NotificationPriority.urgent
              ? Priority.max
              : Priority.high,
          icon: '@mipmap/ic_launcher',
          color: priority == NotificationPriority.urgent
              ? Color(0xFFF44336)
              : Color(0xFFFF9800),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: priority == NotificationPriority.urgent
              ? InterruptionLevel.timeSensitive
              : InterruptionLevel.active,
        ),
      );

      await _notifications.show(
        trip.id.hashCode + 2,
        title,
        body,
        notificationDetails,
        payload: trip.id,
      );

      debugPrint('✅ Dynamic notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send dynamic notification: $e');
    }
  }

  /// 특정 일정의 알림 취소 / Cancel notifications for a specific trip
  Future<void> cancelNotifications(Trip trip) async {
    try {
      debugPrint('🔕 Cancelling notifications for trip: ${trip.title}');

      // 30분 알림 취소
      await _notifications.cancel(trip.id.hashCode);

      // 10분 알림 취소
      await _notifications.cancel(trip.id.hashCode + 1);

      // 동적 알림 취소
      await _notifications.cancel(trip.id.hashCode + 2);

      debugPrint('✅ Notifications cancelled for trip: ${trip.title}');
    } catch (e) {
      debugPrint('❌ Failed to cancel notifications: $e');
    }
  }

  /// 모든 알림 취소 / Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      debugPrint('🔕 Cancelling all notifications');

      await _notifications.cancelAll();

      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel all notifications: $e');
    }
  }

  /// 예약된 알림 목록 조회 / Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();

      debugPrint('📋 Pending notifications: ${pendingNotifications.length}');

      return pendingNotifications;
    } catch (e) {
      debugPrint('❌ Failed to get pending notifications: $e');
      return [];
    }
  }

  /// 알림 권한 확인 / Check notification permission
  Future<bool> hasPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      return await plugin?.areNotificationsEnabled() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final plugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  /// 알림 권한 요청 / Request notification permission
  Future<bool> requestPermission() async {
    try {
      debugPrint('🔔 Requesting notification permission');

      if (defaultTargetPlatform == TargetPlatform.android) {
        final plugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        final granted = await plugin?.requestNotificationsPermission();

        debugPrint(
            '${granted == true ? '✅' : '❌'} Android notification permission: $granted');
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final plugin = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        final granted = await plugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint(
            '${granted == true ? '✅' : '❌'} iOS notification permission: $granted');
        return granted ?? false;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Failed to request notification permission: $e');
      return false;
    }
  }

  /// 디버그 정보 / Debug info
  Future<String> getDebugInfo() async {
    final pending = await getPendingNotifications();
    final hasPermission = await this.hasPermission();

    return '''
🔍 NotificationService Debug Info:
- Initialized: $_initialized
- Platform: ${defaultTargetPlatform.name}
- Permission granted: $hasPermission
- Pending notifications: ${pending.length}
- Pending details: ${pending.map((n) => 'ID: ${n.id}, Title: ${n.title}').join(', ')}
''';
  }
}

/// 알림 우선순위 / Notification priority
enum NotificationPriority {
  normal,
  high,
  urgent,
}
