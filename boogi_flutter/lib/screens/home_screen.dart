import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../providers/home_provider.dart';

// ─────────────────────────────────────────────────────────────
// 홈 화면 — Finch 스타일 캐릭터 인터랙션 + 목표 리스트 (Fidelity 리팩토링)
// 디자인 톤: 파스텔 민트(#B2DFDB) 베이스 + 비비드 코랄(#FF823A) 포인트
// ─────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 감정별 테마 컬러 (코랄 포인트와 민트 베이스에 어울리는 소프트 톤)
  Color _getMoodColor(String? mood) {
    switch (mood) {
      case '☀️ 맑음':
        return const Color(0xFFFF823A); // 성취와 오늘을 나타내는 비비드 코랄
      case '☁️ 잔잔':
        return const Color(0xFF4DB6AC); // 평온한 민트
      case '🌧️ 비 옴':
        return const Color(0xFF5C6BC0); // 깊은 바다 파랑
      default:
        return const Color(0xFF4DB6AC);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final moodColor = _getMoodColor(homeState.selectedMood);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. 배경 물결 데코레이션 (파스텔 민트 베이스) ──
          ...List.generate(3, (index) {
            final double bottom = 40.0 + (index * 35);
            final double opacity = 0.15 - (index * 0.04);
            final int duration = 6000 + (index * 2000);
            return Positioned(
              left: -60,
              right: -60,
              bottom: bottom,
              height: 110,
              child: Opacity(
                opacity: opacity,
                child: const CustomPaint(painter: WavePainter()),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideX(
                    begin: -0.06,
                    end: 0.06,
                    duration: duration.ms,
                    curve: Curves.easeInOutSine,
                  ),
            );
          }),

          // ── 2. 메인 스크롤 콘텐츠 ──
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8.0),

                  // [상단 바] 유저 상태 뱃지 + 리셋 버튼
                  _buildTopBar(context, ref, onboardingState),
                  const SizedBox(height: 20.0),

                  // [캐릭터 섹션] 부기 🐢 + 기분 칩 + 인용문
                  _buildCharacterSection(
                    homeState: homeState,
                    onboardingState: onboardingState,
                    moodColor: moodColor,
                  ),
                  const SizedBox(height: 24.0),

                  // [에너지 바] 여행 에너지 프로그레스 바 (민트 ➔ 코랄 그라데이션)
                  _buildEnergyBar(homeState),
                  const SizedBox(height: 28.0),

                  // [완료 섹션] 오늘 완료한 일 (기본: 접힘)
                  _buildCollapsibleSection(
                    context: context,
                    sectionKey: 'completed',
                    title: '오늘 완료한 일',
                    emoji: '✨',
                    goals: homeState.completedGoals,
                    notifier: homeNotifier,
                    initiallyExpanded: false,
                    isCompletedSection: true,
                  ),
                  const SizedBox(height: 16.0),

                  // [활성 섹션 1] 하루의 시작 (기본: 펼침)
                  _buildCollapsibleSection(
                    context: context,
                    sectionKey: 'morning',
                    title: '하루의 시작',
                    emoji: '🌅',
                    goals: homeState.activeBySection('morning'),
                    notifier: homeNotifier,
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 16.0),

                  // [활성 섹션 2] 언제든 편한 때! (기본: 펼침)
                  _buildCollapsibleSection(
                    context: context,
                    sectionKey: 'anytime',
                    title: '언제든 편한 때!',
                    emoji: '🌊',
                    goals: homeState.activeBySection('anytime'),
                    notifier: homeNotifier,
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 20.0),

                  // [추가 버튼] 목표 추가
                  _buildAddGoalButton(context),

                  // 에너지 달성 완료 메시지 (비비드 코랄 하이라이트 배너)
                  if (homeState.energyProgress >= 1.0) ...[
                    const SizedBox(height: 20.0),
                    _buildCompletionBanner(),
                  ],

                  const SizedBox(height: 100.0), // 바텀 탭바 여백
                ],
              ),
            ),
          ),

          // ── 3. 모닥불 FAB (비비드 코랄 강조) ──
          Positioned(
            right: 20.0,
            bottom: 104.0,
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
                    backgroundColor: const Color(0xFFFF823A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: const Color(0xFFFF823A),
              foregroundColor: Colors.white,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: const Text(
                '모닥불',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
              icon: const Text('🔥', style: TextStyle(fontSize: 18)),
            )
                .animate()
                .fade(delay: 800.ms, duration: 600.ms)
                .scale(
                  delay: 800.ms,
                  begin: const Offset(0.7, 0.7),
                  curve: Curves.easeOutBack,
                ),
          ),

          // ── 4. 일간 기분 체크 오버레이 (진입 시 1회 필수 노출) ──
          IgnorePointer(
            ignoring: homeState.isMoodSelected,
            child: AnimatedOpacity(
              opacity: homeState.isMoodSelected ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: _buildMoodOverlay(ref, homeNotifier),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 상단 바: 유저 상태 뱃지 + 리셋 버튼 ───────────────────

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    OnboardingState onboardingState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFB2DFDB).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFB2DFDB).withValues(alpha: 0.4),
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
                  color: Color(0xFF004D40),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fade(duration: 600.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              curve: Curves.easeOutBack,
            ),
        IconButton(
          onPressed: () {
            ref.read(onboardingProvider.notifier).reset();
            ref.read(homeProvider.notifier).reset();
            Navigator.of(context).pushReplacementNamed('/');
          },
          icon: const Icon(
            Icons.refresh_rounded,
            size: 20,
            color: Color(0xFF5A7D82),
          ),
          tooltip: '온보딩 다시하기',
        ),
      ],
    );
  }

  // ─── 캐릭터 섹션: 부기 🐢 + 무드 칩 + 인용문 ──────────────

  Widget _buildCharacterSection({
    required HomeState homeState,
    required OnboardingState onboardingState,
    required Color moodColor,
  }) {
    return Column(
      children: [
        // 무드 선택 이후 비비드 코랄 또는 파스텔 민트 무드 칩 표시
        if (homeState.isMoodSelected && homeState.selectedMood != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: moodColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              homeState.selectedMood!,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w800,
                color: moodColor == const Color(0xFFFF823A) 
                    ? const Color(0xFFFF823A)
                    : const Color(0xFF00796B),
              ),
            ),
          )
              .animate()
              .fade(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.easeOutBack,
              ),

        // 부기 캐릭터 (큼직하게) + 무드 기반 후광
        Stack(
          alignment: Alignment.center,
          children: [
            if (homeState.isMoodSelected)
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: moodColor.withValues(alpha: 0.25),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2500.ms,
                    curve: Curves.easeInOutSine,
                  ),

            // 부기 🐢 본체
            const Text('🐢', style: TextStyle(fontSize: 72))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideY(
                  begin: -0.06,
                  end: 0.06,
                  duration: 1800.ms,
                  curve: Curves.easeInOutQuad,
                ),
          ],
        )
            .animate()
            .fade(delay: 200.ms, duration: 700.ms)
            .scale(
              delay: 200.ms,
              begin: const Offset(0.8, 0.8),
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 14.0),

        // 서약 인용문 (담백한 안내 문구)
        Text(
          onboardingState.pledgeText.isNotEmpty
              ? '"${onboardingState.pledgeText}"'
              : '완벽하지 않아도 괜찮아. 느려도 꾸준히 헤엄치자.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF5A7D82),
            fontSize: 13.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        )
            .animate()
            .fade(delay: 400.ms, duration: 600.ms),
      ],
    );
  }

  // ─── 에너지 프로그레스 바 (민트 ➔ 비비드 코랄 그라데이션) ─────────────────

  Widget _buildEnergyBar(HomeState homeState) {
    final progress = homeState.energyProgress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFB2DFDB).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ 여행 에너지',
                style: TextStyle(
                  color: Color(0xFF004D40),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${homeState.totalEnergy} / ${homeState.maxEnergy}',
                style: const TextStyle(
                  color: Color(0xFFFF823A), // 비비드 코랄로 수치 강조
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // 프로그레스 바 본체 (민트에서 비비드 코랄로 자연스러운 변화)
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 14.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFB2DFDB).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF80CBC4), Color(0xFFFF823A)],
                      ),
                      borderRadius: BorderRadius.circular(7.0),
                      boxShadow: progress > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF823A).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    )
        .animate()
        .fade(delay: 300.ms, duration: 600.ms)
        .slideY(begin: 0.08, end: 0.0, curve: Curves.easeOut);
  }

  // ─── 접이식 목표 섹션 (ExpansionTile + 둥근 컨테이너) ─────

  Widget _buildCollapsibleSection({
    required BuildContext context,
    required String sectionKey,
    required String title,
    required String emoji,
    required List<GoalItem> goals,
    required HomeNotifier notifier,
    required bool initiallyExpanded,
    bool isCompletedSection = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFB2DFDB).withValues(alpha: 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>(sectionKey),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          childrenPadding: EdgeInsets.zero,
          iconColor: const Color(0xFF5A7D82),
          collapsedIconColor: const Color(0xFF8BA6A1),
          title: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF004D40),
                  fontSize: 15.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              
              // 목표 개수 뱃지 (완료 섹션은 코랄 포인트, 활성은 민트 베이스)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompletedSection
                      ? const Color(0xFFFF823A).withValues(alpha: 0.12)
                      : const Color(0xFFB2DFDB).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${goals.length}',
                  style: TextStyle(
                    color: isCompletedSection
                        ? const Color(0xFFFF823A)
                        : const Color(0xFF004D40),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: goals.isEmpty
              ? [_buildEmptyState(isCompletedSection)]
              : [
                  for (int i = 0; i < goals.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: const Color(0xFFB2DFDB).withValues(alpha: 0.25),
                      ),
                    _buildGoalItem(context, goals[i], notifier),
                  ],
                  const SizedBox(height: 4),
                ],
        ),
      ),
    )
        .animate()
        .fade(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0.0, curve: Curves.easeOut);
  }

  Widget _buildEmptyState(bool isCompletedSection) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Text(
        isCompletedSection
            ? '아직 완료한 일이 없어요. 천천히 시작해 볼까?'
            : '모든 목표를 달성했어! 🎉',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8BA6A1),
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // ─── 개별 목표 아이템 행 (비비드 코랄 체크박스 & 라인 쓰루 연동) ───────────────────

  Widget _buildGoalItem(
    BuildContext context,
    GoalItem goal,
    HomeNotifier notifier,
  ) {
    return InkWell(
      onTap: () {
        final willComplete = !goal.isCompleted;
        notifier.toggleGoal(goal.id);

        if (willComplete) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('⚡ ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      '+${goal.energyReward} 에너지 충전 완료!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFF823A), // 성취의 비비드 코랄
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(milliseconds: 1200),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // 커스텀 코랄 원형 체크박스
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goal.isCompleted
                    ? const Color(0xFFFF823A)
                    : Colors.transparent,
                border: Border.all(
                  color: goal.isCompleted
                      ? const Color(0xFFFF823A)
                      : const Color(0xFF80CBC4),
                  width: 2,
                ),
              ),
              child: goal.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            // 목표 제목 (완료 시 은은한 회색 처리)
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: goal.isCompleted
                      ? const Color(0xFFB0BEC5) // 성취 탭 내 회색 텍스트
                      : const Color(0xFF004D40),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  decoration: goal.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: const Color(0xFFB0BEC5),
                  fontFamily: 'Pretendard',
                ),
                child: Text(goal.title),
              ),
            ),

            // 에너지 보상 뱃지 (비비드 코랄 하이라이트)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: goal.isCompleted
                    ? const Color(0xFFFF823A).withValues(alpha: 0.12)
                    : const Color(0xFFB2DFDB).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${goal.energyReward}⚡',
                style: TextStyle(
                  color: goal.isCompleted
                      ? const Color(0xFFFF823A)
                      : const Color(0xFF00796B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 목표 추가 버튼 (코랄 포인트 피드백) ──────────────────────────────────

  Widget _buildAddGoalButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('📝 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    '목표 추가 기능 준비 중',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF5A7D82),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFF823A).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: const Color(0xFFFF823A).withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Color(0xFFFF823A), size: 20),
            SizedBox(width: 6),
            Text(
              '목표 추가하기',
              style: TextStyle(
                color: Color(0xFFFF823A),
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(delay: 700.ms, duration: 500.ms);
  }

  // ─── 에너지 100% 달성 배너 (Vivid Coral) ─────────────────────────────────

  Widget _buildCompletionBanner() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF823A), Color(0xFFFFAB40)],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF823A).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text(
            '오늘의 여행 에너지를 모두 모았어!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }

  // ─── 일간 기분 체크 오버레이 (Daily Mood Overlay) ──────────

  Widget _buildMoodOverlay(WidgetRef ref, HomeNotifier notifier) {
    return Container(
      color: const Color(0xFF004D40).withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32.0),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D40).withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌊', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16.0),
              const Text(
                '오늘 바다는 어때?',
                style: TextStyle(
                  color: Color(0xFF004D40),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6.0),
              const Text(
                '오늘의 기분을 바다 날씨로 알려줘.',
                style: TextStyle(
                  color: Color(0xFF5A7D82),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoodButton(
                    emoji: '☀️',
                    label: '맑음',
                    color: const Color(0xFFFF823A), // 성취와 매칭되는 선명한 코랄
                    onTap: () => notifier.selectMood('☀️ 맑음'),
                  ),
                  _buildMoodButton(
                    emoji: '☁️',
                    label: '잔잔',
                    color: const Color(0xFF4DB6AC), // 평온한 민트
                    onTap: () => notifier.selectMood('☁️ 잔잔'),
                  ),
                  _buildMoodButton(
                    emoji: '🌧️',
                    label: '비 옴',
                    color: const Color(0xFF5C6BC0), // 바다의 우울함
                    onTap: () => notifier.selectMood('🌧️ 비 옴'),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fade(delay: 300.ms, duration: 500.ms)
            .scale(
              delay: 300.ms,
              begin: const Offset(0.85, 0.85),
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _buildMoodButton({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 잔잔하게 흔들리는 물결 CustomPainter ─────────────────────

class WavePainter extends CustomPainter {
  const WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB2DFDB).withValues(alpha: 0.35)
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
