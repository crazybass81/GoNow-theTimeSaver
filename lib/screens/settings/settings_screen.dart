import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';
import '../auth/login_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_policy_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

/// 설정 화면 - GitHub 패턴 완전 복제 / Settings Screen - Complete GitHub pattern clone
///
/// **GitHub Reference**: https://github.com/khyapple/go_now/blob/master/lib/screens/settings_screen.dart
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
      backgroundColor: AppColors.background, // GitHub pattern: light background
      appBar: AppBar(
        backgroundColor: Colors.white, // GitHub pattern: white appbar
        elevation: 0, // GitHub pattern: no shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '설정',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
          ),
        ),
        centerTitle: false, // GitHub pattern: left-aligned title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // GitHub pattern: 20px padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub UI 순서: Notifications → Account → App Settings → App Info → Logout

            // 1. 알림 설정
            _buildNotificationSection(theme),
            SizedBox(height: UIConstants.spacingSectionGap),

            // 2. 계정 관리
            _buildAccountSection(theme, authProvider),
            SizedBox(height: UIConstants.spacingSectionGap),

            // 3. 앱 설정 (이동수단 + 버퍼시간)
            _buildAppSettingsSection(theme),
            SizedBox(height: UIConstants.spacingSectionGap),

            // 4. 앱 정보
            _buildAppInfoSection(theme),
            SizedBox(height: UIConstants.spacingSectionGap),

            // 5. 로그아웃
            _buildLogoutSection(theme, authProvider),
            const SizedBox(height: 40), // Extra bottom padding
          ],
        ),
      ),
    );
  }


  /// 버퍼 시간 슬라이더 위젯 / Buffer time slider widget - GitHub pattern
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
      padding: const EdgeInsets.all(18), // GitHub pattern: 18px padding
      decoration: BoxDecoration(
        color: Colors.white, // GitHub pattern: white card
        borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
        border: Border.all(color: AppColors.divider, width: 1), // GitHub pattern: subtle border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // GitHub UI: Icon with 48x48 blue[50] background container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.referenceBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
              Text(
                displayValue,
                style: AppTextStyles.badgeTimeLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.referenceLabel.copyWith(
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          SizedBox(height: UIConstants.spacingCardGap),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
          ),
        ],
      ),
    );
  }


  /// 알림 설정 섹션 / Notification settings section - GitHub pattern
  Widget _buildNotificationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '알림 설정',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        SizedBox(height: UIConstants.spacingScreen),

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
          onTap: () => _showNotificationSoundModal(context),
        ),
      ],
    );
  }

  /// 계정 관리 섹션 / Account management section - GitHub pattern
  Widget _buildAccountSection(ThemeData theme, AuthProvider authProvider) {
    final userName = authProvider.currentUser?.userMetadata?['name'] as String?;
    final userEmail = authProvider.currentUser?.email ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 관리',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        SizedBox(height: UIConstants.spacingScreen),

        // 프로필 정보 - GitHub pattern: white card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // GitHub pattern: 12px for cards
            border: Border.all(color: AppColors.divider, width: 1),
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
              CircleAvatar(
                radius: 32, // GitHub pattern: slightly larger avatar
                backgroundColor: AppColors.primary,
                child: Text(
                  userName != null && userName.isNotEmpty
                      ? userName[0].toUpperCase()
                      : userEmail[0].toUpperCase(),
                  style: AppTextStyles.dateHeader.copyWith(
                    color: Colors.white,
                    fontSize: 24,
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
                      style: AppTextStyles.badgeTimeLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: AppTextStyles.formLabel.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: UIConstants.spacingCardInternal),

        // 프로필 수정
        _buildSettingTile(
          theme: theme,
          icon: Icons.person_outline,
          title: '프로필 수정',
          subtitle: '이름, 전화번호 변경',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 앱 정보 섹션 / App information section - GitHub pattern
  Widget _buildAppInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '앱 정보',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        SizedBox(height: UIConstants.spacingScreen),

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsScreen(),
              ),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
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

  /// 앱 설정 섹션 / App settings section - GitHub pattern
  /// 이동수단 + 버퍼시간을 묶음 / Groups transport mode + buffer time
  Widget _buildAppSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '앱 설정',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        SizedBox(height: UIConstants.spacingScreen),

        // 기본 이동 수단 - ListTile that opens modal
        _buildSettingTile(
          theme: theme,
          icon: Icons.directions_transit,
          title: '기본 이동 수단',
          subtitle: _getTransportModeLabel(_defaultTransportMode),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showTransportModeModal(context),
        ),
        const Divider(height: 1),

        // 기본 버퍼 시간 설정 - ListTile that opens modal
        _buildSettingTile(
          theme: theme,
          icon: Icons.schedule,
          title: '기본 버퍼 시간 설정',
          subtitle: '외출 준비, 도착 버퍼, 오차율, 마무리',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showBufferTimeModal(context),
        ),
      ],
    );
  }

  /// 이동 수단 코드를 한글 레이블로 변환 / Convert transport mode code to Korean label
  /// TMAP API 지원 수단만 포함 / Only includes TMAP API supported modes
  String _getTransportModeLabel(String mode) {
    switch (mode) {
      case 'transit':
        return '대중교통';
      case 'car':
        return '자가용';
      case 'walk':
        return '도보';
      default:
        return '대중교통'; // 기본값 / Default value (fallback to transit)
    }
  }

  /// 로그아웃 섹션 / Logout section - GitHub pattern
  Widget _buildLogoutSection(ThemeData theme, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleLogout(authProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그아웃',
                      style: AppTextStyles.badgeTimeLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '계정에서 로그아웃합니다',
                      style: AppTextStyles.formLabel.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 설정 타일 위젯 / Setting tile widget - GitHub pattern
  Widget _buildSettingTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.referenceBody.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.referenceLabel.copyWith(
          color: AppColors.secondaryText,
          height: 1.4,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // GitHub pattern: minimal padding
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

  /// 알림 소리 선택 모달 / Notification sound selection modal
  Future<void> _showNotificationSoundModal(BuildContext context) async {
    final soundOptions = ['기본', '벨소리', '알람', '무음'];

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusDialog),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(UIConstants.spacingScreen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '알림 소리',
              style: AppTextStyles.sectionTitle.copyWith(
                color: Colors.black87,
              ),
            ),
            SizedBox(height: UIConstants.spacingScreen),
            ...soundOptions.map((sound) => RadioListTile<String>(
                  title: Text(
                    sound,
                    style: AppTextStyles.referenceBody.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  value: sound,
                  groupValue: _notificationSound,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _notificationSound = value!);
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: UIConstants.spacingCardGap),
          ],
        ),
      ),
    );
  }

  /// 이동 수단 선택 모달 / Transport mode selection modal
  /// TMAP API 지원 수단만 포함 / Only includes TMAP API supported modes
  Future<void> _showTransportModeModal(BuildContext context) async {
    // TMAP API 지원 이동 수단 옵션 / TMAP API supported transport mode options
    final transportModes = [
      {'value': 'transit', 'icon': Icons.directions_transit, 'label': '대중교통'},
      {'value': 'car', 'icon': Icons.directions_car, 'label': '자가용'},
      {'value': 'walk', 'icon': Icons.directions_walk, 'label': '도보'},
    ];

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusDialog),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(UIConstants.spacingScreen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 이동 수단',
              style: AppTextStyles.sectionTitle.copyWith(
                color: Colors.black87,
              ),
            ),
            SizedBox(height: UIConstants.spacingScreen),
            // 이동 수단 옵션 동적 생성 / Dynamically generate transport mode options
            ...transportModes.map((mode) => RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(mode['icon'] as IconData, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        mode['label'] as String,
                        style: AppTextStyles.referenceBody.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  value: mode['value'] as String,
                  groupValue: _defaultTransportMode,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _defaultTransportMode = value!);
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: UIConstants.spacingCardGap),
          ],
        ),
      ),
    );
  }

  /// 버퍼 시간 설정 모달 / Buffer time settings modal
  Future<void> _showBufferTimeModal(BuildContext context) async {
    // 임시 변수로 저장하여 취소 시 원복 가능
    int tempPreparationTime = _defaultPreparationTime;
    int tempEarlyArrivalBuffer = _defaultEarlyArrivalBuffer;
    double tempTravelErrorRate = _defaultTravelErrorRate;
    int tempFinishUpTime = _defaultFinishUpTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusDialog),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(UIConstants.spacingScreen),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '기본 버퍼 시간 설정',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.spacingScreen),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 1. 외출 준비 시간
                      _buildBufferSlider(
                        theme: Theme.of(context),
                        icon: Icons.house_outlined,
                        title: '1️⃣ 외출 준비 시간',
                        description: '옷 입기, 짐 챙기기 등',
                        value: tempPreparationTime.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        unit: '분',
                        onChanged: (value) {
                          setModalState(() => tempPreparationTime = value.toInt());
                        },
                      ),
                      SizedBox(height: UIConstants.spacingCardInternal),

                      // 2. 일찍 도착 버퍼
                      _buildBufferSlider(
                        theme: Theme.of(context),
                        icon: Icons.schedule,
                        title: '2️⃣ 일찍 도착 버퍼',
                        description: '약속 시간 전 여유롭게 도착',
                        value: tempEarlyArrivalBuffer.toDouble(),
                        min: 0,
                        max: 30,
                        divisions: 6,
                        unit: '분',
                        onChanged: (value) {
                          setModalState(() => tempEarlyArrivalBuffer = value.toInt());
                        },
                      ),
                      SizedBox(height: UIConstants.spacingCardInternal),

                      // 3. 이동 오차율
                      _buildBufferSlider(
                        theme: Theme.of(context),
                        icon: Icons.trending_up,
                        title: '3️⃣ 이동 오차율',
                        description: '교통 예측 불확실성, 신호 대기',
                        value: tempTravelErrorRate,
                        min: 0,
                        max: 0.5,
                        divisions: 10,
                        unit: '%',
                        isPercentage: true,
                        onChanged: (value) {
                          setModalState(() => tempTravelErrorRate = value);
                        },
                      ),
                      SizedBox(height: UIConstants.spacingCardInternal),

                      // 4. 일정 마무리 시간
                      _buildBufferSlider(
                        theme: Theme.of(context),
                        icon: Icons.check_circle_outline,
                        title: '4️⃣ 일정 마무리 시간',
                        description: '이전 일정 정리 후 출발',
                        value: tempFinishUpTime.toDouble(),
                        min: 0,
                        max: 30,
                        divisions: 6,
                        unit: '분',
                        onChanged: (value) {
                          setModalState(() => tempFinishUpTime = value.toInt());
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: UIConstants.spacingScreen),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _defaultPreparationTime = tempPreparationTime;
                      _defaultEarlyArrivalBuffer = tempEarlyArrivalBuffer;
                      _defaultTravelErrorRate = tempTravelErrorRate;
                      _defaultFinishUpTime = tempFinishUpTime;
                    });
                    Navigator.pop(context);
                  },
                  style: UIConstants.primaryButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '저장',
                      style: AppTextStyles.referenceBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
