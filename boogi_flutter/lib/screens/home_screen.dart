import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBFE3E8), // 아침 안개가 걷힌 상쾌한 파스텔 하늘색
              Color(0xFFE0F2F1), // 따뜻한 온도가 깃든 민트빛 바다 거품색
              Color(0xFFF7FDFD), // 평온하고 안전한 백사장 모래색
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 잔잔한 물결 데코레이션
              ...List.generate(4, (index) {
                final double bottom = 20.0 + (index * 45);
                final double opacity = 0.15 - (index * 0.03);
                final int duration = 5000 + (index * 1500);
                return Positioned(
                  left: -50,
                  right: -50,
                  bottom: bottom,
                  height: 120,
                  child: Opacity(
                    opacity: opacity,
                    child: const CustomPaint(
                      painter: WavePainter(),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .slideX(begin: -0.05, end: 0.05, duration: duration.ms, curve: Curves.easeInOutSine),
                );
              }),

              // 메인 대시보드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    // 평화롭게 둥둥 떠서 아래위로 호흡하는 귀여운 부기 🐢
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DEBE1).withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🐢',
                            style: TextStyle(fontSize: 54),
                          ),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .slideY(begin: -0.1, end: 0.1, duration: 1500.ms, curve: Curves.easeInOutQuad)
                          ..animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.0, 1.0),
                            duration: 800.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                    const SizedBox(height: 30.0),

                    // 여정 시작 타이틀
                    const Text(
                      '나만의 평온한 항해 시작',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E5257),
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    )
                        .animate()
                        .fade(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOut),

                    const SizedBox(height: 8.0),
                    const Text(
                      '축하해요! 안전하고 따뜻한 바다에 무사히 닻을 내렸습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4A7D82),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fade(delay: 500.ms, duration: 600.ms),

                    const SizedBox(height: 40.0),

                    // 온보딩에서 동기화 및 저장한 유저 데이터 요약 카드
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE0F2F1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.directions_boat, color: Color(0xFF4FA095), size: 18),
                              SizedBox(width: 8.0),
                              Text(
                                '나의 여행 정보',
                                style: TextStyle(
                                  color: Color(0xFF1E5257),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24.0, color: Color(0xFFE0F2F1)),
                          _buildInfoRow(
                            label: '여행자 유형',
                            value: onboardingState.userStatus.isNotEmpty
                                ? onboardingState.userStatus
                                : '미선택 여행자',
                          ),
                          const SizedBox(height: 12.0),
                          _buildInfoRow(
                            label: '나를 위한 한마디',
                            value: onboardingState.pledgeText.isNotEmpty
                                ? '"${onboardingState.pledgeText}"'
                                : '"지치지 않고 헤엄치기"',
                            isItalic: true,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fade(delay: 800.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOut),

                    const Spacer(),

                    // 초기화 및 다시 온보딩 테스트할 수 있는 보조 버튼
                    TextButton(
                      onPressed: () {
                        ref.read(onboardingProvider.notifier).reset();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: const Text(
                        '온보딩 다시 체험하기',
                        style: TextStyle(
                          color: Color(0xFF4A7D82),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isItalic = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A989B),
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF2E4E52),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  const WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4FA095)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.35,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.65,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
