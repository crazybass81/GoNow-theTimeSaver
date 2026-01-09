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
  // 참조 저장소 기본 색상 / Reference repository base colors
  // ========================================

  /// 배경 색상 / Background color (reference: Colors.grey[50])
  static const Color background = Color(0xFFFAFAFA); // grey[50]

  /// 카드 배경 / Card background
  static const Color cardBackground = Colors.white;

  /// 주 색상 / Primary color (reference: Colors.blue[600])
  static const Color primary = Color(0xFF1E88E5); // blue[600]

  /// 주 색상 어두운 버전 / Primary color dark (reference: Colors.blue[700])
  static const Color primaryDark = Color(0xFF1976D2); // blue[700]

  /// 주 색상 밝은 버전 / Primary color light (reference: Colors.blue[100])
  static const Color primaryLight = Color(0xFFBBDEFB); // blue[100]

  /// 주 색상 매우 밝은 버전 / Primary color very light (reference: Colors.blue[50])
  static const Color primaryLighter = Color(0xFFE3F2FD); // blue[50]

  /// 주 텍스트 색상 / Primary text color (reference: Colors.grey[800])
  static const Color primaryText = Color(0xFF424242); // grey[800]

  /// 보조 텍스트 색상 / Secondary text color (reference: Colors.grey[600])
  static const Color secondaryText = Color(0xFF757575); // grey[600]

  /// 비활성 텍스트/아이콘 / Disabled text/icon (reference: Colors.grey[300])
  static const Color disabled = Color(0xFFE0E0E0); // grey[300]

  /// 구분선/테두리 / Divider/border (reference: Colors.grey[200])
  static const Color divider = Color(0xFFEEEEEE); // grey[200]

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
  // Material Design 그림자 / Material shadows (Reference pattern)
  // ========================================

  /// 기본 그림자 / Default shadow (reference: blurRadius 10, opacity 0.05)
  static List<BoxShadow> get referenceShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 카드 기본 그림자 / Default card shadow
  /// **참조 저장소 패턴 적용 / Reference repository pattern**
  static List<BoxShadow> cardShadow(Color baseColor) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 카드 강조 그림자 / Elevated card shadow (for special elements)
  static List<BoxShadow> elevatedCardShadow(Color baseColor) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 원형 타이머 그림자 / Circular timer shadow
  static List<BoxShadow> timerShadow(Color progressColor) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
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

  /// 에러 어두운 버전 / Error dark (reference: Colors.red[900])
  static const Color errorDark = Color(0xFFB71C1C); // red[900]

  /// 에러 중간 버전 / Error medium (reference: Colors.red[700])
  static const Color errorMedium = Color(0xFFD32F2F); // red[700]

  /// 에러 밝은 버전 / Error light (reference: Colors.red[50])
  static const Color errorLight = Color(0xFFFFEBEE); // red[50]

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
