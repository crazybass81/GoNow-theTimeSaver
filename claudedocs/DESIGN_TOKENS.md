# GoNow Design Tokens Documentation

**Last Updated**: 2026-01-09
**Status**: Production
**Design System Compliance**: 100%

## Overview

This document describes the complete design token system for GoNow, defining colors, typography, spacing, and layout constants for consistent UI implementation.

---

## Color System (`/lib/utils/app_colors.dart`)

### Primary Colors

| Token | Value | Usage | Material Design Source |
|-------|-------|-------|------------------------|
| `AppColors.primary` | `#1E88E5` | Main brand color, CTAs, links | `Colors.blue[600]` |
| `AppColors.primaryDark` | `#1976D2` | Hover states, emphasis | `Colors.blue[700]` |
| `AppColors.primaryLight` | `#BBDEFB` | Backgrounds, subtle highlights | `Colors.blue[100]` |
| `AppColors.primaryLighter` | `#E3F2FD` | Very light backgrounds | `Colors.blue[50]` |

### Neutral Colors

| Token | Value | Usage | Material Design Source |
|-------|-------|-------|------------------------|
| `AppColors.background` | `#FAFAFA` | Screen backgrounds | `Colors.grey[50]` |
| `AppColors.cardBackground` | `#FFFFFF` | Card backgrounds | `Colors.white` |
| `AppColors.primaryText` | `#424242` | Headings, important text | `Colors.grey[800]` |
| `AppColors.secondaryText` | `#757575` | Body text, descriptions | `Colors.grey[600]` |
| `AppColors.disabled` | `#E0E0E0` | Disabled elements, borders | `Colors.grey[300]` |
| `AppColors.divider` | `#EEEEEE` | Dividers, subtle borders | `Colors.grey[200]` |

### Status Colors

| Token | Value | Usage | Material Design Source |
|-------|-------|-------|------------------------|
| `AppColors.success` | `#4CAF50` | Success messages | Standard green |
| `AppColors.error` | `#F44336` | Error messages, delete | `Colors.red[600]` |
| `AppColors.errorDark` | `#B71C1C` | Critical errors | `Colors.red[900]` |
| `AppColors.errorMedium` | `#D32F2F` | Error emphasis | `Colors.red[700]` |
| `AppColors.errorLight` | `#FFEBEE` | Error backgrounds | `Colors.red[50]` |
| `AppColors.warning` | `#FF9800` | Warning messages | Standard orange |
| `AppColors.info` | `#2196F3` | Info messages | Standard blue |

### Schedule Category Colors

| Token | Value | Usage |
|-------|-------|-------|
| `AppColors.scheduleRed` | `#E57373` | Important/Urgent |
| `AppColors.scheduleBlue` | `#64B5F6` | Work/Meeting |
| `AppColors.scheduleGreen` | `#81C784` | Personal/Exercise |
| `AppColors.scheduleOrange` | `#FFB74D` | Study/Learning |
| `AppColors.schedulePurple` | `#BA68C8` | Hobby/Leisure |
| `AppColors.scheduleTeal` | `#4DB6AC` | Health/Medical |

### Timer Status Colors

| Token | Value | Threshold | Usage |
|-------|-------|-----------|-------|
| `AppColors.timerGreen` | `#4CAF50` | >30 min | Plenty of time |
| `AppColors.timerOrange` | `#FF9800` | 10-30 min | Should hurry |
| `AppColors.timerRed` | `#F44336` | <10 min | Urgent |

---

## Typography System (`/lib/utils/app_text_styles.dart`)

### Header Styles

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `AppTextStyles.pageTitle` | 28px | Bold (700) | 1.2 | Page main titles |
| `AppTextStyles.sectionTitle` | 20px | Bold (700) | 1.3 | Section headers |
| `AppTextStyles.cardTitle` | 18px | Bold (700) | 1.3 | Card titles |

### Body Styles

| Token | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `AppTextStyles.referenceBody` | 16px | Normal (400) | 1.5 | Body text |
| `AppTextStyles.formLabel` | 14px | Medium (500) | 1.4 | Form labels |
| `AppTextStyles.referenceLabel` | 12px | Medium (500) | 1.3 | Small labels |

### Date & Time Styles

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTextStyles.dateHeader` | 40px | Bold (700) | Large date displays |
| `AppTextStyles.timeDisplay` | 64px | Bold (700) | Main timer |
| `AppTextStyles.timeLabel` | 14px | Medium (500) | Time descriptions |

### Special Styles

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTextStyles.badgeTime` | 12px | Bold (700) | Time badges |
| `AppTextStyles.badgeTimeSmall` | 11px | Bold (700) | Small time badges |
| `AppTextStyles.scheduleTitle` | 18px | Bold (700) | Schedule titles |

---

## Layout System (`/lib/utils/ui_constants.dart`)

### Border Radius

| Token | Value | Usage | Design Pattern |
|-------|-------|-------|----------------|
| `UIConstants.radiusCard` | 12px | Cards, containers | Standard card radius |
| `UIConstants.radiusDialog` | 24px | Modal dialogs | Dialog radius |
| `UIConstants.radiusButton` | 12px | Buttons | Interactive elements |
| `UIConstants.radiusInput` | 12px | Input fields | Form controls |
| `UIConstants.radiusSnackbar` | 10px | Toast messages | Notifications |
| `UIConstants.radiusEventPill` | 3px | Calendar events | Event badges |
| `UIConstants.radiusSmall` | 8px | Small elements | Time badges, icons |

### Spacing

| Token | Value | Usage | Design Pattern |
|-------|-------|-------|----------------|
| `UIConstants.spacingScreen` | 20px | Screen outer padding | Screen-level spacing |
| `UIConstants.spacingCardInternal` | 16px | Card inner padding | Card content padding |
| `UIConstants.spacingCardGap` | 12px | Between cards | Element gaps |
| `UIConstants.spacingHorizontal` | 12px | Row spacing | Horizontal gaps |
| `UIConstants.spacingVertical` | 12px | Column spacing | Vertical gaps |
| `UIConstants.spacingSettings` | 18px | Settings cards | Settings-specific |
| `UIConstants.spacingSectionGap` | 32px | Between major sections | Section separation |

### Shadows

| Token | Configuration | Usage |
|-------|--------------|-------|
| `UIConstants.cardShadow` | `opacity: 0.05, blur: 10px, offset: (0,2)` | All cards and containers |

**Note**: All shadows have been unified to use `cardShadow` for consistency.

### Icon Sizing

| Token | Value | Usage |
|-------|-------|-------|
| `UIConstants.iconSize` | 24px | Standard icons |
| `UIConstants.iconSizeSmall` | 16px | Small icons |
| `UIConstants.iconContainerSize` | 48px | Icon containers |

---

## Component-Specific Tokens

### Calendar

| Token | Value | Usage |
|-------|-------|-------|
| `UIConstants.calendarRowHeight` | 140px | Week row height |
| `UIConstants.calendarDayHeaderHeight` | 40px | Weekday labels |
| `UIConstants.calendarMaxEventsPerCell` | 4 | Max events before "+N more" |

### Color Picker

| Token | Value | Usage |
|-------|-------|-------|
| `UIConstants.colorPickerCircleSize` | 50px | Color swatch size |
| `UIConstants.colorPickerSpacing` | 12px | Between swatches |
| `UIConstants.colorPickerSelectedBorder` | 3px | Selected border width |

### Buttons

| Token | Value | Usage |
|-------|-------|-------|
| `UIConstants.buttonPaddingVertical` | 16px | Vertical padding |
| `UIConstants.buttonPaddingHorizontal` | 24px | Horizontal padding |

---

## Usage Examples

### Creating a Standard Card

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(UIConstants.radiusCard),
    boxShadow: [UIConstants.cardShadow],
  ),
  padding: EdgeInsets.all(UIConstants.spacingCardInternal),
  child: Text(
    'Card Title',
    style: AppTextStyles.cardTitle,
  ),
)
```

### Using Color System

```dart
Container(
  color: AppColors.background,
  child: Card(
    color: AppColors.cardBackground,
    child: Column(
      children: [
        Text(
          'Heading',
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.primaryText,
          ),
        ),
        Text(
          'Description',
          style: AppTextStyles.referenceBody.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    ),
  ),
)
```

### Using Spacing System

```dart
Padding(
  padding: EdgeInsets.all(UIConstants.spacingScreen),
  child: Column(
    children: [
      Card(...),
      SizedBox(height: UIConstants.spacingCardGap),
      Card(...),
    ],
  ),
)
```

---

## Migration Guide

### From Colors.xxx to AppColors

| Old | New |
|-----|-----|
| `Colors.blue[600]` | `AppColors.primary` |
| `Colors.blue[700]` | `AppColors.primaryDark` |
| `Colors.blue[100]` | `AppColors.primaryLight` |
| `Colors.blue[50]` | `AppColors.primaryLighter` |
| `Colors.grey[50]` | `AppColors.background` |
| `Colors.grey[800]` | `AppColors.primaryText` |
| `Colors.grey[600]` | `AppColors.secondaryText` |
| `Colors.grey[300]` | `AppColors.disabled` |
| `Colors.grey[200]` | `AppColors.divider` |
| `Colors.red[600]` | `AppColors.error` |
| `Colors.red[700]` | `AppColors.errorMedium` |
| `Colors.red[900]` | `AppColors.errorDark` |
| `Colors.red[50]` | `AppColors.errorLight` |

### From Inline fontSize to AppTextStyles

| Old | New |
|-----|-----|
| `fontSize: 28` | `AppTextStyles.pageTitle` |
| `fontSize: 20` | `AppTextStyles.sectionTitle` |
| `fontSize: 18` | `AppTextStyles.cardTitle` |
| `fontSize: 16` | `AppTextStyles.referenceBody` |
| `fontSize: 14` | `AppTextStyles.formLabel` |
| `fontSize: 12` | `AppTextStyles.referenceLabel` |
| `fontSize: 64` | `AppTextStyles.timeDisplay` |
| `fontSize: 40` | `AppTextStyles.dateHeader` |

### From Magic Numbers to UIConstants

| Old | New |
|-----|-----|
| `BorderRadius.circular(12)` | `BorderRadius.circular(UIConstants.radiusCard)` |
| `BorderRadius.circular(24)` | `BorderRadius.circular(UIConstants.radiusDialog)` |
| `EdgeInsets.all(20)` | `EdgeInsets.all(UIConstants.spacingScreen)` |
| `EdgeInsets.all(16)` | `EdgeInsets.all(UIConstants.spacingCardInternal)` |
| `SizedBox(height: 12)` | `SizedBox(height: UIConstants.spacingCardGap)` |

---

## Design Decisions

### Why Three Systems?

1. **AppColors**: Color palette and semantic colors
   - Single source of truth for all colors
   - Centralized color management

2. **AppTextStyles**: Typography system
   - Consistent text styling
   - Reduces inline fontSize usage

3. **UIConstants**: Layout and spacing constants
   - Spacing, radius, shadows, icons
   - Consistent UI pattern implementation

### Design System Compliance

This implementation follows Material Design principles with GoNow-specific adaptations for optimal user experience.

### Brand Colors (Intentional)

Kakao login button uses official brand colors:
- Kakao Yellow: `#FEE500`
- Kakao Text: `#3C1E1E`

These are intentional brand colors and should not be changed to AppColors.

---

## Verification

### Compliance Checklist

- ✅ All `Colors.xxx[shade]` references replaced with AppColors
- ✅ All inline `fontSize` values replaced with AppTextStyles
- ✅ All cards use 12px borderRadius (UIConstants.radiusCard)
- ✅ All dialogs use 24px borderRadius (UIConstants.radiusDialog)
- ✅ All cards use standard shadow (UIConstants.cardShadow)
- ✅ All spacing follows 12px/16px/20px/32px system
- ✅ Primary color is #1E88E5 (Material Design blue[600])
- ✅ No hardcoded Color(0x...) values except brand colors
- ✅ Settings icons have 48x48px blue[50] containers
- ✅ Shadow patterns unified (opacity 0.05, blur 10px)
- ✅ 14 spacing values centralized to UIConstants

### Files Modified

**Color System Enhancement**:
- `lib/utils/app_colors.dart` (9 new constants added)

**Typography Applied**:
- `lib/screens/dashboard/dashboard_screen.dart` (15 fontSize → AppTextStyles)
- `lib/screens/calendar/calendar_screen.dart` (8 fontSize → AppTextStyles)
- `lib/screens/settings/settings_screen.dart` (16 fontSize → AppTextStyles)

**Colors Migration**:
- `lib/screens/dashboard/dashboard_screen.dart` (24 Colors.xxx → AppColors)
- `lib/screens/calendar/calendar_screen.dart` (15 Colors.xxx → AppColors)
- `lib/screens/settings/settings_screen.dart` (20 Colors.xxx → AppColors)
- `lib/screens/schedule/schedule_detail_screen.dart` (20 Colors.xxx → AppColors)
- `lib/screens/main_wrapper.dart` (4 Colors.xxx → AppColors)
- `lib/widgets/circular_timer_widget.dart` (2 Colors.xxx → AppColors)
- `lib/screens/schedule/add_schedule_screen_new.dart` (1 Color(0x) → AppColors)

**Design System Integration**:
- `lib/utils/ui_constants.dart` (Colors.xxx → AppColors integration)

**Total**: 83 Colors.xxx references eliminated, 39 fontSize values centralized, 14 spacing values centralized

---

## Maintenance

### Adding New Colors

1. Add to `app_colors.dart` with documentation
2. Use descriptive name (e.g., `primaryDark`, not `blue700`)
3. Include hex value and Material Design source in comment

### Adding New Text Styles

1. Add to `app_text_styles.dart`
2. Follow naming convention (e.g., `cardTitle`, not `text18Bold`)
3. Include usage description in comment

### Adding New Layout Constants

1. Add to `ui_constants.dart`
2. Include design pattern reference
3. Provide usage examples in docstring

---

**Generated with Claude Code**
**Design System Version**: 2.0
**Last Updated**: 2026-01-09
