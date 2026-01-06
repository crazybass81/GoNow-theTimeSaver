import 'package:flutter/material.dart';

/// 일정 추가 화면 / Add Schedule Screen
///
/// **기능 / Features**:
/// - 4단계 일정 추가 플로우
///   - Step 1: 목적지 입력
///   - Step 2: 시간 및 이동 수단 설정
///   - Step 3: 버퍼 시간 설정
///   - Step 4: 확인 및 저장
/// - 단계별 유효성 검사
/// - 뒤로 가기 지원
///
/// **Context**: 대시보드 FAB에서 이동
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: 목적지 데이터
  String? _selectedPlaceName;
  String? _selectedPlaceAddress;

  // Step 2: 시간 및 이동 수단 데이터
  DateTime? _arrivalDateTime;
  String _transportMode = 'transit'; // 'transit' or 'car'

  // Step 3: 버퍼 시간 데이터
  int _preparationTime = 15; // 외출 준비 시간 (분)
  int _earlyArrivalBuffer = 10; // 일찍 도착 버퍼 (분)
  double _travelErrorRate = 0.2; // 이동 오차율 (20%)
  int _finishUpTime = 5; // 일정 마무리 시간 (분)

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 다음 단계로 이동 / Move to next step
  void _nextStep() {
    if (_currentStep < 3) {
      // 현재 단계 유효성 검사
      if (!_validateCurrentStep()) {
        return;
      }

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveSchedule();
    }
  }

  /// 이전 단계로 이동 / Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 현재 단계 유효성 검사 / Validate current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Step 1: 목적지
        if (_selectedPlaceName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('목적지를 선택해주세요')),
          );
          return false;
        }
        return true;
      case 1: // Step 2: 시간 및 이동 수단
        if (_arrivalDateTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('도착 시간을 선택해주세요')),
          );
          return false;
        }
        if (_arrivalDateTime!.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('도착 시간은 현재 시간 이후여야 합니다')),
          );
          return false;
        }
        return true;
      case 2: // Step 3: 버퍼 시간
        // 버퍼 시간은 기본값이 있으므로 항상 유효
        return true;
      default:
        return true;
    }
  }

  /// 일정 저장 / Save schedule
  void _saveSchedule() {
    // TODO: Supabase에 일정 저장
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 저장되었습니다 (구현 예정)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('일정 추가'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 0
              ? () => Navigator.pop(context)
              : _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            _buildStepIndicator(theme),
            const SizedBox(height: 16),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1(theme),
                  _buildStep2(theme),
                  _buildStep3(theme),
                  _buildStep4(theme),
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == 3 ? '저장' : '다음'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step Indicator 위젯 / Step indicator widget
  Widget _buildStepIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: 목적지 입력 / Destination input
  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어디로 가시나요?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '목적지를 검색하거나 선택해주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // 검색 입력창
          TextField(
            decoration: InputDecoration(
              hintText: '장소 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // TODO: 검색어 초기화
                },
              ),
            ),
            onChanged: (value) {
              // TODO: 장소 검색
            },
          ),
          const SizedBox(height: 24),

          // 최근 장소
          _buildSectionHeader(theme, Icons.history, '최근 장소'),
          const SizedBox(height: 12),
          _buildPlaceList(theme, [
            {'name': '강남역 스타벅스', 'address': '서울시 강남구 강남대로'},
            {'name': '코엑스', 'address': '서울시 강남구 영동대로'},
            {'name': '홍대입구역', 'address': '서울시 마포구 양화로'},
          ]),
          const SizedBox(height: 24),

          // 즐겨찾기
          _buildSectionHeader(theme, Icons.star, '즐겨찾기'),
          const SizedBox(height: 12),
          _buildPlaceList(theme, [
            {'name': '회사', 'address': '서울시 강남구 테헤란로'},
            {'name': '집', 'address': '서울시 송파구 올림픽로'},
          ]),
        ],
      ),
    );
  }

  /// Step 2: 시간 및 이동 수단 설정 / Time and transport mode
  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '언제 도착하시나요?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '도착 시간과 이동 수단을 설정해주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // 선택된 목적지 표시
          if (_selectedPlaceName != null)
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPlaceName!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedPlaceAddress != null)
                          Text(
                            _selectedPlaceAddress!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // 도착 시간 선택
          _buildSectionHeader(theme, Icons.access_time, '도착 시간'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectArrivalDateTime(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _arrivalDateTime != null
                          ? '${_arrivalDateTime!.month}월 ${_arrivalDateTime!.day}일 ${_arrivalDateTime!.hour}:${_arrivalDateTime!.minute.toString().padLeft(2, '0')}'
                          : '날짜와 시간을 선택하세요',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 이동 수단 선택
          _buildSectionHeader(theme, Icons.directions, '이동 수단'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTransportModeButton(
                  theme,
                  '대중교통',
                  Icons.directions_transit,
                  'transit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTransportModeButton(
                  theme,
                  '자가용',
                  Icons.directions_car,
                  'car',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 예상 이동 시간 (정적)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '예상 이동 시간: 약 25분\n출발 시간: 14:05',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: 버퍼 시간 설정 / Buffer time settings
  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '버퍼 시간 설정',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '각 상황에 맞는 여유 시간을 설정하세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // 외출 준비 시간
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
          const SizedBox(height: 24),

          // 일찍 도착 버퍼
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
          const SizedBox(height: 24),

          // 이동 오차율
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
          const SizedBox(height: 24),

          // 일정 마무리 시간
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
        ],
      ),
    );
  }

  /// Step 4: 확인 및 저장 / Confirm and save
  Widget _buildStep4(ThemeData theme) {
    // TODO: 실제 계산된 출발 시간
    final departureTime = _arrivalDateTime?.subtract(
      Duration(
        minutes: 25 + _preparationTime + _earlyArrivalBuffer + _finishUpTime,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일정 확인',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일정 정보를 확인하고 저장하세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // 목적지
          _buildSummaryItem(
            theme,
            Icons.place,
            '목적지',
            _selectedPlaceName ?? '',
            _selectedPlaceAddress,
          ),
          const Divider(height: 32),

          // 도착 시간
          _buildSummaryItem(
            theme,
            Icons.flag,
            '도착 시간',
            _arrivalDateTime != null
                ? '${_arrivalDateTime!.month}월 ${_arrivalDateTime!.day}일 ${_arrivalDateTime!.hour}:${_arrivalDateTime!.minute.toString().padLeft(2, '0')}'
                : '',
            null,
          ),
          const Divider(height: 32),

          // 출발 시간
          _buildSummaryItem(
            theme,
            Icons.directions_run,
            '출발 시간',
            departureTime != null
                ? '${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}'
                : '',
            '외출 준비 시간 포함',
          ),
          const Divider(height: 32),

          // 이동 수단
          _buildSummaryItem(
            theme,
            _transportMode == 'transit'
                ? Icons.directions_transit
                : Icons.directions_car,
            '이동 수단',
            _transportMode == 'transit' ? '대중교통' : '자가용',
            null,
          ),
          const SizedBox(height: 32),

          // 알림 설정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '알림',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '출발 15분, 5분, 3분 전에 알림을 받습니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 / Section header
  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
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

  /// 장소 리스트 / Place list
  Widget _buildPlaceList(
    ThemeData theme,
    List<Map<String, String>> places,
  ) {
    return Column(
      children: places.map((place) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedPlaceName = place['name'];
              _selectedPlaceAddress = place['address'];
            });
            _nextStep();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['name']!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        place['address']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
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
        );
      }).toList(),
    );
  }

  /// 도착 시간 선택 / Select arrival date time
  Future<void> _selectArrivalDateTime(BuildContext context) async {
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

  /// 이동 수단 버튼 / Transport mode button
  Widget _buildTransportModeButton(
    ThemeData theme,
    String label,
    IconData icon,
    String mode,
  ) {
    final isSelected = _transportMode == mode;

    return InkWell(
      onTap: () => setState(() => _transportMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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

  /// 요약 아이템 / Summary item
  Widget _buildSummaryItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    String? subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
