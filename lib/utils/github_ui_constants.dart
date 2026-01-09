import 'package:flutter/material.dart';
import 'app_colors.dart';

/// GitHub UI Design System Constants
/// GitHub UI 디자인 시스템 상수
///
/// **Reference**: https://github.com/khyapple/go_now
///
/// **Purpose**: Centralized design tokens following GitHub's UI patterns
/// to ensure visual consistency across all screens and components.
///
/// **Usage**:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(GitHubUI.radiusCard),
///     boxShadow: [GitHubUI.cardShadow],
///   ),
/// )
/// ```
class GitHubUI {
  // Private constructor to prevent instantiation
  GitHubUI._();

  // ═══════════════════════════════════════════════════════════════
  // Border Radius Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Cards**: Main content cards, containers, and panels
  /// **GitHub Pattern**: 12px radius for all card-like components
  static const double radiusCard = 12.0;

  /// **Dialogs**: Modal dialogs, popup windows, and overlays
  /// **GitHub Pattern**: 24px radius for modal components
  static const double radiusDialog = 24.0;

  /// **Snackbars**: Toast messages and notifications
  /// **GitHub Pattern**: 10px radius for transient messages
  static const double radiusSnackbar = 10.0;

  /// **Buttons**: All button types (elevated, outlined, text)
  /// **GitHub Pattern**: 12px radius for interactive buttons
  static const double radiusButton = 12.0;

  /// **Input Fields**: Text inputs, dropdowns, and form controls
  /// **GitHub Pattern**: 12px radius for input components
  static const double radiusInput = 12.0;

  /// **Event Pills**: Small badge-like components (calendar events, tags)
  /// **GitHub Pattern**: 3px radius for inline badges
  static const double radiusEventPill = 3.0;

  /// **Small Elements**: Time badges, icon containers, nested info boxes
  /// **GitHub Pattern**: 8px radius for small UI elements
  static const double radiusSmall = 8.0;

  // ═══════════════════════════════════════════════════════════════
  // Spacing Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Screen Padding**: Outer padding around screen content
  /// **GitHub Pattern**: 20px for screen-level spacing
  static const double spacingScreen = 20.0;

  /// **Card Internal Padding**: Inside padding for cards and containers
  /// **GitHub Pattern**: 16px for card content padding
  static const double spacingCardInternal = 16.0;

  /// **Card Gaps**: Spacing between cards and major sections
  /// **GitHub Pattern**: 12px gaps between elements
  static const double spacingCardGap = 12.0;

  /// **Horizontal Spacing**: Gaps between horizontal elements
  /// **GitHub Pattern**: 12px for row spacing
  static const double spacingHorizontal = 12.0;

  /// **Vertical Spacing**: Gaps between vertical elements
  /// **GitHub Pattern**: 12px for column spacing
  static const double spacingVertical = 12.0;

  /// **Settings Card Padding**: Special padding for settings cards
  /// **GitHub Pattern**: 18px for settings screen cards
  static const double spacingSettings = 18.0;

  /// **Section Gaps**: Large spacing between major sections
  /// **GitHub Pattern**: 32px for spacing between major section cards
  static const double spacingSectionGap = 32.0;

  // ═══════════════════════════════════════════════════════════════
  // Shadow Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Card Shadow**: Standard elevation shadow for cards
  /// **GitHub Pattern**: Subtle shadow with 0.05 opacity, 10px blur, (0,2) offset
  ///
  /// **Usage**:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     boxShadow: [GitHubUI.cardShadow],
  ///   ),
  /// )
  /// ```
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      );

  /// **Reference Shadow**: Alternative shadow for special components
  /// **GitHub Pattern**: Very subtle shadow with 0.04 opacity, 8px blur
  static BoxShadow get referenceShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  // ═══════════════════════════════════════════════════════════════
  // Typography Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Large Headers**: Page titles and major section headers
  /// **GitHub Pattern**: 28px bold text
  static const double fontSizeHeaderLarge = 28.0;

  /// **Medium Headers**: Section titles
  /// **GitHub Pattern**: 20px bold text
  static const double fontSizeHeaderMedium = 20.0;

  /// **Section Labels**: Small section labels and tags
  /// **GitHub Pattern**: 12px text
  static const double fontSizeLabel = 12.0;

  /// **Content Text**: Body text and descriptions
  /// **GitHub Pattern**: 16px text
  static const double fontSizeContent = 16.0;

  /// **Small Text**: Badges, timestamps, and minor labels
  /// **GitHub Pattern**: 10-11px text
  static const double fontSizeSmall = 11.0;

  /// **Event Pills**: Text inside calendar event badges
  /// **GitHub Pattern**: 11px text
  static const double fontSizeEventPill = 11.0;

  // ═══════════════════════════════════════════════════════════════
  // Icon Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Standard Icon Size**: Default icon dimensions
  /// **GitHub Pattern**: 24x24px icons
  static const double iconSize = 24.0;

  /// **Icon Container**: Container size for icon backgrounds
  /// **GitHub Pattern**: 48x48px containers with light blue background
  static const double iconContainerSize = 48.0;

  /// **Small Icon Size**: Compact icons for tight spaces
  /// **GitHub Pattern**: 16px icons
  static const double iconSizeSmall = 16.0;

  // ═══════════════════════════════════════════════════════════════
  // Color Standards
  // ═══════════════════════════════════════════════════════════════

  /// **Primary Color**: Main brand color for CTAs and highlights
  /// **GitHub Pattern**: blue[600] - #1E88E5
  static Color get primaryColor => AppColors.primary;

  /// **Border Color (Enabled)**: Default border for inputs and cards
  /// **GitHub Pattern**: grey[300] - #E0E0E0
  static Color get borderColorEnabled => AppColors.disabled;

  /// **Border Color (Focused)**: Active/focused state border
  /// **GitHub Pattern**: blue[600] with 2px width
  static Color get borderColorFocused => AppColors.primary;

  /// **Background (Screen)**: Main screen background
  /// **GitHub Pattern**: grey[50] - #FAFAFA
  static Color get backgroundScreen => AppColors.background;

  /// **Background (Card)**: Card and container background
  /// **GitHub Pattern**: white - #FFFFFF
  static const Color backgroundCard = AppColors.cardBackground;

  /// **Icon Container Background**: Light background for icon containers
  /// **GitHub Pattern**: blue[50] - #E3F2FD
  static Color get iconContainerBackground => AppColors.primaryLighter;

  /// **Destructive Color**: Delete buttons and warnings
  /// **GitHub Pattern**: red[600] - #E53935
  static Color get destructiveColor => AppColors.error;

  /// **Neutral Color**: Secondary text and subtle elements
  /// **GitHub Pattern**: grey[600] - #757575
  static Color get neutralColor => AppColors.secondaryText;

  // ═══════════════════════════════════════════════════════════════
  // Component-Specific Patterns
  // ═══════════════════════════════════════════════════════════════

  /// **Color Picker Circle Size**: Circular color swatch dimensions
  /// **GitHub Pattern**: 50x50px circles with 12px spacing
  static const double colorPickerCircleSize = 50.0;

  /// **Color Picker Spacing**: Gaps between color swatches
  /// **GitHub Pattern**: 12px horizontal and vertical spacing
  static const double colorPickerSpacing = 12.0;

  /// **Color Picker Selected Border**: Border width for selected color
  /// **GitHub Pattern**: 3px black border with checkmark icon
  static const double colorPickerSelectedBorder = 3.0;

  /// **Input Border (Enabled)**: Default input field border configuration
  /// **GitHub Pattern**: 12px radius, grey[300] color, 1px width
  static OutlineInputBorder get inputBorderEnabled => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusInput),
        borderSide: BorderSide(
          color: borderColorEnabled,
          width: 1.0,
        ),
      );

  /// **Input Border (Focused)**: Focused input field border configuration
  /// **GitHub Pattern**: 12px radius, blue[600] color, 2px width
  static OutlineInputBorder get inputBorderFocused => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusInput),
        borderSide: BorderSide(
          color: borderColorFocused,
          width: 2.0,
        ),
      );

  /// **Calendar Row Height**: Height of each calendar week row
  /// **GitHub Pattern**: 140px to accommodate event pills
  static const double calendarRowHeight = 140.0;

  /// **Calendar Day Header Height**: Height of weekday labels
  /// **GitHub Pattern**: 40px
  static const double calendarDayHeaderHeight = 40.0;

  /// **Calendar Max Events Per Cell**: Maximum event pills shown per day
  /// **GitHub Pattern**: 4 events, then "+N more" indicator
  static const int calendarMaxEventsPerCell = 4;

  // ═══════════════════════════════════════════════════════════════
  // Button Patterns
  // ═══════════════════════════════════════════════════════════════

  /// **Button Vertical Padding**: Internal vertical padding for buttons
  /// **GitHub Pattern**: 16px vertical padding
  static const double buttonPaddingVertical = 16.0;

  /// **Button Horizontal Padding**: Internal horizontal padding for buttons
  /// **GitHub Pattern**: 24px horizontal padding
  static const double buttonPaddingHorizontal = 24.0;

  // ═══════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════

  /// **Get Card Decoration**: Complete BoxDecoration for standard cards
  ///
  /// **Usage**:
  /// ```dart
  /// Container(
  ///   decoration: GitHubUI.cardDecoration,
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
  ///
  /// **Usage**:
  /// ```dart
  /// showDialog(
  ///   builder: (context) => AlertDialog(
  ///     shape: GitHubUI.dialogShape,
  ///     ...
  ///   ),
  /// )
  /// ```
  static ShapeBorder get dialogShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusDialog),
      );

  /// **Get Button Style**: Complete ButtonStyle for ElevatedButton
  ///
  /// **Usage**:
  /// ```dart
  /// ElevatedButton(
  ///   style: GitHubUI.primaryButtonStyle,
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
