import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    // 감정별 컬러 맵 지정 (선택 시 활용할 테마 컬러)
    Color getEmotionColor(String emotion) {
      switch (emotion) {
        case '☀️ 맑음':
          return const Color(0xFFFBC02D); // 포근하고 따뜻한 골드 옐로우
        case '☁️ 잔잔':
          return const Color(0xFF4DB6AC); // 차분하고 평온한 민트 테알
        case '🌧️ 비 옴':
          return const Color(0xFF5C6BC0); // 슬픔을 포근히 안아주는 인디고 블루
        default:
          return const Color(0xFF4FA095);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // main_layout의 그라데이션이 비치도록 설정
      body: Stack(
        children: [
          // 1. 잔잔하게 물결치는 바다 데코레이션
          ...List.generate(3, (index) {
            final double bottom = 40.0 + (index * 35);
            final double opacity = 0.12 - (index * 0.03);
            final int duration = 6000 + (index * 2000);
            return Positioned(
              left: -60,
              right: -60,
              bottom: bottom,
              height: 110,
              child: Opacity(
                opacity: opacity,
                child: const CustomPaint(
                  painter: WavePainter(),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .slideX(begin: -0.06, end: 0.06, duration: duration.ms, curve: Curves.easeInOutSine),
            );
          }),

          // 2. 메인 컨텐츠 영역
          SafeArea(
            bottom: false, // 바텀 네비게이션 플로팅과의 여유 공간을 위해
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),

                  // [상단 영역] 온보딩 정보 뱃지 및 환영 타이틀
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FA095).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: const Color(0xFF4FA095).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('⛵ ', style: TextStyle(fontSize: 12)),
                            Text(
                              onboardingState.userStatus.isNotEmpty
                                  ? onboardingState.userStatus
                                  : '포근한 여행자',
                              style: const TextStyle(
                                color: Color(0xFF1E5257),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fade(duration: 600.ms)
                          .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
                      
                      // 온보딩 리셋/체험용 간소화된 버튼
                      IconButton(
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).reset();
                          ref.read(homeProvider.notifier).reset();
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF5A7D82)),
                        tooltip: '온보딩 다시하기',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  // 위로와 안정을 주는 따뜻한 감성 질문
                  const Text(
                    '오늘 바다는 어때?',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                  )
                      .animate()
                      .fade(duration: 700.ms)
                      .slideY(begin: 0.15, end: 0.0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 6.0),
                  
                  // 유저가 등록한 다짐을 서브 텍스트로 녹여내어 극대화된 감성 선사
                  Text(
                    onboardingState.pledgeText.isNotEmpty
                        ? '“${onboardingState.pledgeText}”'
                        : '완벽하지 않아도 괜찮아. 느려도 꾸준히 헤엄치자.',
                    style: const TextStyle(
                      color: Color(0xFF5A7D82),
                      fontSize: 13.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fade(delay: 200.ms, duration: 700.ms),

                  const SizedBox(height: 20.0),

                  // 감정 체크인 버튼 목록 (ChoiceChips)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEmotionChip(
                        emotion: '☀️ 맑음',
                        isSelected: homeState.selectedEmotion == '☀️ 맑음',
                        onTap: () => homeNotifier.selectEmotion('☀️ 맑음'),
                        themeColor: getEmotionColor('☀️ 맑음'),
                      ),
                      const SizedBox(width: 8.0),
                      _buildEmotionChip(
                        emotion: '☁️ 잔잔',
                        isSelected: homeState.selectedEmotion == '☁️ 잔잔',
                        onTap: () => homeNotifier.selectEmotion('☁️ 잔잔'),
                        themeColor: getEmotionColor('☁️ 잔잔'),
                      ),
                      const SizedBox(width: 8.0),
                      _buildEmotionChip(
                        emotion: '🌧️ 비 옴',
                        isSelected: homeState.selectedEmotion == '🌧️ 비 옴',
                        onTap: () => homeNotifier.selectEmotion('🌧️ 비 옴'),
                        themeColor: getEmotionColor('🌧️ 비 옴'),
                      ),
                    ],
                  )
                      .animate()
                      .fade(delay: 350.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOut),

                  const SizedBox(height: 36.0),

                  // [중앙 영역] 둥근 유기적 바위 섬 컨테이너 & 궁극의 숨쉬기 퀘스트
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 숨 쉬기 퀘스트 완료 시, 바위 섬 뒷편에서 은은하게 뿜어져 나오는 신비로운 후광 효과
                        if (homeState.hasBreathed)
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6DEBE1).withValues(alpha: 0.45),
                                  blurRadius: 40,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 2.seconds, curve: Curves.easeInOutSine),

                        // 바위 섬 메인 컨테이너
                        GestureDetector(
                          onTap: () {
                            homeNotifier.toggleBreathed();
                            _triggerQuestVibration(context, !homeState.hasBreathed);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              // 자연의 동글동글한 유기적 바위 섬을 재현하는 불규칙하고 부드러운 border-radius
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(90),
                                topRight: Radius.circular(105),
                                bottomLeft: Radius.circular(110),
                                bottomRight: Radius.circular(85),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: homeState.hasBreathed
                                    ? [
                                        const Color(0xFF539C94), // 따뜻한 온기가 빛나는 청록색 바위
                                        const Color(0xFF7CCEC4), 
                                      ]
                                    : [
                                        const Color(0xFF8FA19B), // 잔잔하고 거친 회녹색의 조용한 바위
                                        const Color(0xFFA5B7B1),
                                      ],
                              ),
                              border: Border.all(
                                color: homeState.hasBreathed
                                    ? const Color(0xFF6DEBE1).withValues(alpha: 0.7)
                                    : const Color(0xFFE0F2F1).withValues(alpha: 0.4),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (homeState.hasBreathed
                                          ? const Color(0xFF4FA095)
                                          : const Color(0xFF1E5257))
                                      .withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 바위 위에서 유유히 떠돌거나 둥실둥실 호흡하는 부기 🐢
                                Text(
                                  homeState.hasBreathed ? '🥰' : '🐢',
                                  style: const TextStyle(fontSize: 48),
                                )
                                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                    .slideY(begin: -0.08, end: 0.08, duration: 1600.ms, curve: Curves.easeInOutQuad),
                                
                                const SizedBox(height: 14),

                                // 필수 생존 퀘스트 텍스트 및 이쁜 체크 박스
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 체크 상태에 따라 크기와 형태가 부드럽게 변하는 커스텀 애니메이션 체크박스
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: homeState.hasBreathed
                                              ? const Color(0xFF4FA095)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: const Color(0xFF4FA095),
                                            width: 2,
                                          ),
                                        ),
                                        child: homeState.hasBreathed
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '🪁 오늘 하루 숨 쉬기',
                                        style: TextStyle(
                                          color: Color(0xFF1E5257),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              // 바위가 계속 둥둥 떠있는 느낌의 평온한 상하 애니메이션
                              .animate(
                                key: ValueKey('rock_island_${homeState.hasBreathed}'),
                                onPlay: (controller) => controller.repeat(reverse: true),
                              )
                              .slideY(begin: -0.03, end: 0.03, duration: 2500.ms, curve: Curves.easeInOutSine)
                              // 숨쉬기를 마쳤을 때 축하하는 심박동(Pulse) 애니메이션 작동
                              .scale(
                                begin: homeState.hasBreathed ? const Offset(1.03, 1.03) : const Offset(1.0, 1.0),
                                end: homeState.hasBreathed ? const Offset(0.97, 0.97) : const Offset(1.0, 1.0),
                                duration: homeState.hasBreathed ? 3.seconds : 100.ms,
                                curve: Curves.easeInOutQuad,
                              ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fade(delay: 500.ms, duration: 800.ms)
                      .scale(delay: 500.ms, begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

                  const SizedBox(height: 32.0),

                  // 안전하고 평온한 바다 공간에 있음을 상기시키는 감성 한 숟가락 코멘트
                  Center(
                    child: Text(
                      homeState.hasBreathed
                          ? '휴우... 깊은 평화가 깃들길 바랄게.'
                          : '아무리 지치고 무기력해도,\n숨 쉬는 것만으로 오늘 너는 완벽하게 생존했어.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: homeState.hasBreathed ? const Color(0xFF1E5257) : const Color(0xFF7A989B),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  )
                      .animate(key: ValueKey('breath_comment_${homeState.hasBreathed}'))
                      .fade(duration: 400.ms),

                  const SizedBox(height: 90.0), // 바텀 탭바에 가려지지 않기 위한 여백
                ],
              ),
            ),
          ),

          // [우측 하단] 특수 액션 버튼 (🔥 모닥불 FAB)
          Positioned(
            right: 20.0,
            bottom: 104.0, // 바텀 플로팅 탭바(72px) 위에 안전하게 떠있도록 마진 설계
            child: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Text('🔥 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            '모닥불 화면 이동 대기',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFD87D56),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: const Color(0xFFE89A73),
              foregroundColor: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: const Text(
                '모닥불',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              icon: const Text('🔥', style: TextStyle(fontSize: 18)),
            )
                .animate()
                .fade(delay: 800.ms, duration: 600.ms)
                .scale(delay: 800.ms, begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  // 감정 체크인 커스텀 칩
  Widget _buildEmotionChip({
    required String emotion,
    required bool isSelected,
    required VoidCallback onTap,
    required Color themeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isSelected ? themeColor : const Color(0xFFE0F2F1),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emotion.split(' ')[0], // 이모티콘만 추출 (☀️, ☁️, 🌧️)
                style: const TextStyle(fontSize: 20),
              )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.25, 1.25), duration: 200.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 4.0),
              Text(
                emotion.split(' ')[1], // 텍스트만 추출 (맑음, 무난, 벅참)
                style: TextStyle(
                  color: isSelected ? themeColor.withValues(alpha: 0.95) : const Color(0xFF5A7D82),
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 퀘스트 완료 시 소소한 스낵바나 반응 피드백
  void _triggerQuestVibration(BuildContext context, bool isCompleted) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(isCompleted ? '🫁 ' : '🐢 ', style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                isCompleted
                    ? '오늘 생존 퀘스트를 달성했습니다. 큰 쉼을 잘 내쉬었습니다.'
                    : '오늘 하루 숨 쉬기 퀘스트가 리셋되었습니다. 조급하지 않게 숨을 쉬어 봐요.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isCompleted ? const Color(0xFF4FA095) : const Color(0xFF7A989B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 잔잔하게 흔들리는 물결을 만드는 CustomPainter
class WavePainter extends CustomPainter {
  const WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6DEBE1).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.25,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.55,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
