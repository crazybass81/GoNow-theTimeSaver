import 'package:flutter/material.dart';

/// 앱 전체 색상 시스템 / App-wide color system
///
/// **기능 / Features**:
/// - 일정 카테고리 색상 (참조 저장소 패턴)
/// - Material Design 3 호환 그림자
/// - 일관된 색상 관리
///
/// **Context**: 참조 저장소 https://github.com/khyapple/go_now 패턴 적용
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ========================================
  // 일정 카테고리 색상 / Schedule category colors
  // ========================================

  /// 빨강 - 중요/긴급 일정 / Red - Important/Urgent
  static const Color scheduleRed = Color(0xFFE57373);

  /// 파랑 - 업무/회의 / Blue - Work/Meeting
  static const Color scheduleBlue = Color(0xFF64B5F6);

  /// 초록 - 개인/운동 / Green - Personal/Exercise
  static const Color scheduleGreen = Color(0xFF81C784);

  /// 주황 - 학습/공부 / Orange - Study/Learning
  static const Color scheduleOrange = Color(0xFFFFB74D);

  /// 보라 - 취미/여가 / Purple - Hobby/Leisure
  static const Color schedulePurple = Color(0xFFBA68C8);

  /// 청록 - 건강/의료 / Teal - Health/Medical
  static const Color scheduleTeal = Color(0xFF4DB6AC);

  /// 일정 카테고리 색상 맵 / Schedule category color map
  static const Map<String, Color> scheduleColors = {
    'red': scheduleRed,
    'blue': scheduleBlue,
    'green': scheduleGreen,
    'orange': scheduleOrange,
    'purple': schedulePurple,
    'teal': scheduleTeal,
  };

  /// 색상 목록 (피커용) / Color list for picker
  static const List<Color> availableColors = [
    scheduleRed,
    scheduleBlue,
    scheduleGreen,
    scheduleOrange,
    schedulePurple,
    scheduleTeal,
  ];

  // ========================================
  // Material Design 그림자 / Material shadows
  // ========================================

  /// 카드 기본 그림자 / Default card shadow
  static List<BoxShadow> cardShadow(Color baseColor) => [
        BoxShadow(
          color: baseColor.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// 카드 강조 그림자 / Elevated card shadow
  static List<BoxShadow> elevatedCardShadow(Color baseColor) => [
        BoxShadow(
          color: baseColor.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// 원형 타이머 그림자 / Circular timer shadow
  static List<BoxShadow> timerShadow(Color progressColor) => [
        BoxShadow(
          color: progressColor.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 색상 피커 그림자 / Color picker shadow
  static List<BoxShadow> colorSwatchShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ========================================
  // 상태 색상 / Status colors
  // ========================================

  /// 성공 / Success
  static const Color success = Color(0xFF4CAF50);

  /// 경고 / Warning
  static const Color warning = Color(0xFFFF9800);

  /// 에러 / Error
  static const Color error = Color(0xFFF44336);

  /// 정보 / Info
  static const Color info = Color(0xFF2196F3);

  // ========================================
  // 타이머 상태 색상 / Timer status colors
  // ========================================

  /// 여유 시간 (초록) / Plenty of time (Green)
  static const Color timerGreen = Color(0xFF4CAF50);

  /// 적당한 시간 (주황) / Moderate time (Orange)
  static const Color timerOrange = Color(0xFFFF9800);

  /// 긴급 (빨강) / Urgent (Red)
  static const Color timerRed = Color(0xFFF44336);

  // ========================================
  // 헬퍼 메서드 / Helper methods
  // ========================================

  /// 색상 값으로 카테고리 이름 찾기 / Find category name by color value
  static String? getColorName(Color color) {
    for (var entry in scheduleColors.entries) {
      if (entry.value.value == color.value) {
        return entry.key;
      }
    }
    return null;
  }

  /// 카테고리 이름으로 색상 가져오기 / Get color by category name
  static Color getColorByName(String name, {Color fallback = scheduleBlue}) {
    return scheduleColors[name.toLowerCase()] ?? fallback;
  }

  /// 남은 시간에 따른 타이머 색상 / Timer color based on remaining time
  static Color getTimerColor(Duration remaining) {
    final minutes = remaining.inMinutes;
    if (minutes > 30) {
      return timerGreen;
    } else if (minutes > 10) {
      return timerOrange;
    } else {
      return timerRed;
    }
  }
}
