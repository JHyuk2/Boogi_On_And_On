import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ocean_theme.dart';

// ─────────────────────────────────────────────────────────────
// 목표 생성 바텀시트 (Goal Creation Bottom Sheet)
// 사용자가 자신의 목표를 입력하고 AI 부기에게 쪼개기를 맡기는 UI
// 공개/비공개 토글 + 게시판 발행 옵션 포함
// ─────────────────────────────────────────────────────────────

class GoalCreationSheet extends StatefulWidget {
  const GoalCreationSheet({super.key});

  /// 바텀시트를 표시하는 편의 메서드
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => const GoalCreationSheet(),
    );
  }

  @override
  State<GoalCreationSheet> createState() => _GoalCreationSheetState();
}

class _GoalCreationSheetState extends State<GoalCreationSheet> {
  final TextEditingController _titleController = TextEditingController();
  bool _isPublic = true; // 기본값: 공개

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: 24.0 + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 드래그 핸들 바 ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OceanTheme.borderMint.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // ── 헤더: 아이콘 + 제목 ──
          Row(
            children: [
              // 거북이 아이콘 배경
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: OceanTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: const Center(
                  child: Text('🐢', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나만의 목표 생성',
                      style: TextStyle(
                        color: OceanTheme.textDark,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'AI 부기가 가장 작고 다정한 첫걸음으로 쪼개줄게요.',
                      style: TextStyle(
                        color: OceanTheme.textSub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fade(duration: 400.ms),

          const SizedBox(height: 24.0),

          // ── 목표 입력 필드 ──
          TextField(
            controller: _titleController,
            maxLines: 3,
            minLines: 2,
            maxLength: 100,
            style: const TextStyle(
              color: OceanTheme.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 15.0,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '이루고 싶은 목표를 자유롭게 적어보세요.\n예) 매일 운동하는 습관 만들기',
              hintStyle: const TextStyle(
                color: OceanTheme.textMuted,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              filled: true,
              fillColor: OceanTheme.cardWarm,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16.0,
              ),
              counterStyle: const TextStyle(
                color: OceanTheme.textMuted,
                fontSize: 11.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: BorderSide(
                  color: OceanTheme.borderMint.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: const BorderSide(
                  color: OceanTheme.primary,
                  width: 1.8,
                ),
              ),
            ),
          ).animate().fade(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 20.0),

          // ── 게시판 발행 안내 ──
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: OceanTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: OceanTheme.borderMint.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⛵', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      '이 목표 섬을 항해 게시판에\n발행할까요?',
                      style: TextStyle(
                        color: OceanTheme.textDark,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '게시판에 공유하면 다른 항해사들이 당신의 길을\n배울 수 있고, 당신의 섬도 더 빛나게 됩니다.',
                  style: TextStyle(
                    color: OceanTheme.textSub,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // 공개/비공개 토글
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isPublic
                          ? '기본: 공개 (다른 사람과 공유 🌊)'
                          : '비공개로 보관 🔒',
                      style: TextStyle(
                        color: _isPublic ? OceanTheme.primary : OceanTheme.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isPublic,
                      activeTrackColor: OceanTheme.primary,
                      onChanged: (val) {
                        setState(() => _isPublic = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 6.0),

          // ── 비공개 보관 버튼 ──
          TextButton(
            onPressed: () {
              setState(() => _isPublic = false);
            },
            child: Text(
              '🔒 비공개로 보관',
              style: TextStyle(
                color: OceanTheme.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                decoration: !_isPublic ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),

          const SizedBox(height: 8.0),

          // ── 하단 버튼 영역 ──
          Row(
            children: [
              // '다음에게 맡겨두기' 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OceanTheme.textSub,
                    side: BorderSide(
                      color: OceanTheme.borderMint.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                  ),
                  child: const Text(
                    '다음에게 맡겨두기',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // '게시하기' 버튼
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          title.isEmpty
                              ? '🐢 목표를 적어주면 부기가 도와줄게!'
                              : '🐢 "$title" — AI 부기가 징검다리를 놓는 중...',
                        ),
                        backgroundColor: OceanTheme.coral,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OceanTheme.coral,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    '게시하기 ⛵',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fade(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
