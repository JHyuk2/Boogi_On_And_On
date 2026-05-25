import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../providers/log_provider.dart';

// ─────────────────────────────────────────────────────────────
// Mock Data Models & Generators
// ─────────────────────────────────────────────────────────────

/// 바다 잔디 그리드 셀 하나를 표현하는 데이터 모델
class _SeaGridItem {
  final String emoji;
  final int level; // 0~3 (수심 깊이 = 활동량)

  const _SeaGridItem(this.emoji, this.level);
}

/// 여정 지도의 섬 하나를 표현하는 데이터 모델
class _IslandData {
  final String name;
  final String emoji;
  final String subtitle;
  final bool isReached;

  const _IslandData({
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.isReached,
  });
}

/// 35일(5주 × 7일) 분량의 바다 잔디 목(Mock) 데이터
/// level 0: ~ (잔잔한 물결), 1: ~ (조금 더 깊은 물결), 2: ⭐ (불가사리), 3: 🪸 (산호초)
final List<_SeaGridItem> _mockGridData = List.generate(35, (i) {
  final rng = Random(i * 7 + 3);
  final level = rng.nextInt(4);
  const emojis = ['~', '~', '⭐', '🪸'];
  return _SeaGridItem(emojis[level], level);
});

/// 여정 지도 섬 목(Mock) 데이터 (아래 → 위 순서로 배치)
const List<_IslandData> _mockIslands = [
  _IslandData(
    name: '시작의 해변',
    emoji: '🏖️',
    subtitle: '여행의 첫 발걸음',
    isReached: true,
  ),
  _IslandData(
    name: '산호초 정원',
    emoji: '🪸',
    subtitle: '작은 습관들이 모여 만든 숲',
    isReached: false,
  ),
  _IslandData(
    name: '별빛 등대섬',
    emoji: '🌟',
    subtitle: '나만의 빛을 발견하는 곳',
    isReached: false,
  ),
];

// ─────────────────────────────────────────────────────────────
// 항해 일지 메인 화면
// ─────────────────────────────────────────────────────────────

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(logViewModeProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE2F6F8), // 부드러운 아침 파스텔 하늘색
            Color(0xFFEAF9F9), // 평온한 바다 안개색
            Color(0xFFF7FDFD), // 따뜻한 모래사장 연한 베이지색
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20.0),

            // 화면 타이틀
            const Text(
              '항해 일지',
              style: TextStyle(
                color: Color(0xFF1E5257),
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fade(duration: 600.ms)
                .slideY(begin: 0.15, end: 0.0, curve: Curves.easeOutCubic),

            const SizedBox(height: 20.0),

            // ── 뷰 모드 토글 ──
            _buildViewToggle(context, ref, viewMode),

            const SizedBox(height: 20.0),

            // ── 뷰 본문 (바다 잔디 or 여정 지도) ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: viewMode == LogViewMode.seaGrass
                    ? const _SeaGrassView(key: ValueKey('sea_grass'))
                    : const _JourneyMapView(key: ValueKey('journey_map')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 슬라이딩 인디케이터가 있는 감성 토글 스위치
  Widget _buildViewToggle(
    BuildContext context,
    WidgetRef ref,
    LogViewMode current,
  ) {
    final isSeaGrass = current == LogViewMode.seaGrass;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      height: 48.0,
      decoration: BoxDecoration(
        color: const Color(0xFF4FA095).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE0F2F1).withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // 슬라이딩 배경 인디케이터
          AnimatedAlign(
            alignment:
                isSeaGrass ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E5257).withValues(alpha: 0.08),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 터치 영역 라벨
          Row(
            children: [
              Expanded(
                child: _toggleOption(
                  label: '🪸 바다 잔디',
                  isActive: isSeaGrass,
                  onTap: () => ref.read(logViewModeProvider.notifier).state =
                      LogViewMode.seaGrass,
                ),
              ),
              Expanded(
                child: _toggleOption(
                  label: '🗺️ 여정 지도',
                  isActive: !isSeaGrass,
                  onTap: () => ref.read(logViewModeProvider.notifier).state =
                      LogViewMode.journeyMap,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOut);
  }

  Widget _toggleOption({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            color: isActive
                ? const Color(0xFF1E5257)
                : const Color(0xFF8BA6A1),
            fontSize: 14.0,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// View A: 바다 잔디 (깃허브 잔디 스타일 히트맵 캘린더)
// ─────────────────────────────────────────────────────────────

class _SeaGrassView extends StatelessWidget {
  const _SeaGrassView({super.key});

  // 수심(레벨)에 따른 바다 컬러 팔레트
  static const _levelColors = [
    Color(0xFFE3F5F2), // level 0 — 얕은 물결
    Color(0xFFB8E5DF), // level 1 — 조용한 모래밭
    Color(0xFF7FCEC5), // level 2 — 불가사리 서식지
    Color(0xFF4FA095), // level 3 — 산호초 군락
  ];

  @override
  Widget build(BuildContext context) {
    // 요약 통계 계산 (Mock 데이터 기반)
    final coralCount = _mockGridData.where((e) => e.emoji == '🪸').length;
    final starCount = _mockGridData.where((e) => e.emoji == '⭐').length;
    final waveCount = _mockGridData.where((e) => e.emoji == '~').length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 부기의 덤덤한 월간 요약 ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFE0F2F1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🐢', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이번 달은 $coralCount개의 산호초가 자랐고, '
                    '$starCount마리의 불가사리가 놀러 왔고, '
                    '$waveCount번의 잔잔한 물결이 일었네.',
                    style: const TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fade(duration: 500.ms)
              .slideY(begin: 0.08, end: 0.0, curve: Curves.easeOut),

          const SizedBox(height: 24.0),

          // ── 요일 헤더 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              children: ['월', '화', '수', '목', '금', '토', '일']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: const Color(0xFF5A7D82).withValues(alpha: 0.7),
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8.0),

          // ── 히트맵 그리드 ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
            ),
            itemCount: _mockGridData.length,
            itemBuilder: (context, index) {
              final item = _mockGridData[index];
              return Container(
                decoration: BoxDecoration(
                  color: _levelColors[item.level],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _levelColors[item.level].withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: TextStyle(
                      fontSize: item.emoji == '~' ? 16.0 : 14.0,
                      color: item.level <= 1
                          ? const Color(0xFF5A7D82)
                          : Colors.white,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fade(
                    delay: (30 * index).ms,
                    duration: 300.ms,
                  )
                  .scale(
                    delay: (30 * index).ms,
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  );
            },
          ),

          const SizedBox(height: 20.0),

          // ── 범례 ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('~', '물결', _levelColors[0]),
              const SizedBox(width: 16),
              _legendItem('⭐', '불가사리', _levelColors[2]),
              const SizedBox(width: 16),
              _legendItem('🪸', '산호초', _levelColors[3]),
            ],
          )
              .animate()
              .fade(delay: 800.ms, duration: 500.ms),

          const SizedBox(height: 100.0), // 바텀 탭바 여백
        ],
      ),
    );
  }

  Widget _legendItem(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 10)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5A7D82),
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// View B: 여정 지도 (보물지도 스타일 세로 스크롤)
// ─────────────────────────────────────────────────────────────

class _JourneyMapView extends StatelessWidget {
  const _JourneyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // 섬을 역순으로 표시 (위 = 목적지, 아래 = 현재 위치)
    final islandsTopToBottom = _mockIslands.reversed.toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // ── 지도 타이틀 ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFE0F2F1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🧭', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '아직 갈 길이 멀지만, 시작한 것만으로도 대단해.\n'
                    '천천히 헤엄치자.',
                    style: TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fade(duration: 500.ms)
              .slideY(begin: 0.08, end: 0.0, curve: Curves.easeOut),

          const SizedBox(height: 32.0),

          // ── 섬 & 점선 경로 ──
          ...List.generate(islandsTopToBottom.length * 2 - 1, (index) {
            // 짝수 인덱스: 섬, 홀수 인덱스: 점선
            if (index.isEven) {
              final islandIndex = index ~/ 2;
              final island = islandsTopToBottom[islandIndex];
              final isFirst = island.isReached &&
                  islandsTopToBottom
                      .where((e) => e.isReached)
                      .toList()
                      .last == island;
              // 징검다리 효과: 섬을 좌우로 교차 배치
              final alignment = index % 4 == 0
                  ? Alignment.centerRight
                  : Alignment.centerLeft;

              return Align(
                alignment: alignment,
                child: _buildIslandContainer(
                  island: island,
                  showTurtle: isFirst,
                  animDelay: (200 * islandIndex),
                ),
              );
            } else {
              // 점선 구간
              return _buildDottedSegment(height: 70.0);
            }
          }),

          const SizedBox(height: 100.0), // 바텀 탭바 여백
        ],
      ),
    );
  }

  /// 유기적 형태의 둥근 섬 컨테이너
  Widget _buildIslandContainer({
    required _IslandData island,
    required bool showTurtle,
    required int animDelay,
  }) {
    final isReached = island.isReached;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 22.0),
          decoration: BoxDecoration(
            // 자연스러운 유기적 바위 섬 모양의 비대칭 border-radius
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(42),
              topRight: Radius.circular(55),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(38),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isReached
                  ? const [Color(0xFF5BBFB5), Color(0xFF4FA095)]
                  : const [Color(0xFFD5E8E5), Color(0xFFC3D8D4)],
            ),
            border: Border.all(
              color: isReached
                  ? const Color(0xFF6DEBE1).withValues(alpha: 0.7)
                  : const Color(0xFFE0F2F1),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isReached
                        ? const Color(0xFF4FA095)
                        : const Color(0xFF1E5257))
                    .withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(island.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Text(
                island.name,
                style: TextStyle(
                  color: isReached ? Colors.white : const Color(0xFF5A7D82),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                island.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isReached
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF8BA6A1),
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              // 도달한 섬에는 작은 도장 배지
              if (isReached) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '도착 ✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .slideY(
              begin: -0.02,
              end: 0.02,
              duration: 2500.ms,
              curve: Curves.easeInOutSine,
            ),

        // 🐢 부기 — 현재 유저 위치 표시
        if (showTurtle)
          Positioned(
            left: -38,
            top: 18,
            child: const Text('🐢', style: TextStyle(fontSize: 30))
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .slideY(
                  begin: -0.15,
                  end: 0.15,
                  duration: 1600.ms,
                  curve: Curves.easeInOutQuad,
                ),
          ),
      ],
    )
        .animate()
        .fade(delay: animDelay.ms, duration: 500.ms)
        .scale(
          delay: animDelay.ms,
          begin: const Offset(0.85, 0.85),
          curve: Curves.easeOutBack,
        );
  }

  /// 섬과 섬 사이를 잇는 점선 세그먼트
  Widget _buildDottedSegment({required double height}) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotCount = (constraints.maxHeight / 10).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              dotCount,
              (_) => Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA095).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fade(delay: 100.ms, duration: 400.ms);
  }
}
