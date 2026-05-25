import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─────────────────────────────────────────────────────────────
// Riverpod State Management
// ─────────────────────────────────────────────────────────────

/// 고수들의 바다 화면의 두 가지 공간 모드 (먼 바다, 나의 해변)
enum CommunityViewMode { farSea, myBeach }

/// 현재 선택된 공간 모드를 관리하는 StateProvider
final communityViewModeProvider = StateProvider<CommunityViewMode>(
  (ref) => CommunityViewMode.farSea,
);

/// 유리병 편지의 감정 성격 구분 (고민 또는 따스한 위로/응원)
enum BottleType { worry, comfort }

/// 먼 바다에 둥실 떠다니는 실시간 유리병 리스트 상태관리 프로바이더
final farSeaLettersProvider = StateNotifierProvider<FarSeaLettersNotifier, List<_BottleLetter>>(
  (ref) => FarSeaLettersNotifier(),
);

class FarSeaLettersNotifier extends StateNotifier<List<_BottleLetter>> {
  FarSeaLettersNotifier() : super([]) {
    refresh();
  }

  /// 새로운 파도를 일으켜 무작위로 3~4개의 편지를 선택하고 감성적인 새 좌표 부여
  void refresh() {
    state = _generateRandomFarSeaLetters();
  }

  /// 특정 편지에 다정한 답글(댓글)을 추가
  void addReply(String id, String reply) {
    state = [
      for (final letter in state)
        if (letter.id == id)
          letter.copyWith(replies: [...letter.replies, reply])
        else
          letter
    ];
  }
}

/// 유저가 💛 보관한 편지 목록 관리 프로바이더
final savedLettersProvider = StateNotifierProvider<_SavedLettersNotifier, List<_BottleLetter>>(
  (ref) => _SavedLettersNotifier(),
);

class _SavedLettersNotifier extends StateNotifier<List<_BottleLetter>> {
  _SavedLettersNotifier() : super([]);

  /// 편지 보관 토글 (없으면 추가, 있으면 제거)
  bool toggle(_BottleLetter letter) {
    final exists = state.any((e) => e.id == letter.id);
    if (exists) {
      state = state.where((e) => e.id != letter.id).toList();
      return false; // 보관 해제됨
    } else {
      state = [...state, letter];
      return true; // 보관됨
    }
  }

  /// 특정 편지가 이미 보관되어 있는지 확인
  bool isSaved(String id) => state.any((e) => e.id == id);
}

// ─────────────────────────────────────────────────────────────
// Mock Data Models for Glass Bottle Letters
// ─────────────────────────────────────────────────────────────

class _BottleLetter {
  final String id;
  final String content;
  final String sender;
  final DateTime date;
  final List<String> replies; // 다중 답장(댓글) 리스트
  final double xRatio; // 먼 바다의 무작위 x 좌표 (0.1 ~ 0.85)
  final double yRatio; // 먼 바다의 무작위 y 좌표 (0.2 ~ 0.7)
  final BottleType type; // 편지 타입 (고민 / 위로)

  const _BottleLetter({
    required this.id,
    required this.content,
    required this.sender,
    required this.date,
    this.replies = const [],
    required this.xRatio,
    required this.yRatio,
    required this.type,
  });

  _BottleLetter copyWith({
    String? id,
    String? content,
    String? sender,
    DateTime? date,
    List<String>? replies,
    double? xRatio,
    double? yRatio,
    BottleType? type,
  }) {
    return _BottleLetter(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      date: date ?? this.date,
      replies: replies ?? this.replies,
      xRatio: xRatio ?? this.xRatio,
      yRatio: yRatio ?? this.yRatio,
      type: type ?? this.type,
    );
  }
}

/// 새로운 파도가 몰고 올 무작위 편지 및 좌표 생성 헬퍼 함수 (유리병 간 겹침 방지 및 FAB 영역 회피 수학적 검증 적용)
List<_BottleLetter> _generateRandomFarSeaLetters() {
  final random = Random();
  final shuffledPool = List<_BottleLetter>.from(_mockFarSeaLetterPool)..shuffle(random);
  final count = random.nextInt(2) + 3; // 3개 또는 4개 무작위 선택
  final selected = shuffledPool.take(count).toList();
  
  final List<Point<double>> placedPositions = [];
  
  return List.generate(selected.length, (i) {
    final original = selected[i];
    double x = 0.15;
    double y = 0.25;
    
    // 최대 25회 난수 발생 및 간격 충돌 재시도 로직
    for (int retry = 0; retry < 25; retry++) {
      // x: 0.12 ~ 0.82, y: 0.26 ~ 0.68 (상단 문구 아래로 중심 유영 확보)
      x = 0.12 + random.nextDouble() * 0.70;
      y = 0.26 + random.nextDouble() * 0.42;
      
      // 우측 하단 FAB 배치 영역(x > 0.58, y > 0.58) 침범 회피
      if (x > 0.58 && y > 0.58) {
        continue;
      }
      
      // 기존 유리병들과의 거리 검증 (최소 가로 0.18, 세로 0.14 거리 확보)
      bool tooClose = false;
      for (final pos in placedPositions) {
        final double dx = pos.x - x;
        final double dy = pos.y - y;
        if (dx.abs() < 0.18 && dy.abs() < 0.14) {
          tooClose = true;
          break;
        }
      }
      
      if (!tooClose) {
        break;
      }
    }
    
    placedPositions.add(Point(x, y));
    return original.copyWith(xRatio: x, yRatio: y);
  });
}

// ── 먼 바다에 떠다니는 익명의 고민/위로 편지 풀(Pool) 목 데이터 ──
final List<_BottleLetter> _mockFarSeaLetterPool = [
  _BottleLetter(
    id: 'f1',
    content: '요즘 남들은 다 한 걸음씩 앞서가는데, 나만 제자리에 고여있는 것 같아 조급해. 아무것도 하고 싶지 않은 무기력한 밤이야.',
    sender: '조급한 바다거북',
    date: DateTime(2026, 5, 25),
    xRatio: 0.18,
    yRatio: 0.28,
    type: BottleType.worry,
    replies: [
      '저도 똑같은 감정을 겪었어요. 하지만 밤이 깊을수록 별이 더 밝게 빛나는 법이에요. 잠시 쉬어 가도 괜찮아요. ✨',
    ],
  ),
  _BottleLetter(
    id: 'f2',
    content: '열심히 준비했던 시험에서 떨어졌어. 내 노력이 전부 거품처럼 흩어진 기분이라 너무 속상하다. 다시 일어설 용기가 생길까?',
    sender: '지친 돌고래',
    date: DateTime(2026, 5, 24),
    xRatio: 0.72,
    yRatio: 0.38,
    type: BottleType.worry,
    replies: [
      '결과가 노력을 대변하진 못해요. 흩어진 거품은 파도가 되어 더 넓은 바다를 품을 테니까요. 힘내세요!',
      '지친 마음을 달래는 따뜻한 소라 차 한 잔 드리고 싶네요. 충분히 쉬고 다시 헤엄쳐요. 🐬',
    ],
  ),
  _BottleLetter(
    id: 'f3',
    content: '인간관계는 왜 이렇게 늘 어려울까? 겉으로는 웃고 있지만 집에 돌아오면 가면을 벗은 것처럼 마음이 너무 공허하고 쓸쓸해.',
    sender: '가면 쓴 흰동가리',
    date: DateTime(2026, 5, 25),
    xRatio: 0.35,
    yRatio: 0.62,
    type: BottleType.worry,
    replies: [],
  ),
  _BottleLetter(
    id: 'f4',
    content: '오늘 하루도 큰 사고 없이 살아냈다는 것만으로 나 자신을 칭찬해주고 싶어. 내 작은 속도대로 걸어가도 괜찮은 거겠지?',
    sender: '느긋한 해마',
    date: DateTime(2026, 5, 25),
    xRatio: 0.62,
    yRatio: 0.70,
    type: BottleType.comfort,
    replies: [
      '멋진 다짐이네요! 해마님만의 속도대로 유유히 헤엄치시는 모습이 정말 아름답습니다. 🌊',
    ],
  ),
  _BottleLetter(
    id: 'f5',
    content: '어떤 파도도 계속 몰아치지는 않아요. 지금 거센 밤바다에 홀로 계시더라도, 곧 눈부시게 맑은 아침 파도가 찾아올 거예요.',
    sender: '바다의 파수꾼',
    date: DateTime(2026, 5, 25),
    xRatio: 0.50,
    yRatio: 0.20,
    type: BottleType.comfort,
    replies: [],
  ),
  _BottleLetter(
    id: 'f6',
    content: '조금 느려도 괜찮아요. 한 뼘씩 물장구치며 나아가는 항해사님의 모습은 이미 충분히 빛나고 있으니까요.',
    sender: '춤추는 소라게',
    date: DateTime(2026, 5, 25),
    xRatio: 0.25,
    yRatio: 0.45,
    type: BottleType.comfort,
    replies: [],
  ),
  _BottleLetter(
    id: 'f7',
    content: '새로운 도전을 꿈꾸고 있지만 두려움이 앞서요. 내가 가고 있는 이 길이 맞는지, 바다 한가운데서 길을 잃은 기분이에요.',
    sender: '방황하는 가오리',
    date: DateTime(2026, 5, 23),
    xRatio: 0.80,
    yRatio: 0.55,
    type: BottleType.worry,
    replies: [],
  ),
  _BottleLetter(
    id: 'f8',
    content: '밤하늘의 수많은 별빛처럼, 우리 모두는 각자의 고유한 자리에 머물며 잔잔하게 반짝이고 있어요. 오늘 하루 고생 많았어요. 🌟',
    sender: '빛나는 아기별',
    date: DateTime(2026, 5, 25),
    xRatio: 0.45,
    yRatio: 0.50,
    type: BottleType.comfort,
    replies: [],
  ),
];



// ─────────────────────────────────────────────────────────────
// Community Screen Implementation
// ─────────────────────────────────────────────────────────────

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(communityViewModeProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071223), // 깊고 조용한 한밤중의 어두운 바다색
              Color(0xFF0D1E36), // 밤하늘이 반사된 잔잔한 바다색
              Color(0xFF142C4C), // 파도가 은은하게 비치는 해안색
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 상단 고정 헤더 레이어 (글자 겹침 원천 격리 차단) ──
              _buildHeader(context, ref, viewMode),

              // ── 본문 영역 (바다 / 해변) ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: viewMode == CommunityViewMode.farSea
                      ? const _FarSeaView(key: ValueKey('far_sea'))
                      : const _MyBeachView(key: ValueKey('my_beach')),
                ),
              ),
            ],
          ),
        ),
      ),
      // ── 편지 띄우기 플로팅 버튼 (하단 플로팅 네비게이션 바 위로 오도록 패딩 조정) ──
      floatingActionButton: viewMode == CommunityViewMode.farSea
          ? Padding(
              padding: const EdgeInsets.only(bottom: 88.0),
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFFF823A), // 비비드 코랄 강조색
                elevation: 6.0,
                highlightElevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                icon: const Text('✉️', style: TextStyle(fontSize: 16.0)),
                label: const Text(
                  '유리병 편지 띄우기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    letterSpacing: -0.3,
                    fontFamily: 'Pretendard',
                  ),
                ),
                onPressed: () => _showSendLetterModal(context),
              )
                  .animate()
                  .scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
            )
          : null,
    );
  }

  /// 상단 격리형 헤더 빌더 (새로고침, 토글, 상단 고정 수직정렬 문구 포함)
  Widget _buildHeader(BuildContext context, WidgetRef ref, CommunityViewMode viewMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12.0),
        // 화면 대타이틀 (중앙 고정으로 겹침 완화)
        const Text(
          '고수들의 바다',
          style: TextStyle(
            color: Color(0xFFE0F2F1),
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        )
            .animate()
            .fade(duration: 500.ms)
            .slideY(begin: -0.15, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 16.0),

        // 부드러운 스위칭 토글
        _buildSeaToggle(context, ref, viewMode),

        const SizedBox(height: 14.0),

        // 수직 정렬된 상단 안내 및 안심 문구 고정 영역 (새로고침 파도 버튼을 나의 해변 아래 우측에 배치)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 안내 및 안심 문구 Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 안내 문구
                  Text(
                    '바다 위 유리병을 탭하여 고민이나 위로를 읽어보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF8BA6A1).withValues(alpha: 0.9),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  // 안심 문구
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        size: 11,
                        color: Color(0xFF80CBC4),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'AI 부기가 안전하게 지키는 바다입니다.',
                        style: TextStyle(
                          color: const Color(0xFF8BA6A1).withValues(alpha: 0.6),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 나의 해변 버튼 바로 아래 영역 우상단에 새로고침 버튼 배치
              if (viewMode == CommunityViewMode.farSea)
                Positioned(
                  right: 8.0,
                  top: -8.0, // 문구 높이와 균형을 맞추기 위한 상단 오프셋
                  child: Tooltip(
                    message: '새로운 파도 부르기',
                    textStyle: const TextStyle(
                      fontSize: 11.0,
                      color: Color(0xFF071223),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh, // Icons.refresh 버튼 적용
                        color: Color(0xFFB2DFDB),
                        size: 24.0,
                      ),
                      onPressed: () {
                        ref.read(farSeaLettersProvider.notifier).refresh();
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 1),
                            backgroundColor: Color(0xFF142C4C),
                            content: Row(
                              children: [
                                Text('🌊', style: TextStyle(fontSize: 16.0)),
                                SizedBox(width: 10.0),
                                Text(
                                  '새로운 파도가 밀려와 바다를 채웁니다.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        )
            .animate()
            .fade(delay: 200.ms, duration: 400.ms),
      ],
    );
  }

  /// 고요한 밤바다 감성의 반투명 스위치 토글 (간소화)
  Widget _buildSeaToggle(
    BuildContext context,
    WidgetRef ref,
    CommunityViewMode current,
  ) {
    final isFarSea = current == CommunityViewMode.farSea;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFFB2DFDB).withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // 슬라이딩 인디케이터
          AnimatedAlign(
            alignment:
                isFarSea ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // 토글 텍스트 버튼들
          Row(
            children: [
              Expanded(
                child: _toggleOption(
                  label: '🌊 먼 바다',
                  isActive: isFarSea,
                  onTap: () => ref
                      .read(communityViewModeProvider.notifier)
                      .state = CommunityViewMode.farSea,
                ),
              ),
              Expanded(
                child: _toggleOption(
                  label: '🏖️ 나의 해변',
                  isActive: !isFarSea,
                  onTap: () => ref
                      .read(communityViewModeProvider.notifier)
                      .state = CommunityViewMode.myBeach,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fade(delay: 200.ms, duration: 400.ms);
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
                ? const Color(0xFFE0F2F1)
                : const Color(0xFF8BA6A1).withValues(alpha: 0.8),
            fontSize: 14.0,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // ── 편지 띄우기 풀스크린 다이얼로그 모달 ──
  void _showSendLetterModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _SendLetterScreen();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// View A: 먼 바다 (익명의 유리병들이 둥둥 떠다니는 밤바다 공간)
// ─────────────────────────────────────────────────────────────

class _FarSeaView extends ConsumerWidget {
  const _FarSeaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // ── 은은한 별빛 레이아웃 백그라운드 ──
        Positioned.fill(
          child: CustomPaint(
            painter: _StarryNightPainter(),
          ),
        ),

        // ── 조용한 밤바다 물결 애니메이션 데코레이션 ──
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                6,
                (i) => const Text('~', style: TextStyle(color: Colors.white, fontSize: 32.0))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .slideY(
                      begin: -0.2,
                      end: 0.2,
                      duration: (1500 + i * 200).ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),
            ),
          ),
        ),

        // ── 무작위 위치에 둥둥 떠있는 유리병 편지 리스트 (Riverpod & AnimatedSwitcher 연동) ──
        Consumer(
          builder: (context, ref, child) {
            final farSeaLetters = ref.watch(farSeaLettersProvider);

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 550),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: LayoutBuilder(
                // 상태(편지 ID들)의 변경을 감지해 자연스러운 페이드 스위칭 유발
                key: ValueKey<String>(farSeaLetters.map((e) => e.id).join(',')),
                builder: (context, constraints) {
                  return Stack(
                    children: farSeaLetters.map((bottle) {
                      final topPos = constraints.maxHeight * bottle.yRatio;
                      final leftPos = constraints.maxWidth * bottle.xRatio;

                      return Positioned(
                        key: ValueKey<String>(bottle.id),
                        top: topPos,
                        left: leftPos,
                        child: _GlassBottleWidget(
                          letter: bottle,
                          onTap: () => _showReadLetterDialog(context, ref, bottle),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            );
          },
        ),

      ],
    );
  }

  // ── 편지 읽기 감성 다이얼로그 팝업 ──
  void _showReadLetterDialog(BuildContext context, WidgetRef ref, _BottleLetter letter) {
    final isWorry = letter.type == BottleType.worry;
    final Color auraColor = isWorry
        ? const Color(0xFF9E9DFF).withValues(alpha: 0.15)
        : const Color(0xFFFFB74D).withValues(alpha: 0.15);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          backgroundColor: const Color(0xFFF9F5F0), // 양피지 따뜻한 아날로그 웜베이지 톤
          elevation: 12.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              // 은은한 편지 성격 맞춤형 RadialGradient 탑재 (감성 아우라)
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.3,
                colors: [
                  auraColor,
                  const Color(0xFFF9F5F0),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 양피지 위 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🍾', // 감성이 사는 유리병 이모지 고정
                          style: TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          letter.sender,
                          style: const TextStyle(
                            color: Color(0xFF5D4037), // 앤티크 브라운 컬러
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${letter.date.month}/${letter.date.day}',
                      style: TextStyle(
                        color: const Color(0xFF5D4037).withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Divider(color: Color(0xFFE4D5C5), height: 1.0, thickness: 1.0),
                const SizedBox(height: 18.0),

                // 편지 본문 (줄글 편지지 감성 디자인 적용)
                _LinedPaperContainer(
                  lineSpacing: 25.0,
                  horizontalPadding: 8.0,
                  backgroundColor: Colors.transparent, // 부모 RadialGradient 배경과 어우러지도록 투명화
                  borderRadius: 16.0,
                  child: Text(
                    letter.content,
                    style: const TextStyle(
                      color: Color(0xFF3E2723), // 깊고 부드러운 아날로그 서체 칼라
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.72, // 25.0 줄간격에 딱 얹히도록 정교하게 매칭 연산
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                
                const SizedBox(height: 24.0),

                // 어떤 유리병이든 동일하게 노출되는 통합 3버튼 액션 인터페이스 (보관, 공감, 답장)
                Row(
                  children: [
                    // [ 💛 ] 내 해변에 보관/해제 (토글 북마크)
                    _buildParchmentActionBtn(
                      icon: ref.read(savedLettersProvider.notifier).isSaved(letter.id) ? '🤍' : '💛',
                      tooltip: ref.read(savedLettersProvider.notifier).isSaved(letter.id) ? '보관 해제' : '해변에 보관',
                      onPressed: () {
                        final wasSaved = ref.read(savedLettersProvider.notifier).toggle(letter);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: wasSaved
                                ? const Color(0xFF4FA095)
                                : const Color(0xFF5D4037),
                            content: Row(
                              children: [
                                Text(wasSaved ? '💛' : '🤍', style: const TextStyle(fontSize: 16.0)),
                                const SizedBox(width: 10.0),
                                Text(
                                  wasSaved
                                      ? '편지가 나의 해변에 소중히 보관되었습니다.'
                                      : '편지가 해변에서 다시 바다로 떠났습니다.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8.0),
                    // [ 🙏 ] 고마움/공감 표시
                    _buildParchmentActionBtn(
                      icon: '🙏',
                      tooltip: '고마움 전하기',
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFFFF823A),
                            content: Row(
                              children: [
                                Text('🙏', style: TextStyle(fontSize: 16.0)),
                                SizedBox(width: 10.0),
                                Text(
                                  '따뜻한 공감의 마음을 보냈습니다.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8.0),
                    // [ ✍️ 답장 쓰기 ] 액션 버튼
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showReplyBottomSheet(context, letter);
                        },
                        icon: const Text('✍️', style: TextStyle(fontSize: 14.0)),
                        label: const Text(
                          '답장 쓰기',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            letterSpacing: -0.3,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FA095), // 파스텔 민트바다 포인트 칼라
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // 닫기 텍스트 버튼
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '바다로 돌려보내기',
                    style: TextStyle(
                      color: const Color(0xFF5D4037).withValues(alpha: 0.7),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .scale(duration: 350.ms, curve: Curves.easeOutBack);
      },
    );
  }

  /// 양피지 감성을 극대화한 소형 스퀘어 둥근 액션 버튼 빌더
  Widget _buildParchmentActionBtn({
    required String icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: const TextStyle(
        fontSize: 11.0,
        color: Color(0xFF5D4037),
        fontWeight: FontWeight.bold,
        fontFamily: 'Pretendard',
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE4D5C5)),
      ),
      child: SizedBox(
        width: 48.0,
        height: 48.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE4D5C5).withValues(alpha: 0.7),
            foregroundColor: const Color(0xFF3E2723),
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
              side: const BorderSide(
                color: Color(0xFFD7CCC8),
                width: 1.0,
              ),
            ),
          ),
          child: Text(
            icon,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }

  // ── 답장 쓰기 바텀시트 모달 ──
  void _showReplyBottomSheet(BuildContext context, _BottleLetter letter) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ReplyDismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: _ReplyBottomSheet(letter: letter),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

// ── 바다에 떠다니는 커스텀 유리병 위젯 ──
class _GlassBottleWidget extends StatelessWidget {
  final _BottleLetter letter;
  final VoidCallback onTap;

  const _GlassBottleWidget({
    required this.letter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 둥둥 떠다니는(Floating) 상하 루프 애니메이션 부여
    final randomDelay = Random().nextInt(800);
    final isWorry = letter.type == BottleType.worry;

    // 감정에 따른 시각적 글로우(아우라) 효과 분리
    final Color glowColor = isWorry
        ? const Color(0xFF9E9DFF).withValues(alpha: 0.25) // 은은한 보랏빛/푸른빛
        : const Color(0xFFFFB74D).withValues(alpha: 0.28); // 따뜻한 노란빛/코랄빛

    final Color baseColor = isWorry
        ? const Color(0xFF9E9DFF).withValues(alpha: 0.08)
        : const Color(0xFFFFB74D).withValues(alpha: 0.08);

    final Color labelColor = isWorry
        ? const Color(0xFFB2DFDB)
        : const Color(0xFFFFCC80);

    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 유리병 병 본체 & 오로라 아우라 이펙트
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 16.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: const Text(
              '🍾', // 밤바다 위에 둥둥 띄우는 감성을 살려 유리병 이모지 고정
              style: TextStyle(fontSize: 32.0),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .slideY(
                begin: -0.15,
                end: 0.15,
                duration: (1800 + randomDelay).ms,
                curve: Curves.easeInOutSine,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: (2000 + randomDelay).ms,
                curve: Curves.easeInOutSine,
              ),
          const SizedBox(height: 6.0),

          // 은은한 닉네임 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
            child: Text(
              letter.sender,
              style: TextStyle(
                color: labelColor.withValues(alpha: 0.8),
                fontSize: 9.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
          )
              .animate()
              .fade(delay: (randomDelay ~/ 2).ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// View B: 나의 해변 (💛 보관한 유리병 편지 보관함)
// ─────────────────────────────────────────────────────────────

class _MyBeachView extends ConsumerWidget {
  const _MyBeachView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLetters = ref.watch(savedLettersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),

          // 보관함 타이틀 + 카운트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text(
                  '💛 소중히 보관한 편지',
                  style: TextStyle(
                    color: Color(0xFFE0F2F1),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(width: 8.0),
                if (savedLetters.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF823A).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      '${savedLetters.length}',
                      style: const TextStyle(
                        color: Color(0xFFFF823A),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
              ],
            ),
          )
              .animate()
              .fade(duration: 400.ms)
              .slideX(begin: -0.05, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 16.0),

          // 컨텐츠 영역
          Expanded(
            child: savedLetters.isEmpty
                ? _buildEmptyState()
                : _buildSavedGrid(context, ref, savedLetters),
          ),
        ],
      ),
    );
  }

  /// 보관된 편지가 없을 때 보여줄 담백한 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🐚',
            style: TextStyle(fontSize: 48.0),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
                curve: Curves.easeInOutSine,
              ),
          const SizedBox(height: 20.0),
          Text(
            '아직 해변에 밀려온 편지가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8BA6A1).withValues(alpha: 0.8),
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '먼 바다에서 유리병을 건져 💛을 눌러 보관해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8BA6A1).withValues(alpha: 0.5),
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  /// 보관된 편지 2열 그리드 뷰
  Widget _buildSavedGrid(BuildContext context, WidgetRef ref, List<_BottleLetter> letters) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100.0), // 하단 네비바 공간 확보
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.82,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        return _SavedLetterCard(
          letter: letter,
          index: index,
          onTap: () => _showSavedLetterDialog(context, ref, letter),
        );
      },
    );
  }

  /// 보관된 편지 재열람 다이얼로그
  void _showSavedLetterDialog(BuildContext context, WidgetRef ref, _BottleLetter letter) {
    final isWorry = letter.type == BottleType.worry;
    final Color auraColor = isWorry
        ? const Color(0xFF9E9DFF).withValues(alpha: 0.15)
        : const Color(0xFFFFB74D).withValues(alpha: 0.15);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          backgroundColor: const Color(0xFFF9F5F0),
          elevation: 12.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.3,
                colors: [auraColor, const Color(0xFFF9F5F0)],
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🍾', style: TextStyle(fontSize: 18.0)),
                        const SizedBox(width: 8.0),
                        Text(
                          letter.sender,
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${letter.date.month}/${letter.date.day}',
                      style: TextStyle(
                        color: const Color(0xFF5D4037).withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Divider(color: Color(0xFFE4D5C5), height: 1.0, thickness: 1.0),
                const SizedBox(height: 18.0),

                // 편지 본문 (줄글 편지지)
                _LinedPaperContainer(
                  lineSpacing: 25.0,
                  horizontalPadding: 8.0,
                  backgroundColor: Colors.transparent,
                  borderRadius: 16.0,
                  child: Text(
                    letter.content,
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.72,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),

                // 기존 답변 목록
                if (letter.replies.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  ...letter.replies.map((reply) => Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 11.0)),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                reply,
                                style: const TextStyle(
                                  color: Color(0xFF5D4037),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 20.0),

                // 보관 해제 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(savedLettersProvider.notifier).toggle(letter);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF5D4037),
                        content: Row(
                          children: [
                            Text('🤍', style: TextStyle(fontSize: 16.0)),
                            SizedBox(width: 10.0),
                            Text(
                              '편지가 해변에서 다시 바다로 떠났습니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Text('🤍', style: TextStyle(fontSize: 14.0)),
                  label: const Text(
                    '해변에서 보내주기',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.0,
                      letterSpacing: -0.3,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4D5C5).withValues(alpha: 0.7),
                    foregroundColor: const Color(0xFF5D4037),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),

                // 닫기 버튼
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: const Color(0xFF5D4037).withValues(alpha: 0.7),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .scale(duration: 350.ms, curve: Curves.easeOutBack);
      },
    );
  }
}

// ── 보관된 편지 카드 위젯 (GridView 아이템) ──
class _SavedLetterCard extends StatelessWidget {
  final _BottleLetter letter;
  final int index;
  final VoidCallback onTap;

  const _SavedLetterCard({
    required this.letter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWorry = letter.type == BottleType.worry;
    final Color accentColor = isWorry
        ? const Color(0xFF9E9DFF) // 연한 퍼플/블루
        : const Color(0xFFFF823A); // 비비드 코랄/오렌지

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타입 뱃지 + 날짜
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    isWorry ? '고민' : '위로',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                Text(
                  '${letter.date.month}/${letter.date.day}',
                  style: TextStyle(
                    color: const Color(0xFF8BA6A1).withValues(alpha: 0.6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),

            // 보낸 사람 닉네임
            Row(
              children: [
                const Text('🍾', style: TextStyle(fontSize: 12.0)),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    letter.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFE0F2F1).withValues(alpha: 0.9),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // 본문 미리보기 (2줄)
            Expanded(
              child: Text(
                letter.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFFE0F2F1).withValues(alpha: 0.7),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),

            // 답변 개수 표시
            if (letter.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 10.0)),
                    const SizedBox(width: 4.0),
                    Text(
                      '${letter.replies.length}개의 따뜻한 답변',
                      style: TextStyle(
                        color: const Color(0xFF80CBC4).withValues(alpha: 0.7),
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fade(delay: (index * 100).ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.0, 1.0),
          delay: (index * 100).ms,
          duration: 350.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-Widgets: 답장 쓰기 바텀시트
// ─────────────────────────────────────────────────────────────

class _ReplyBottomSheet extends ConsumerStatefulWidget {
  final _BottleLetter letter;

  const _ReplyBottomSheet({required this.letter});

  @override
  ConsumerState<_ReplyBottomSheet> createState() => _ReplyBottomSheetState();
}

class _ReplyBottomSheetState extends ConsumerState<_ReplyBottomSheet> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85, // 화면의 최대 85%까지 유동적 확장
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF142C4C), // 깊은 해안 파란색
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 16.0,
          bottom: bottomPadding > 0 ? bottomPadding + 16.0 : 32.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 손잡이 바
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            // 상단 타이틀
            Text(
              '${widget.letter.sender}님께 다정한 엽서 쓰기',
              style: const TextStyle(
                color: Color(0xFFE0F2F1),
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              '조급하게 다그치거나 섣부른 조언 대신, 따뜻한 공감과 은은한 응원의 문장만 전해주세요.',
              style: TextStyle(
                color: const Color(0xFF8BA6A1).withValues(alpha: 0.8),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 16.0),

            // 스크롤 가능한 원본 영역 & 기존 답변들 리스트
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 원본 고민 내용 (아날로그 줄글 편지지 느낌 연계 적용)
                    _LinedPaperContainer(
                      lineSpacing: 22.0,
                      horizontalPadding: 10.0,
                      backgroundColor: const Color(0xFFFDFBF7), // 다소 밝고 크리미한 웜베이지 양피지색
                      borderRadius: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🍾', style: TextStyle(fontSize: 12.0)),
                              const SizedBox(width: 6.0),
                              Text(
                                '${widget.letter.sender}님의 편지 내용',
                                style: const TextStyle(
                                  color: Color(0xFF5D4037),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            widget.letter.content,
                            style: const TextStyle(
                              color: Color(0xFF3E2723), // 서체 브라운 톤
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.76, // 22.0 줄간격 매칭 세밀화
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 기존에 달린 답변 리스트 (릴레이 답변 연출)
                    if (widget.letter.replies.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          '💬 이웃들이 남긴 따뜻한 흔적 (${widget.letter.replies.length}개)',
                          style: const TextStyle(
                            color: Color(0xFF80CBC4),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                      ...widget.letter.replies.map((reply) => Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: const Color(0xFF80CBC4).withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💬', style: TextStyle(fontSize: 12.0)),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    reply,
                                    style: const TextStyle(
                                      color: Color(0xFFECEFF1),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      height: 1.45,
                                      fontFamily: 'Pretendard',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12.0),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12.0),

            // 신규 답장 입력창 (양피지 보더 및 다정한 디자인 적용)
            TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.4,
                fontFamily: 'Pretendard',
              ),
              decoration: InputDecoration(
                hintText: '기존 이웃들의 답변 밑에 소중한 마음을 한 겹 덧붙여 보세요...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12.5,
                  height: 1.4,
                ),
                fillColor: Colors.black.withValues(alpha: 0.25),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF80CBC4),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14.0),

            // 띄우기 액션 버튼
            ElevatedButton(
              onPressed: () {
                final replyText = _textController.text.trim();
                if (replyText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('다정한 응원의 말을 한마디라도 적어주세요. 🐚'),
                    ),
                  );
                  return;
                }

                // 릴레이 답글 저장 비즈니스 로직 구동 (Riverpod 상태 누적 업데이트)
                ref.read(farSeaLettersProvider.notifier).addReply(widget.letter.id, replyText);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF4FA095),
                    content: Row(
                      children: [
                        const Text('🐢', style: TextStyle(fontSize: 16.0)),
                        const SizedBox(width: 10.0),
                        Text(
                          '${widget.letter.sender}님께 따뜻한 위로 엽서가 발송되었습니다.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF823A), // 비비드 코랄
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text(
                '다정한 엽서 띄워 보내기 ✓',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                  letterSpacing: -0.2,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-Widgets: 유리병 고민 편지 새로 띄우기 (FullScreen Screen)
// ─────────────────────────────────────────────────────────────

class _SendLetterScreen extends StatefulWidget {
  @override
  State<_SendLetterScreen> createState() => _SendLetterScreenState();
}

class _SendLetterScreenState extends State<_SendLetterScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071223), // 깊은 한밤의 밤바다 테마
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071223),
              Color(0xFF0D1E36),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더 엽서 타이틀 바
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFE0F2F1)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      '유리병 편지 쓰기',
                      style: TextStyle(
                        color: Color(0xFFE0F2F1),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(width: 48.0), // 대칭용 더미 공간
                  ],
                ),
                const SizedBox(height: 24.0),

                // 안내 가이드 메시지
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFFB2DFDB).withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🐢', style: TextStyle(fontSize: 22.0)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          '마음의 응어리를 가감 없이 쏟아내세요.\n'
                          '닉네임은 비밀이며, 부기가 안전한 숲으로 유도할게요.',
                          style: TextStyle(
                            color: const Color(0xFF80CBC4).withValues(alpha: 0.9),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // 양피지 느낌의 널찍한 편지지 입력 폼
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5F0), // 웜베이지 양피지 아날로그 감성 톤
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Text('📜', style: TextStyle(fontSize: 16.0)),
                            SizedBox(width: 8.0),
                            Text(
                              '밤바다로 띄워 보낼 고민',
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontWeight: FontWeight.w800,
                                fontSize: 13.0,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        const Divider(color: Color(0xFFE4D5C5), height: 1.0, thickness: 1.0),
                        const SizedBox(height: 12.0),
                        
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              color: Color(0xFF3E2723), // 서체 브라운 톤
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                              fontFamily: 'Pretendard',
                            ),
                            decoration: InputDecoration(
                              hintText: '아무에게도 털어놓지 못했던 깊은 마음속 무거운 생각들을 자유롭게 흘려보내세요...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF5D4037).withValues(alpha: 0.4),
                                fontSize: 13.5,
                                height: 1.6,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // 띄우기 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFFFF823A), // 비비드 코랄
                        content: Row(
                          children: [
                            Text('🍾', style: TextStyle(fontSize: 16.0)),
                            SizedBox(width: 10.0),
                            Text(
                              '고민을 품은 유리병이 고요한 밤바다 위로 둥실 떠났습니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Text('🌊', style: TextStyle(fontSize: 14.0)),
                  label: const Text(
                    '어두운 바다에 띄워 보내기',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                      letterSpacing: -0.2,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF823A), // 비비드 코랄
                    foregroundColor: Colors.white,
                    elevation: 4.0,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Custom Painter for Starry Night Sky
// ─────────────────────────────────────────────────────────────

class _StarryNightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    final random = Random(42); // 고정 난수로 별들의 은하수 레이아웃 위치 보존

    for (int i = 0; i < 40; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height * 0.7; // 상단 영역 위주로 별 분포
      final double radius = random.nextDouble() * 1.5 + 0.3; // 별 크기
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Lined Paper Painter & Container for Analog Paper Vibe
// ─────────────────────────────────────────────────────────────

class _LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineSpacing;
  final double horizontalPadding;

  const _LinedPaperPainter({
    required this.lineColor,
    required this.lineSpacing,
    required this.horizontalPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 가로 줄선 그리기 (첫 줄은 상단 여백 고려, 아래 20dp 여백 남김)
    double y = 48.0;
    while (y < size.height - 20.0) {
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        paint,
      );
      y += lineSpacing;
    }

    // 좌측 연한 붉은 세로 가이드선 (아날로그 공책 감성 마진)
    final redMarginPaint = Paint()
      ..color = const Color(0xFFFFAB91).withValues(alpha: 0.35)
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(horizontalPadding + 12.0, 15.0),
      Offset(horizontalPadding + 12.0, size.height - 15.0),
      redMarginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinedPaperContainer extends StatelessWidget {
  final Widget child;
  final double lineSpacing;
  final double horizontalPadding;
  final Color? backgroundColor;
  final double borderRadius;

  const _LinedPaperContainer({
    required this.child,
    this.lineSpacing = 26.0,
    this.horizontalPadding = 20.0,
    this.backgroundColor,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF9F5F0), // 양피지 따뜻한 아날로그 웜베이지 톤
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFE4D5C5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          painter: _LinedPaperPainter(
            lineColor: const Color(0xFFE4D5C5).withValues(alpha: 0.55),
            lineSpacing: lineSpacing,
            horizontalPadding: horizontalPadding,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding + 22.0, // 빨간 세로선 안쪽 배치
              right: horizontalPadding + 10.0,
              top: 24.0,
              bottom: 24.0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

