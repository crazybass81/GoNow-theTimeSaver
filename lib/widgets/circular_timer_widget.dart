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

class _CircularTimerWidgetState extends State<CircularTimerWidget> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

      if (widget.onCountdownComplete != null) {
        widget.onCountdownComplete!();
      }
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
    // 참조 저장소 패턴: 단순 색상 (grey[200] 배경, blue[600] 진행)
    final backgroundColor = Colors.grey[200]!;
    final progressColor = Colors.blue[600]!;

    return Container(
      // BoxShadow 깊이 효과 (참조 패턴)
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      backgroundColor,
                    ),
                  ),
                ),

                // 원형 프로그레스 인디케이터 (진행 상태)
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _calculateProgress(),
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor,
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
                        color: theme.colorScheme.onSurface,
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
        ],
      ),
    );
  }
}
