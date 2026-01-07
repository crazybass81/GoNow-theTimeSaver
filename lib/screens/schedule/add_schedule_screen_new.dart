import 'package:flutter/material.dart';
import '../../widgets/color_picker_widget.dart';
import '../../widgets/emoji_picker_widget.dart';

/// 일정 추가 화면 (단일 스크롤 레이아웃) / Add Schedule Screen (Single Scroll Layout)
///
/// **기능 / Features**:
/// - 단일 스크롤 레이아웃 (4단계 PageView 제거)
/// - 색상 피커로 일정 카테고리 색상 선택
/// - 이모지 피커로 일정 아이콘 선택
/// - DropdownButton으로 교통수단 선택
/// - 읽기 전용 필드 탭하여 피커 표시
///
/// **Context**: 대시보드 FAB에서 이동 - 참조: https://github.com/khyapple/go_now/master/lib/screens/schedule_edit_screen.dart
class AddScheduleScreenNew extends StatefulWidget {
  const AddScheduleScreenNew({super.key});

  @override
  State<AddScheduleScreenNew> createState() => _AddScheduleScreenNewState();
}

class _AddScheduleScreenNewState extends State<AddScheduleScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();

  // 기본 정보
  String _selectedEmoji = '🚗';
  Color _selectedColor = const Color(0xFF64B5F6);
  DateTime? _arrivalDateTime;
  String _transportMode = 'transit'; // 'transit' or 'car'

  // 버퍼 시간
  int _preparationTime = 15;
  int _earlyArrivalBuffer = 10;
  double _travelErrorRate = 0.2;
  int _finishUpTime = 5;

  // 피커 표시 상태
  bool _showColorPicker = false;
  bool _showEmojiPicker = false;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  /// 일정 저장 / Save schedule
  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 입력해주세요')),
      );
      return;
    }

    if (_arrivalDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('도착 시간을 선택해주세요')),
      );
      return;
    }

    // TODO: Supabase에 일정 저장
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 저장되었습니다 (구현 예정)')),
    );
    Navigator.pop(context);
  }

  /// 도착 시간 선택 다이얼로그 / Select arrival date time dialog
  Future<void> _selectArrivalDateTime() async {
    final now = DateTime.now();

    // 날짜 선택
    final date = await showDatePicker(
      context: context,
      initialDate: _arrivalDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    // 시간 선택
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_arrivalDateTime ?? now),
    );

    if (time == null || !mounted) return;

    setState(() {
      _arrivalDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('일정 추가'),
        actions: [
          // 저장 버튼
          TextButton(
            onPressed: _saveSchedule,
            child: Text(
              '저장',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '일정 제목',
                  hintText: '예: 강남역 미팅',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 색상 및 이모지 선택
              _buildColorEmojiSection(theme),
              const SizedBox(height: 24),

              // 목적지 입력
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: '목적지',
                  hintText: '장소를 입력하세요',
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '목적지를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 도착 시간 선택
              _buildArrivalTimeField(theme),
              const SizedBox(height: 24),

              // 이동 수단 선택 (DropdownButton)
              _buildTransportModeDropdown(theme),
              const SizedBox(height: 32),

              // 버퍼 시간 설정 섹션
              _buildSectionHeader(theme, '버퍼 시간 설정', Icons.schedule),
              const SizedBox(height: 16),

              _buildBufferTimeSlider(
                theme,
                '외출 준비 시간',
                '옷 입고 짐 챙기는 시간',
                Icons.checkroom,
                _preparationTime,
                0,
                60,
                (value) => setState(() => _preparationTime = value.round()),
              ),
              const SizedBox(height: 16),

              _buildBufferTimeSlider(
                theme,
                '일찍 도착 버퍼',
                '여유있게 도착하기 위한 시간',
                Icons.access_time,
                _earlyArrivalBuffer,
                0,
                30,
                (value) => setState(() => _earlyArrivalBuffer = value.round()),
              ),
              const SizedBox(height: 16),

              _buildErrorRateSlider(
                theme,
                '이동 오차율',
                '교통 상황에 따른 변동',
                Icons.traffic,
                _travelErrorRate,
                0.0,
                0.5,
                (value) => setState(() => _travelErrorRate = value),
              ),
              const SizedBox(height: 16),

              _buildBufferTimeSlider(
                theme,
                '일정 마무리 시간',
                '이전 일정을 마무리하는 시간',
                Icons.event_note,
                _finishUpTime,
                0,
                30,
                (value) => setState(() => _finishUpTime = value.round()),
              ),

              const SizedBox(height: 80), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 헤더 / Section header
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 색상 및 이모지 선택 섹션 / Color and emoji selection section
  Widget _buildColorEmojiSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 색상 섹션
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '색상',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 선택된 색상 미리보기 (탭하여 피커 토글)
                  GestureDetector(
                    onTap: () => setState(() => _showColorPicker = !_showColorPicker),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // 이모지 섹션
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '아이콘',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 선택된 이모지 미리보기 (탭하여 피커 토글)
                  GestureDetector(
                    onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 색상 피커 (토글)
        if (_showColorPicker) ...[
          const SizedBox(height: 16),
          ColorPickerWidget(
            selectedColor: _selectedColor,
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
                _showColorPicker = false; // 선택 후 자동 닫기
              });
            },
          ),
        ],

        // 이모지 피커 (토글)
        if (_showEmojiPicker) ...[
          const SizedBox(height: 16),
          EmojiPickerWidget(
            selectedEmoji: _selectedEmoji,
            onEmojiSelected: (emoji) {
              setState(() {
                _selectedEmoji = emoji;
                _showEmojiPicker = false; // 선택 후 자동 닫기
              });
            },
          ),
        ],
      ],
    );
  }

  /// 도착 시간 선택 필드 / Arrival time selection field
  Widget _buildArrivalTimeField(ThemeData theme) {
    return InkWell(
      onTap: _selectArrivalDateTime,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '도착 시간',
          prefixIcon: const Icon(Icons.access_time),
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _arrivalDateTime != null
              ? '${_arrivalDateTime!.month}월 ${_arrivalDateTime!.day}일 ${_arrivalDateTime!.hour}:${_arrivalDateTime!.minute.toString().padLeft(2, '0')}'
              : '날짜와 시간을 선택하세요',
          style: _arrivalDateTime != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
        ),
      ),
    );
  }

  /// 이동 수단 선택 드롭다운 / Transport mode dropdown
  Widget _buildTransportModeDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _transportMode,
      decoration: InputDecoration(
        labelText: '이동 수단',
        prefixIcon: Icon(
          _transportMode == 'transit'
              ? Icons.directions_transit
              : Icons.directions_car,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'transit',
          child: Row(
            children: [
              Icon(Icons.directions_transit, size: 20),
              SizedBox(width: 12),
              Text('대중교통'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'car',
          child: Row(
            children: [
              Icon(Icons.directions_car, size: 20),
              SizedBox(width: 12),
              Text('자가용'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _transportMode = value);
        }
      },
    );
  }

  /// 버퍼 시간 슬라이더 / Buffer time slider
  Widget _buildBufferTimeSlider(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    int value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$value분',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// 오차율 슬라이더 / Error rate slider
  Widget _buildErrorRateSlider(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 10,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
