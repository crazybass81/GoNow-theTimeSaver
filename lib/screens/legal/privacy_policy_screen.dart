import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';

/// 개인정보 처리방침 화면 / Privacy Policy Screen
///
/// **기능 / Features**:
/// - 개인정보 처리방침 표시 (9개 섹션)
/// - 법적 필수 화면 (개인정보보호법 준수)
///
/// **Context**: Settings 화면에서 접근
/// **참고 / Reference**: GitHub khyapple/go_now privacy_policy_screen.dart
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '개인정보 처리방침',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 안내문
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingCardInternal),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius:
                    BorderRadius.circular(UIConstants.radiusCard),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GoNow는 이용자의 개인정보를 소중히 다루며, 개인정보보호법을 준수합니다.',
                      style: AppTextStyles.referenceBody.copyWith(
                        color: Colors.blue[900],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingSectionGap),
            _buildSection(
              title: '1. 개인정보의 수집 및 이용 목적',
              content:
                  'GoNow는 다음의 목적을 위하여 개인정보를 수집하고 이용합니다:\n\n'
                  '- 회원 가입 및 관리: 본인 확인, 서비스 부정 이용 방지\n'
                  '- 서비스 제공: 일정 관리, 경로 탐색, 알림 발송\n'
                  '- 서비스 개선: 사용 패턴 분석, 기능 개선\n'
                  '- 고객 지원: 문의 응대, 공지사항 전달',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '2. 수집하는 개인정보 항목',
              content: '가. 필수 항목:\n'
                  '   - 이메일 주소 (로그인 인증)\n'
                  '   - 비밀번호 (암호화 저장)\n'
                  '   - 기기 정보 (푸시 알림 발송)\n\n'
                  '나. 선택 항목:\n'
                  '   - 위치 정보 (경로 탐색 시)\n'
                  '   - 일정 정보 (서비스 이용 시 자동 수집)\n'
                  '   - 사용 기록 (서비스 개선 목적)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '3. 개인정보의 보유 및 이용 기간',
              content:
                  '회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 '
                  '동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다:\n\n'
                  '- 회원 탈퇴 시: 즉시 파기 (단, 관련 법령에 의한 정보 보유 사유가 있을 경우 예외)\n'
                  '- 부정 이용 기록: 1년 (전자상거래법)\n'
                  '- 서비스 이용 기록: 3개월',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '4. 개인정보의 제3자 제공',
              content:
                  '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. '
                  '다만, 다음의 경우는 예외로 합니다:\n\n'
                  '- 이용자가 사전에 동의한 경우\n'
                  '- 법령의 규정에 의거하거나 수사 목적으로 법령에 정해진 절차와 방법에 따라 '
                  '수사기관의 요구가 있는 경우\n\n'
                  '현재 제3자 제공 내역: 없음',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '5. 개인정보 처리의 위탁',
              content: '회사는 서비스 제공을 위해 다음과 같이 개인정보 처리를 위탁하고 있습니다:\n\n'
                  '- Supabase (데이터베이스 호스팅)\n'
                  '  · 위탁 업무: 사용자 데이터 저장 및 관리\n'
                  '  · 보유 기간: 회원 탈퇴 시 또는 위탁 계약 종료 시까지\n\n'
                  '- TMAP (경로 탐색 API)\n'
                  '  · 위탁 업무: 경로 정보 제공\n'
                  '  · 보유 기간: 서비스 이용 시점에 한함 (별도 저장 안 함)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '6. 정보주체의 권리·의무',
              content:
                  '이용자는 언제든지 다음과 같은 권리를 행사할 수 있습니다:\n\n'
                  '- 개인정보 열람 요구\n'
                  '- 개인정보 정정·삭제 요구\n'
                  '- 개인정보 처리 정지 요구\n'
                  '- 회원 탈퇴 (앱 내 설정 메뉴)\n\n'
                  '권리 행사는 서면, 전화, 이메일 등을 통하여 할 수 있으며, '
                  '회사는 이에 대해 지체 없이 조치하겠습니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '7. 개인정보의 파기',
              content: '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 '
                  '개인정보가 불필요하게 되었을 때에는 지체 없이 해당 개인정보를 파기합니다:\n\n'
                  '- 파기 절차: 불필요한 개인정보는 개인정보 보호책임자의 승인 후 파기\n'
                  '- 파기 방법:\n'
                  '  · 전자적 파일: 복구 불가능한 방법으로 영구 삭제\n'
                  '  · 종이 문서: 분쇄 또는 소각',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '8. 개인정보 보호를 위한 기술적·관리적 대책',
              content: '회사는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:\n\n'
                  '기술적 대책:\n'
                  '- 개인정보 암호화 (비밀번호, 민감 정보)\n'
                  '- 해킹 방지 시스템 (방화벽, 보안 프로그램)\n'
                  '- 접근 기록 보관 및 점검\n\n'
                  '관리적 대책:\n'
                  '- 개인정보 취급자 최소화 및 교육\n'
                  '- 개인정보 보호책임자 지정',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '9. 개인정보 보호책임자',
              content: '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, '
                  '개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제를 위하여 '
                  '아래와 같이 개인정보 보호책임자를 지정하고 있습니다:\n\n'
                  '▶ 개인정보 보호책임자\n'
                  '   성명: 개인정보보호담당자\n'
                  '   이메일: privacy@gonow.app\n\n'
                  '▶ 개인정보 침해 신고\n'
                  '   개인정보침해신고센터: (국번없이) 118\n'
                  '   대검찰청 사이버수사과: (국번없이) 1301\n'
                  '   경찰청 사이버안전국: (국번없이) 182',
            ),
            const SizedBox(height: UIConstants.spacingSectionGap),
            // 시행일 - GitHub 패턴
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingCardInternal),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius:
                    BorderRadius.circular(UIConstants.radiusCard),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시행일',
                    style: AppTextStyles.referenceTitle.copyWith(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '본 개인정보 처리방침은 2026년 1월 1일부터 시행됩니다.',
                    style: AppTextStyles.referenceBody.copyWith(
                      color: Colors.orange[900],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 빌더 / Section builder
  ///
  /// **Context**: 일관된 섹션 포맷 제공
  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.referenceTitle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyles.referenceBody.copyWith(
            color: AppColors.secondaryText,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
