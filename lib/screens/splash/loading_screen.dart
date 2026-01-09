import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/ui_constants.dart';
import '../auth/login_screen.dart';
import '../main_wrapper.dart';

/// 로딩 화면 / Loading Screen
///
/// **기능 / Features**:
/// - 인증 상태 확인 / Check authentication status
/// - 사용자 데이터 프리로드 / Preload user data
/// - Supabase 연결 확인 / Verify Supabase connection
/// - 에러 처리 및 재시도 / Error handling with retry
///
/// **Context**: Splash 후 또는 앱 초기화 시 데이터 로딩 표시
/// **Design**: GitHub pattern + Local enhancements (Provider, error handling)
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _statusMessage = '데이터를 불러오는 중...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 초기화 및 인증 확인 / Initialize app and check authentication
  Future<void> _initializeApp() async {
    setState(() {
      _statusMessage = '인증 상태 확인 중...';
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // AuthProvider는 constructor에서 이미 인증 상태를 확인했음
      // AuthProvider already checked auth state in constructor
      // 약간의 지연을 주어 초기화 완료 대기 / Small delay to wait for initialization
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // 인증된 사용자의 데이터 로드 / Load authenticated user data
      if (authProvider.currentUser != null) {
        setState(() {
          _statusMessage = '일정 데이터를 불러오는 중...';
        });

        final tripProvider = context.read<TripProvider>();
        await tripProvider.loadTrips(authProvider.currentUser!.id);

        if (!mounted) return;

        // 성공: MainWrapper로 이동 / Success: Navigate to MainWrapper
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      } else {
        // 미인증 사용자: LoginScreen으로 이동 / Unauthenticated: Navigate to LoginScreen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // 에러 처리 / Error handling
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _statusMessage = '데이터 로딩 실패';
        });
      }
    }
  }

  /// 재시도 / Retry initialization
  Future<void> _retry() async {
    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingScreen),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 아이콘 / Logo icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(UIConstants.radiusCard),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingSectionGap),

                // 앱 이름 / App name
                Text(
                  'GoNow',
                  style: AppTextStyles.dateHeader.copyWith(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingCardGap),

                // 상태 메시지 / Status message
                Text(
                  _statusMessage,
                  style: AppTextStyles.referenceBody.copyWith(
                    color: _hasError ? AppColors.errorMedium : AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spacingSectionGap),

                // 로딩 인디케이터 또는 에러 UI / Loading indicator or error UI
                if (!_hasError)
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary!),
                    ),
                  )
                else
                  Column(
                    children: [
                      // 에러 아이콘 / Error icon
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.errorMedium,
                      ),
                      const SizedBox(height: UIConstants.spacingCardGap),

                      // 에러 메시지 / Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(UIConstants.spacingCardInternal),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(UIConstants.radiusCard),
                            border: Border.all(color: AppColors.errorMedium, width: 1),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.referenceLabel.copyWith(
                              color: AppColors.errorMedium,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: UIConstants.spacingSectionGap),

                      // 재시도 버튼 / Retry button
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.spacingScreen,
                            vertical: UIConstants.spacingCardGap,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(UIConstants.radiusCard),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          '재시도',
                          style: AppTextStyles.formLabel.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingCardGap),

                      // 로그인 화면으로 이동 버튼 / Go to login button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          '로그인 화면으로 이동',
                          style: AppTextStyles.referenceLabel.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
