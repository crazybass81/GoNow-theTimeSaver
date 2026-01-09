import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_colors.dart';
import '../../utils/github_ui_constants.dart';

/// 스플래시 화면 / Splash Screen
///
/// **기능 / Features**:
/// - 앱 시작 시 브랜딩 경험 제공 / Provides branding experience on app launch
/// - 페이드 인 애니메이션 / Fade-in animation
/// - 2.5초 후 AuthGate로 전환 / Transitions to AuthGate after 2.5 seconds
///
/// **Context**: 앱 시작 시 표시되는 첫 화면 / First screen shown on app launch
/// **Design**: GitHub UI pattern with GitHubUI constants
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 페이드 인 애니메이션 설정 / Setup fade-in animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // 애니메이션 시작 / Start animation
    _animationController.forward();

    // 2.5초 후 다음 화면으로 전환 / Navigate to next screen after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 아이콘 / Logo icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GitHubUI.radiusDialog),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: GitHubUI.spacingSectionGap),
              // 앱 이름 / App name
              const Text(
                'GoNow',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // 부제목 / Subtitle
              Text(
                'Time Saver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
