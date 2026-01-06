import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';

/// 회원가입 화면 / Signup Screen
///
/// **기능 / Features**:
/// - 3단계 회원가입 플로우
///   - Step 1: 이메일/비밀번호
///   - Step 2: 이름/전화번호 (선택)
///   - Step 3: 약관 동의
/// - 소셜 회원가입 (Google, Apple, Kakao)
/// - 단계별 유효성 검사
///
/// **Context**: 로그인 화면에서 이동
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Email & Password
  final _step1FormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Step 2: Name & Phone
  final _step2FormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3: Terms & Conditions
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToMarketing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 다음 단계로 이동 / Move to next step
  void _nextStep() {
    if (_currentStep == 0 && !_step1FormKey.currentState!.validate()) return;
    if (_currentStep == 1 && !_step2FormKey.currentState!.validate()) return;
    if (_currentStep == 2 && (!_agreeToTerms || !_agreeToPrivacy)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해주세요')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleSignup();
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

  /// 회원가입 처리 / Handle signup
  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 성공!')),
          );
          Navigator.pop(context); // 로그인 화면으로 돌아가기
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? '회원가입에 실패했습니다',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 소셜 회원가입 / Social signup
  Future<void> _handleSocialSignup(String provider) async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // Provider 문자열을 OAuthProvider로 변환
      final oauthProvider = _getOAuthProvider(provider);
      if (oauthProvider == null) {
        throw Exception('지원하지 않는 소셜 로그인 제공자입니다');
      }

      final success = await authProvider.signInWithProvider(
        provider: oauthProvider,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$provider 회원가입을 시작합니다...')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? '$provider 회원가입에 실패했습니다',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$provider 회원가입 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 소셜 로그인 제공자 변환 / Convert social login provider
  OAuthProvider? _getOAuthProvider(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return OAuthProvider.google;
      case 'apple':
        return OAuthProvider.apple;
      case 'kakao':
        // Supabase에서 Kakao는 custom provider로 설정 필요
        // TODO: Kakao OAuth 설정 후 활성화
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('회원가입'),
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
            const SizedBox(height: 24),

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
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_currentStep == 2 ? '가입 완료' : '다음'),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(
          3,
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
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: 이메일/비밀번호 / Email & Password
  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '계정 정보 입력',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '이메일과 비밀번호를 입력해주세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // 이메일 입력
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '6자 이상 입력',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호 재입력',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 다시 입력해주세요';
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // 구분선
            Row(
              children: [
                Expanded(child: Divider(color: theme.dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '또는',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(child: Divider(color: theme.dividerColor)),
              ],
            ),
            const SizedBox(height: 24),

            // 소셜 회원가입 버튼들
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _handleSocialSignup('Google'),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Google로 시작하기'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _handleSocialSignup('Apple'),
              icon: const Icon(Icons.apple, size: 24),
              label: const Text('Apple로 시작하기'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _handleSocialSignup('Kakao'),
              icon: const Icon(Icons.chat_bubble, size: 24),
              label: const Text('Kakao로 시작하기'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFEE500)),
                foregroundColor: const Color(0xFF3C1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: 이름/전화번호 / Name & Phone
  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '프로필 정보',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '이름과 전화번호를 입력해주세요 (선택사항)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // 이름 입력
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '홍길동',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                // 선택사항이므로 비어있어도 OK
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 전화번호 입력
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010-1234-5678',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                // 선택사항이므로 비어있어도 OK
                // 단, 입력한 경우 형식 검증
                if (value != null && value.isNotEmpty) {
                  final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{4}-?[0-9]{4}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return '올바른 전화번호 형식이 아닙니다';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '프로필 정보는 나중에 설정에서 변경할 수 있습니다',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
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

  /// Step 3: 약관 동의 / Terms & Conditions
  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '약관 동의',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '서비스 이용을 위해 약관에 동의해주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // 전체 동의
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CheckboxListTile(
              value: _agreeToTerms && _agreeToPrivacy && _agreeToMarketing,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                  _agreeToPrivacy = value ?? false;
                  _agreeToMarketing = value ?? false;
                });
              },
              title: const Text('전체 동의'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 16),

          // 이용약관 동의 (필수)
          CheckboxListTile(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            title: Row(
              children: [
                const Text('이용약관 동의'),
                const SizedBox(width: 4),
                Text(
                  '(필수)',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
            subtitle: TextButton(
              onPressed: () {
                // TODO: 이용약관 상세 보기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이용약관 상세 보기 (구현 예정)')),
                );
              },
              child: const Text('내용 보기'),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          // 개인정보 처리방침 동의 (필수)
          CheckboxListTile(
            value: _agreeToPrivacy,
            onChanged: (value) {
              setState(() {
                _agreeToPrivacy = value ?? false;
              });
            },
            title: Row(
              children: [
                const Text('개인정보 처리방침 동의'),
                const SizedBox(width: 4),
                Text(
                  '(필수)',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
            subtitle: TextButton(
              onPressed: () {
                // TODO: 개인정보 처리방침 상세 보기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('개인정보 처리방침 상세 보기 (구현 예정)')),
                );
              },
              child: const Text('내용 보기'),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          // 마케팅 정보 수신 동의 (선택)
          CheckboxListTile(
            value: _agreeToMarketing,
            onChanged: (value) {
              setState(() {
                _agreeToMarketing = value ?? false;
              });
            },
            title: Row(
              children: [
                const Text('마케팅 정보 수신 동의'),
                const SizedBox(width: 4),
                Text(
                  '(선택)',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
            subtitle: const Text('이벤트, 혜택 정보를 받아보실 수 있습니다'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
