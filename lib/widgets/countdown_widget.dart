import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';

/// 카운트다운 위젯 / Countdown Widget
///
/// **기능 / Features**:
/// - 남은 시간 실시간 표시
/// - 시간대별 색상 변화 (초록→주황→빨강)
/// - 프로그레스 바 애니메이션
/// - 시간 상태 메시지 ("여유 있어요", "서둘러야 해요", "지금 출발하세요!")
///
/// **Context**: 대시보드 메인 화면에서 사용
class CountdownWidget extends StatefulWidget {
  /// 목표 도착 시간 / Target arrival time
  final DateTime targetTime;

  /// 출발해야 하는 시간 / Departure time
  final DateTime departureTime;

  /// 카운트다운 완료 콜백 / Countdown completion callback
  final VoidCallback? onCountdownComplete;

  const CountdownWidget({
    super.key,
    required this.targetTime,
    required this.departureTime,
    this.onCountdownComplete,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Duration _remainingTime = Duration.zero;
  int _minutesLeft = 0;
  Color _currentColor = AppTheme.timeGreen;
  String _statusMessage = '여유 있어요';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// 애니메이션 초기화 / Initialize animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 긴급 상태일 때 펄스 애니메이션
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  /// 타이머 시작 / Start timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRemainingTime();
        });
      }
    });
  }

  /// 남은 시간 업데이트 / Update remaining time
  void _updateRemainingTime() {
    final now = DateTime.now();
    _remainingTime = widget.departureTime.difference(now);

    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
      _minutesLeft = 0;

      // 카운트다운 완료 콜백 호출
      if (widget.onCountdownComplete != null) {
        widget.onCountdownComplete!();
      }
    } else {
      _minutesLeft = _remainingTime.inMinutes;
    }

    // 색상 및 상태 메시지 업데이트
    _currentColor = AppTheme.getTimeColor(_minutesLeft);
    _statusMessage = AppTheme.getTimeStatusMessage(_minutesLeft);

    // 긴급 상태일 때 펄스 애니메이션 시작
    if (_minutesLeft < 10 && !_animationController.isAnimating) {
      _animationController.forward();
    } else if (_minutesLeft >= 10 && _animationController.isAnimating) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  /// 프로그레스 값 계산 / Calculate progress value
  double _calculateProgress() {
    final totalDuration = widget.departureTime.difference(
      DateTime.now().subtract(_remainingTime),
    );

    if (totalDuration.inSeconds == 0) return 0.0;

    return (_remainingTime.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _minutesLeft < 10 ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _currentColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상태 메시지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _currentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _statusMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 남은 시간 표시
            _buildTimeDisplay(theme),
            const SizedBox(height: 24),

            // 프로그레스 바
            _buildProgressBar(),
            const SizedBox(height: 16),

            // 목표 시간 표시
            _buildTargetTimeInfo(theme),
          ],
        ),
      ),
    );
  }

  /// 시간 표시 위젯 / Time display widget
  Widget _buildTimeDisplay(ThemeData theme) {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hours > 0) ...[
          _buildTimeUnit(hours.toString(), '시간', theme),
          const SizedBox(width: 8),
        ],
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), '분', theme),
        const SizedBox(width: 8),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), '초', theme),
      ],
    );
  }

  /// 시간 단위 위젯 / Time unit widget
  Widget _buildTimeUnit(String value, String unit, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(
            color: _currentColor,
            fontWeight: FontWeight.w700,
            fontSize: 48,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: theme.textTheme.titleMedium?.copyWith(
            color: _currentColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 프로그레스 바 위젯 / Progress bar widget
  Widget _buildProgressBar() {
    final progress = _calculateProgress();

    return Column(
      children: [
        // 선형 프로그레스 바
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 12,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _currentColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_currentColor),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 도트 프로그레스 인디케이터 (10개)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (index) {
            final threshold = (index + 1) / 10;
            final isFilled = progress >= threshold;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? _currentColor
                      : _currentColor.withOpacity(0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 목표 시간 정보 위젯 / Target time info widget
  Widget _buildTargetTimeInfo(ThemeData theme) {
    final departureTimeStr =
        '${widget.departureTime.hour}:${widget.departureTime.minute.toString().padLeft(2, '0')}';
    final targetTimeStr =
        '${widget.targetTime.hour}:${widget.targetTime.minute.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeInfoItem(
          theme,
          '출발',
          departureTimeStr,
          Icons.directions_run,
        ),
        Icon(
          Icons.arrow_forward,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          size: 20,
        ),
        _buildTimeInfoItem(
          theme,
          '도착',
          targetTimeStr,
          Icons.place,
        ),
      ],
    );
  }

  /// 시간 정보 아이템 / Time info item
  Widget _buildTimeInfoItem(
    ThemeData theme,
    String label,
    String time,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              time,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 상태 아이콘 반환 / Get status icon
  IconData _getStatusIcon() {
    if (_minutesLeft >= 30) {
      return Icons.check_circle;
    } else if (_minutesLeft >= 10) {
      return Icons.warning_amber;
    } else {
      return Icons.alarm;
    }
  }
}
