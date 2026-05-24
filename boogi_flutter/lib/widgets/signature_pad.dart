import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final ValueChanged<List<Offset>> onSignatureChanged;

  const SignaturePad({
    super.key,
    required this.onSignatureChanged,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];

  void _clear() {
    setState(() {
      _points.clear();
    });
    widget.onSignatureChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2).withValues(alpha: 0.9), // 양피지 매칭 소프트 크림색
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFD4C5B9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _points.add(details.localPosition);
                  });
                  // 유효한 포인트(null이 아닌 것)들만 넘겨줍니다.
                  widget.onSignatureChanged(
                      _points.whereType<Offset>().toList());
                },
                onPanEnd: (details) {
                  setState(() {
                    _points.add(null); // 한 획을 마침
                  });
                },
                child: CustomPaint(
                  painter: SignaturePainter(_points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF7A6B5D)),
            label: const Text(
              '다시 그리기',
              style: TextStyle(
                color: Color(0xFF7A6B5D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3547) // 고급스러운 짙은 네이비 잉크 색
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
