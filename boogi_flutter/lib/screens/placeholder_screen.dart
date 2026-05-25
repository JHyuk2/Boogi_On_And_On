import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아름다운 파도/물결 장식 뒤로 둥실 떠있는 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA095).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4FA095).withValues(alpha: 0.2),
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 44,
                  color: const Color(0xFF4FA095),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .slideY(begin: -0.08, end: 0.08, duration: 2.seconds, curve: Curves.easeInOutQuad),
              
              const SizedBox(height: 24),
              
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E5257),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 10),

              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5A7D82),
                  fontSize: 14.0,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fade(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: 32),

              // "개발 중..." 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA095).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4FA095).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FA095)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '더 멋진 기능 준비 중',
                      style: TextStyle(
                        color: Color(0xFF1E5257),
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fade(delay: 400.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
