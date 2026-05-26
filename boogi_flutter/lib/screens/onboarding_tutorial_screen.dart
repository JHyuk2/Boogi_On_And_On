import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import 'main_layout.dart';

class OnboardingTutorialScreen extends ConsumerStatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  ConsumerState<OnboardingTutorialScreen> createState() =>
      _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState
    extends ConsumerState<OnboardingTutorialScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1;
  String _selectedPersona = '';
  String _inputName = '';
  final TextEditingController _nameController = TextEditingController();

  // 대사 타이핑 상태 관리
  String _fullDialogueText = '';
  String _displayedDialogueText = '';
  Timer? _typingTimer;
  bool _isTypingCompleted = false;

  // 뽀글뽀글 바품 효과용 난수 저장
  final List<Map<String, double>> _bubbleData = [];

  // 암전 효과 제어용 애니메이션
  bool _isSuccessTriggered = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 버블 데코용 좌표 미리 난수 생성
    for (int i = 0; i < 15; i++) {
      _bubbleData.add({
        'left': ((i * 37) % 320 + 20).toDouble(),
        'bottom': ((i * 61) % 550 + 40).toDouble(),
        'size': ((i * 9) % 12 + 6).toDouble(),
        'speed': (4 + (i % 3)).toDouble(),
      });
    }

    // 첫 번째 대사 시작
    _startDialogue(
      "안녕! 🌊 이 푸른 바다에 온 걸 진심으로 환영해. 나는 너의 여행을 도와줄 안내자 거북이야. 너에 대해 조금 더 알고 싶은데, 너는 어떤 사람이야?",
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // 글자 한 글자씩 출력하는 타이핑 메커니즘
  void _startDialogue(String text) {
    _typingTimer?.cancel();
    setState(() {
      _fullDialogueText = text;
      _displayedDialogueText = '';
      _isTypingCompleted = false;
    });

    int charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (charIndex < text.length) {
        setState(() {
          _displayedDialogueText += text[charIndex];
        });
        charIndex++;
      } else {
        _typingTimer?.cancel();
        setState(() {
          _isTypingCompleted = true;
        });
      }
    });
  }

  // 사용자가 말풍선을 누르면 타이핑 완료 상태로 스킵
  void _skipTyping() {
    if (!_isTypingCompleted) {
      _typingTimer?.cancel();
      setState(() {
        _displayedDialogueText = _fullDialogueText;
        _isTypingCompleted = true;
      });
    }
  }

  // 1단계: 정체성 선택 시 처리
  void _onSelectPersona(String persona) {
    setState(() {
      _selectedPersona = persona;
      _currentStep = 2;
    });
    ref.read(onboardingProvider.notifier).setSelectedPersona(persona);

    _startDialogue(
      "$_selectedPersona이구나! 정말 잘 찾아왔어. 여기까지 먼 길 오느라 많이 힘들었지?\n\n이 넓은 바다에서는 완벽하지 않아도 괜찮아. 조금 느려도, 서툴러도 다 괜찮으니까 편하게 있어. 내가 언제나 네 곁에서 도와줄게! 우리 함께 즐거운 여행을 시작해 볼까?",
    );
  }

  // 2단계 -> 3단계 이동
  void _goToStep3() {
    setState(() {
      _currentStep = 3;
    });
    _startDialogue(
      "그러고 보니... 내 친구가 어떤 별에서 온 왕자와 나눈 이야기를 들었어!\n\n『이 세상엔 수많은 거북이가 있지만, 네가 나에게 이름을 붙여주고 불러주는 순간... 나는 너에게 지구상에 단 하나뿐인 특별한 거북이가 되는 거야.』 🐢✨\n\n나도 너와 친해지고 특별한 거부기가 되고싶어! 나를 이 바다에서 뭐라고 불러줄래? 네가 지어준 이름으로 불리고 싶어!",
    );
  }

  // 3단계 -> 4단계 이름 설정 시 처리
  void _onNameSubmitted() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('부기에게 지어줄 이름을 적어주세요. 🐢'),
          backgroundColor: Color(0xFF4FA095),
        ),
      );
      return;
    }

    setState(() {
      _inputName = name;
      _currentStep = 4;
    });
    ref.read(onboardingProvider.notifier).setTurtleName(name);

    _startDialogue(
      "$_inputName부기...? 와, 정말 이 이름이 맞아?",
    );
  }

  // 4단계 -> 응 선택 시 Step 5로 이동
  void _confirmName() {
    setState(() {
      _currentStep = 5;
    });
    // 홈 화면 서약서 텍스트 자동 동기화
    ref.read(onboardingProvider.notifier).setPledgeText(
          "오직 너만을 위한 $_inputName부기야. 우리 앞으로 이 바다에서 예쁜 추억 많이 만들자. 잘 부탁해!",
        );

    _startDialogue(
      "와아...! 눈이 부실 정도로 너무 멋진 이름이야! 감동이야... 주르륵 😭\n\n이제 나는 그냥 거북이가 아니라, 오직 너만을 위한 $_inputName부기야. 우리 앞으로 이 바다에서 예쁜 추억 많이 만들자. 잘 부탁해! 🐳💙",
    );
  }

  // 4단계 -> 아니오 선택 시 Step 3으로 롤백
  void _rollbackToStep3() {
    setState(() {
      _currentStep = 3;
    });
    _startDialogue(
      "나의 다른 멋진 이름을 고민해 주는구나! 언제든 기다릴게. 나를 뭐라고 불러줄래? 네가 지어준 이름으로 불리고 싶어!",
    );
  }

  // 5단계 -> 여정 최종 시작하기
  Future<void> _startVoyage() async {
    setState(() {
      _isSuccessTriggered = true;
    });

    // 온보딩 프로바이더의 항해 시작 프로세스 트리거 (시뮬레이션 포함)
    await ref.read(onboardingProvider.notifier).startVoyage();

    // 암전 효과 시작
    await _fadeController.forward();

    if (mounted) {
      // 메인화면(MainLayout)으로 이동하며 온보딩 스택 삭제
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. 배경: 마음이 편안해지는 은은한 파스텔 민트 그라데이션 ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE2F6F8), // 부드러운 아침 하늘 민트
                  Color(0xFFD4EFEF), // 편안한 바다 안개 민트
                  Color(0xFFB5E3E6), // 뽀글뽀글 파스텔 민트색
                ],
              ),
            ),
          ),

          // ── 2. 물방울 뽀글뽀글 바다 효과 데코레이션 ──
          ...List.generate(_bubbleData.length, (index) {
            final bubble = _bubbleData[index];
            return Positioned(
              left: bubble['left'],
              bottom: bubble['bottom'],
              child: Container(
                width: bubble['size'],
                height: bubble['size'],
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .slideY(
                    begin: 1.0,
                    end: -4.0,
                    duration: Duration(seconds: bubble['speed']!.toInt()),
                    curve: Curves.easeOut,
                  )
                  .fade(begin: 0.4, end: 0.0),
            );
          }),

          // ── 3. 메인 콘텐츠 ──
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // 상단 단계 게이지바
                  _buildProgressGauge(),
                  const SizedBox(height: 10.0),

                  // 중앙: 고정된 부기 🐢 일러스트 (둥실둥실 호흡 애니메이션 적용)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 부기 뒤편의 은은한 감성 오라(Halo) 광채 효과
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4FA095)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              )
                                  .animate(
                                      onPlay: (c) => c.repeat(reverse: true))
                                  .scale(
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1.1, 1.1),
                                    duration: 2500.ms,
                                    curve: Curves.easeInOutSine,
                                  ),

                              // 고정 부기 캐릭터 (둥실둥실 감성 🐢)
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🐢',
                                    style: TextStyle(fontSize: 76),
                                  ),
                                ),
                              )
                                  .animate(
                                      onPlay: (c) => c.repeat(reverse: true))
                                  .slideY(
                                    begin: -0.06,
                                    end: 0.06,
                                    duration: 1800.ms,
                                    curve: Curves.easeInOutQuad,
                                  ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_inputName.isNotEmpty && _currentStep >= 4)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E5257)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_inputName부기 🐢',
                                style: const TextStyle(
                                  color: Color(0xFF1E5257),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ).animate().fade(duration: 400.ms),
                        ],
                      ),
                    ),
                  ),

                  // 하단 영역: 말풍선 대화 상자 + 선택지/버튼 구역
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 글래스모피즘 타이핑 말풍선
                      GestureDetector(
                        onTap: _skipTyping,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 120),
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: const Color(0xFFB2DFDB)
                                  .withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E5257)
                                    .withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // 말풍선 대사 출력
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  _displayedDialogueText,
                                  style: const TextStyle(
                                    color: Color(0xFF2E4E52),
                                    fontSize: 14.5,
                                    height: 1.6,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // 타이핑 중일 때 미세하게 반짝이는 스킵 가이드
                              if (!_isTypingCompleted)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Text(
                                    '터치하여 빠르게 넘기기 ➔',
                                    style: TextStyle(
                                      color: const Color(0xFF4FA095)
                                          .withValues(alpha: 0.7),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .fade(
                                          begin: 0.3,
                                          end: 0.9,
                                          duration: 800.ms),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // 동적 인터랙션 선택 구역 (타이핑이 다 끝나거나 유저가 스킵했을 때 부드럽게 페이드인)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _isTypingCompleted
                            ? _buildInteractionArea(onboardingState)
                            : const SizedBox(height: 60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 4. 암전 연출용 전체 화면 오버레이 ──
          if (_isSuccessTriggered)
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                color: const Color(0xFF070F1C), // 칠흑 같은 밤바다색으로 암전
              ),
            ),
        ],
      ),
    );
  }

  // 상단 진행 단계 게이지바 뷰
  Widget _buildProgressGauge() {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _currentStep / 5.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF80CBC4), Color(0xFF4FA095)],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FA095).withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 각 단계에 따른 선택지/버튼 구역
  Widget _buildInteractionArea(OnboardingState state) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Choices();
      case 2:
        return _buildStep2Button();
      case 3:
        return _buildStep3Input();
      case 4:
        return _buildStep4Confirm();
      case 5:
        return _buildStep5Finish(state);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1단계: 정체성 묻기 (4가지 Choice Card 형태)
  Widget _buildStep1Choices() {
    final List<String> personas = [
      "💻 일하는 직장인",
      "📝 공부하는 학생",
      "☕️ 휴식이 필요한 사람",
      "✨ 나만의 길을 가는 중",
    ];

    return Column(
      children: personas.map((persona) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () => _onSelectPersona(persona),
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 14.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: const Color(0xFFB2DFDB).withValues(alpha: 0.4),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    persona,
                    style: const TextStyle(
                      color: Color(0xFF1E5257),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF8BA6A1),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.15, end: 0);
      }).toList(),
    );
  }

  // 2단계: 위로 및 다음 이동 버튼
  Widget _buildStep2Button() {
    return ElevatedButton(
      onPressed: _goToStep3,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FA095),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 3,
      ),
      child: const Text(
        '좋아, 함께 가자! ⛵',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1800.ms, color: Colors.white24)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }

  // 3단계: 이름 짓기 입력창 + 버튼
  Widget _buildStep3Input() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          maxLength: 8,
          style: const TextStyle(
            color: Color(0xFF1E5257),
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
          ),
          decoration: InputDecoration(
            hintText: '여기에 이름 입력',
            hintStyle: const TextStyle(color: Color(0xFF9EAFA9)),
            counterText: '',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.9),
            suffixText: '부기',
            suffixStyle: const TextStyle(
              color: Color(0xFF1E5257),
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 14.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                color: Color(0xFFB2DFDB),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(
                color: Color(0xFF4FA095),
                width: 1.8,
              ),
            ),
          ),
        ).animate().fade(duration: 400.ms),
        const SizedBox(height: 14.0),
        ElevatedButton(
          onPressed: _onNameSubmitted,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FA095),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 2,
          ),
          child: const Text(
            '이 이름으로 할래 🐢',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 4단계: 이름 재확인 (예/아니오)
  Widget _buildStep4Confirm() {
    return Row(
      children: [
        // '아니, 다시 지을래' 버튼
        Expanded(
          child: OutlinedButton(
            onPressed: _rollbackToStep3,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5A7D82),
              side: const BorderSide(color: Color(0xFFB2DFDB), width: 1.5),
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.6),
            ),
            child: const Text(
              '아니, 다시 지을래',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),

        // '응, 맞아!' 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmName,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA095),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 2,
            ),
            child: const Text(
              '응, 맞아! ✨',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.03, 1.03),
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // 5단계: 완료 및 여정 시작하기
  Widget _buildStep5Finish(OnboardingState state) {
    return ElevatedButton(
      onPressed: state.isUploading ? null : _startVoyage,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF823A), // 성취와 에너지를 채우는 비비드 코랄
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFD4C5B9),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        elevation: 4,
      ),
      child: state.isUploading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '🌊 여행 시작하기',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: Colors.white30)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}
