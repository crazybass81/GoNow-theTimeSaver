import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

/// 설정 화면 / Settings Screen
///
/// **기능 / Features**:
/// - 4가지 버퍼 시간 기본값 설정
/// - 알림 설정 (30분 전, 10분 전)
/// - 계정 관리 (프로필, 비밀번호 변경, 로그아웃)
/// - 앱 정보 (버전, 약관, 개인정보 처리방침)
///
/// **Context**: 대시보드 AppBar의 설정 버튼에서 접근
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 4가지 버퍼 시간 기본값 (분)
  int _defaultPreparationTime = 15;
  int _defaultEarlyArrivalBuffer = 10;
  double _defaultTravelErrorRate = 0.2; // 20%
  int _defaultFinishUpTime = 5;

  // 알림 설정
  bool _notificationEnabled = true;
  bool _notification30MinBefore = true;
  bool _notification10MinBefore = true;
  String _notificationSound = '기본';

  // 기본 이동 수단
  String _defaultTransportMode = 'transit'; // 'transit' or 'car'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 버퍼 시간 설정
            _buildBufferTimeSection(theme),
            const SizedBox(height: 24),

            // 알림 설정
            _buildNotificationSection(theme),
            const SizedBox(height: 24),

            // 계정 관리
            _buildAccountSection(theme, authProvider),
            const SizedBox(height: 24),

            // 앱 정보
            _buildAppInfoSection(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 기본 버퍼 시간 설정 섹션 / Default buffer time settings section
  Widget _buildBufferTimeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 버퍼 시간 설정 (4가지)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '새 일정 추가 시 기본값으로 사용됩니다',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),

        // 외출 준비 시간
        _buildBufferSlider(
          theme: theme,
          icon: Icons.house_outlined,
          title: '1️⃣ 외출 준비 시간',
          description: '옷 입기, 짐 챙기기 등',
          value: _defaultPreparationTime.toDouble(),
          min: 0,
          max: 60,
          divisions: 12,
          unit: '분',
          onChanged: (value) {
            setState(() => _defaultPreparationTime = value.toInt());
          },
        ),
        const SizedBox(height: 16),

        // 일찍 도착 버퍼
        _buildBufferSlider(
          theme: theme,
          icon: Icons.schedule,
          title: '2️⃣ 일찍 도착 버퍼',
          description: '약속 시간 전 여유롭게 도착',
          value: _defaultEarlyArrivalBuffer.toDouble(),
          min: 0,
          max: 30,
          divisions: 6,
          unit: '분',
          onChanged: (value) {
            setState(() => _defaultEarlyArrivalBuffer = value.toInt());
          },
        ),
        const SizedBox(height: 16),

        // 이동 오차율
        _buildBufferSlider(
          theme: theme,
          icon: Icons.trending_up,
          title: '3️⃣ 이동 오차율',
          description: '교통 예측 불확실성, 신호 대기',
          value: _defaultTravelErrorRate,
          min: 0,
          max: 0.5,
          divisions: 10,
          unit: '%',
          isPercentage: true,
          onChanged: (value) {
            setState(() => _defaultTravelErrorRate = value);
          },
        ),
        const SizedBox(height: 16),

        // 일정 마무리 시간
        _buildBufferSlider(
          theme: theme,
          icon: Icons.check_circle_outline,
          title: '4️⃣ 일정 마무리 시간',
          description: '이전 일정 정리 후 출발',
          value: _defaultFinishUpTime.toDouble(),
          min: 0,
          max: 30,
          divisions: 6,
          unit: '분',
          onChanged: (value) {
            setState(() => _defaultFinishUpTime = value.toInt());
          },
        ),
        const SizedBox(height: 16),

        // 기본 이동 수단
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
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
                    '기본 이동 수단',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTransportModeButton(
                      theme: theme,
                      mode: 'transit',
                      icon: Icons.directions_transit,
                      label: '대중교통',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTransportModeButton(
                      theme: theme,
                      mode: 'car',
                      icon: Icons.directions_car,
                      label: '자가용',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 버퍼 시간 슬라이더 위젯 / Buffer time slider widget
  Widget _buildBufferSlider({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    bool isPercentage = false,
    required ValueChanged<double> onChanged,
  }) {
    final displayValue = isPercentage
        ? '${(value * 100).toInt()}$unit'
        : '${value.toInt()}$unit';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                displayValue,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// 이동 수단 선택 버튼 / Transport mode selection button
  Widget _buildTransportModeButton({
    required ThemeData theme,
    required String mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _defaultTransportMode == mode;

    return InkWell(
      onTap: () {
        setState(() => _defaultTransportMode = mode);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 설정 섹션 / Notification settings section
  Widget _buildNotificationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '알림 설정',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // 알림 활성화
        _buildSettingTile(
          theme: theme,
          icon: Icons.notifications_outlined,
          title: '알림 사용',
          subtitle: '출발 시간 알림을 받습니다',
          trailing: Switch(
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() => _notificationEnabled = value);
            },
          ),
        ),
        const Divider(height: 1),

        // 30분 전 알림
        _buildSettingTile(
          theme: theme,
          icon: Icons.alarm,
          title: '30분 전 알림',
          subtitle: '출발 30분 전 알림',
          trailing: Switch(
            value: _notification30MinBefore,
            onChanged: _notificationEnabled
                ? (value) {
                    setState(() => _notification30MinBefore = value);
                  }
                : null,
          ),
        ),
        const Divider(height: 1),

        // 10분 전 긴급 알림
        _buildSettingTile(
          theme: theme,
          icon: Icons.alarm_add,
          title: '10분 전 긴급 알림',
          subtitle: '출발 10분 전 긴급 알림',
          trailing: Switch(
            value: _notification10MinBefore,
            onChanged: _notificationEnabled
                ? (value) {
                    setState(() => _notification10MinBefore = value);
                  }
                : null,
          ),
        ),
        const Divider(height: 1),

        // 알림 소리
        _buildSettingTile(
          theme: theme,
          icon: Icons.volume_up,
          title: '알림 소리',
          subtitle: _notificationSound,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: 알림 소리 선택 모달
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알림 소리 선택 (구현 예정)')),
            );
          },
        ),
      ],
    );
  }

  /// 계정 관리 섹션 / Account management section
  Widget _buildAccountSection(ThemeData theme, AuthProvider authProvider) {
    final userName = authProvider.currentUser?.userMetadata?['name'] as String?;
    final userEmail = authProvider.currentUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 관리',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // 프로필 정보
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  userName != null && userName.isNotEmpty
                      ? userName[0].toUpperCase()
                      : userEmail[0].toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? '사용자',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 프로필 수정
        _buildSettingTile(
          theme: theme,
          icon: Icons.person_outline,
          title: '프로필 수정',
          subtitle: '이름, 전화번호 변경',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: 프로필 수정 화면
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('프로필 수정 (구현 예정)')),
            );
          },
        ),
        const Divider(height: 1),

        // 비밀번호 변경
        _buildSettingTile(
          theme: theme,
          icon: Icons.lock_outline,
          title: '비밀번호 변경',
          subtitle: '보안을 위해 주기적으로 변경하세요',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: 비밀번호 변경 화면
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('비밀번호 변경 (구현 예정)')),
            );
          },
        ),
        const Divider(height: 1),

        // 로그아웃
        _buildSettingTile(
          theme: theme,
          icon: Icons.logout,
          title: '로그아웃',
          subtitle: '계정에서 로그아웃합니다',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _handleLogout(authProvider),
        ),
      ],
    );
  }

  /// 앱 정보 섹션 / App information section
  Widget _buildAppInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '앱 정보',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        // 버전 정보
        _buildSettingTile(
          theme: theme,
          icon: Icons.info_outline,
          title: '버전 정보',
          subtitle: 'v1.0.0',
          trailing: null,
        ),
        const Divider(height: 1),

        // 이용약관
        _buildSettingTile(
          theme: theme,
          icon: Icons.description_outlined,
          title: '이용약관',
          subtitle: '서비스 이용약관 보기',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: 이용약관 화면
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이용약관 (구현 예정)')),
            );
          },
        ),
        const Divider(height: 1),

        // 개인정보 처리방침
        _buildSettingTile(
          theme: theme,
          icon: Icons.privacy_tip_outlined,
          title: '개인정보 처리방침',
          subtitle: '개인정보 처리방침 보기',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: 개인정보 처리방침 화면
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('개인정보 처리방침 (구현 예정)')),
            );
          },
        ),
        const Divider(height: 1),

        // 오픈소스 라이선스
        _buildSettingTile(
          theme: theme,
          icon: Icons.code,
          title: '오픈소스 라이선스',
          subtitle: '사용된 오픈소스 라이선스',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'GoNow',
              applicationVersion: '1.0.0',
            );
          },
        ),
      ],
    );
  }

  /// 설정 타일 위젯 / Setting tile widget
  Widget _buildSettingTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  /// 로그아웃 처리 / Handle logout
  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authProvider.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }
}
