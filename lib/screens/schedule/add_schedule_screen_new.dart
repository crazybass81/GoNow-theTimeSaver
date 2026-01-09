import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/color_picker_widget.dart';
import '../../widgets/emoji_picker_widget.dart';
import '../../utils/app_colors.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import '../../services/poi_search_service.dart';
import '../../services/route_service.dart';
import '../../services/transit_service.dart';
import '../../providers/auth_provider.dart';

/// 시간 항목 클래스 / Time item class
class TimeItem {
  final String name;
  final int minutes;

  TimeItem({required this.name, required this.minutes});
}

/// 일정 추가/수정 화면 (단일 스크롤 레이아웃) / Add/Edit Schedule Screen (Single Scroll Layout)
///
/// **기능 / Features**:
/// - 단일 스크롤 레이아웃 (4단계 PageView 제거)
/// - 색상 피커로 일정 카테고리 색상 선택
/// - 이모지 피커로 일정 아이콘 선택
/// - DropdownButton으로 교통수단 선택
/// - 읽기 전용 필드 탭하여 피커 표시
/// - Edit Mode: 기존 일정 수정 지원
///
/// **Context**: 대시보드 FAB에서 이동 또는 ScheduleDetailScreen에서 수정/복제 - 참조: https://github.com/khyapple/go_now/master/lib/screens/schedule_edit_screen.dart
class AddScheduleScreenNew extends StatefulWidget {
  final Trip? tripToEdit; // 수정할 일정 (null이면 새로 추가)
  final bool isDuplicate; // 복제 모드 여부

  const AddScheduleScreenNew({
    super.key,
    this.tripToEdit,
    this.isDuplicate = false,
  });

  @override
  State<AddScheduleScreenNew> createState() => _AddScheduleScreenNewState();
}

class _AddScheduleScreenNewState extends State<AddScheduleScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();

  // 기본 정보
  String _selectedEmoji = '🚗';
  Color _selectedColor = AppColors.scheduleBlue;
  DateTime? _arrivalDateTime;
  String _transportMode = 'transit'; // 'transit' or 'car'

  // 버퍼 시간 - Chip-based lists / Buffer time - Chip-based lists
  List<TimeItem> _prepItems = [];
  List<TimeItem> _finishItems = [];
  int _earlyArrivalBuffer = 10;
  double _travelErrorRate = 0.2;

  // 피커 표시 상태
  bool _showColorPicker = false;
  bool _showEmojiPicker = false;

  // 장소 검색 관련
  List<POIResult> _searchResults = [];
  POIResult? _selectedPOI;
  bool _isSearching = false;

  // 사용자 현재 위치
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadTripDataIfEditing();
  }

  /// Edit mode일 경우 기존 일정 데이터 로드 / Load existing trip data if in edit mode
  void _loadTripDataIfEditing() {
    if (widget.tripToEdit != null) {
      final trip = widget.tripToEdit!;

      // 기본 정보
      _titleController.text = widget.isDuplicate ? '${trip.title} (복사본)' : trip.title;
      _selectedEmoji = trip.emoji;
      _selectedColor = AppColors.getColorByName(trip.color);
      // Supabase에서 UTC로 반환되므로 로컬 시간으로 변환 / Convert from UTC to local time
      _arrivalDateTime = trip.arrivalTime.toLocal();
      _transportMode = trip.transportMode;

      // 버퍼 시간 - Initialize lists from totals / Initialize lists from totals
      _earlyArrivalBuffer = trip.earlyArrivalBufferMinutes;
      _travelErrorRate = trip.travelUncertaintyRate;

      // 준비 시간을 리스트로 초기화 (기존 값이 있으면 '외출 준비' 항목으로)
      // Initialize prep time as list (use existing value as '외출 준비' item)
      _prepItems = trip.preparationMinutes > 0
          ? [TimeItem(name: '외출 준비', minutes: trip.preparationMinutes)]
          : [];

      // 마무리 시간을 리스트로 초기화 (기존 값이 있으면 '이전 일정 마무리' 항목으로)
      // Initialize finish time as list (use existing value as '이전 일정 마무리' item)
      _finishItems = trip.previousTaskWrapupMinutes > 0
          ? [TimeItem(name: '이전 일정 마무리', minutes: trip.previousTaskWrapupMinutes)]
          : [];

      // 목적지 정보 (검색 결과 없이 기존 주소 사용)
      _destinationController.text = trip.destinationAddress;
      _selectedPOI = POIResult(
        id: trip.id ?? '',
        name: trip.destinationAddress,
        address: trip.destinationAddress,
        lat: trip.destinationLat,
        lng: trip.destinationLng,
        category: '',
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  /// 현재 위치 가져오기 / Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services are disabled');
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permissions are permanently denied');
        return;
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      debugPrint('✅ Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
    }
  }

  /// 총 준비 시간 계산 / Calculate total preparation time
  int _getTotalPrepTime() {
    return _prepItems.fold(0, (sum, item) => sum + item.minutes);
  }

  /// 총 마무리 시간 계산 / Calculate total finish time
  int _getTotalFinishTime() {
    return _finishItems.fold(0, (sum, item) => sum + item.minutes);
  }

  /// 준비 항목 추가 다이얼로그 / Show add preparation item dialog
  Future<void> _showAddPrepItemDialog() async {
    final nameController = TextEditingController();
    final minutesController = TextEditingController(text: '10');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // GitHub pattern: 24px for dialogs
        ),
        title: const Text('준비 항목 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '항목 이름',
                hintText: '예: 샤워, 메이크업, 짐 챙기기',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              decoration: const InputDecoration(
                labelText: '소요 시간 (분)',
                hintText: '예: 10',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final minutes = int.tryParse(minutesController.text.trim()) ?? 0;

              if (name.isNotEmpty && minutes > 0) {
                setState(() {
                  _prepItems.add(TimeItem(name: name, minutes: minutes));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  /// 마무리 항목 추가 다이얼로그 / Show add finish item dialog
  Future<void> _showAddFinishItemDialog() async {
    final nameController = TextEditingController();
    final minutesController = TextEditingController(text: '5');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // GitHub pattern: 24px for dialogs
        ),
        title: const Text('마무리 항목 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '항목 이름',
                hintText: '예: 회의 정리, 자료 저장, 정리',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minutesController,
              decoration: const InputDecoration(
                labelText: '소요 시간 (분)',
                hintText: '예: 5',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final minutes = int.tryParse(minutesController.text.trim()) ?? 0;

              if (name.isNotEmpty && minutes > 0) {
                setState(() {
                  _finishItems.add(TimeItem(name: name, minutes: minutes));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  /// 장소 검색 / Search POI
  Future<void> _searchPOI(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await POISearchService().searchPOI(
        keyword: keyword,
        count: 10,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('❌ POI search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('장소 검색 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// POI 선택 / Select POI
  void _selectPOI(POIResult poi) {
    setState(() {
      _selectedPOI = poi;
      _destinationController.text = poi.name;
      _searchResults = [];
    });
  }

  /// 일정 저장 / Save schedule
  ///
  /// **실제 구현 / Real Implementation**:
  /// - 사용자 현재 위치 및 선택된 목적지 사용
  /// - RouteService 또는 TransitService로 실제 이동 시간 계산
  /// - Supabase에 일정 정보 저장
  Future<void> _saveSchedule() async {
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

    if (_selectedPOI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목적지를 검색하여 선택해주세요')),
      );
      return;
    }

    // 사용자 인증 확인
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    // 로딩 표시
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 1. 출발지 좌표 (현재 위치 또는 기본값)
      double originLat;
      double originLng;

      if (_currentPosition != null) {
        originLat = _currentPosition!.latitude;
        originLng = _currentPosition!.longitude;
      } else {
        // 현재 위치를 가져오지 못한 경우 서울 시청을 기본값으로 사용
        originLat = 37.5665;
        originLng = 126.9780;
      }

      // 2. 목적지 좌표 (선택된 POI)
      final destLat = _selectedPOI!.lat;
      final destLng = _selectedPOI!.lng;

      // 3. 경로 API 호출하여 실제 이동 시간 계산
      int travelDurationMinutes;
      Map<String, dynamic>? routeData; // 경로 상세 데이터

      if (_transportMode == 'transit') {
        // 대중교통 경로
        final transitResults = await TransitService().calculateTransitRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );

        if (transitResults.isEmpty) {
          throw Exception('대중교통 경로를 찾을 수 없습니다');
        }

        final transitResult = transitResults.first;
        travelDurationMinutes = transitResult.durationMinutes;
        routeData = transitResult.toJson(); // TransitResult 전체를 JSON으로 저장
      } else {
        // 자동차 경로
        final routeResult = await RouteService().calculateRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );

        if (routeResult == null) {
          throw Exception('자동차 경로를 찾을 수 없습니다');
        }

        travelDurationMinutes = routeResult.durationMinutes;
      }

      // 4. 시간 계산 로직 (약속시간 기준)
      // 약속시간(meetingTime): 사용자가 입력한 시간 (_arrivalDateTime)
      // 도착시간(arrivalTime): 약속시간 - 일찍도착버퍼
      // 출발시간(departureTime): 도착시간 - 이동시간 - 준비시간 - 이동오차 - 마무리시간

      final meetingDateTime = _arrivalDateTime!; // 약속시간 (사용자 입력)

      // 도착시간 = 약속시간 - 일찍도착버퍼
      final actualArrivalTime = meetingDateTime.subtract(
        Duration(minutes: _earlyArrivalBuffer),
      );

      // 출발시간 = 도착시간 - (이동시간 + 준비시간 + 이동오차 + 마무리시간)
      final totalPrepBufferMinutes = _getTotalPrepTime() +
          _getTotalFinishTime() +
          (travelDurationMinutes * _travelErrorRate).round();
      final departureDatetime = actualArrivalTime.subtract(
        Duration(minutes: travelDurationMinutes + totalPrepBufferMinutes),
      );

      // 5. Trip 객체 생성
      // 주의: arrivalTime은 실제 도착시간 (약속시간 - 일찍도착버퍼)
      // Supabase는 UTC로 저장하므로 .toUtc() 변환 필요
      final trip = Trip(
        id: widget.isDuplicate ? null : widget.tripToEdit?.id, // 복제 모드면 새 ID, 수정이면 기존 ID
        userId: currentUser.id,
        title: _titleController.text.trim(),
        color: AppColors.getColorName(_selectedColor) ?? 'blue',
        emoji: _selectedEmoji,
        destinationAddress: _selectedPOI!.displayAddress,
        destinationLat: destLat,
        destinationLng: destLng,
        arrivalTime: actualArrivalTime.toUtc(),  // 로컬 → UTC 변환
        departureTime: departureDatetime.toUtc(),  // 로컬 → UTC 변환
        transportMode: _transportMode,
        routeData: routeData, // 대중교통 상세 경로 데이터 저장
        travelDurationMinutes: travelDurationMinutes,
        preparationMinutes: _getTotalPrepTime(),
        earlyArrivalBufferMinutes: _earlyArrivalBuffer,
        travelUncertaintyRate: _travelErrorRate,
        previousTaskWrapupMinutes: _getTotalFinishTime(),
      );

      // 6. Supabase에 저장 (추가 또는 수정)
      final tripService = TripService();

      if (widget.tripToEdit == null || widget.isDuplicate) {
        // 새로 추가 또는 복제
        await tripService.createTrip(trip);
      } else {
        // 기존 일정 수정
        await tripService.updateTrip(trip);
      }

      // 로딩 다이얼로그 닫기
      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ 일정이 저장되었습니다\n'
            '목적지: ${trip.destinationAddress}\n'
            '이동 시간: ${trip.travelDurationMinutes}분\n'
            '출발: ${trip.departureTime.hour}:${trip.departureTime.minute.toString().padLeft(2, '0')}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true); // 화면 닫기 + 새로고침 트리거
    } catch (e) {
      debugPrint('❌ Error saving schedule: $e');

      // 로딩 다이얼로그 닫기
      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일정 저장 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
        title: Text(
          widget.tripToEdit == null
              ? '일정 추가'
              : widget.isDuplicate
                  ? '일정 복제'
                  : '일정 수정',
        ),
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

              // 목적지 검색
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: '목적지',
                  hintText: '장소를 검색하세요 (예: 강남역)',
                  prefixIcon: const Icon(Icons.place),
                  suffixIcon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _selectedPOI != null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
                onChanged: (value) {
                  // 검색어 입력 시 POI 검색
                  _searchPOI(value);
                  // 선택 초기화
                  if (_selectedPOI != null) {
                    setState(() => _selectedPOI = null);
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '목적지를 입력해주세요';
                  }
                  if (_selectedPOI == null) {
                    return '검색 결과에서 목적지를 선택해주세요';
                  }
                  return null;
                },
              ),

              // 검색 결과 목록
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final poi = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, size: 20),
                        title: Text(
                          poi.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          poi.displayAddress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          poi.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        onTap: () => _selectPOI(poi),
                      );
                    },
                  ),
                ),
              ],

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

              _buildTimeItemsChips(
                theme,
                '외출 준비 시간',
                '옷 입고 짐 챙기는 시간 (여러 항목 추가 가능)',
                Icons.checkroom,
                _prepItems,
                _showAddPrepItemDialog,
                (index) => setState(() => _prepItems.removeAt(index)),
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

              _buildTimeItemsChips(
                theme,
                '일정 마무리 시간',
                '이전 일정을 마무리하는 시간 (여러 항목 추가 가능)',
                Icons.event_note,
                _finishItems,
                _showAddFinishItemDialog,
                (index) => setState(() => _finishItems.removeAt(index)),
              ),

              const SizedBox(height: 24),

              // 최종 계산 Preview / Final calculation preview
              _buildFinalPreview(theme),

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
                      width: 50, // GitHub pattern: 50x50px for color picker circles
                      height: 50,
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

            const SizedBox(width: 12), // GitHub pattern: 12px gap between sections

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
                      width: 50, // GitHub pattern: 50x50px for emoji picker circles
                      height: 50,
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

  /// 최종 계산 Preview 섹션 / Final calculation preview section
  Widget _buildFinalPreview(ThemeData theme) {
    // 필수 필드가 모두 입력되었는지 확인 / Check if all required fields are filled
    if (_selectedPOI == null || _arrivalDateTime == null) {
      return const SizedBox.shrink();
    }

    final prepTime = _getTotalPrepTime();
    final finishTime = _getTotalFinishTime();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '최종 계산 (Preview)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildPreviewRow('📍', '목적지', _selectedPOI!.name),
          const SizedBox(height: 8),
          _buildPreviewRow(
            '🕐',
            '도착',
            '${_arrivalDateTime!.hour}:${_arrivalDateTime!.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 8),
          _buildPreviewRow('🚗', '이동', '경로 계산 필요 (저장 시 자동 계산)'),
          const SizedBox(height: 8),
          _buildPreviewRow('👔', '준비', '$prepTime분'),
          const SizedBox(height: 8),
          _buildPreviewRow('📝', '마무리', '$finishTime분'),
          const SizedBox(height: 8),
          _buildPreviewRow('📋', '버퍼', '${_earlyArrivalBuffer}분 + ${(_travelErrorRate * 100).toInt()}%'),
          const Divider(height: 24),
          Row(
            children: [
              Icon(
                Icons.alarm,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '⏰ 출발 시간: 경로 계산 후 표시됩니다',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Preview row helper / Preview row helper
  Widget _buildPreviewRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Chip-based 시간 항목 위젯 / Chip-based time items widget
  Widget _buildTimeItemsChips(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    List<TimeItem> items,
    VoidCallback onAddPressed,
    Function(int) onDeletePressed,
  ) {
    final totalMinutes = items.fold(0, (sum, item) => sum + item.minutes);

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
              '총 $totalMinutes분',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Chip(
                label: Text('${item.name}: ${item.minutes}분'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => onDeletePressed(index),
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('항목 추가'),
              onPressed: onAddPressed,
            ),
          ],
        ),
      ],
    );
  }
}
