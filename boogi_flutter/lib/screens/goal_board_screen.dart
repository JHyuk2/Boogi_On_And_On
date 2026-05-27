import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ocean_theme.dart';
import '../models/voyage_template_model.dart';
import '../providers/voyage_provider.dart';
import '../widgets/voyage_card.dart';
import '../widgets/goal_creation_sheet.dart';

// ─────────────────────────────────────────────────────────────
// 🎯 넷플릭스 스타일 항해 게시판 (목표 탭)
// 번아웃이 온 여행자들이 다른 이들의 항로를 탐색하고 영감을 얻는 공간
// 디자인 톤: 파스텔 오션 테마 (#FFF8F0 베이스, 민트, 코랄 포인트)
// ─────────────────────────────────────────────────────────────

/// 현재 📚 카테고리별 항로 섹션에서 선택된 카테고리를 추적하는 프로바이더
final selectedCategoryProvider = StateProvider<String>((ref) => '멘탈케어');

class GoalBoardScreen extends ConsumerWidget {
  const GoalBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod에서 탭별 템플릿 데이터 감시
    final popularTemplates = ref.watch(voyageTemplatesProvider(VoyageTab.popular));
    final latestTemplates = ref.watch(voyageTemplatesProvider(VoyageTab.latest));
    final hallOfFameTemplates = ref.watch(voyageTemplatesProvider(VoyageTab.hallOfFame));

    // 선택된 서브 카테고리 및 필터링 데이터
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoryTemplates = ref.watch(voyageByCategoryProvider(selectedCategory));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. 배경 물결 데코레이션 ──
          ...List.generate(3, (index) {
            final double bottom = 30.0 + (index * 30);
            final double opacity = 0.10 - (index * 0.02);
            final int duration = 7000 + (index * 2000);
            return Positioned(
              left: -60,
              right: -60,
              bottom: bottom,
              height: 100,
              child: Opacity(
                opacity: opacity,
                child: const CustomPaint(painter: _WavePainter()),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideX(
                    begin: -0.05,
                    end: 0.05,
                    duration: duration.ms,
                    curve: Curves.easeInOutSine,
                  ),
            );
          }),

          // ── 2. 메인 스크롤 가능한 콘텐츠 ──
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── [헤더] 타이틀 영역 ──
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // ── [배너] 나만의 목표 생성 카드 ──
                  _buildGoalCreationBanner(context),
                  const SizedBox(height: 28),

                  // ── [캐러셀 1] 🔥 인기 항로 ──
                  _buildSectionHeader(
                    context,
                    title: '🔥 인기 항로',
                    subtitle: '가장 많은 여행자가 담아간 항로예요',
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalCarousel(popularTemplates),
                  const SizedBox(height: 28),

                  // ── [캐러셀 2] ✨ 최신 항로 ──
                  _buildSectionHeader(
                    context,
                    title: '✨ 최신 항로',
                    subtitle: '방금 모래사장에 도착한 따끈따끈한 계획들',
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalCarousel(latestTemplates),
                  const SizedBox(height: 28),

                  // ── [캐러셀 3] 🏅 명예 항해사 ──
                  _buildSectionHeader(
                    context,
                    title: '🏅 명예 항해사',
                    subtitle: '수많은 징검다리를 끝까지 건넌 완성형 항로',
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalCarousel(hallOfFameTemplates),
                  const SizedBox(height: 28),

                  // ── [캐러셀 4] 📚 카테고리별 항로 ──
                  _buildSectionHeader(
                    context,
                    title: '📚 카테고리별 항로',
                    subtitle: '내 관심사에 맞는 작은 걸음을 찾아보세요',
                    showMore: false,
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryChips(ref, selectedCategory),
                  const SizedBox(height: 16),
                  _buildCategoryCarousel(categoryTemplates, selectedCategory),

                  const SizedBox(height: 120), // 바텀 탭바 여백 확보
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── [헤더] 타이틀 영역 ─────────────────────
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 항해 게시판',
            style: OceanTheme.headingLarge,
          ),
          SizedBox(height: 4),
          Text(
            '다른 여행자들의 다정한 항로를 둘러보며 영감을 얻어보세요.',
            style: TextStyle(
              color: OceanTheme.textSub,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }

  // ─── [배너] 나만의 목표 생성 ─────────────────────
  Widget _buildGoalCreationBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: GestureDetector(
        onTap: () => GoalCreationSheet.show(context),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: OceanTheme.cardHighlightDecoration(radius: 20.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: OceanTheme.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: const Center(
                  child: Text('🐢', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          color: OceanTheme.coral.withValues(alpha: 0.8),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '나만의 목표 생성하기',
                          style: TextStyle(
                            color: OceanTheme.textDark,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'AI 부기가 다정하고 실천 가능한 3단계로 쪼개드릴게요.',
                      style: TextStyle(
                        color: OceanTheme.textSub,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: OceanTheme.coral,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: 150.ms, duration: 500.ms)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack);
  }

  // ─── [공통] 섹션 헤더 (제목 + 설명 + 더보기) ─────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool showMore = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: OceanTheme.headingMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: OceanTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showMore)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✨ "$title" 전체 목록 보기 준비 중입니다!'),
                    backgroundColor: OceanTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  '더보기 >',
                  style: TextStyle(
                    color: OceanTheme.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fade(delay: 200.ms, duration: 400.ms);
  }

  // ─── [캐러셀] 가로 스크롤 넷플릭스 스타일 ─────────────────────
  Widget _buildHorizontalCarousel(List<VoyageTemplate> templates) {
    if (templates.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: Text(
            '비어 있는 바다입니다 🌊',
            style: TextStyle(color: OceanTheme.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return VoyageCard(
            template: templates[index],
            index: index,
          );
        },
      ),
    );
  }

  // ─── [카테고리 칩 필터] 가로 스크롤 필터 칩 ─────────────────────
  Widget _buildCategoryChips(WidgetRef ref, String selected) {
    final categories = ['멘탈케어', '개발', '취미', '건강', '업무', '시험준비', '부동산', '창업'];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? OceanTheme.primary.withValues(alpha: 0.12)
                    : OceanTheme.borderMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(OceanTheme.chipRadius),
                border: Border.all(
                  color: isActive
                      ? OceanTheme.primary.withValues(alpha: 0.4)
                      : OceanTheme.borderMint.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isActive ? OceanTheme.primary : OceanTheme.textMuted,
                    fontSize: 12.0,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fade(delay: 250.ms, duration: 400.ms);
  }

  // ─── [카테고리 캐러셀] 필터 결과 가로 캐러셀 ─────────────────────
  Widget _buildCategoryCarousel(List<VoyageTemplate> templates, String category) {
    if (templates.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        decoration: OceanTheme.cardDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          radius: 18,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌊', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                '아직 "$category" 테마의 항로가 없어요.\n첫 번째 탐험가가 되어 볼까요?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OceanTheme.textMuted,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      )
          .animate(key: ValueKey(category))
          .fade(duration: 450.ms);
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        key: ValueKey(category), // 카테고리 변경 시 애니메이션 리셋 및 리로드
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return VoyageCard(
            template: templates[index],
            index: index,
          );
        },
      ),
    )
        .animate()
        .fade(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─── [CustomPainter] 잔잔하게 흔들리는 물결 ─────────────────────
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OceanTheme.borderMint.withValues(alpha: 0.25)
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
