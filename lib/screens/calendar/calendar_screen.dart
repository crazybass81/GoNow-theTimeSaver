import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../schedule/schedule_detail_screen.dart';
import '../schedule/schedule_edit_screen.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// 캘린더 화면 - GitHub 패턴 완전 복제 / Calendar Screen - Complete GitHub pattern clone
///
/// **GitHub Reference**: https://github.com/khyapple/go_now/blob/master/lib/screens/calendar_screen.dart
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  MaterialColor _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  /// 특정 날짜의 일정 가져오기 (TripProvider 사용)
  List<Map<String, String>> _getEventsForDay(DateTime day) {
    final tripProvider = context.watch<TripProvider>();
    final allTrips = tripProvider.trips;

    // 해당 날짜에 해당하는 일정만 필터링
    final dayTrips = allTrips.where((trip) {
      final tripDate = trip.departureTime;
      return tripDate.year == day.year &&
             tripDate.month == day.month &&
             tripDate.day == day.day;
    }).toList();

    return dayTrips.map((trip) {
      return <String, String>{
        'title': trip.title,
        // Supabase에서 UTC로 반환되므로 로컬 시간으로 변환 / Convert from UTC to local time
        'time': '${trip.departureTime.toLocal().hour.toString().padLeft(2, '0')}:${trip.departureTime.toLocal().minute.toString().padLeft(2, '0')}',
        'location': trip.destinationAddress,
        'color': trip.color,
      };
    }).toList();
  }

  /// 커스텀 날짜 셀 (GitHub pattern: 각 날짜 칸에 스케줄 제목 직접 표시)
  Widget _buildCalendarCell(BuildContext context, DateTime day, bool isToday, bool isSelected, {bool isOutside = false}) {
    final events = _getEventsForDay(day);

    Color backgroundColor = Colors.white;
    Color textColor = isOutside ? AppColors.disabled : Colors.black87;
    Color dayCircleColor = Colors.transparent;

    if (isToday) {
      dayCircleColor = AppColors.primary;
      textColor = Colors.white;
    }

    if (isSelected) {
      backgroundColor = AppColors.primaryLighter;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: AppColors.disabled, width: 0.5),
          bottom: BorderSide(color: AppColors.disabled, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 숫자
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: isToday ? 28 : null,
                height: isToday ? 28 : null,
                decoration: BoxDecoration(
                  color: dayCircleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: AppTextStyles.referenceLabel.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.white : textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 스케줄 제목들 (GitHub pattern: 최대 4개까지 표시)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: events.length > 4 ? 4 : events.length,
                itemBuilder: (context, index) {
                  final eventColor = _getColorFromString(events[index]['color'] ?? 'blue');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: eventColor[600],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      events[index]['title']!,
                      style: AppTextStyles.formLabel.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          // 더 많은 일정이 있으면 "+N more" 표시
          if (events.length > 4)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                '+${events.length - 4} more',
                style: AppTextStyles.referenceLabel.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 일정 모달 (GitHub pattern: 날짜 클릭 시 일정 목록 표시)
  void _showEventModal(BuildContext context, DateTime selectedDay) {
    final tripProvider = context.read<TripProvider>();
    final dayTrips = tripProvider.trips.where((trip) {
      final tripDate = trip.departureTime;
      return tripDate.year == selectedDay.year &&
             tripDate.month == selectedDay.month &&
             tripDate.day == selectedDay.day;
    }).toList();

    final events = _getEventsForDay(selectedDay);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 날짜 헤더
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // 일정 리스트
              Flexible(
                child: events.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Text(
                          '일정이 없습니다',
                          style: AppTextStyles.referenceBody.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          final eventColor = _getColorFromString(event['color'] ?? 'blue');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: eventColor[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    event['time']!,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.badgeTimeSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: eventColor[600],
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                event['title']!,
                                style: AppTextStyles.referenceBody.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.disabled,
                              ),
                              onTap: () {
                                Navigator.of(context).pop(); // 모달 닫기
                                // 해당 index의 Trip 객체 전달
                                if (index < dayTrips.length) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleDetailScreen(
                                        trip: dayTrips[index],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
          border: Border.all(color: AppColors.disabled, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // GitHub pattern: 일정이 있으면 모달 표시, 없으면 일정 추가 화면으로 이동
              final events = _getEventsForDay(selectedDay);
              if (events.isNotEmpty) {
                _showEventModal(context, selectedDay);
              } else {
                // 일정이 없는 날짜 선택 시 → ScheduleEditScreen으로 이동 (선택한 날짜를 기본값으로)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScheduleEditScreen(
                      initialDate: selectedDay,
                    ),
                  ),
                );
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(context, day, false, false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(context, day, true, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(context, day, false, true);
              },
              outsideBuilder: (context, day, focusedDay) {
                return _buildCalendarCell(context, day, false, false, isOutside: true);
              },
            ),
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.zero,
              cellPadding: EdgeInsets.zero,
              todayDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 0, // GitHub pattern: 마커 숨기기 (커스텀 셀에서 표시)
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.sectionTitle.copyWith(
                height: 1.3,
              ),
              // GitHub pattern: 2줄로 표시 (2024년\n1월)
              titleTextFormatter: (date, locale) {
                return '${date.year}년\n${date.month}월';
              },
            ),
            daysOfWeekHeight: 40,
            rowHeight: 140, // GitHub pattern: 날짜 칸 높이 증가
          ),
        ),
      ),
    );
  }
}
