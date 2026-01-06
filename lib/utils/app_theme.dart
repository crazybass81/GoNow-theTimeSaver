import 'package:flutter/material.dart';

/// GoNow 앱 테마 정의 / GoNow app theme definition
///
/// **색상 시스템 / Color System**:
/// - 초록(Green): 여유 시간 충분 (30분+ 남음)
/// - 주황(Orange): 경고 단계 (10-30분 남음)
/// - 빨강(Red): 긴급 단계 (10분 미만)
///
/// **Context**: 전체 앱에서 일관된 디자인 적용
class AppTheme {
  // Primary Colors - 시간대별 색상 시스템
  static const Color timeGreen = Color(0xFF4CAF50); // 여유 시간 (충분)
  static const Color timeOrange = Color(0xFFFF9800); // 경고 (서둘러야 함)
  static const Color timeRed = Color(0xFFF44336); // 긴급 (늦음)

  // Brand Colors
  static const Color primaryBlue = Color(0xFF2196F3); // 브랜드 메인 컬러
  static const Color primaryDark = Color(0xFF1976D2); // 어두운 블루

  // Neutral Colors
  static const Color textPrimary = Color(0xFF212121); // 제목, 중요 텍스트
  static const Color textSecondary = Color(0xFF757575); // 부가 설명
  static const Color textHint = Color(0xFFBDBDBD); // 힌트, 플레이스홀더
  static const Color divider = Color(0xFFE0E0E0); // 구분선
  static const Color background = Color(0xFFFAFAFA); // 배경

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // 성공
  static const Color error = Color(0xFFF44336); // 에러
  static const Color warning = Color(0xFFFF9800); // 경고
  static const Color info = Color(0xFF2196F3); // 정보

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: timeOrange,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryBlue, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
    ),

    // Typography
    textTheme: const TextTheme(
      // Headings
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),

      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textHint,
      ),
    ),
  );

  /// 시간 상태에 따른 색상 반환 / Get color based on time status
  ///
  /// @param minutesLeft - 남은 시간 (분)
  /// @returns 시간대별 색상 (초록/주황/빨강)
  static Color getTimeColor(int minutesLeft) {
    if (minutesLeft >= 30) {
      return timeGreen; // 여유
    } else if (minutesLeft >= 10) {
      return timeOrange; // 경고
    } else {
      return timeRed; // 긴급
    }
  }

  /// 시간 상태 메시지 반환 / Get time status message
  ///
  /// @param minutesLeft - 남은 시간 (분)
  /// @returns 시간대별 메시지
  static String getTimeStatusMessage(int minutesLeft) {
    if (minutesLeft >= 30) {
      return '여유 있어요';
    } else if (minutesLeft >= 10) {
      return '서둘러야 해요';
    } else {
      return '지금 출발하세요!';
    }
  }
}
