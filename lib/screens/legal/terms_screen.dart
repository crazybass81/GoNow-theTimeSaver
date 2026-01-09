import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';

/// 이용약관 화면 / Terms of Service Screen
///
/// **기능 / Features**:
/// - 서비스 이용약관 표시 (8개 조항)
/// - 법적 필수 화면 (앱스토어 심사 요구사항)
///
/// **Context**: Settings 화면에서 접근
/// **참고 / Reference**: GitHub khyapple/go_now terms_screen.dart
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          '이용약관',
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
            _buildSection(
              title: '제1조 (목적)',
              content:
                  '본 약관은 GoNow(이하 "회사")가 제공하는 ADHD 시간 관리 서비스(이하 "서비스")의 이용과 관련하여 '
                  '회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제2조 (정의)',
              content: '1. "서비스"란 회사가 제공하는 역산 스케줄링 기반 시간 관리 애플리케이션을 의미합니다.\n'
                  '2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 자를 의미합니다.\n'
                  '3. "일정"이란 이용자가 서비스에 등록한 약속, 회의 등의 시간 관리 정보를 의미합니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제3조 (약관의 효력 및 변경)',
              content:
                  '1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.\n'
                  '2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 변경할 수 있습니다.\n'
                  '3. 약관이 변경되는 경우 회사는 변경사항을 시행일 7일 전부터 공지합니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제4조 (서비스의 제공)',
              content: '1. 회사는 다음과 같은 서비스를 제공합니다:\n'
                  '   - 역산 스케줄링: 도착 시간 기준 출발 시간 자동 계산\n'
                  '   - 경로 탐색: TMAP API 기반 대중교통/자동차 경로\n'
                  '   - 실시간 알림: 출발 시간 30분/10분 전 푸시 알림\n'
                  '   - 홈 위젯: 다음 일정 카운트다운 표시\n'
                  '2. 서비스는 연중무휴 1일 24시간 제공함을 원칙으로 합니다.\n'
                  '3. 회사는 시스템 점검, 보수 등의 사유로 서비스 제공을 일시적으로 중단할 수 있습니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제5조 (이용자의 의무)',
              content: '이용자는 다음 행위를 하여서는 안 됩니다:\n'
                  '1. 타인의 정보 도용\n'
                  '2. 회사가 게시한 정보의 변경\n'
                  '3. 회사 또는 제3자의 지적재산권 침해\n'
                  '4. 회사의 서비스 운영을 방해하는 행위\n'
                  '5. 외설적이거나 폭력적인 정보 등록',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제6조 (저작권의 귀속)',
              content:
                  '1. 서비스 내 회사가 제공하는 콘텐츠에 대한 저작권 및 지적재산권은 회사에 귀속됩니다.\n'
                  '2. 이용자가 서비스 내에 게시한 게시물의 저작권은 이용자에게 귀속됩니다.\n'
                  '3. 이용자는 서비스를 이용하여 얻은 정보를 회사의 사전 승낙 없이 복제, 송신, 출판, 배포, 방송 등 '
                  '기타 방법으로 이용하거나 제3자에게 이용하게 하여서는 안 됩니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제7조 (개인정보 보호)',
              content:
                  '1. 회사는 이용자의 개인정보를 보호하기 위하여 개인정보처리방침을 운영합니다.\n'
                  '2. 회사는 법령에 의하거나 이용자가 별도로 동의하지 아니하는 한 이용자의 개인정보를 제3자에게 제공하지 않습니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '제8조 (면책사항)',
              content:
                  '1. 회사는 천재지변, 전쟁, 기간통신사업자의 서비스 중지 등 불가항력으로 인하여 서비스를 제공할 수 없는 경우 '
                  '서비스 제공에 대한 책임이 면제됩니다.\n'
                  '2. 회사는 이용자의 귀책사유로 인한 서비스 이용 장애에 대하여 책임을 지지 않습니다.\n'
                  '3. 회사는 TMAP API 등 제3자 서비스의 장애로 인한 손해에 대하여 책임을 지지 않습니다.\n'
                  '4. 회사는 이용자가 서비스를 이용하여 기대하는 효과를 얻지 못한 것에 대하여 책임을 지지 않습니다.',
            ),
            const SizedBox(height: UIConstants.spacingSectionGap),
            // 부칙 (Supplementary Provision) - GitHub 패턴
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '부칙',
                    style: AppTextStyles.referenceTitle.copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '본 약관은 2026년 1월 1일부터 시행됩니다.',
                    style: AppTextStyles.referenceBody.copyWith(
                      color: Colors.blue[900],
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

  /// 약관 섹션 빌더 / Terms section builder
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
