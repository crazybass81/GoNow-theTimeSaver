import 'package:flutter/material.dart';

/// 이모지 피커 위젯 / Emoji Picker Widget
///
/// **기능 / Features**:
/// - 5-column GridView 레이아웃
/// - 20개 이모지 (교통/활동 관련)
/// - 60x60px 터치 영역
/// - 32px 이모지 크기
/// - 선택 인디케이터 (원형 배경)
///
/// **Context**: 일정 추가/수정 화면 - 참조: https://github.com/khyapple/go_now/master/lib/screens/schedule_edit_screen.dart
class EmojiPickerWidget extends StatelessWidget {
  /// 현재 선택된 이모지 / Currently selected emoji
  final String selectedEmoji;

  /// 이모지 선택 콜백 / Emoji selection callback
  final ValueChanged<String> onEmojiSelected;

  /// 사용 가능한 이모지 목록 / Available emojis
  final List<String> availableEmojis;

  const EmojiPickerWidget({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    List<String>? availableEmojis,
  }) : availableEmojis = availableEmojis ?? _defaultEmojis;

  /// 기본 이모지 목록 (교통/활동 테마) / Default emoji list
  static const List<String> _defaultEmojis = [
    '🚗', // Car
    '🚕', // Taxi
    '🚙', // SUV
    '🚌', // Bus
    '🚎', // Trolleybus
    '🚐', // Minibus
    '🚑', // Ambulance
    '🚒', // Fire truck
    '🚓', // Police car
    '🚖', // Oncoming taxi
    '🚘', // Oncoming automobile
    '🚛', // Articulated lorry
    '🚜', // Tractor
    '🏍️', // Motorcycle
    '🛵', // Motor scooter
    '🚲', // Bicycle
    '🛴', // Kick scooter
    '🚂', // Locomotive
    '✈️', // Airplane
    '⛴️', // Ferry
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: availableEmojis.map((emoji) {
        final isSelected = emoji == selectedEmoji;

        return GestureDetector(
          onTap: () => onEmojiSelected(emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      width: 1,
                    ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
