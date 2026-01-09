import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../services/transit_service.dart';
import '../../utils/app_colors.dart';
import 'schedule_edit_screen.dart';

/// 스케줄 상세 화면 - GitHub 패턴 완전 복제 / Schedule Detail Screen - Complete GitHub pattern clone
///
/// **GitHub Reference**: https://github.com/khyapple/go_now/blob/master/lib/screens/schedule_detail_screen.dart
class ScheduleDetailScreen extends StatefulWidget {
  final Trip trip;

  const ScheduleDetailScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // GitHub pattern: Listen to provider changes
    final tripProvider = context.read<TripProvider>();
    tripProvider.addListener(_onTripChanged);
  }

  @override
  void dispose() {
    // Context may be null during dispose, check if mounted
    if (mounted) {
      final tripProvider = context.read<TripProvider>();
      tripProvider.removeListener(_onTripChanged);
    }
    super.dispose();
  }

  void _onTripChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // GitHub pattern: Get current trip data from provider
  Trip get currentTrip {
    final tripProvider = context.watch<TripProvider>();
    final allTrips = tripProvider.trips;

    // Find the trip by ID
    try {
      return allTrips.firstWhere((t) => t.id == widget.trip.id);
    } catch (e) {
      // If trip not found, return original
      return widget.trip;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '일정 상세',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 정보 (GitHub pattern: blue header card with borderRadius)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Supabase에서 UTC로 반환되므로 로컬 시간으로 변환 / Convert from UTC to local time
                          '${currentTrip.departureTime.toLocal().year}년 ${currentTrip.departureTime.toLocal().month}월 ${currentTrip.departureTime.toLocal().day}일',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentTrip.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12), // GitHub pattern: 12px gap between cards

                  // 시간 정보
                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: '시간',
                    content: _formatTime(currentTrip.departureTime),
                  ),
                  const SizedBox(height: 12),

                  // 장소 정보
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: '장소',
                    content: currentTrip.destinationAddress,
                  ),
                  const SizedBox(height: 12),

                  // 이동 방식 / Transport mode
                  if (currentTrip.transportMode == 'transit' && currentTrip.transitDetails != null)
                    _buildTransitRouteCard(currentTrip.transitDetails!)
                  else
                    _buildInfoCard(
                      icon: currentTrip.transportMode == 'car' ? Icons.directions_car : Icons.directions_transit,
                      title: '이동 방식',
                      content: currentTrip.transportMode == 'car' ? '자동차' : '대중교통',
                    ),
                  const SizedBox(height: 12),

                  // 준비 시간 (GitHub pattern: TimeItemsCard)
                  _buildTimeItemsCard(
                    icon: Icons.timer_outlined,
                    title: '준비 시간',
                    totalTime: currentTrip.preparationMinutes.toString(),
                    items: _buildPrepTimeItems(),
                  ),
                  const SizedBox(height: 12),

                  // 마무리 시간 (GitHub pattern: TimeItemsCard for wrapUpTime)
                  _buildTimeItemsCard(
                    icon: Icons.more_time_outlined,
                    title: '마무리 시간',
                    totalTime: currentTrip.previousTaskWrapupMinutes.toString(),
                    items: _buildWrapUpTimeItems(),
                  ),
                  const SizedBox(height: 12),

                  // 스케줄 색상 (GitHub pattern: ColorCard)
                  _buildColorCard(
                    title: '스케줄 색상',
                    colorValue: currentTrip.color,
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼들 (GitHub pattern: Material + InkWell buttons)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.content_copy,
                    label: '복사',
                    color: AppColors.secondaryText,
                    onTap: () => _handleDuplicate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.edit,
                    label: '편집',
                    color: AppColors.primary,
                    onTap: () => _handleEdit(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.delete_outline,
                    label: '삭제',
                    color: AppColors.error,
                    onTap: () => _showDeleteDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildPrepTimeItems() {
    final items = <Map<String, dynamic>>[];

    if (currentTrip.preparationMinutes > 0) {
      items.add({
        'name': '외출 준비',
        'minutes': currentTrip.preparationMinutes,
        'emoji': currentTrip.emoji,
      });
    }

    return items;
  }

  List<Map<String, dynamic>> _buildWrapUpTimeItems() {
    final items = <Map<String, dynamic>>[];

    if (currentTrip.previousTaskWrapupMinutes > 0) {
      items.add({
        'name': '이전 일정 마무리',
        'minutes': currentTrip.previousTaskWrapupMinutes,
      });
    }

    return items;
  }

  Color _getColorFromString(String colorName) {
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

  /// GitHub pattern: ColorCard with exact styling
  Widget _buildColorCard({
    required String title,
    required String colorValue,
  }) {
    final color = _getColorFromString(colorValue);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.disabled,
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      colorValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  /// GitHub pattern: TimeItemsCard with exact styling
  Widget _buildTimeItemsCard({
    required IconData icon,
    required String title,
    required String totalTime,
    List<Map<String, dynamic>>? items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총 ${totalTime}분',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (items != null && items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (item['emoji'] != null)
                    Text(
                      item['emoji'],
                      style: const TextStyle(fontSize: 20),
                    ),
                  if (item['emoji'] != null)
                    const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item['minutes']}분',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  /// 대중교통 상세 경로 카드 / Transit route details card
  Widget _buildTransitRouteCard(TransitResult transitDetails) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_transit,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '대중교통',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transitDetails.durationMinutes}분 · ${transitDetails.totalTransitCount}회 환승 · ${transitDetails.totalFare}원',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // SubPath list
          if (transitDetails.subPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...transitDetails.subPaths.map((subPath) {
              final icon = subPath.icon;
              final displayText = subPath.displayText;
              final durationText = '${subPath.durationMinutes}분';

              // 지하철 노선 색상 처리 / Subway line color
              Color? lineColor;
              if (subPath.trafficType == TransitType.subway && subPath.subwayColor != null) {
                try {
                  lineColor = Color(int.parse('0xFF${subPath.subwayColor}'));
                } catch (e) {
                  lineColor = null;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Icon
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),

                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        durationText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Route details with subway line color
                    Expanded(
                      child: Row(
                        children: [
                          if (lineColor != null) ...[
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: lineColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
        ],
      ),
    );
  }

  /// GitHub pattern: InfoCard with exact styling
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// GitHub pattern: ActionButton with Material + InkWell
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              final tripProvider = context.read<TripProvider>();

              try {
                await tripProvider.cancelTrip(currentTrip.id!);

                if (context.mounted) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 상세 페이지 닫기

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('일정이 삭제되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// 복제 액션
  void _handleDuplicate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleEditScreen(
          tripToEdit: currentTrip,
          isDuplicate: true,
        ),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 복사되었습니다')),
      );
    }
  }

  /// 수정 액션
  void _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleEditScreen(
          tripToEdit: currentTrip,
          isDuplicate: false,
        ),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  String _formatTime(DateTime time) {
    // Supabase에서 UTC로 반환되므로 로컬 시간으로 변환 / Convert from UTC to local time
    return DateFormat('HH:mm').format(time.toLocal());
  }
}
