import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/signature_pad.dart';
import 'main_layout.dart';

class PledgeScreen extends ConsumerStatefulWidget {
  const PledgeScreen({super.key});

  @override
  ConsumerState<PledgeScreen> createState() => _PledgeScreenState();
}

class _PledgeScreenState extends ConsumerState<PledgeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _pledgeController = TextEditingController();
  bool _hasSignature = false;
  bool _isSuccessTriggered = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pledgeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSignatureChanged(List<Offset> points) {
    setState(() {
      // 5개 이상의 점이 찍혔을 때 유효한 서명으로 간주합니다.
      _hasSignature = points.length >= 5;
    });
  }

  Future<void> _onStartVoyage() async {
    final pledgeText = _pledgeController.text.trim();
    if (pledgeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('나 자신을 위한 따뜻한 한마디를 적어주세요.')),
      );
      return;
    }

    // Riverpod 상태에 다짐 텍스트 저장
    ref.read(onboardingProvider.notifier).setPledgeText(pledgeText);

    // Firebase 백그라운드 로그인 및 데이터 저장 실행
    await ref.read(onboardingProvider.notifier).startVoyage();

    final onboardingState = ref.read(onboardingProvider);

    if (onboardingState.uploadSuccess) {
      // 업로드 성공 시, 양피지 카드가 빛으로 스르륵 부서지는/사라지는 애니메이션 효과 트리거
      setState(() {
        _isSuccessTriggered = true;
      });

      // 암전 효과용 애니메이션 실행
      await _fadeController.forward();

      // 메인 홈 화면으로 자연스럽게 라우팅
      if (mounted) {
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
    } else if (onboardingState.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('항해를 시작하지 못했습니다: ${onboardingState.errorMessage}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final isButtonEnabled = _pledgeController.text.trim().isNotEmpty &&
        _hasSignature &&
        !onboardingState.isUploading &&
        !_isSuccessTriggered;

    Widget cardContent = Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // 감성 가득한 베이지 톤의 양피지 종이 질감
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 제목 및 설명
          const Text(
            '🌊 나를 위한 항해 서약서',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2E433E),
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12.0),
          const Text(
            '이 여정을 시작하며, 나 자신에게 하고 싶은 말 한마디를 적어주세요.\n이 약속은 가장 깊고 어두운 밤에 당신을 찾아갈게요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5A6E69),
              fontSize: 13.0,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20.0),

          // 다짐 입력창
          TextField(
            controller: _pledgeController,
            onChanged: (text) => setState(() {}),
            maxLength: 30,
            style: const TextStyle(
              color: Color(0xFF1E3547),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '예: 너무 자책하지 말자, 오늘 하루도 수고했어',
              hintStyle: const TextStyle(color: Color(0xFF9EAFA9)),
              counterText: '',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFFD4C5B9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF4FA095), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // 서명 안내 텍스트
          const Text(
            '아래에 손가락으로 다짐 서명을 그려주세요.',
            style: TextStyle(
              color: Color(0xFF5A6E69),
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),

          // 서명 드로잉 패드 (SignaturePad)
          Expanded(
            child: SignaturePad(
              onSignatureChanged: _onSignatureChanged,
            ),
          ),
          const SizedBox(height: 20.0),

          // 항해 시작 버튼
          ElevatedButton(
            onPressed: isButtonEnabled ? _onStartVoyage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA095),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD4C5B9),
              disabledForegroundColor: Colors.white54,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 2,
            ),
            child: onboardingState.isUploading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '항해 시작하기 ⛵',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );

    // 성공 트리거가 되었을 때 양피지 종이가 빛으로 바스러지며 축소 + 투명해지는 연출
    if (_isSuccessTriggered) {
      cardContent = cardContent
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.7, 0.7),
            duration: 1000.ms,
            curve: Curves.easeInOutBack,
          )
          .fade(
            begin: 1.0,
            end: 0.0,
            duration: 900.ms,
          )
          .blurXY(
            begin: 0.0,
            end: 8.0,
            duration: 900.ms,
          );
    } else {
      // 첫 화면 진입 시 양피지 카드가 아래서 둥실 부드럽게 솟아오름
      cardContent = cardContent
          .animate()
          .fade(duration: 600.ms)
          .slideY(begin: 0.2, end: 0.0, duration: 600.ms, curve: Curves.easeOutBack);
    }

    return Scaffold(
      body: Stack(
        children: [
          // 배경: 밤바다 다크 블루 그라데이션
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F1E36),
                  Color(0xFF1D2F4E),
                  Color(0xFF2C4368),
                ],
              ),
            ),
          ),

          // 은은한 파도 소리 배경 및 밤바다 별 이펙트
          ...List.generate(20, (index) {
            final double left = (index * 43) % 360 + 10;
            final double top = (index * 73) % 700 + 40;
            final double size = (index % 3) == 0 ? 3.0 : 1.5;
            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fade(
                    begin: 0.2,
                    end: 0.9,
                    duration: Duration(seconds: 2 + (index % 3)),
                  ),
            );
          }),

          // 메인 컨텐츠 영역
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // 뒤로가기 버튼
                  if (!_isSuccessTriggered)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        tooltip: '뒤로가기',
                      ),
                    ),
                  Expanded(
                    child: Center(child: cardContent),
                  ),
                ],
              ),
            ),
          ),

          // 암전 연출용 전체 화면 오버레이 (성공 시)
          if (_isSuccessTriggered)
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                color: const Color(0xFF070F1C), // 아주 칠흑같은 밤바다 검정색으로 서서히 암전
              ),
            ),
        ],
      ),
    );
  }
}
