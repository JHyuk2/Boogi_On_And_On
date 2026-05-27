import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/voyage_template_model.dart';
import '../theme/ocean_theme.dart';

// ─────────────────────────────────────────────────────────────
// 항해 게시판 카드 위젯
// 따뜻한 크림색 배경에 둥글둥글한 모서리, 이모지 포인트 디자인
// ─────────────────────────────────────────────────────────────

class VoyageCard extends StatelessWidget {
  final VoyageTemplate template;
  final int index;

  const VoyageCard({
    super.key,
    required this.template,
    this.index = 0,
  });

  /// 큰 숫자를 읽기 쉬운 단축 형태로 변환 (예: 1200 → 1.2k)
  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: OceanTheme.cardDecoration(
        color: OceanTheme.cardWarm,
        radius: 18.0,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.0),
          onTap: () {
            // 추후 상세 화면 이동 연결
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📋 "${template.title.replaceAll('\n', ' ')}" 상세 보기 준비 중'),
                backgroundColor: OceanTheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── 상단: 이모지 아이콘 배경 ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: OceanTheme.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Center(
                    child: Text(
                      template.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── 중간: 제목 (2줄 고정, 말줄임) ──
                Text(
                  template.title,
                  style: OceanTheme.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // ── 작성자 ──
                Text(
                  'By: ${template.authorName}',
                  style: OceanTheme.cardSubtitle.copyWith(
                    color: OceanTheme.textMuted,
                  ),
                ),

                const Spacer(),

                // ── 하단: 좋아요 / 저장 / 조회 통계 ──
                Row(
                  children: [
                    _buildStatChip('❤️', _formatCount(template.likeCount)),
                    const SizedBox(width: 10),
                    _buildStatChip('📌', _formatCount(template.saveCount)),
                    const SizedBox(width: 10),
                    _buildStatChip('👁️', _formatCount(template.viewCount)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(
          delay: (100 * index).ms,
          duration: 500.ms,
        )
        .slideX(
          delay: (100 * index).ms,
          begin: 0.15,
          end: 0.0,
          curve: Curves.easeOutCubic,
        );
  }

  /// 작은 통계 칩 위젯 (이모지 + 숫자)
  Widget _buildStatChip(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            color: OceanTheme.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 세로 리스트용 넓은 카드 (2열 그리드 아이템)
// ─────────────────────────────────────────────────────────────

class VoyageCardCompact extends StatelessWidget {
  final VoyageTemplate template;
  final int index;

  const VoyageCardCompact({
    super.key,
    required this.template,
    this.index = 0,
  });

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OceanTheme.cardDecoration(
        color: OceanTheme.cardWarm,
        radius: 16.0,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📋 "${template.title.replaceAll('\n', ' ')}" 상세 보기 준비 중'),
                backgroundColor: OceanTheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 이모지 + 제목 Row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: OceanTheme.coral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11.0),
                      ),
                      child: Center(
                        child: Text(
                          template.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        template.title.replaceAll('\n', ' '),
                        style: OceanTheme.cardTitle.copyWith(fontSize: 13.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── 작성자 ──
                Padding(
                  padding: const EdgeInsets.only(left: 46.0),
                  child: Text(
                    'By: ${template.authorName}',
                    style: OceanTheme.cardSubtitle.copyWith(
                      color: OceanTheme.textMuted,
                      fontSize: 11.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ── 통계 ──
                Padding(
                  padding: const EdgeInsets.only(left: 46.0),
                  child: Row(
                    children: [
                      _buildStatChip('❤️', _formatCount(template.likeCount)),
                      const SizedBox(width: 8),
                      _buildStatChip('📌', _formatCount(template.saveCount)),
                      const SizedBox(width: 8),
                      _buildStatChip('👁️', _formatCount(template.viewCount)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(
          delay: (80 * index).ms,
          duration: 500.ms,
        )
        .slideY(
          delay: (80 * index).ms,
          begin: 0.08,
          end: 0.0,
          curve: Curves.easeOut,
        );
  }

  Widget _buildStatChip(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            color: OceanTheme.textMuted,
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
