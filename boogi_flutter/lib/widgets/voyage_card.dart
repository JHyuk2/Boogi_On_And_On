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
      width: 140, // ── 카드 가로 140으로 황금비율 약간 확대
      decoration: OceanTheme.cardDecoration(
        color: OceanTheme.cardWarm,
        radius: 14.0, // 모서리 비례 조절
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
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
            padding: const EdgeInsets.all(12.0), // ── 내부 여백 12로 넓혀 여유 증대
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 상단: 썸네일 (32x32로 살짝 키움) ──
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: OceanTheme.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      template.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── 중간: 제목 (14px, 굵게, 2줄 고정) ──
                Text(
                  template.title.replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF004D40),
                    fontSize: 14.0, // ── 제목 14px로 가독성 강화
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // ── 작성자 (10px, 회색) ──
                Text(
                  'By: ${template.authorName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8BA6A1),
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // ── [에러 원천 차단] Row 대신 Wrap 위젯 도입하여 가로 공간 부족 시 아래 줄로 자동 래핑 ──
                Wrap(
                  spacing: 6.0, // 칩 간 가로 마진
                  runSpacing: 4.0, // 자동 줄바꿈 시 세로 마진
                  alignment: WrapAlignment.start,
                  children: [
                    _buildStatChip('❤️', _formatCount(template.likeCount)),
                    _buildStatChip('📌', _formatCount(template.saveCount)),
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

  /// 작은 통계 칩 위젯 (이모지 + 숫자 11px)
  Widget _buildStatChip(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 9.5)),
        const SizedBox(width: 2.0),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF8BA6A1),
            fontSize: 11.0, // ── 11px로 가독성 향상
            fontWeight: FontWeight.bold,
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
