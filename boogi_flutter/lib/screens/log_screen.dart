import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/log_provider.dart';
import '../models/daily_log_model.dart';
import '../providers/daily_log_provider.dart';

// ─────────────────────────────────────────────────────────────
// Mock Data Models & Generators
// ─────────────────────────────────────────────────────────────

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

class _SeaGrassView extends ConsumerWidget {
  const _SeaGrassView({super.key});

  // 수심(레벨)에 따른 바다 컬러 팔레트
  static const _levelColors = [
    Color(0xFFE3F5F2), // level 0 — 얕은 물결
    Color(0xFFB8E5DF), // level 1 — 조용한 모래밭
    Color(0xFF7FCEC5), // level 2 — 불가사리 서식지
    Color(0xFF4FA095), // level 3 — 산호초 군락
  ];

  // ── 상세 모달 바텀 시트 호출 메서드 ──
  void _showDetailBottomSheet(BuildContext context, DailyLog item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 드래그 핸들 바
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              // 상단 헤더 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5월 ${item.date.day}일의 항해 기록',
                    style: const TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FA095).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF4FA095).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      item.mood,
                      style: const TextStyle(
                        color: Color(0xFF4FA095),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Divider(
                height: 1.0,
                color: const Color(0xFFE0F2F1).withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20.0),

              // 중앙 완료 목록 영역
              const Text(
                '<완료한 물장구>',
                style: TextStyle(
                  color: Color(0xFF4FA095),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 12.0),

              if (item.completedTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    '- 오늘은 파도에 몸을 맡기고 편안하게 쉬어갔습니다.',
                    style: TextStyle(
                      color: const Color(0xFF8BA6A1).withValues(alpha: 0.9),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                )
              else
                ...item.completedTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFF5A7D82),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(
                              color: Color(0xFF1E5257),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24.0),

              // 하단 푸터 영역 (부기 코멘트)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA095).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFF4FA095).withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🐢', style: TextStyle(fontSize: 18.5)),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        item.boogiQuote,
                        style: const TextStyle(
                          color: Color(0xFF5A7D82),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  // ── 빈 날짜 모달 바텀 시트 호출 메서드 ──
  void _showEmptyBottomSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 드래그 핸들 바
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              // 상단 헤더 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.month}월 ${date.day}일의 항해 기록',
                    style: const TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A7D82).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF5A7D82).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      '기록 없음',
                      style: TextStyle(
                        color: Color(0xFF5A7D82),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Divider(
                height: 1.0,
                color: const Color(0xFFE0F2F1).withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20.0),

              // 중앙 완료 목록 영역
              const Text(
                '<완료한 물장구>',
                style: TextStyle(
                  color: Color(0xFF8BA6A1),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 12.0),

              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '- 이날은 아직 항해 기록이 없습니다. 물속을 천천히 헤엄쳐 볼까요?',
                  style: TextStyle(
                    color: const Color(0xFF8BA6A1).withValues(alpha: 0.9),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // 하단 푸터 영역
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A7D82).withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFF5A7D82).withValues(alpha: 0.1),
                  ),
                ),
                child: const Row(
                  children: [
                    Text('🐢', style: TextStyle(fontSize: 18.5)),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        '조급해할 필요 없어. 앞으로 천천히 채워나갈 나만의 멋진 바다니까.',
                        style: TextStyle(
                          color: Color(0xFF5A7D82),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  DailyLog? _findLogForDate(List<DailyLog> logs, DateTime date) {
    try {
      return logs.firstWhere((log) =>
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(dailyLogProvider);

    return logsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FA095)),
          ),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '오류가 발생했습니다: $err',
            style: const TextStyle(color: Color(0xFFD87D56)),
          ),
        ),
      ),
      data: (logs) {
        // 실제 Dart DateTime을 이용한 동적 달력 생성 로직
        // 시스템 기준 오늘 날짜는 2026-05-25이므로 2026년 5월을 기준으로 연출합니다.
        final now = DateTime(2026, 5, 25);
        final year = now.year;
        final month = now.month;
        
        final firstDayOfMonth = DateTime(year, month, 1);
        final totalDays = DateTime(year, month + 1, 0).day; // 해당 월의 총 일수
        final emptySpaces = firstDayOfMonth.weekday - 1; // 월 시작 전 빈 공간 (월요일 = 1, 일요일 = 7이므로 weekday - 1)

        // 통계 실시간 계산
        final coralCount = logs.where((e) => e.grassType == '🪸').length;
        final starCount = logs.where((e) => e.grassType == '⭐').length;
        final waveCount = logs.where((e) => e.grassType == '~').length;

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
                itemCount: emptySpaces + totalDays,
                itemBuilder: (context, index) {
                  if (index < emptySpaces) {
                    // 월의 1일 이전 빈 공간 (공백 칸)
                    return const SizedBox.shrink();
                  }

                  final dayNum = index - emptySpaces + 1;
                  final targetDate = DateTime(year, month, dayNum);
                  final log = _findLogForDate(logs, targetDate);

                  if (log == null) {
                    // 기록이 없는 빈 캘린더 칸
                    return GestureDetector(
                      onTap: () => _showEmptyBottomSheet(context, targetDate),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FA095).withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: const Color(0xFF4FA095).withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4.0,
                              left: 5.0,
                              child: Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5A7D82).withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 기록이 존재하는 유효 셀 렌더링
                  final levelColor = _levelColors[log.level];
                  final isDarkLevel = log.level >= 2;

                  return GestureDetector(
                    onTap: () => _showDetailBottomSheet(context, log),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color: levelColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: levelColor.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4.0,
                            left: 5.0,
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: isDarkLevel
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF5A7D82).withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              log.grassType,
                              style: TextStyle(
                                fontSize: log.grassType == '~' ? 16.0 : 14.0,
                                color: log.level <= 1
                                    ? const Color(0xFF5A7D82)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fade(
                        delay: (20 * dayNum).ms,
                        duration: 300.ms,
                      )
                      .scale(
                        delay: (20 * dayNum).ms,
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
      },
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
