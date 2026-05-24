import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'onboarding_chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _turtleController;
  late Animation<double> _turtleAnimation;

  @override
  void initState() {
    super.initState();
    _turtleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _turtleAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _turtleController, curve: Curves.easeInOutCubic),
    );

    // 거북이 애니메이션을 시작하고, 끝나면 온보딩 대화창으로 전환합니다.
    _turtleController.forward().then((_) {
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
  void dispose() {
    _turtleController.dispose();
    super.dispose();
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

            // 중앙 로고 & 거북이 수영 영역
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
                  const Text(
                    '완벽하지 않아도 괜찮은 바다',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFF4A7D82),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ).animate().fade(delay: 500.ms, duration: 800.ms),
                  const SizedBox(height: 80.0),

                  // 거북이가 지나가는 수영선 레인
                  ClipRect(
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: AnimatedBuilder(
                        animation: _turtleAnimation,
                        builder: (context, child) {
                          return FractionalTranslation(
                            translation: Offset(_turtleAnimation.value, 0.0),
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4FA095),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '🐢',
                                  style: TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            const Text(
                              '느릿느릿...',
                              style: TextStyle(
                                color: Color(0xFF1E5257),
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
}
