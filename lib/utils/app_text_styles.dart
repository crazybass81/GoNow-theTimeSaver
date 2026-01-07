import 'package:flutter/material.dart';

/// 앱 전체 타이포그래피 시스템 / App-wide typography system
///
/// **기능 / Features**:
/// - 일관된 텍스트 스타일 정의
/// - Material Design 3 호환
/// - 참조 저장소 패턴 적용
///
/// **Context**: 참조 저장소 https://github.com/khyapple/go_now 패턴 적용
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // ========================================
  // 참조 저장소 기본 타이포그래피 / Reference repository typography
  // ========================================

  /// 날짜 헤더 / Date header (reference: 32px, bold)
  /// 예: "2024년 1월 15일 (월)"
  static const TextStyle dateHeader = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// 제목 / Title (reference: 28px, bold)
  /// 예: "회사 미팅", 일정 제목
  static const TextStyle referenceTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// 본문 / Body (reference: 16px, medium)
  /// 예: 일반 텍스트, 설명
  static const TextStyle referenceBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 라벨 / Label (reference: 12px, bold)
  /// 예: "N분 남음", 시간 표시
  static const TextStyle referenceLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ========================================
  // 원형 타이머 텍스트 / Circular timer text
  // ========================================

  /// 타이머 대형 (남은 시간) / Timer large (Remaining time)
  /// 예: "45분 후 출발"
  static const TextStyle timerLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 타이머 중형 (도착 시간) / Timer medium (Arrival time)
  /// 예: "14:30 도착"
  static const TextStyle timerMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  /// 타이머 소형 (서브텍스트) / Timer small (Subtext)
  static const TextStyle timerSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ========================================
  // 일정 카드 텍스트 / Schedule card text
  // ========================================

  /// 일정 제목 / Schedule title (updated to match reference: 28px)
  static const TextStyle scheduleTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  /// 일정 부제목 / Schedule subtitle
  static const TextStyle scheduleSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  /// 일정 설명 / Schedule description
  static const TextStyle scheduleDescription = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ========================================
  // 시간 배지 텍스트 / Time badge text
  // ========================================

  /// 시간 배지 대형 (시간) / Time badge large (Hour)
  static const TextStyle badgeTimeLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  /// 시간 배지 소형 (분) / Time badge small (Minute)
  static const TextStyle badgeTimeSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  // ========================================
  // 버튼 텍스트 / Button text
  // ========================================

  /// 주 버튼 텍스트 / Primary button text
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 보조 버튼 텍스트 / Secondary button text
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // ========================================
  // 섹션 헤더 텍스트 / Section header text
  // ========================================

  /// 섹션 타이틀 / Section title
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 섹션 서브타이틀 / Section subtitle
  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ========================================
  // 폼 필드 텍스트 / Form field text
  // ========================================

  /// 폼 라벨 / Form label
  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 폼 힌트 / Form hint
  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  /// 폼 에러 / Form error
  static const TextStyle formError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // ========================================
  // 네비게이션 텍스트 / Navigation text
  // ========================================

  /// 하단 네비게이션 라벨 / Bottom navigation label
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// 하단 네비게이션 활성 라벨 / Bottom navigation active label
  static const TextStyle navLabelActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ========================================
  // 상태 텍스트 / Status text
  // ========================================

  /// 성공 메시지 / Success message
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 경고 메시지 / Warning message
  static const TextStyle warning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 에러 메시지 / Error message
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ========================================
  // 헬퍼 메서드 / Helper methods
  // ========================================

  /// 색상 적용 / Apply color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 불투명도 적용 / Apply opacity
  static TextStyle withOpacity(TextStyle style, Color baseColor, double opacity) {
    return style.copyWith(color: baseColor.withOpacity(opacity));
  }

  /// Material Design 3 테마와 통합 / Integration with Material Design 3
  static TextTheme getMaterialTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: timerLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: timerMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: timerSmall.copyWith(color: colorScheme.onSurface),

      // Headline styles
      headlineLarge: scheduleTitle.copyWith(color: colorScheme.onSurface),
      headlineMedium: sectionTitle.copyWith(color: colorScheme.onSurface),
      headlineSmall: sectionSubtitle.copyWith(color: colorScheme.onSurface),

      // Title styles
      titleLarge: scheduleTitle.copyWith(color: colorScheme.onSurface),
      titleMedium: scheduleSubtitle.copyWith(color: colorScheme.onSurface),
      titleSmall: formLabel.copyWith(color: colorScheme.onSurface),

      // Body styles
      bodyLarge: scheduleSubtitle.copyWith(color: colorScheme.onSurface),
      bodyMedium: scheduleDescription.copyWith(color: colorScheme.onSurface),
      bodySmall: formHint.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),

      // Label styles
      labelLarge: buttonPrimary.copyWith(color: colorScheme.onPrimary),
      labelMedium: buttonSecondary.copyWith(color: colorScheme.onSurface),
      labelSmall: navLabel.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
    );
  }
}
