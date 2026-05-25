import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'onboarding_chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후 온보딩 대화 화면으로 자동 전환
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE2F6F8), // 아주 여린 파스텔 민트색
              Color(0xFFB5E3E6), // 뽀글뽀글 바다 거품 파스텔색
            ],
          ),
        ),
        child: Stack(
          children: [
            // 물방울 뽀글뽀글 배경 데코레이션
            ...List.generate(15, (index) {
              final double left = (index * 27) % 360 + 20;
              final double bottom = (index * 58) % 600 + 50;
              final double size = (index * 7) % 15 + 8;
              return Positioned(
                left: left,
                bottom: bottom,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .slideY(
                      begin: 1.0,
                      end: -3.0,
                      duration: Duration(seconds: 4 + (index % 3)),
                      curve: Curves.easeOut,
                    )
                    .fade(begin: 0.3, end: 0.0),
              );
            }),

            // 중앙 로고 & 부기 아이콘 + 로딩 인디케이터
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 감성적인 부기온앤온 로고
                  Text(
                    'Boogi On & On',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E5257),
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fade(duration: 800.ms, curve: Curves.easeOut)
                      .scale(
                          delay: 100.ms,
                          duration: 800.ms,
                          curve: Curves.easeOutBack),
                  const SizedBox(height: 12.0),
                  Text(
                    '각자의 물결을 따라서 On&On',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: const Color(0xFF4A7D82),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fade(delay: 500.ms, duration: 800.ms),
                  const SizedBox(height: 60.0),

                  // 부기 아이콘 (가만히 고정) + 원형 로딩 인디케이터
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 빙글빙글 도는 원형 로딩
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF4FA095).withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        // 가운데 고정된 부기 아이콘
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF4FA095).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '🐢',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 300.ms, duration: 600.ms).scale(
                        delay: 300.ms,
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '물장구 준비 중...',
                    style: TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: 600.ms, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
