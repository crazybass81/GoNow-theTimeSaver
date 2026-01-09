import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';

/// 프로필 수정 화면 / Edit Profile Screen
///
/// **기능 / Features**:
/// - 이름 변경 / Change name
/// - 전화번호 변경 / Change phone number
/// - 프로필 정보 업데이트 / Update profile information
///
/// **Context**: Settings 화면의 "프로필 수정"에서 접근
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.currentUser?.userMetadata?['name'] as String?;
    final userPhone = authProvider.currentUser?.userMetadata?['phone'] as String?;

    _nameController = TextEditingController(text: userName ?? '');
    _phoneController = TextEditingController(text: userPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          '프로필 수정',
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UIConstants.spacingScreen),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름 입력
              Text(
                '이름',
                style: AppTextStyles.formLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: UIConstants.spacingCardGap),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름을 입력하세요',
                  hintStyle: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: UIConstants.inputBorderEnabled,
                  enabledBorder: UIConstants.inputBorderEnabled,
                  focusedBorder: UIConstants.inputBorderFocused,
                  contentPadding: EdgeInsets.all(UIConstants.spacingCardInternal),
                ),
                style: AppTextStyles.referenceBody.copyWith(
                  color: Colors.black87,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 전화번호 입력
              Text(
                '전화번호',
                style: AppTextStyles.formLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: UIConstants.spacingCardGap),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: UIConstants.inputBorderEnabled,
                  enabledBorder: UIConstants.inputBorderEnabled,
                  focusedBorder: UIConstants.inputBorderFocused,
                  contentPadding: EdgeInsets.all(UIConstants.spacingCardInternal),
                ),
                style: AppTextStyles.referenceBody.copyWith(
                  color: Colors.black87,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
                  // 간단한 전화번호 형식 검증
                  final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
                  if (!phoneRegex.hasMatch(value.replaceAll('-', ''))) {
                    return '올바른 전화번호 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: UIConstants.primaryButtonStyle,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '저장',
                          style: AppTextStyles.referenceBody.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

  /// 프로필 저장 / Save profile
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // TODO: Supabase에 프로필 업데이트 API 호출
      // await authProvider.updateProfile(
      //   name: _nameController.text.trim(),
      //   phone: _phoneController.text.trim(),
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필이 업데이트되었습니다'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusSnackbar),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 업데이트 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusSnackbar),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
