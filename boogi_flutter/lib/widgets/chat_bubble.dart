import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool delayAppear;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.delayAppear = false,
  });

  @override
  Widget build(BuildContext context) {
    final double leftPadding = isMe ? 64.0 : 8.0;
    final double rightPadding = isMe ? 8.0 : 64.0;

    Widget bubble = Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: leftPadding,
        right: rightPadding,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF3B5B88) // 유저: 잔잔한 밤바다 밤색/짙은 청색
            : const Color(0xFFE2EFF0), // 부기: 부드러운 파스텔 민트/바다 거품색
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16.0),
          topRight: const Radius.circular(16.0),
          bottomLeft: Radius.circular(isMe ? 16.0 : 4.0),
          bottomRight: Radius.circular(isMe ? 4.0 : 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : const Color(0xFF1E3547),
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );

    // 부기 말풍선일 경우 원형 아바타를 포함시킵니다.
    if (!isMe) {
      bubble = Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 귀여운 부기(거북이) 아바타
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF90D2D8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🐢',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(child: bubble),
          ],
        ),
      );
    }

    if (delayAppear) {
      return bubble
          .animate()
          .fade(duration: 500.ms, curve: Curves.easeOut)
          .slideY(begin: 0.2, end: 0.0, duration: 500.ms, curve: Curves.easeOut);
    }

    return bubble;
  }
}
