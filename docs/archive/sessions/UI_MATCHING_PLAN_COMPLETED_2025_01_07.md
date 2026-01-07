# UI Matching Implementation Plan

**Date**: 2026-01-07
**Target**: Match dashboard_screen.dart UI to reference home_screen.dart from khyapple/go_now

---

## Phase 1: Foundation (Color & Typography) - HIGH PRIORITY

### Task 1.1: Update Color Scheme
**File**: `lib/core/theme/app_colors.dart`
**Changes**:
```dart
// Reference target colors:
- Background: Colors.grey[50]!
- Cards: Colors.white
- Primary: Colors.blue[600]!
- Secondary text: Colors.grey[600]!
- Shadow: Colors.black.withOpacity(0.1), blurRadius: 10
```

**Action Items**:
- [ ] Add reference color constants to AppColors
- [ ] Update theme data to use grey[50] background
- [ ] Simplify shadow system to match Reference
- [ ] Test color changes across app

**Estimated Time**: 30 minutes

---

### Task 1.2: Typography System Alignment
**File**: `lib/core/theme/app_text_styles.dart`
**Changes**:
```dart
// Reference target sizes:
- Date/Header: 32px, bold (FontWeight.w700)
- Titles: 28px, bold
- Body: 16px, medium (FontWeight.w500)
- Labels: 12px, bold, grey[600]
```

**Action Items**:
- [ ] Update AppTextStyles constants to match Reference sizes
- [ ] Ensure font weights match (bold = w700, medium = w500)
- [ ] Update color usage in text styles
- [ ] Test typography changes

**Estimated Time**: 20 minutes

---

## Phase 2: Structural Changes - HIGH PRIORITY

### Task 2.1: Remove/Simplify AppBar
**File**: `lib/screens/dashboard/dashboard_screen.dart`
**Changes**:
- Remove AppBar or make it transparent
- Move calendar/settings buttons to body (optional)
- Add date header as first element in body

**Options**:
1. **Option A**: Remove AppBar entirely, add date header in body
2. **Option B**: Keep transparent AppBar with actions, add date header

**Action Items**:
- [ ] Decide on AppBar approach (A or B)
- [ ] Implement date header widget (format: "2024년 1월 15일 (월)")
- [ ] Move/remove action buttons
- [ ] Test navigation still works

**Estimated Time**: 45 minutes

---

### Task 2.2: Simplify Timer Widget Appearance
**File**: `lib/widgets/circular_timer_widget.dart` (need to check)
**Changes**:
- Match Reference visual style:
  - strokeWidth: 12
  - backgroundColor: Colors.grey[300]
  - valueColor: Colors.blue[600]
- Keep dynamic countdown functionality (don't break)

**Action Items**:
- [ ] Find CircularTimerWidget implementation
- [ ] Update styling to match Reference
- [ ] Ensure countdown logic still works
- [ ] Test on device

**Estimated Time**: 30 minutes

---

### Task 2.3: Simplify Next Schedule Card
**File**: `lib/screens/dashboard/dashboard_screen.dart` (_buildNextScheduleSection)
**Changes**:
- Remove elaborate container decoration
- Simplify to text-only format like Reference:
  - Just title (emoji + text)
  - Just arrival time
  - No destination card

**Action Items**:
- [ ] Refactor _buildNextScheduleSection method
- [ ] Use simple Text widgets instead of Container cards
- [ ] Match typography from Phase 1
- [ ] Test visual appearance

**Estimated Time**: 30 minutes

---

## Phase 3: Component Refinement - MEDIUM PRIORITY

### Task 3.1: Route Section Styling
**File**: `lib/screens/dashboard/dashboard_screen.dart` (_buildRouteSection)
**Changes**:
- Simplify ExpansionTile styling to match Reference
- Standard Material design instead of custom container
- Keep dividers visible (don't use transparent)

**Action Items**:
- [ ] Remove custom container wrapper around ExpansionTile
- [ ] Use default ExpansionTile styling
- [ ] Adjust colors to match Reference (blue[600])
- [ ] Test expansion behavior

**Estimated Time**: 25 minutes

---

### Task 3.2: Upcoming Cards Layout Polish
**File**: `lib/screens/dashboard/dashboard_screen.dart` (_buildUpcomingSchedulesSection)
**Changes**:
- Ensure card layout matches Reference:
  - Time badge on left (colored box)
  - Title + location in middle
  - Arrow icon on right
- Verify tap navigation works
- Match spacing and padding

**Action Items**:
- [ ] Compare current layout with Reference
- [ ] Add GestureDetector/InkWell for tap navigation
- [ ] Adjust padding/spacing to match Reference
- [ ] Test card interactions

**Estimated Time**: 35 minutes

---

## Phase 4: Polish & Testing - LOW PRIORITY

### Task 4.1: Shadow System Simplification
**File**: `lib/core/theme/app_colors.dart` (cardShadow method)
**Changes**:
- Simplify from multi-layered shadows to single shadow
- Match Reference: `color: Colors.black.withOpacity(0.1), blurRadius: 10`

**Action Items**:
- [ ] Update AppColors.cardShadow() method
- [ ] Remove colorSwatchShadow if not needed
- [ ] Apply simplified shadows across cards
- [ ] Verify visual consistency

**Estimated Time**: 20 minutes

---

### Task 4.2: Overall Visual Testing
**Changes**:
- Test all changes together on device
- Compare side-by-side with Reference screenshots (if available)
- Fine-tune spacing, colors, typography

**Action Items**:
- [ ] Run app on device
- [ ] Take screenshots of dashboard
- [ ] Compare with Reference (fetch screenshots if possible)
- [ ] Make final adjustments

**Estimated Time**: 30 minutes

---

## Optional Enhancements (Keep Current Features)

### Keep These Features (Not in Reference):
1. ✅ **Departure Button** - Adds user value
2. ✅ **Empty/Error States** - Good UX practice
3. ✅ **RefreshIndicator** - Modern UX pattern
4. ✅ **FloatingActionButton** - Quick access
5. ✅ **Provider State Management** - Better architecture

**Rationale**: These features improve UX and don't conflict with visual matching goal

---

## Implementation Order Summary

1. **Phase 1**: Foundation (colors + typography) - 50 min
2. **Phase 2**: Structural changes (AppBar, timer, schedule card) - 105 min
3. **Phase 3**: Component refinement (route section, upcoming cards) - 60 min
4. **Phase 4**: Polish & testing - 50 min

**Total Estimated Time**: ~4.5 hours

---

## Dependencies & Considerations

### Files to Modify:
1. `lib/core/theme/app_colors.dart` - Color system
2. `lib/core/theme/app_text_styles.dart` - Typography
3. `lib/screens/dashboard/dashboard_screen.dart` - Main UI changes
4. `lib/widgets/circular_timer_widget.dart` - Timer appearance
5. Possibly theme configuration files

### Testing Checklist:
- [ ] Colors match Reference on light theme
- [ ] Typography sizes correct (32px, 28px, 16px, 12px)
- [ ] Timer countdown still works dynamically
- [ ] Route ExpansionTile expands/collapses correctly
- [ ] Upcoming cards navigation works
- [ ] Empty/error states still functional
- [ ] RefreshIndicator still works
- [ ] No visual regressions on other screens

### Potential Issues:
- ⚠️ CircularTimerWidget might be complex to modify
- ⚠️ AppColors changes might affect other screens
- ⚠️ Typography changes might need adjustment across app
- ⚠️ Need to verify Reference color values are exact

---

## Next Steps

1. **Immediate**: Start Phase 1 (Foundation)
2. **Before starting**: Verify CircularTimerWidget location
3. **During work**: Test incrementally after each phase
4. **After completion**: Full device testing + comparison

---

## Notes

- This plan focuses on **dashboard_screen.dart** (home screen equivalent)
- Other screens (login, calendar, settings) will need separate matching
- Reference repo might have **exact source code** - consider fetching raw files for precision
- Keep **functional improvements** while matching **visual style**
