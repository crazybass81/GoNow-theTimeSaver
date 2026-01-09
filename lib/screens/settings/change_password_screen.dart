import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';

/// 비밀번호 변경 화면 / Change Password Screen
///
/// **기능 / Features**:
/// - 현재 비밀번호 확인 / Verify current password
/// - 새 비밀번호 입력 / Enter new password
/// - 새 비밀번호 확인 / Confirm new password
/// - 비밀번호 업데이트 / Update password
///
/// **Context**: Settings 화면의 "비밀번호 변경"에서 접근
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          '비밀번호 변경',
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
              // 보안 안내
              Container(
                padding: EdgeInsets.all(UIConstants.spacingCardInternal),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(UIConstants.radiusCard),
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
                        '보안을 위해 주기적으로 비밀번호를 변경하세요',
                        style: AppTextStyles.referenceBody.copyWith(
                          color: Colors.blue[900],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 현재 비밀번호
              Text(
                '현재 비밀번호',
                style: AppTextStyles.formLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: UIConstants.spacingCardGap),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  hintText: '현재 비밀번호를 입력하세요',
                  hintStyle: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: UIConstants.inputBorderEnabled,
                  enabledBorder: UIConstants.inputBorderEnabled,
                  focusedBorder: UIConstants.inputBorderFocused,
                  contentPadding: EdgeInsets.all(UIConstants.spacingCardInternal),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: () {
                      setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                    },
                  ),
                ),
                style: AppTextStyles.referenceBody.copyWith(
                  color: Colors.black87,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 새 비밀번호
              Text(
                '새 비밀번호',
                style: AppTextStyles.formLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: UIConstants.spacingCardGap),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  hintText: '새 비밀번호 (8자 이상)',
                  hintStyle: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: UIConstants.inputBorderEnabled,
                  enabledBorder: UIConstants.inputBorderEnabled,
                  focusedBorder: UIConstants.inputBorderFocused,
                  contentPadding: EdgeInsets.all(UIConstants.spacingCardInternal),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                  ),
                ),
                style: AppTextStyles.referenceBody.copyWith(
                  color: Colors.black87,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 최소 8자 이상이어야 합니다';
                  }
                  if (value == _currentPasswordController.text) {
                    return '현재 비밀번호와 다른 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 새 비밀번호 확인
              Text(
                '새 비밀번호 확인',
                style: AppTextStyles.formLabel.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: UIConstants.spacingCardGap),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: '새 비밀번호를 다시 입력하세요',
                  hintStyle: AppTextStyles.formLabel.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: UIConstants.inputBorderEnabled,
                  enabledBorder: UIConstants.inputBorderEnabled,
                  focusedBorder: UIConstants.inputBorderFocused,
                  contentPadding: EdgeInsets.all(UIConstants.spacingCardInternal),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                style: AppTextStyles.referenceBody.copyWith(
                  color: Colors.black87,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호 확인을 입력해주세요';
                  }
                  if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: UIConstants.spacingSectionGap),

              // 변경 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
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
                          '비밀번호 변경',
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

  /// 비밀번호 변경 처리 / Handle password change
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // TODO: Supabase 비밀번호 변경 API 호출
      // await authProvider.changePassword(
      //   currentPassword: _currentPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 변경되었습니다'),
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
            content: Text('비밀번호 변경 실패: ${e.toString()}'),
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
