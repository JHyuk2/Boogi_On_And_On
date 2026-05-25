import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/chat_bubble.dart';
import 'pledge_screen.dart';

class OnboardingChatScreen extends ConsumerStatefulWidget {
  const OnboardingChatScreen({super.key});

  @override
  ConsumerState<OnboardingChatScreen> createState() =>
      _OnboardingChatScreenState();
}

class _OnboardingChatScreenState extends ConsumerState<OnboardingChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _showChoices = false;
  String? _selectedChoice;
  bool _showNextButton = false;

  final List<String> _statusChoices = [
    "🎒 나만의 속도로 묵묵히 공부하고 있는 학생",
    "🏢 바쁘게 굴러가는 일상 속 직장인",
    "⛵ 새로운 변화와 출발을 맞이하고 있는 상태",
    "🌧️ 잠시 숨을 고르며 쉬어가고 싶은 시기"
  ];

  @override
  void initState() {
    super.initState();
    _startIntro();
  }

  Future<void> _startIntro() async {
    // 0.5초 딜레이 후 첫 부기 대사 노출
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _messages.add({
        'text': "안녕? 난 이 바다를 안내하는 부기야.\n넌 지금 어떤 여행을 하고 있어?",
        'isMe': false,
      });
    });
    _scrollToBottom();

    // 부기 대사가 나타나고 0.8초 후 선택지 칩 활성화
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _showChoices = true;
    });
    _scrollToBottom();
  }

  void _onSelectChoice(String choice) async {
    if (_selectedChoice != null) return; // 이미 선택한 경우 무시

    setState(() {
      _selectedChoice = choice;
      _showChoices = false; // 선택 완료 시 칩 숨김
      _messages.add({
        'text': choice,
        'isMe': true,
      });
    });
    _scrollToBottom();

    // 상태 저장
    ref.read(onboardingProvider.notifier).setUserStatus(choice);

    // 유저 대사 출력 후 1.0초 뒤 부기의 반응 메시지
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _messages.add({
        'text':
            "그렇구나. 많이 힘들고 지쳤을 텐데 여기까지 잘 찾아왔어.\n완벽하지 않아도 괜찮아. 내가 언제나 이 바다에서 도와줄게!",
        'isMe': false,
      });
    });
    _scrollToBottom();

    // 부기 리액션 노출 후 0.6초 뒤 '다음으로' 버튼 활성화
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _showNextButton = true;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.microtask(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1E36), // 깊은 밤바다 어두운 남색
              Color(0xFF1D2F4E), // 중간 톤의 새벽 바다색
              Color(0xFF2C4368), // 잔잔한 수평선 다크 블루
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 커스텀 앱바
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6DEBE1), // 안내자 시그널 라이트
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      '안내자 부기와의 만남',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1.0),

              // 채팅 목록 구역
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return ChatBubble(
                      text: msg['text'],
                      isMe: msg['isMe'],
                      delayAppear: true,
                    );
                  },
                ),
              ),

              // 하단 인터랙션 구역 (선택 칩 또는 다음으로 버튼)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1726)
                        .withValues(alpha: 0.9), // 가상 키보드 영역
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 선택지 칩 영역
                      if (_showChoices)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _statusChoices.map((choice) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: InkWell(
                                onTap: () => _onSelectChoice(choice),
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          choice,
                                          style: const TextStyle(
                                            color: Color(0xFFF7F9FB),
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white38,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fade(duration: 400.ms).slideX(
                                begin: 0.1, end: 0.0, curve: Curves.easeOut);
                          }).toList(),
                        ),

                      // 다음으로 버튼 영역
                      if (_showNextButton)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const PledgeScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 600),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6DEBE1), // 활기차면서도 부드러운 청록색
                            foregroundColor: const Color(0xFF0F1E36),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            '다음 여정으로 ⛵',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        )
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .shimmer(duration: 1500.ms, color: Colors.white30)
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.02, 1.02),
                              duration: 1000.ms,
                              curve: Curves.easeInOut,
                            ),

                      // 초기 상태(첫 대사 출력 전) 안내 문구
                      if (!_showChoices &&
                          !_showNextButton &&
                          _selectedChoice == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white30),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Text(
                                '부기가 말을 건네고 있습니다...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
