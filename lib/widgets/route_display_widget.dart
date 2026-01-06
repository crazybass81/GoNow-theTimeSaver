import 'package:flutter/material.dart';
import '../models/route_step.dart';

/// 경로 표시 위젯 / Route Display Widget
///
/// **기능 / Features**:
/// - 대중교통 경로 리스트 (버스/지하철/도보)
/// - 실시간 버스 도착 정보 표시
/// - 경로 변경 버튼
/// - 이동 시간 및 거리 표시
///
/// **Context**: 대시보드 메인 화면에서 사용
class RouteDisplayWidget extends StatelessWidget {
  /// 경로 단계 리스트 / Route steps list
  final List<RouteStep> routeSteps;

  /// 총 이동 시간 (분) / Total travel time in minutes
  final int totalTravelTime;

  /// 총 이동 거리 (미터) / Total distance in meters
  final int totalDistance;

  /// 경로 변경 콜백 / Change route callback
  final VoidCallback? onChangeRoute;

  const RouteDisplayWidget({
    super.key,
    required this.routeSteps,
    required this.totalTravelTime,
    required this.totalDistance,
    this.onChangeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 총 시간 및 거리
          _buildHeader(theme),

          const Divider(height: 1),

          // 경로 단계 리스트
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...routeSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == routeSteps.length - 1;

                  return _buildRouteStep(theme, step, isLast);
                }).toList(),
              ],
            ),
          ),

          // 경로 변경 버튼
          if (onChangeRoute != null) ...[
            const Divider(height: 1),
            _buildChangeRouteButton(theme),
          ],
        ],
      ),
    );
  }

  /// 헤더 위젯 / Header widget
  Widget _buildHeader(ThemeData theme) {
    final distanceKm = (totalDistance / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 총 이동 시간
          Icon(
            Icons.access_time,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '약 $totalTravelTime분',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),

          // 총 이동 거리
          Icon(
            Icons.straighten,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$distanceKm km',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 경로 단계 위젯 / Route step widget
  Widget _buildRouteStep(ThemeData theme, RouteStep step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 단계 인디케이터
        Column(
          children: [
            _buildStepIcon(theme, step),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // 단계 내용
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 교통수단 및 노선 정보
                _buildStepHeader(theme, step),
                const SizedBox(height: 4),

                // 상세 정보
                if (step.description != null)
                  Text(
                    step.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                // 실시간 정보 (버스인 경우)
                if (step.type == RouteStepType.bus && step.arrivalInfo != null)
                  _buildArrivalInfo(theme, step.arrivalInfo!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 단계 아이콘 / Step icon
  Widget _buildStepIcon(ThemeData theme, RouteStep step) {
    IconData icon;
    Color color;

    switch (step.type) {
      case RouteStepType.walk:
        icon = Icons.directions_walk;
        color = theme.colorScheme.onSurface.withOpacity(0.6);
        break;
      case RouteStepType.bus:
        icon = Icons.directions_bus;
        color = const Color(0xFF4CAF50); // 버스 초록색
        break;
      case RouteStepType.subway:
        icon = Icons.subway;
        color = step.lineColor ?? theme.colorScheme.primary;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }

  /// 단계 헤더 (교통수단 정보) / Step header
  Widget _buildStepHeader(ThemeData theme, RouteStep step) {
    return Row(
      children: [
        // 노선 번호/이름
        if (step.lineName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: step.lineColor?.withOpacity(0.1) ??
                  theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              step.lineName!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: step.lineColor ?? theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // 이동 시간
        Text(
          '${step.duration}분',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 8),

        // 거리 (도보인 경우)
        if (step.type == RouteStepType.walk && step.distance != null)
          Text(
            '${step.distance}m',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  /// 실시간 도착 정보 / Real-time arrival info
  Widget _buildArrivalInfo(ThemeData theme, String arrivalInfo) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 4),
          Text(
            arrivalInfo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 경로 변경 버튼 / Change route button
  Widget _buildChangeRouteButton(ThemeData theme) {
    return InkWell(
      onTap: onChangeRoute,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '다른 경로 보기',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
