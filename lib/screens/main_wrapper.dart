import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/dashboard_screen.dart';
import 'calendar/calendar_screen.dart';

/// 메인 래퍼 - PageView 기반 네비게이션 / Main Wrapper - PageView-based Navigation
///
/// **기능 / Features**:
/// - PageView 스와이프 네비게이션 (Dashboard ↔ Calendar)
/// - SharedPreferences로 현재 페이지 상태 유지
/// - 커스텀 하단 인디케이터 (300ms easeInOut 애니메이션)
/// - 페이지 변경 시 자동 저장
///
/// **Context**: 앱 메인 엔트리 포인트 - 참조: https://github.com/khyapple/go_now/master/lib/screens/main_wrapper.dart
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadLastPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// SharedPreferences에서 마지막 페이지 로드 / Load last page from SharedPreferences
  Future<void> _loadLastPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('current_page') ?? 0;

      // 유효한 페이지 범위 확인
      if (lastPage >= 0 && lastPage < 2) {
        setState(() {
          _currentPage = lastPage;
          _isLoading = false;
        });

        // PageController는 build 후에만 사용 가능
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading last page: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 페이지 변경 시 SharedPreferences에 저장 / Save page change to SharedPreferences
  Future<void> _onPageChanged(int page) async {
    setState(() {
      _currentPage = page;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_page', page);
    } catch (e) {
      debugPrint('Error saving current page: $e');
    }
  }

  /// 하단 인디케이터 탭 시 페이지 이동 / Navigate to page on indicator tap
  void _onIndicatorTap(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // PageView (Dashboard + Calendar)
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: const [
                DashboardScreen(),
                CalendarScreen(),
              ],
            ),
          ),

          // 커스텀 하단 인디케이터
          _buildBottomIndicator(),
        ],
      ),
    );
  }

  /// 커스텀 하단 인디케이터 (참조 패턴) / Custom bottom indicator
  Widget _buildBottomIndicator() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Dashboard 인디케이터
            _buildIndicatorItem(
              index: 0,
              icon: Icons.home,
              label: 'Dashboard',
              isActive: _currentPage == 0,
            ),

            // Calendar 인디케이터
            _buildIndicatorItem(
              index: 1,
              icon: Icons.calendar_month,
              label: 'Calendar',
              isActive: _currentPage == 1,
            ),
          ],
        ),
      ),
    );
  }

  /// 인디케이터 아이템 / Indicator item
  Widget _buildIndicatorItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onIndicatorTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            // 활성 상태일 때만 라벨 표시
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
