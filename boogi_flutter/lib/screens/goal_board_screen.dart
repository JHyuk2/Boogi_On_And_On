import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ocean_theme.dart';
import '../models/voyage_template_model.dart';
import '../providers/voyage_provider.dart';
import '../widgets/voyage_card.dart';
import '../widgets/goal_creation_sheet.dart';

// ─────────────────────────────────────────────────────────────
// 🎯 순정 Horizontal ListView 기반의 탐색형 갤러리 (목표 탭)
// 상단 2단 탭바 탑재 및 세로 Stacking 배치 구조
// 디자인 톤: 파스텔 오션 테마 (#FFF8F0 베이스, 민트, 코랄 포인트)
// ─────────────────────────────────────────────────────────────

/// 현재 📚 카테고리별 항로 섹션에서 선택된 카테고리를 추적하는 프로바이더
final selectedCategoryProvider = StateProvider<String>((ref) => '멘탈케어');

/// ⛵ 상단 2단 탭 상태를 추적하는 프로바이더 (0: 나의 바다, 1: 항해 게시판)
final goalBoardTabProvider = StateProvider<int>((ref) => 0);

class GoalBoardScreen extends ConsumerWidget {
  const GoalBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod에서 2단 탭 상태 및 각 데이터 감시
    final currentTab = ref.watch(goalBoardTabProvider);
    
    // 세로 배치(Stacking)를 위해 모든 템플릿 데이터 사전 준비
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── [헤더] 타이틀 영역 (부기온앤온 텍스트 + 아바타) ──
                _buildHeader(),
                const SizedBox(height: 14),

                // ── [토글] 상단 2단 탭바 ──
                _buildTopTabBar(ref, currentTab),
                const SizedBox(height: 16),

                // ── 탭별 본문 전환 (나의 바다 vs 항해 게시판) ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: currentTab == 0
                        ? _buildMySeaView(context, ref)
                        : _buildVoyageBoardView(
                            context,
                            ref,
                            popularTemplates,
                            latestTemplates,
                            hallOfFameTemplates,
                            selectedCategory,
                            categoryTemplates,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── [헤더] 타이틀 영역 (부기온앤온 텍스트 + 아바타) ─────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '부기온앤온',
            style: TextStyle(
              color: Color(0xFFFF823A), // 부기온앤온 주황/코랄 메인 컬러
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFB2DFDB).withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🐢', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
  }

  // ─── [토글] 상단 2단 탭바 ─────────────────────
  Widget _buildTopTabBar(WidgetRef ref, int currentTab) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1).withValues(alpha: 0.45), // 연한 파스텔 민트 뒷배경
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        children: [
          // [나의 바다] 탭
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(goalBoardTabProvider.notifier).state = 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11.0),
                decoration: BoxDecoration(
                  color: currentTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: currentTab == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1E5257).withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '[ 나의 바다 ]',
                    style: TextStyle(
                      color: currentTab == 0 ? const Color(0xFF004D40) : const Color(0xFF8BA6A1),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // [항해 게시판] 탭
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(goalBoardTabProvider.notifier).state = 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11.0),
                decoration: BoxDecoration(
                  color: currentTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: currentTab == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1E5257).withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    '[ 항해 게시판 ]',
                    style: TextStyle(
                      color: currentTab == 1 ? const Color(0xFF004D40) : const Color(0xFF8BA6A1),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── [나의 바다] 탭 뷰 ─────────────────────
  Widget _buildMySeaView(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          // 1. 큼직하고 풍성한 Hero 목표 생성 카드
          _buildHeroGoalCreationBanner(context),
          const SizedBox(height: 24),

          // 2. Empty State 뷰 영역
          _buildMySeaEmptyState(ref),
        ],
      ),
    );
  }

  // ─── [나의 바다] 큼직하고 풍성한 Hero 목표 생성 카드 ─────────────────────
  Widget _buildHeroGoalCreationBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: GestureDetector(
        onTap: () => GoalCreationSheet.show(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F5), // 따뜻한 파스텔 피치 베이스 (#FFF9F5)
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: const Color(0xFFFFE3D1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF823A).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBE0).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(child: Text('🐢', style: TextStyle(fontSize: 26))),
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
                              color: const Color(0xFFFF823A).withValues(alpha: 0.8),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '나만의 목표 생성',
                              style: TextStyle(
                                color: Color(0xFF004D40),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI 부기가 가장 작고 다정한 첫걸음으로\n쪼개줄게요.',
                          style: TextStyle(
                            color: Color(0xFF5A7D82),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 살구빛 서브 텍스트 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBE0).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Center(
                  child: Text(
                    '당신의 막연한 목표를 AI 부기가 가장 작고',
                    style: TextStyle(
                      color: Color(0xFF004D40),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '다정한 첫걸음으로 쪼개드립니다.',
                style: TextStyle(
                  color: Color(0xFF004D40),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                ),
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

  // ─── [나의 바다] 아직 항해를 시작하지 않았어요 Empty State ─────────────────────
  Widget _buildMySeaEmptyState(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 44.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: const Color(0xFFE0F2F1).withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E5257).withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 매끄럽게 출렁이는 파도 애니메이션
            const Text(
              '🌊',
              style: TextStyle(fontSize: 54),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideY(begin: -0.06, end: 0.06, duration: 1800.ms, curve: Curves.easeInOutSine),
            const SizedBox(height: 20),
            const Text(
              '아직 항해를 시작하지 않았어요',
              style: TextStyle(
                color: Color(0xFF004D40),
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '위의 목표 생성 카드를 터치해서\n첫 번째 섬을 만들어 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8BA6A1),
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // 구경하기 팁 버튼 (클릭 시 항해 게시판 탭 1로 스위칭)
            GestureDetector(
              onTap: () => ref.read(goalBoardTabProvider.notifier).state = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFF80CBC4).withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '💡 다른 여행자의 항로를 구경해 보는 건 어때요?',
                      style: TextStyle(
                        color: Color(0xFF00796B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 1500.ms, curve: Curves.easeInOutSine),
          ],
        ),
      ),
    )
        .animate()
        .fade(delay: 250.ms, duration: 500.ms);
  }

  // ─── [항해 게시판] 탭 뷰 (탭 폐기 및 세로 Stacking 구조) ─────────────────────
  Widget _buildVoyageBoardView(
    BuildContext context,
    WidgetRef ref,
    List<VoyageTemplate> popularTemplates,
    List<VoyageTemplate> latestTemplates,
    List<VoyageTemplate> hallOfFameTemplates,
    String selectedCategory,
    List<VoyageTemplate> categoryTemplates,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 얇고 슬림한 배너 카드
          _buildSimpleGoalCreationBanner(context),
          const SizedBox(height: 28),

          // 2. 📚 카테고리별 항로 (가장 상단에 필터 칩 배치)
          _buildSectionHeader(
            context,
            title: '📚 카테고리별 항로',
            subtitle: '내 관심사에 맞는 작은 걸음을 찾아보세요',
            showMore: false,
          ),
          const SizedBox(height: 12),
          _buildCategoryChips(ref, selectedCategory),
          const SizedBox(height: 16),
          _buildCategoryHorizontalList(context, categoryTemplates, selectedCategory),
          const SizedBox(height: 36), // 섹션 간 넉넉하고 편안한 세로 마진

          // 3. 🔥 인기 항로
          _buildSectionHeader(
            context,
            title: '🔥 인기 항로',
            subtitle: '가장 많은 여행자가 담아간 항로예요',
          ),
          const SizedBox(height: 12),
          _buildHorizontalList(context, popularTemplates),
          const SizedBox(height: 36),

          // 4. ✨ 최신 항로
          _buildSectionHeader(
            context,
            title: '✨ 최신 항로',
            subtitle: '방금 모래사장에 도착한 따끈따끈한 계획들',
          ),
          const SizedBox(height: 12),
          _buildHorizontalList(context, latestTemplates),
          const SizedBox(height: 36),

          // 5. 🏅 명예 항해사
          _buildSectionHeader(
            context,
            title: '🏅 명예 항해사',
            subtitle: '수많은 징검다리를 끝까지 건넌 완성형 항로',
          ),
          const SizedBox(height: 12),
          _buildHorizontalList(context, hallOfFameTemplates),
        ],
      ),
    );
  }

  // ─── [항해 게시판] 얇고 심플한 목표 생성 바 ─────────────────────
  Widget _buildSimpleGoalCreationBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
      child: GestureDetector(
        onTap: () => GoalCreationSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F5),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFFFE3D1),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBE0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Color(0xFFFF823A),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '나만의 목표 생성하기',
                      style: TextStyle(
                        color: Color(0xFF004D40),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '당신의 막연한 목표를 AI 부기가 가장 작고 다정한 첫걸음으로 쪼개드립니다.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF5A7D82).withValues(alpha: 0.85),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFF823A),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 400.ms);
  }

  // ─── [공통] 섹션 헤더 (제목 + 설명) ─────────────────────
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

  // ─── [순정 가로 리스트] 카드 1개 가로 너비를 140으로 고정 (가로 180 높이) ─────────────────────
  Widget _buildHorizontalList(BuildContext context, List<VoyageTemplate> templates) {
    if (templates.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            '비어 있는 바다입니다 🌊',
            style: TextStyle(color: OceanTheme.textMuted),
          ),
        ),
      );
    }

    // ── 카드 가로 크기를 140으로 고정 지정
    const double cardWidth = 140.0;

    return SizedBox(
      height: 180, // ── SizedBox 높이 180으로 약간 확대
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: VoyageCard(
              template: templates[index],
              index: index,
            ),
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
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? OceanTheme.primary.withValues(alpha: 0.12)
                    : OceanTheme.borderMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(OceanTheme.chipRadius),
                border: Border.all(
                  color: isActive
                      ? OceanTheme.primary.withValues(alpha: 0.45)
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

  // ─── [카테고리 리스트] 필터 결과 가로 리스트 (순정 ListView 미니 압축 버전) ─────────────────────
  Widget _buildCategoryHorizontalList(BuildContext context, List<VoyageTemplate> templates, String category) {
    if (templates.isEmpty) {
      return Container(
        height: 150, // ── 높이에 맞춰 압축
        margin: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        decoration: OceanTheme.cardDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          radius: 14,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌊', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(
                '아직 "$category" 테마의 항로가 없어요.\n첫 번째 탐험가가 되어 볼까요?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OceanTheme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      )
          .animate(key: ValueKey(category))
          .fade(duration: 450.ms);
    }

    const double cardWidth = 140.0;

    return SizedBox(
      height: 180, // ── SizedBox 높이 180으로 약간 확대
      child: ListView.separated(
        key: ValueKey(category),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: OceanTheme.horizontalPadding),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: VoyageCard(
              template: templates[index],
              index: index,
            ),
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
