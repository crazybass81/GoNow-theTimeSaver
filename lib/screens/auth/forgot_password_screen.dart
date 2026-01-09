import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';

/// 비밀번호 찾기 화면 / Forgot Password Screen
///
/// **기능 / Features**:
/// - 이메일 입력
/// - 비밀번호 재설정 이메일 발송
/// - 발송 완료 안내
///
/// **Context**: 로그인 화면의 "비밀번호 찾기"에서 접근
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// 비밀번호 재설정 이메일 발송 / Send password reset email
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.resetPassword(
        email: _emailController.text.trim(),
      );

      if (success) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } else {
        throw Exception(
            authProvider.errorMessage ?? '이메일 발송에 실패했습니다');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusSnackbar),
            ),
          ),
        );
      }
    }
  }

  /// 이메일 입력 화면 / Email input screen
  Widget _buildEmailForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 안내 문구
          Text(
            '비밀번호 재설정',
            style: AppTextStyles.heading1.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '가입하신 이메일 주소를 입력해주세요.\n비밀번호 재설정 링크를 보내드립니다.',
            style: AppTextStyles.body2.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // 이메일 입력
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              labelText: '이메일',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(UIConstants.radiusTextField),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // 발송 버튼
          ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: UIConstants.paddingButton,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusButton),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    '재설정 링크 보내기',
                    style: AppTextStyles.button,
                  ),
          ),
        ],
      ),
    );
  }

  /// 발송 완료 화면 / Email sent screen
  Widget _buildSuccessScreen(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 완료 아이콘
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),

        // 안내 문구
        Text(
          '이메일이 발송되었습니다',
          style: AppTextStyles.heading1.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '${_emailController.text}로\n비밀번호 재설정 링크를 보냈습니다.\n\n메일함을 확인하여 비밀번호를 재설정해주세요.',
          style: AppTextStyles.body2.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // 로그인 화면으로 돌아가기
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: UIConstants.paddingButton,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusButton),
            ),
          ),
          child: Text(
            '로그인 화면으로 돌아가기',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIConstants.paddingScreen),
          child: Center(
            child: SingleChildScrollView(
              child: _emailSent
                  ? _buildSuccessScreen(theme)
                  : _buildEmailForm(theme),
            ),
          ),
        ),
      ),
    );
  }
}
