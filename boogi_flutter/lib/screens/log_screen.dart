import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/log_provider.dart';
import '../models/daily_log_model.dart';
import '../providers/daily_log_provider.dart';
import '../providers/home_provider.dart';

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
// 항해 일지 메인 화면 (전체 세로 스크롤 레이아웃 리팩토링)
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
        // [수정 1 / Task 1] 화면 전체 요소를 세로로 부드럽게 스크롤하기 위해 최상단에 SingleChildScrollView 배치
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20.0),

              // 화면 타이틀
              const Text(
                '항해 일지',
                style: TextStyle(
                  color: Color(0xFF004D40),
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
              // [수정 1] 최상단 전체 스크롤을 적용하기 위해 Expanded/AnimatedSwitcher 구조에서 Expanded 해제
              AnimatedSwitcher(
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
            ],
          ),
        ),
      ),
    );
  }

  /// 슬라이딩 인디케이터가 있는 감성 토글 스위치 (파스텔 민트 스타일)
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
        color: const Color(0xFF80CBC4).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFB2DFDB).withValues(alpha: 0.6),
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
                      color: const Color(0xFF004D40).withValues(alpha: 0.06),
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
                ? const Color(0xFF004D40)
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
// View A: 바다 잔디 (진짜 캘린더 연산 ➔ 스무스 슬라이딩 제스처 적용)
// ─────────────────────────────────────────────────────────────

class _SeaGrassView extends ConsumerStatefulWidget {
  const _SeaGrassView({super.key});

  @override
  ConsumerState<_SeaGrassView> createState() => _SeaGrassViewState();
}

class _SeaGrassViewState extends ConsumerState<_SeaGrassView> {
  // 수심(레벨)에 따른 바다 컬러 팔레트 (일반 일지용)
  static const _levelColors = [
    Color(0xFFE3F5F2), // level 0 — 얕은 물결
    Color(0xFFB8E5DF), // level 1 — 조용한 모래밭
    Color(0xFF7FCEC5), // level 2 — 불가사리 서식지
    Color(0xFF4FA095), // level 3 — 산호초 군락
  ];

  @override
  void initState() {
    super.initState();
  }

  // ── 상세 모달 바텀 시트 호출 메서드 ──
  void _showDetailBottomSheet(BuildContext context, DailyLog item, bool isToday) {
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
                    color: const Color(0xFFB2DFDB).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              // 상단 헤더 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.date.month}월 ${item.date.day}일의 항해 기록',
                    style: const TextStyle(
                      color: Color(0xFF004D40),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: isToday 
                          ? const Color(0xFFFF823A).withValues(alpha: 0.08)
                          : const Color(0xFF4FA095).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isToday 
                            ? const Color(0xFFFF823A).withValues(alpha: 0.25)
                            : const Color(0xFF4FA095).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      item.mood,
                      style: TextStyle(
                        color: isToday ? const Color(0xFFFF823A) : const Color(0xFF00796B),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Divider(
                height: 1.0,
                color: const Color(0xFFB2DFDB).withValues(alpha: 0.3),
              ),
              const SizedBox(height: 20.0),

              // 중앙 완료 목록 영역
              const Text(
                '<완료한 물장구>',
                style: TextStyle(
                  color: Color(0xFFFF823A), // 비비드 코랄 강조
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
                            color: Color(0xFFFF823A),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(
                              color: Color(0xFF004D40),
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
                  color: const Color(0xFFB2DFDB).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFB2DFDB).withValues(alpha: 0.25),
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
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2DFDB).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.month}월 ${date.day}일의 항해 기록',
                    style: const TextStyle(
                      color: Color(0xFF004D40),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8BA6A1).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFF8BA6A1).withValues(alpha: 0.2),
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
                color: const Color(0xFFB2DFDB).withValues(alpha: 0.3),
              ),
              const SizedBox(height: 20.0),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2DFDB).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFB2DFDB).withValues(alpha: 0.15),
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

  // ── 간소화된 연/월 선택 모달 팝업 ──
  void _showMonthYearPickerDialog(BuildContext context, DateTime focusedMonth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // [수정 1 / RenderFlex 오버플로우 방어] 바텀시트가 전체 높이를 확보하도록 차단 해제!
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              int selectedYear = focusedMonth.year;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2DFDB).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const Text(
                    '항해할 연월 선택하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF004D40),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF00796B)),
                        onPressed: () {
                          setState(() {
                            selectedYear--;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$selectedYear년',
                        style: const TextStyle(
                          color: Color(0xFF004D40),
                          fontSize: 17.0,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF00796B)),
                        onPressed: () {
                          setState(() {
                            selectedYear++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final targetMonth = index + 1;
                      final isCurrentMonth =
                          focusedMonth.year == selectedYear && focusedMonth.month == targetMonth;

                      return GestureDetector(
                        onTap: () {
                          ref.read(focusedMonthProvider.notifier).state =
                              DateTime(selectedYear, targetMonth, 25);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? const Color(0xFFFF823A)
                                : const Color(0xFFB2DFDB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isCurrentMonth
                                  ? const Color(0xFFFF823A)
                                  : const Color(0xFFB2DFDB).withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$targetMonth월',
                              style: TextStyle(
                                color: isCurrentMonth ? Colors.white : const Color(0xFF004D40),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
              );
            },
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
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(dailyLogProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);

    return logsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
          ),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '오류가 발생했습니다: $err',
            style: const TextStyle(color: Color(0xFFFF823A)),
          ),
        ),
      ),
      data: (logs) {
        // 시스템 기준 오늘 날짜 (2026-05-25)
        final today = DateTime(2026, 5, 25);

        // 통계 실시간 계산
        final coralCount = logs.where((e) => e.grassType == '🪸').length;
        final starCount = logs.where((e) => e.grassType == '⭐').length;
        final waveCount = logs.where((e) => e.grassType == '~').length;

        // 달력 일자 연산
        final pageYear = focusedMonth.year;
        final pageMonth = focusedMonth.month;
        
        final firstDayOfMonth = DateTime(pageYear, pageMonth, 1);
        final totalDays = DateTime(pageYear, pageMonth + 1, 0).day;
        final emptySpaces = firstDayOfMonth.weekday - 1;

        // [수정 1] 최상단에서 전체 세로 스크롤을 하므로 본문 바다 잔디 위젯 내부의 SingleChildScrollView는 제거하고 Padding으로 구성
        return Padding(
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
                          color: Color(0xFF004D40),
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

              // ── 연월 선택 버튼 & 양옆 네비게이션 ──
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF00796B)),
                      onPressed: () {
                        ref.read(focusedMonthProvider.notifier).update(
                          (date) => DateTime(date.year, date.month - 1, 1),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => _showMonthYearPickerDialog(context, focusedMonth),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF823A).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: const Color(0xFFFF823A).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${focusedMonth.year}-${focusedMonth.month.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFFFF823A), // 선명한 비비드 코랄 강조
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: Color(0xFFFF823A),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF00796B)),
                      onPressed: () {
                        ref.read(focusedMonthProvider.notifier).update(
                          (date) => DateTime(date.year, date.month + 1, 1),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

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

              // ── 히트맵 그리드 (GestureDetector를 통한 좌우 물리 드래그 방향 감지 스와이프 구현) ──
              // [수정 2 / Task 2] PageView를 완전히 걷어내고, 달력 영역 전체를 GestureDetector로 감싸 완벽하고 매끄러운 스와이프를 보장합니다!
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < 0) {
                    // 오른쪽에서 왼쪽으로 쓸기 (다음 달로 이동)
                    ref.read(focusedMonthProvider.notifier).update(
                      (date) => DateTime(date.year, date.month + 1, 1),
                    );
                  } else if (details.primaryVelocity! > 0) {
                    // 왼쪽에서 오른쪽으로 쓸기 (이전 달로 이동)
                    ref.read(focusedMonthProvider.notifier).update(
                      (date) => DateTime(date.year, date.month - 1, 1),
                    );
                  }
                },
                // [수정 3 / Task 3] 내부의 달력 GridView는 반드시 shrinkWrap: true와 NeverScrollableScrollPhysics를 달아 충돌 방지 및 비율 명시
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 1.15, // 납작하고 이쁜 컴팩트 사각형 비율 지정
                  ),
                  itemCount: emptySpaces + totalDays,
                  itemBuilder: (context, gridIndex) {
                    if (gridIndex < emptySpaces) {
                      return const SizedBox.shrink();
                    }

                    final dayNum = gridIndex - emptySpaces + 1;
                    final targetDate = DateTime(pageYear, pageMonth, dayNum);
                    
                    final isToday = targetDate.year == today.year &&
                                    targetDate.month == today.month &&
                                    targetDate.day == today.day;
                    final isFuture = targetDate.isAfter(today);
                    final isPast = targetDate.isBefore(today);

                    // 오늘 날짜 기분 체크/물장구 동기화
                    DailyLog? log;
                    if (isToday) {
                      final homeState = ref.watch(homeProvider);
                      final completedCount = homeState.completedGoals.length;
                      
                      String grassType;
                      int level;
                      if (completedCount == 0) {
                        grassType = '~';
                        level = 0;
                      } else if (completedCount == 1) {
                        grassType = '~';
                        level = 1;
                      } else if (completedCount == 2) {
                        grassType = '⭐';
                        level = 2;
                      } else {
                        grassType = '🪸';
                        level = 3;
                      }

                      log = DailyLog(
                        date: targetDate,
                        mood: homeState.selectedMood ?? '☁️ 잔잔',
                        completedTasks: homeState.completedGoals.map((g) => g.title).toList(),
                        grassType: grassType,
                        level: level,
                        boogiQuote: completedCount == 0 
                          ? '오늘도 나만의 속도로 헤엄치기 시작해보자.'
                          : '오늘도 나의 걸음으로 꾸준히 헤엄친 나를 칭찬해.',
                      );
                    } else {
                      log = _findLogForDate(logs, targetDate);
                    }

                    // ── (1) 미래 날짜 셀 렌더링 ──
                    if (isFuture) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: const Color(0xFFB2DFDB).withValues(alpha: 0.4),
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
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF5A7D82).withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ── (2) 기록 없는 과거 날짜 셀 렌더링 (연한 회색 흐릿한 물결) ──
                    if (isPast && log == null) {
                      return GestureDetector(
                        onTap: () => _showEmptyBottomSheet(context, targetDate),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB0BEC5).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFB0BEC5).withValues(alpha: 0.15),
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
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB0BEC5),
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  '~',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFFCFD8DC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // ── (3) 오늘 강조 (비비드 코랄) 또는 데이터 있는 과거 날짜 셀 ──
                    final isDarkLevel = log!.level >= 2;

                    return GestureDetector(
                      onTap: () => _showDetailBottomSheet(context, log!, isToday),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday 
                              ? const Color(0xFFFF823A) // 선명한 비비드 코랄
                              : _levelColors[log.level],
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: isToday 
                                  ? const Color(0xFFFF823A) 
                                  : _levelColors[log.level].withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                          boxShadow: isToday
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFF823A).withValues(alpha: 0.35),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
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
                                    color: isToday
                                        ? Colors.white // 비비드 코랄 위 하얀 글씨
                                        : (isDarkLevel
                                            ? Colors.white.withValues(alpha: 0.6)
                                            : const Color(0xFF5A7D82).withValues(alpha: 0.55)),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  log.grassType,
                                  style: TextStyle(
                                    fontSize: log.grassType == '~' ? 16.0 : 14.0,
                                    color: isToday
                                        ? Colors.white // 비비드 코랄 위 하얀 이모지
                                        : (log.level <= 1
                                            ? const Color(0xFF5A7D82)
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fade(
                            delay: (15 * dayNum).ms,
                            duration: 300.ms,
                          )
                          .scale(
                            delay: (15 * dayNum).ms,
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.0, 1.0),
                            duration: 300.ms,
                            curve: Curves.easeOutBack,
                          );
                    },
                  ),
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
    final islandsTopToBottom = _mockIslands.reversed.toList();

    // [수정 3] 최상단에서 전체 스크롤을 하므로 본문 여정 지도 위젯 내부의 SingleChildScrollView는 제거하고 Padding으로 구성
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: const Color(0xFFB2DFDB).withValues(alpha: 0.4),
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
                      color: Color(0xFF004D40),
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

          ...List.generate(islandsTopToBottom.length * 2 - 1, (index) {
            if (index.isEven) {
              final islandIndex = index ~/ 2;
              final island = islandsTopToBottom[islandIndex];
              final isFirst = island.isReached &&
                  islandsTopToBottom
                      .where((e) => e.isReached)
                      .toList()
                      .last == island;
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
              return _buildDottedSegment(height: 70.0);
            }
          }),

          const SizedBox(height: 100.0), // 바텀 탭바 여백
        ],
      ),
    );
  }

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
