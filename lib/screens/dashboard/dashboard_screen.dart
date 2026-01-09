import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/transit_service.dart';
import '../../widgets/circular_timer_widget.dart';
import '../../widgets/route_display_widget.dart';
import '../../models/route_step.dart';
import '../../models/trip.dart';
import '../schedule/schedule_edit_screen.dart';
import '../schedule/schedule_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../calendar/calendar_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// 대시보드 메인 화면 / Dashboard Main Screen
///
/// **기능 / Features**:
/// - 다음 일정 카운트다운 (실시간 업데이트)
/// - 경로 정보 표시
/// - 이후 일정 3개 미리보기
/// - "출발했어요" 버튼
/// - 일정 추가 FAB
///
/// **Context**: 로그인 후 메인 화면
class DashboardScreen extends StatefulWidget {
  /// 테스트용 Provider 주입 / Provider injection for testing
  final dynamic authProviderOverride;
  final dynamic tripProviderOverride;

  const DashboardScreen({
    super.key,
    this.authProviderOverride,
    this.tripProviderOverride,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRouteExpanded = false; // GitHub pattern: route expansion state

  @override
  void initState() {
    super.initState();
    // TripProvider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.authProviderOverride != null && widget.tripProviderOverride != null) {
        // Test mode: use injected providers
        if (widget.authProviderOverride.currentUser != null) {
          widget.tripProviderOverride.initialize(widget.authProviderOverride.currentUser.id);
        }
      } else {
        // Production mode: use Provider
        final authProvider = context.read<AuthProvider>();
        final tripProvider = context.read<TripProvider>();

        if (authProvider.currentUser != null) {
          tripProvider.initialize(authProvider.currentUser!.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use injected providers in test mode, otherwise use Provider
    final authProvider = widget.authProviderOverride ?? context.watch<AuthProvider>();
    final tripProvider = widget.tripProviderOverride ?? context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 에러 배너 (Graceful degradation: 에러가 있어도 UI 차단하지 않음)
          if (tripProvider.error != null)
            Material(
              color: AppColors.errorLight,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, color: AppColors.errorMedium, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '오프라인 모드',
                            style: AppTextStyles.formLabel.copyWith(
                              color: AppColors.errorDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '서버 연결 실패 - 로컬 데이터로 작동',
                            style: AppTextStyles.referenceLabel.copyWith(
                              color: AppColors.errorMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final tripProvider = context.read<TripProvider>();
                        if (authProvider.currentUser != null) {
                          await tripProvider.loadTrips(authProvider.currentUser!.id);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorMedium,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('재시도', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          // 메인 컨텐츠 (에러 여부와 관계없이 항상 표시)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // 실제 데이터 새로고침 / Refresh data
                if (authProvider.currentUser != null) {
                  await tripProvider.loadTrips(authProvider.currentUser!.id);
                }
              },
              child: tripProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 오늘 날짜 (GitHub pattern)
                          _buildDateHeader(),
                          const SizedBox(height: 16),

                          // 원형 타이머 (GitHub pattern: real data from TripProvider)
                          _buildCircularTimer(tripProvider),
                          const SizedBox(height: 24),

                          // 스케줄 제목 (GitHub pattern: real data from TripProvider)
                          _buildScheduleTitle(tripProvider),
                          const SizedBox(height: 20),

                          // 경로 드롭다운 (GitHub pattern: always visible)
                          _buildRouteDropdown(),
                          const SizedBox(height: 32),

                          // 다음 스케줄 섹션 (GitHub pattern: always visible)
                          _buildUpcomingSchedulesSection(),

                          const SizedBox(height: 80), // FAB를 위한 여백
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleEditScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for buttons
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          '일정 추가',
          style: AppTextStyles.formLabel.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 에러 뷰 / Error view
  Widget _buildErrorView(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '데이터를 불러오는데 실패했습니다',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final tripProvider = context.read<TripProvider>();
              if (authProvider.currentUser != null) {
                await tripProvider.loadTrips(authProvider.currentUser!.id);
              }
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 뷰 / Empty state view
  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '일정이 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '하단의 + 버튼을 눌러\n새 일정을 추가해보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 날짜 헤더 (GitHub pattern) / Date header (GitHub pattern)
  Widget _buildDateHeader() {
    final now = DateTime.now();
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][now.weekday - 1];

    return Center(
      child: Column(
        children: [
          Text(
            '${now.year}년 ${now.month}월 ${now.day}일',
            style: AppTextStyles.dateHeader.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$weekday요일',
            style: AppTextStyles.badgeTimeLarge.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// 원형 타이머 (GitHub pattern: 250x250, real data from TripProvider)
  Widget _buildCircularTimer(TripProvider tripProvider) {
    final upcomingTrip = tripProvider.upcomingTrip;

    if (upcomingTrip == null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: AppColors.disabled,
            ),
            const SizedBox(height: 16),
            Text(
              '다가오는 일정이 없습니다',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    final timeUntilDeparture = upcomingTrip.getTimeUntilDeparture();
    final minutesLeft = timeUntilDeparture.inMinutes;
    final totalMinutes = upcomingTrip.arrivalTime.difference(DateTime.now()).inMinutes;
    final progress = totalMinutes > 0 ? (minutesLeft / totalMinutes).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 원
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // 진행 표시
            SizedBox(
              width: 230,
              height: 230,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary!),
              ),
            ),
            // 중앙 텍스트
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  minutesLeft > 0 ? '$minutesLeft' : '0',
                  style: AppTextStyles.timerLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  minutesLeft > 0 ? '분 후 출발' : '출발 시간입니다!',
                  style: AppTextStyles.timerSmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 스케줄 제목 (GitHub pattern: centered, real data from TripProvider)
  Widget _buildScheduleTitle(TripProvider tripProvider) {
    final upcomingTrip = tripProvider.upcomingTrip;

    if (upcomingTrip == null) {
      return const SizedBox.shrink();
    }

    // Supabase에서 UTC로 반환되므로 로컬 시간으로 변환 / Convert from UTC (Supabase) to local time
    final arrivalTime = upcomingTrip.arrivalTime.toLocal();
    final timeString = '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';

    return Center(
      child: Column(
        children: [
          Text(
            upcomingTrip.title,
            style: AppTextStyles.scheduleTitle,
          ),
          const SizedBox(height: 8),
          Text(
            '$timeString 도착 예정',
            style: AppTextStyles.referenceBody.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// 경로 드롭다운 (GitHub pattern: real data from TripProvider)
  Widget _buildRouteDropdown() {
    final tripProvider = context.watch<TripProvider>();
    final upcomingTrip = tripProvider.upcomingTrip;

    // upcomingTrip이 없으면 아무것도 표시하지 않음
    if (upcomingTrip == null) {
      return const SizedBox.shrink();
    }

    // 실제 경로 정보 구성 / Build actual route information
    final String routeInfo = upcomingTrip.transportMode == 'car'
        ? '자동차 (예상 ${upcomingTrip.travelDurationMinutes}분)'
        : '대중교통 (예상 ${upcomingTrip.travelDurationMinutes}분)';

    final String startPoint = '현재 위치';
    final String destination = upcomingTrip.destinationAddress;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 경로 헤더
          Row(
            children: [
              Icon(
                upcomingTrip.transportMode == 'car'
                    ? Icons.directions_car
                    : Icons.directions_transit,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  routeInfo,
                  style: AppTextStyles.referenceBody.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 출발지 → 목적지
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  startPoint,
                  style: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Icon(Icons.arrow_downward, size: 16, color: AppColors.disabled),
          ),
          Row(
            children: [
              Icon(Icons.place, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination,
                  style: AppTextStyles.formLabel.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 다음 일정 섹션 / Next schedule section (GitHub pattern)
  /// **변경 사항**: GitHub home_screen.dart 패턴 정확 복제
  Widget _buildNextScheduleSection(ThemeData theme, Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 원형 타이머 위젯 (GitHub pattern: timer first)
        CircularTimerWidget(
          targetTime: trip.arrivalTime,
          departureTime: trip.departureTime,
          onCountdownComplete: () {
            // 카운트다운 완료 시 알림
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('출발 시간입니다!')),
            );
          },
        ),
        const SizedBox(height: 24),

        // 일정 제목 및 도착 시간 (GitHub pattern: centered, exact styling)
        Center(
          child: Column(
            children: [
              Text(
                '${trip.emoji} ${trip.title}',
                style: AppTextStyles.scheduleTitle,
              ),
              const SizedBox(height: 8),
              Text(
                // 약속시간 표시 = 도착시간 + 일찍도착버퍼 / Display meeting time = arrival time + early arrival buffer
                () {
                  final meetingTime = trip.arrivalTime.toLocal().add(
                    Duration(minutes: trip.earlyArrivalBufferMinutes),
                  );
                  return '${meetingTime.hour}:${meetingTime.minute.toString().padLeft(2, '0')} 도착 예정';
                }(),
                style: AppTextStyles.referenceBody.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 경로 섹션 / Route section with GitHub pattern collapsible component
  Widget _buildRouteSection(ThemeData theme, Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '이동 정보',
              style: AppTextStyles.sectionTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // GitHub pattern: Custom collapsible component with smooth animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px borderRadius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isRouteExpanded ? 0.08 : 0.04),
                blurRadius: _isRouteExpanded ? 12 : 6,
                offset: Offset(0, _isRouteExpanded ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // GitHub pattern: Clickable header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isRouteExpanded = !_isRouteExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Transport icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            trip.transportMode == 'car'
                                ? Icons.directions_car
                                : Icons.directions_transit,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.transportMode == 'car' ? '자동차' : '대중교통',
                                style: AppTextStyles.referenceBody.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '예상 소요 시간: ${trip.travelDurationMinutes}분',
                                style: AppTextStyles.scheduleSubtitle.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // GitHub pattern: Animated expand/collapse icon
                        AnimatedRotation(
                          turns: _isRouteExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // GitHub pattern: Animated expandable content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isRouteExpanded
                    ? Column(
                        children: [
                          Divider(
                            height: 1,
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildRouteDetails(theme, trip),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 경로 상세 정보 / Route details (expandable content)
  Widget _buildRouteDetails(ThemeData theme, Trip trip) {
    // 대중교통 상세 경로 표시 / Display transit route details
    if (trip.transportMode == 'transit' && trip.transitDetails != null) {
      final transitDetails = trip.transitDetails!;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 총 시간, 환승, 요금
            Row(
              children: [
                Icon(
                  Icons.directions_transit,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${transitDetails.durationMinutes}분 · ${transitDetails.totalTransitCount}회 환승 · ${transitDetails.totalFare}원',
                    style: AppTextStyles.sectionSubtitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SubPath 리스트 (컴팩트 버전)
            ...transitDetails.subPaths.map((subPath) {
              final icon = subPath.icon;
              final displayText = subPath.displayText;

              // 지하철 노선 색상 처리
              Color? lineColor;
              if (subPath.trafficType == TransitType.subway && subPath.subwayColor != null) {
                try {
                  lineColor = Color(int.parse('0xFF${subPath.subwayColor}'));
                } catch (e) {
                  lineColor = null;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    // Icon
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),

                    // Duration badge (컴팩트)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${subPath.durationMinutes}분',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Route details with line color
                    Expanded(
                      child: Row(
                        children: [
                          if (lineColor != null) ...[
                            Container(
                              width: 3,
                              height: 16,
                              decoration: BoxDecoration(
                                color: lineColor,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              displayText,
                              style: AppTextStyles.scheduleDescription.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    // 자동차 또는 routeData가 없을 경우 기본 안내 메시지
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            trip.transportMode == 'car' ? Icons.directions_car : Icons.route,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trip.transportMode == 'car'
                  ? '자동차 · ${trip.travelDurationMinutes}분\n도착지: ${trip.destinationAddress}'
                  : '출발지: 현재 위치\n도착지: ${trip.destinationAddress}',
              style: AppTextStyles.scheduleDescription.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 출발 버튼 / Departure button (실제 동작)
  /// 출발 버튼 / Departure button
  /// tripProvider: TripProvider 또는 테스트용 Mock / TripProvider or Mock for testing
  Widget _buildDepartureButton(
      BuildContext context, ThemeData theme, dynamic tripProvider, Trip trip) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('출발 확인'),
              content: const Text('출발하셨나요?\n일정이 완료 처리됩니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    // 실제 Trip 완료 처리 / Complete trip
                    await tripProvider.completeTrip(trip.id!);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('일정이 완료되었습니다')),
                      );
                    }
                  },
                  child: const Text('출발했어요'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_run, size: 24),
            const SizedBox(width: 8),
            Text(
              '출발했어요',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 다음 스케줄 섹션 (GitHub pattern: always visible, no parameters)
  Widget _buildUpcomingSchedulesSection() {
    final tripProvider = context.watch<TripProvider>();
    final trips = tripProvider.trips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '다음 스케줄',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${trips.length}개',
                style: AppTextStyles.referenceLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (trips.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                '오늘 예정된 스케줄이 없습니다',
                style: AppTextStyles.referenceBody.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
        else
          ...trips.asMap().entries.map((entry) {
            final trip = entry.value;
            final theme = Theme.of(context);

            // 일정 색상 (Trip 모델의 color 필드 사용)
            final scheduleColor = AppColors.getColorByName(
              trip.color,
              fallback: AppColors.scheduleBlue,
            );

            return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // 일정 상세 화면으로 이동 / Navigate to schedule detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleDetailScreen(trip: trip),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                    ),
                    boxShadow: AppColors.cardShadow(scheduleColor),
                  ),
                  child: Row(
                    children: [
                      // 시간 배지 / Time badge (60x60px - GitHub reference pattern)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: scheduleColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppColors.referenceShadow,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // 약속시간 표시 = 도착시간 + 일찍도착버퍼 / Display meeting time
                                () {
                                  final meetingTime = trip.arrivalTime.toLocal().add(
                                    Duration(minutes: trip.earlyArrivalBufferMinutes),
                                  );
                                  return meetingTime.hour.toString();
                                }(),
                                style: AppTextStyles.badgeTimeLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                () {
                                  final meetingTime = trip.arrivalTime.toLocal().add(
                                    Duration(minutes: trip.earlyArrivalBufferMinutes),
                                  );
                                  return meetingTime.minute.toString().padLeft(2, '0');
                                }(),
                                style: AppTextStyles.badgeTimeSmall.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trip.emoji} ${trip.title}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    trip.destinationAddress,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
