import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';

/// 원형 타이머 위젯 / Circular Timer Widget
///
/// **기능 / Features**:
/// - 250x250px 원형 프로그레스 인디케이터
/// - 64px 큰 타이머 텍스트, 28px 부제목
/// - 시간대별 색상 변화 (초록→주황→빨강)
/// - BoxShadow 깊이 효과
///
/// **Context**: 대시보드 메인 화면 - 참조: https://github.com/khyapple/go_now/master/lib/screens/home_screen.dart
class CircularTimerWidget extends StatefulWidget {
  /// 목표 도착 시간 / Target arrival time
  final DateTime targetTime;

  /// 출발해야 하는 시간 / Departure time
  final DateTime departureTime;

  /// 카운트다운 완료 콜백 / Countdown completion callback
  final VoidCallback? onCountdownComplete;

  const CircularTimerWidget({
    super.key,
    required this.targetTime,
    required this.departureTime,
    this.onCountdownComplete,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Duration _remainingTime = Duration.zero;
  int _minutesLeft = 0;
  Color _currentColor = AppTheme.timeGreen;

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
    _pulseController.dispose();
    super.dispose();
  }

  /// 펄스 애니메이션 초기화 / Initialize pulse animations
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 긴급 상태일 때 반복 펄스
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
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

      if (widget.onCountdownComplete != null) {
        widget.onCountdownComplete!();
      }
    } else {
      _minutesLeft = _remainingTime.inMinutes;
    }

    // 색상 업데이트
    _currentColor = AppTheme.getTimeColor(_minutesLeft);

    // 10분 미만일 때 펄스 애니메이션 시작
    if (_minutesLeft < 10 && !_pulseController.isAnimating) {
      _pulseController.forward();
    } else if (_minutesLeft >= 10 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  /// 프로그레스 값 계산 (0.0 ~ 1.0) / Calculate progress value
  double _calculateProgress() {
    final now = DateTime.now();
    final totalDuration = widget.departureTime.difference(
      now.subtract(_remainingTime),
    );

    if (totalDuration.inSeconds == 0) return 0.0;

    return 1.0 - (_remainingTime.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  /// 출발 시간까지 남은 시간 텍스트 / Get remaining time text
  String _getRemainingTimeText() {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 후 출발';
    } else if (minutes > 0) {
      return '$minutes분 후 출발';
    } else {
      return '지금 출발!';
    }
  }

  /// 도착 시간 텍스트 / Get arrival time text
  String _getArrivalTimeText() {
    return '${widget.targetTime.hour}:${widget.targetTime.minute.toString().padLeft(2, '0')} 도착';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _minutesLeft < 10 ? _pulseAnimation.value : 1.0,
          child: Container(
            // BoxShadow 깊이 효과 (참조 패턴)
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 원형 타이머 (250x250px Stack)
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 원형 프로그레스 인디케이터 배경
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 20,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentColor.withOpacity(0.15),
                          ),
                        ),
                      ),

                      // 원형 프로그레스 인디케이터 (진행 상태)
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: _calculateProgress(),
                          strokeWidth: 20,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentColor,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),

                      // 중앙 텍스트 (64px 타이머 + 28px 부제목)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 주 타이머 텍스트 (64px)
                          Text(
                            _getRemainingTimeText(),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: _currentColor,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // 부제목 텍스트 (28px)
                          Text(
                            _getArrivalTimeText(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 상태 인디케이터
                _buildStatusIndicator(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 상태 인디케이터 위젯 / Status indicator widget
  Widget _buildStatusIndicator(ThemeData theme) {
    String statusMessage;
    IconData statusIcon;

    if (_minutesLeft >= 30) {
      statusMessage = '여유 있어요';
      statusIcon = Icons.check_circle;
    } else if (_minutesLeft >= 10) {
      statusMessage = '서둘러야 해요';
      statusIcon = Icons.warning_amber;
    } else {
      statusMessage = '지금 출발하세요!';
      statusIcon = Icons.alarm;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _currentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: _currentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            statusMessage,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _currentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
