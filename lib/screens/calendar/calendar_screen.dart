import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

/// 월간 캘린더 화면 / Monthly Calendar Screen
///
/// **기능 / Features**:
/// - 월간 캘린더 뷰
/// - 날짜별 일정 개수 표시
/// - 선택된 날짜의 일정 리스트
/// - 일정 추가 버튼
///
/// **Context**: 대시보드 또는 네비게이션 바에서 접근
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // TODO: 실제 데이터로 대체 - Supabase에서 일정 로드
  // 샘플 일정 데이터 (날짜별로 일정 저장)
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.utc(2026, 1, 15): [
      {
        'title': '강남역 스타벅스',
        'time': '09:00',
        'location': '강남역 2번 출구',
        'icon': Icons.coffee,
      },
      {
        'title': '클라이언트 미팅',
        'time': '14:00',
        'location': '삼성동 코엑스',
        'icon': Icons.business,
      },
      {
        'title': '팀 회의',
        'time': '16:30',
        'location': '회사',
        'icon': Icons.groups,
      },
    ],
    DateTime.utc(2026, 1, 16): [
      {
        'title': '병원 진료',
        'time': '10:30',
        'location': '서울대병원',
        'icon': Icons.local_hospital,
      },
      {
        'title': '저녁 약속',
        'time': '18:30',
        'location': '홍대입구역',
        'icon': Icons.restaurant,
      },
    ],
    DateTime.utc(2026, 1, 20): [
      {
        'title': '친구 생일',
        'time': '19:00',
        'location': '강남역',
        'icon': Icons.cake,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  /// 특정 날짜의 일정 가져오기 / Get events for a specific day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  /// 날짜 선택 처리 / Handle day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('캘린더'),
        actions: [
          // 오늘로 이동 버튼
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: '오늘',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _selectedEvents.value = _getEventsForDay(_selectedDay!);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          _buildCalendar(theme),

          const SizedBox(height: 8),

          // 선택된 날짜 표시
          _buildSelectedDateHeader(theme),

          const Divider(height: 1),

          // 선택된 날짜의 일정 리스트
          Expanded(
            child: _buildEventList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 일정 추가 화면으로 이동 (선택된 날짜 전달)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${DateFormat('yyyy-MM-dd').format(_selectedDay!)} 일정 추가 (구현 예정)',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
      ),
    );
  }

  /// 캘린더 위젯 / Calendar widget
  Widget _buildCalendar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        // 캘린더 스타일링
        calendarStyle: CalendarStyle(
          // 오늘 날짜
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
          // 선택된 날짜
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          // 이벤트 마커
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          // 일반 날짜
          defaultTextStyle: theme.textTheme.bodyMedium!,
          weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.error,
          ),
          // 다른 달 날짜
          outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        // 헤더 스타일링
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: theme.colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface,
          ),
        ),
        // 요일 헤더 스타일링
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          weekendStyle: theme.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.error.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  /// 선택된 날짜 헤더 / Selected date header
  Widget _buildSelectedDateHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.event,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedDay != null
                ? DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_selectedDay!)
                : '날짜를 선택하세요',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${events.length}개 일정',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 일정 리스트 / Event list
  Widget _buildEventList(ThemeData theme) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '일정이 없습니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새 일정을 추가해보세요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(theme, event);
          },
        );
      },
    );
  }

  /// 일정 카드 / Event card
  Widget _buildEventCard(ThemeData theme, Map<String, dynamic> event) {
    return InkWell(
      onTap: () {
        // TODO: 일정 상세 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event['title']} 상세 화면 (구현 예정)')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            // 시간
            Column(
              children: [
                Text(
                  event['time'].split(':')[0],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  event['time'].split(':')[1],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // 구분선
            Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 16),

            // 일정 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        event['icon'] as IconData,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                          event['location'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
