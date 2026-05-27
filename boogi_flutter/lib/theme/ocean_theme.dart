import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// 🌊 파스텔 오션 테마 — 색상·스타일·간격 토큰 중앙 관리
// 부기온앤온의 '다정함(Comfort)'과 '편안함'을 시각적으로 구현합니다.
// ─────────────────────────────────────────────────────────────

class OceanTheme {
  OceanTheme._(); // 인스턴스화 방지

  // ── 1. 브랜드 컬러 ──────────────────────────────────────────
  /// 프라이머리 민트 (차분한 바다의 대표색)
  static const Color primary = Color(0xFF4FA095);

  /// 세컨더리 밝은 민트
  static const Color secondary = Color(0xFF6DEBE1);

  /// 비비드 코랄 — 성취/포인트 컬러 (따뜻한 에너지)
  static const Color coral = Color(0xFFFF823A);

  /// 깊은 바다 텍스트 (제목용 다크 민트)
  static const Color textDark = Color(0xFF1E5257);

  /// 서브 텍스트 (설명/보조 문구)
  static const Color textSub = Color(0xFF5A7D82);

  /// 비활성 텍스트 (플레이스홀더 등)
  static const Color textMuted = Color(0xFF8BA6A1);

  /// 파스텔 민트 배경 보더 (카드 테두리 등)
  static const Color borderMint = Color(0xFFB2DFDB);

  // ── 2. 배경 컬러 ──────────────────────────────────────────
  /// 따뜻한 모래색 카드 배경 (목업 기반)
  static const Color cardWarm = Color(0xFFFFF8F0);

  /// 밝은 카드 배경 (화이트 반투명)
  static const Color cardWhite = Color(0xFFF7FDFD);

  /// 파스텔 하늘 (그라데이션 상단)
  static const Color skyTop = Color(0xFFE2F6F8);

  /// 바다 안개 (그라데이션 중간)
  static const Color skyMid = Color(0xFFEAF9F9);

  /// 모래사장 (그라데이션 하단)
  static const Color skyBottom = Color(0xFFF7FDFD);

  // ── 3. 배경 그라데이션 (홈 화면 전체 배경) ───────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyMid, skyBottom],
  );

  // ── 4. 카드 스타일 ─────────────────────────────────────────
  /// 기본 둥근 카드 데코레이션 (따뜻한 크림색 배경)
  static BoxDecoration cardDecoration({
    Color color = cardWarm,
    double radius = 20.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderMint.withValues(alpha: 0.3),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// 하이라이트 카드 데코레이션 (코랄 테두리)
  static BoxDecoration cardHighlightDecoration({double radius = 20.0}) {
    return BoxDecoration(
      color: cardWarm,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: coral.withValues(alpha: 0.25),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: coral.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ── 5. 텍스트 스타일 ───────────────────────────────────────
  /// 화면 대제목 (22pt, 굵은 다크)
  static const TextStyle headingLarge = TextStyle(
    color: textDark,
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// 섹션 제목 (16pt, 볼드)
  static const TextStyle headingMedium = TextStyle(
    color: textDark,
    fontSize: 16.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  /// 카드 제목 (14.5pt, 볼드)
  static const TextStyle cardTitle = TextStyle(
    color: textDark,
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  /// 카드 부제목 / 작성자 (12pt, 미디엄)
  static const TextStyle cardSubtitle = TextStyle(
    color: textSub,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
  );

  /// 칩/뱃지 텍스트 (11.5pt, 볼드)
  static const TextStyle chipText = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.bold,
  );

  /// 바디 텍스트 (13.5pt)
  static const TextStyle bodyText = TextStyle(
    color: textSub,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ── 6. 간격 상수 ──────────────────────────────────────────
  /// 화면 수평 패딩
  static const double horizontalPadding = 20.0;

  /// 섹션 간 여백
  static const double sectionGap = 24.0;

  /// 카드 모서리 곡률
  static const double cardRadius = 20.0;

  /// 칩/뱃지 모서리 곡률
  static const double chipRadius = 14.0;
}
