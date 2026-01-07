import 'package:flutter/material.dart';

/// 색상 피커 위젯 / Color Picker Widget
///
/// **기능 / Features**:
/// - 6개 원형 색상 견본 (Circular color swatches)
/// - 선택 인디케이터 (3px black border)
/// - 50x50px 원형 크기
/// - Wrap 레이아웃 (10px spacing)
///
/// **Context**: 일정 추가/수정 화면 - 참조: https://github.com/khyapple/go_now/master/lib/screens/schedule_edit_screen.dart
class ColorPickerWidget extends StatelessWidget {
  /// 현재 선택된 색상 / Currently selected color
  final Color selectedColor;

  /// 색상 선택 콜백 / Color selection callback
  final ValueChanged<Color> onColorSelected;

  /// 사용 가능한 색상 목록 / Available colors
  final List<Color> availableColors;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    List<Color>? availableColors,
  }) : availableColors = availableColors ?? _defaultColors;

  /// 기본 색상 팔레트 (참조 패턴) / Default color palette
  static const List<Color> _defaultColors = [
    Color(0xFFE57373), // Red
    Color(0xFF64B5F6), // Blue
    Color(0xFF81C784), // Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFBA68C8), // Purple
    Color(0xFF4DB6AC), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableColors.map((color) {
        final isSelected = color.value == selectedColor.value;

        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Colors.black,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
