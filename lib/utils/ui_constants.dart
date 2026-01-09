import 'package:flutter/material.dart';
import 'app_colors.dart';

/// UI Design System Constants / UI 디자인 시스템 상수
///
/// **Purpose**: Centralized design tokens for visual consistency
/// **목적**: 모든 화면과 컴포넌트의 시각적 일관성을 보장하는 중앙화된 디자인 토큰
///
/// **Reference**: Design patterns based on modern UI best practices
/// **참고**: 현대적인 UI 모범 사례 기반 디자인 패턴
///
/// **Usage / 사용법**:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(UIConstants.radiusCard),
///     boxShadow: [UIConstants.cardShadow],
///   ),
/// )
/// ```
class UIConstants {
  // Private constructor to prevent instantiation
  // 인스턴스 생성 방지를 위한 private 생성자
  UIConstants._();

  // ═══════════════════════════════════════════════════════════════
  // Border Radius Standards / 테두리 반경 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Cards**: Main content cards, containers, and panels
  /// **카드**: 메인 콘텐츠 카드, 컨테이너, 패널
  /// **Pattern**: 12px radius for all card-like components
  static const double radiusCard = 12.0;

  /// **Dialogs**: Modal dialogs, popup windows, and overlays
  /// **다이얼로그**: 모달 다이얼로그, 팝업 창, 오버레이
  /// **Pattern**: 24px radius for modal components
  static const double radiusDialog = 24.0;

  /// **Snackbars**: Toast messages and notifications
  /// **스낵바**: 토스트 메시지 및 알림
  /// **Pattern**: 10px radius for transient messages
  static const double radiusSnackbar = 10.0;

  /// **Buttons**: All button types (elevated, outlined, text)
  /// **버튼**: 모든 버튼 타입 (elevated, outlined, text)
  /// **Pattern**: 12px radius for interactive buttons
  static const double radiusButton = 12.0;

  /// **Input Fields**: Text inputs, dropdowns, and form controls
  /// **입력 필드**: 텍스트 입력, 드롭다운, 폼 컨트롤
  /// **Pattern**: 12px radius for input components
  static const double radiusInput = 12.0;

  /// **Event Pills**: Small badge-like components (calendar events, tags)
  /// **이벤트 필**: 작은 뱃지형 컴포넌트 (캘린더 이벤트, 태그)
  /// **Pattern**: 3px radius for inline badges
  static const double radiusEventPill = 3.0;

  /// **Small Elements**: Time badges, icon containers, nested info boxes
  /// **작은 요소**: 시간 뱃지, 아이콘 컨테이너, 중첩된 정보 박스
  /// **Pattern**: 8px radius for small UI elements
  static const double radiusSmall = 8.0;

  // ═══════════════════════════════════════════════════════════════
  // Spacing Standards / 간격 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Screen Padding**: Outer padding around screen content
  /// **화면 패딩**: 화면 콘텐츠 주변 외부 패딩
  /// **Pattern**: 20px for screen-level spacing
  static const double spacingScreen = 20.0;

  /// **Card Internal Padding**: Inside padding for cards and containers
  /// **카드 내부 패딩**: 카드 및 컨테이너 내부 패딩
  /// **Pattern**: 16px for card content padding
  static const double spacingCardInternal = 16.0;

  /// **Card Gaps**: Spacing between cards and major sections
  /// **카드 간격**: 카드 및 주요 섹션 간 간격
  /// **Pattern**: 12px gaps between elements
  static const double spacingCardGap = 12.0;

  /// **Horizontal Spacing**: Gaps between horizontal elements
  /// **수평 간격**: 수평 요소 간 간격
  /// **Pattern**: 12px for row spacing
  static const double spacingHorizontal = 12.0;

  /// **Vertical Spacing**: Gaps between vertical elements
  /// **수직 간격**: 수직 요소 간 간격
  /// **Pattern**: 12px for column spacing
  static const double spacingVertical = 12.0;

  /// **Settings Card Padding**: Special padding for settings cards
  /// **설정 카드 패딩**: 설정 화면 카드를 위한 특별 패딩
  /// **Pattern**: 18px for settings screen cards
  static const double spacingSettings = 18.0;

  /// **Section Gaps**: Large spacing between major sections
  /// **섹션 간격**: 주요 섹션 간 큰 간격
  /// **Pattern**: 32px for spacing between major section cards
  static const double spacingSectionGap = 32.0;

  // ═══════════════════════════════════════════════════════════════
  // Shadow Standards / 그림자 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Card Shadow**: Standard elevation shadow for cards
  /// **카드 그림자**: 카드를 위한 표준 elevation 그림자
  /// **Pattern**: Subtle shadow with 0.05 opacity, 10px blur, (0,2) offset
  ///
  /// **Usage / 사용법**:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     boxShadow: [UIConstants.cardShadow],
  ///   ),
  /// )
  /// ```
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      );

  /// **Reference Shadow**: Alternative shadow for special components
  /// **참조 그림자**: 특수 컴포넌트를 위한 대안 그림자
  /// **Pattern**: Very subtle shadow with 0.04 opacity, 8px blur
  static BoxShadow get referenceShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  // ═══════════════════════════════════════════════════════════════
  // Typography Standards / 타이포그래피 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Large Headers**: Page titles and major section headers
  /// **큰 헤더**: 페이지 제목 및 주요 섹션 헤더
  /// **Pattern**: 28px bold text
  static const double fontSizeHeaderLarge = 28.0;

  /// **Medium Headers**: Section titles
  /// **중간 헤더**: 섹션 제목
  /// **Pattern**: 20px bold text
  static const double fontSizeHeaderMedium = 20.0;

  /// **Section Labels**: Small section labels and tags
  /// **섹션 레이블**: 작은 섹션 레이블 및 태그
  /// **Pattern**: 12px text
  static const double fontSizeLabel = 12.0;

  /// **Content Text**: Body text and descriptions
  /// **콘텐츠 텍스트**: 본문 텍스트 및 설명
  /// **Pattern**: 16px text
  static const double fontSizeContent = 16.0;

  /// **Small Text**: Badges, timestamps, and minor labels
  /// **작은 텍스트**: 뱃지, 타임스탬프, 부차적 레이블
  /// **Pattern**: 10-11px text
  static const double fontSizeSmall = 11.0;

  /// **Event Pills**: Text inside calendar event badges
  /// **이벤트 필**: 캘린더 이벤트 뱃지 내부 텍스트
  /// **Pattern**: 11px text
  static const double fontSizeEventPill = 11.0;

  // ═══════════════════════════════════════════════════════════════
  // Icon Standards / 아이콘 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Standard Icon Size**: Default icon dimensions
  /// **표준 아이콘 크기**: 기본 아이콘 크기
  /// **Pattern**: 24x24px icons
  static const double iconSize = 24.0;

  /// **Icon Container**: Container size for icon backgrounds
  /// **아이콘 컨테이너**: 아이콘 배경을 위한 컨테이너 크기
  /// **Pattern**: 48x48px containers with light blue background
  static const double iconContainerSize = 48.0;

  /// **Small Icon Size**: Compact icons for tight spaces
  /// **작은 아이콘 크기**: 좁은 공간을 위한 컴팩트 아이콘
  /// **Pattern**: 16px icons
  static const double iconSizeSmall = 16.0;

  // ═══════════════════════════════════════════════════════════════
  // Color Standards / 색상 표준
  // ═══════════════════════════════════════════════════════════════

  /// **Primary Color**: Main brand color for CTAs and highlights
  /// **주요 색상**: CTA 및 강조를 위한 메인 브랜드 색상
  /// **Pattern**: blue[600] - #1E88E5
  static Color get primaryColor => AppColors.primary;

  /// **Border Color (Enabled)**: Default border for inputs and cards
  /// **테두리 색상 (활성)**: 입력 및 카드를 위한 기본 테두리
  /// **Pattern**: grey[300] - #E0E0E0
  static Color get borderColorEnabled => AppColors.disabled;

  /// **Border Color (Focused)**: Active/focused state border
  /// **테두리 색상 (포커스)**: 활성/포커스 상태 테두리
  /// **Pattern**: blue[600] with 2px width
  static Color get borderColorFocused => AppColors.primary;

  /// **Background (Screen)**: Main screen background
  /// **배경 (화면)**: 메인 화면 배경
  /// **Pattern**: grey[50] - #FAFAFA
  static Color get backgroundScreen => AppColors.background;

  /// **Background (Card)**: Card and container background
  /// **배경 (카드)**: 카드 및 컨테이너 배경
  /// **Pattern**: white - #FFFFFF
  static const Color backgroundCard = AppColors.cardBackground;

  /// **Icon Container Background**: Light background for icon containers
  /// **아이콘 컨테이너 배경**: 아이콘 컨테이너를 위한 밝은 배경
  /// **Pattern**: blue[50] - #E3F2FD
  static Color get iconContainerBackground => AppColors.primaryLighter;

  /// **Destructive Color**: Delete buttons and warnings
  /// **파괴적 색상**: 삭제 버튼 및 경고
  /// **Pattern**: red[600] - #E53935
  static Color get destructiveColor => AppColors.error;

  /// **Neutral Color**: Secondary text and subtle elements
  /// **중립 색상**: 보조 텍스트 및 미묘한 요소
  /// **Pattern**: grey[600] - #757575
  static Color get neutralColor => AppColors.secondaryText;

  // ═══════════════════════════════════════════════════════════════
  // Component-Specific Patterns / 컴포넌트별 패턴
  // ═══════════════════════════════════════════════════════════════

  /// **Color Picker Circle Size**: Circular color swatch dimensions
  /// **색상 선택기 원 크기**: 원형 색상 견본 크기
  /// **Pattern**: 50x50px circles with 12px spacing
  static const double colorPickerCircleSize = 50.0;

  /// **Color Picker Spacing**: Gaps between color swatches
  /// **색상 선택기 간격**: 색상 견본 간 간격
  /// **Pattern**: 12px horizontal and vertical spacing
  static const double colorPickerSpacing = 12.0;

  /// **Color Picker Selected Border**: Border width for selected color
  /// **색상 선택기 선택 테두리**: 선택된 색상의 테두리 너비
  /// **Pattern**: 3px black border with checkmark icon
  static const double colorPickerSelectedBorder = 3.0;

  /// **Input Border (Enabled)**: Default input field border configuration
  /// **입력 테두리 (활성)**: 기본 입력 필드 테두리 설정
  /// **Pattern**: 12px radius, grey[300] color, 1px width
  static OutlineInputBorder get inputBorderEnabled => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusInput),
        borderSide: BorderSide(
          color: borderColorEnabled,
          width: 1.0,
        ),
      );

  /// **Input Border (Focused)**: Focused input field border configuration
  /// **입력 테두리 (포커스)**: 포커스 입력 필드 테두리 설정
  /// **Pattern**: 12px radius, blue[600] color, 2px width
  static OutlineInputBorder get inputBorderFocused => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusInput),
        borderSide: BorderSide(
          color: borderColorFocused,
          width: 2.0,
        ),
      );

  /// **Calendar Row Height**: Height of each calendar week row
  /// **캘린더 행 높이**: 각 캘린더 주 행의 높이
  /// **Pattern**: 140px to accommodate event pills
  static const double calendarRowHeight = 140.0;

  /// **Calendar Day Header Height**: Height of weekday labels
  /// **캘린더 일자 헤더 높이**: 요일 레이블의 높이
  /// **Pattern**: 40px
  static const double calendarDayHeaderHeight = 40.0;

  /// **Calendar Max Events Per Cell**: Maximum event pills shown per day
  /// **캘린더 셀당 최대 이벤트**: 하루당 표시되는 최대 이벤트 필 개수
  /// **Pattern**: 4 events, then "+N more" indicator
  static const int calendarMaxEventsPerCell = 4;

  // ═══════════════════════════════════════════════════════════════
  // Button Patterns / 버튼 패턴
  // ═══════════════════════════════════════════════════════════════

  /// **Button Vertical Padding**: Internal vertical padding for buttons
  /// **버튼 수직 패딩**: 버튼의 내부 수직 패딩
  /// **Pattern**: 16px vertical padding
  static const double buttonPaddingVertical = 16.0;

  /// **Button Horizontal Padding**: Internal horizontal padding for buttons
  /// **버튼 수평 패딩**: 버튼의 내부 수평 패딩
  /// **Pattern**: 24px horizontal padding
  static const double buttonPaddingHorizontal = 24.0;

  // ═══════════════════════════════════════════════════════════════
  // Utility Methods / 유틸리티 메서드
  // ═══════════════════════════════════════════════════════════════

  /// **Get Card Decoration**: Complete BoxDecoration for standard cards
  /// **카드 장식 가져오기**: 표준 카드를 위한 완전한 BoxDecoration
  ///
  /// **Usage / 사용법**:
  /// ```dart
  /// Container(
  ///   decoration: UIConstants.cardDecoration,
  ///   child: ...,
  /// )
  /// ```
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: backgroundCard,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: borderColorEnabled, width: 1),
        boxShadow: [cardShadow],
      );

  /// **Get Dialog Decoration**: Complete ShapeBorder for dialogs
  /// **다이얼로그 장식 가져오기**: 다이얼로그를 위한 완전한 ShapeBorder
  ///
  /// **Usage / 사용법**:
  /// ```dart
  /// showDialog(
  ///   builder: (context) => AlertDialog(
  ///     shape: UIConstants.dialogShape,
  ///     ...
  ///   ),
  /// )
  /// ```
  static ShapeBorder get dialogShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusDialog),
      );

  /// **Get Button Style**: Complete ButtonStyle for ElevatedButton
  /// **버튼 스타일 가져오기**: ElevatedButton을 위한 완전한 ButtonStyle
  ///
  /// **Usage / 사용법**:
  /// ```dart
  /// ElevatedButton(
  ///   style: UIConstants.primaryButtonStyle,
  ///   child: Text('Save'),
  ///   onPressed: () {},
  /// )
  /// ```
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: buttonPaddingVertical,
          horizontal: buttonPaddingHorizontal,
        ),
      );
}
