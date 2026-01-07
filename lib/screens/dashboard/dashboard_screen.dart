import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/circular_timer_widget.dart';
import '../../widgets/route_display_widget.dart';
import '../../models/route_step.dart';
import '../../models/trip.dart';
import '../schedule/add_schedule_screen_new.dart';
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _getFormattedDate(),
          style: AppTextStyles.dateHeader.copyWith(
            fontSize: 20, // AppBar에 맞게 크기 조정
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          // 캘린더 버튼
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: '캘린더',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
          ),
          // 프로필/설정 버튼
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 실제 데이터 새로고침 / Refresh data
          if (authProvider.currentUser != null) {
            await tripProvider.loadTrips(authProvider.currentUser!.id);
          }
        },
        child: tripProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tripProvider.error != null
                ? _buildErrorView(theme, tripProvider.error!)
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 다음 일정 카운트다운 또는 빈 상태
                        tripProvider.upcomingTrip != null
                            ? _buildNextScheduleSection(
                                theme, tripProvider.upcomingTrip!)
                            : _buildEmptyState(theme),

                        if (tripProvider.upcomingTrip != null) ...[
                          const SizedBox(height: 24),

                          // 경로 정보
                          _buildRouteSection(theme, tripProvider.upcomingTrip!),
                          const SizedBox(height: 24),

                          // "출발했어요" 버튼
                          _buildDepartureButton(
                              context, theme, tripProvider, tripProvider.upcomingTrip!),
                          const SizedBox(height: 32),
                        ],

                        // 이후 일정 미리보기
                        if (tripProvider.trips.length > 1)
                          _buildUpcomingSchedulesSection(theme, tripProvider.trips),

                        const SizedBox(height: 80), // FAB를 위한 여백
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddScheduleScreenNew(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
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
        borderRadius: BorderRadius.circular(16),
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

  /// 날짜 헤더 포맷 / Date header format
  /// 예: "2024년 1월 15일 (월)"
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return '${now.year}년 ${now.month}월 ${now.day}일 ($weekday)';
  }

  /// 다음 일정 섹션 / Next schedule section (참조 저장소 패턴)
  /// **변경 사항**: Container 카드 제거, 단순 텍스트로 변경
  Widget _buildNextScheduleSection(ThemeData theme, Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 일정 제목 (emoji + title)
        Text(
          '${trip.emoji} ${trip.title}',
          style: AppTextStyles.referenceTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 도착 예정 시간
        Text(
          '${trip.arrivalTime.hour}:${trip.arrivalTime.minute.toString().padLeft(2, '0')} 도착 예정',
          style: AppTextStyles.referenceBody.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // 원형 타이머 위젯
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
      ],
    );
  }

  /// 경로 섹션 / Route section with ExpansionTile
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

        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow(theme.colorScheme.primary),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Icon(
                trip.transportMode == 'car'
                    ? Icons.directions_car
                    : Icons.directions_transit,
                color: theme.colorScheme.primary,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.transportMode == 'car' ? '자동차' : '대중교통',
                    style: AppTextStyles.scheduleTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '예상 소요 시간: ${trip.travelDurationMinutes}분',
                    style: AppTextStyles.scheduleSubtitle.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              children: [
                _buildRouteDetails(theme, trip),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 경로 상세 정보 / Route details (expandable content)
  Widget _buildRouteDetails(ThemeData theme, Trip trip) {
    // routeData가 있으면 상세 경로 표시, 없으면 기본 정보 표시
    if (trip.routeData != null && trip.routeData!.isNotEmpty) {
      // JSON 데이터를 파싱하여 경로 단계 표시
      // 현재는 간단한 형태로 표시
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '상세 경로',
                  style: AppTextStyles.sectionSubtitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '경로 데이터가 준비되었습니다.\n상세 경로는 추후 표시됩니다.',
              style: AppTextStyles.scheduleDescription.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // routeData가 없을 경우 기본 안내 메시지
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '출발지: 현재 위치\n도착지: ${trip.destinationAddress}',
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

  /// 이후 일정 섹션 / Upcoming schedules section (실제 데이터)
  Widget _buildUpcomingSchedulesSection(ThemeData theme, List<Trip> trips) {
    // 현재 일정(첫 번째)을 제외한 나머지 일정 (최대 3개)
    final upcomingTrips = trips.skip(1).take(3).toList();

    if (upcomingTrips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              '이후 일정',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...upcomingTrips.map((trip) {
          // 일정 색상 (Trip 모델의 color 필드 사용)
          final scheduleColor = AppColors.getColorByName(
            trip.color,
            fallback: AppColors.scheduleBlue,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              boxShadow: AppColors.cardShadow(scheduleColor),
            ),
            child: Row(
              children: [
                // 시간 배지 / Time badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheduleColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppColors.colorSwatchShadow(scheduleColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        trip.arrivalTime.hour.toString(),
                        style: AppTextStyles.badgeTimeLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        trip.arrivalTime.minute.toString().padLeft(2, '0'),
                        style: AppTextStyles.badgeTimeSmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
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
          );
        }).toList(),
      ],
    );
  }
}
