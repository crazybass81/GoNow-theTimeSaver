import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/countdown_widget.dart';
import '../../widgets/route_display_widget.dart';
import '../../models/route_step.dart';
import '../schedule/add_schedule_screen.dart';
import '../settings/settings_screen.dart';

/// 대시보드 메인 화면 / Dashboard Main Screen
///
/// **기능 / Features**:
/// - 다음 일정 카운트다운
/// - 경로 정보 표시
/// - 이후 일정 3개 미리보기
/// - "출발했어요" 버튼
/// - 일정 추가 FAB
///
/// **Context**: 로그인 후 메인 화면
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('GoNow'),
        actions: [
          // 프로필/설정 버튼
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
          // TODO: 데이터 새로고침
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              _buildWelcomeSection(theme, authProvider),
              const SizedBox(height: 24),

              // 다음 일정 카운트다운
              _buildNextScheduleSection(theme),
              const SizedBox(height: 24),

              // 경로 정보
              _buildRouteSection(theme),
              const SizedBox(height: 24),

              // "출발했어요" 버튼
              _buildDepartureButton(context, theme),
              const SizedBox(height: 32),

              // 이후 일정 미리보기
              _buildUpcomingSchedulesSection(theme),
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
              builder: (context) => const AddScheduleScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
      ),
    );
  }

  /// 환영 섹션 / Welcome section
  Widget _buildWelcomeSection(ThemeData theme, AuthProvider authProvider) {
    final userName = authProvider.currentUser?.userMetadata?['name'] as String?;
    final displayName = userName ?? '사용자';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $displayName님',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '다음 일정까지 남은 시간을 확인하세요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// 다음 일정 섹션 / Next schedule section
  Widget _buildNextScheduleSection(ThemeData theme) {
    // TODO: 실제 일정 데이터로 대체
    final now = DateTime.now();
    final departureTime = now.add(const Duration(minutes: 25));
    final targetTime = now.add(const Duration(minutes: 55));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '다음 일정',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 일정 정보 카드
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.place,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '강남역 스타벅스',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${targetTime.hour}:${targetTime.minute.toString().padLeft(2, '0')} 도착 예정',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 카운트다운 위젯
        CountdownWidget(
          targetTime: targetTime,
          departureTime: departureTime,
          onCountdownComplete: () {
            // TODO: 카운트다운 완료 시 알림
          },
        ),
      ],
    );
  }

  /// 경로 섹션 / Route section
  Widget _buildRouteSection(ThemeData theme) {
    // TODO: 실제 경로 데이터로 대체
    final sampleRouteSteps = [
      RouteStep(
        id: '1',
        type: RouteStepType.walk,
        duration: 5,
        distance: 400,
        description: '집에서 도보',
      ),
      RouteStep(
        id: '2',
        type: RouteStepType.bus,
        lineName: '401',
        lineColor: const Color(0xFF4CAF50),
        duration: 15,
        departureStation: '역삼역',
        arrivalStation: '강남역',
        arrivalInfo: '2분 후 도착',
      ),
      RouteStep(
        id: '3',
        type: RouteStepType.subway,
        lineName: '2호선',
        lineColor: const Color(0xFF4CAF50),
        duration: 10,
        departureStation: '강남역',
        arrivalStation: '역삼역',
      ),
      RouteStep(
        id: '4',
        type: RouteStepType.walk,
        duration: 5,
        distance: 300,
        description: '3번 출구로 나와서 직진',
      ),
    ];

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
              '추천 경로',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        RouteDisplayWidget(
          routeSteps: sampleRouteSteps,
          totalTravelTime: 35,
          totalDistance: 12500,
          onChangeRoute: () {
            // TODO: 다른 경로 보기
          },
        ),
      ],
    );
  }

  /// 출발 버튼 / Departure button
  Widget _buildDepartureButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 출발 확인 다이얼로그 표시
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('출발 확인'),
              content: const Text('출발하셨나요?\n출발 시간이 기록됩니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: 출발 기록 저장
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('출발 시간이 기록되었습니다')),
                    );
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

  /// 이후 일정 섹션 / Upcoming schedules section
  Widget _buildUpcomingSchedulesSection(ThemeData theme) {
    // TODO: 실제 일정 데이터로 대체
    final upcomingSchedules = [
      {
        'title': '회의',
        'time': '15:00',
        'location': '삼성동 코엑스',
      },
      {
        'title': '저녁 약속',
        'time': '18:30',
        'location': '홍대입구역 2번 출구',
      },
      {
        'title': '영화 관람',
        'time': '20:00',
        'location': 'CGV 강남',
      },
    ];

    if (upcomingSchedules.isEmpty) {
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

        ...upcomingSchedules.map((schedule) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      schedule['time']!.split(':')[0],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      schedule['time']!.split(':')[1],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['title']!,
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
                              schedule['location']!,
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
