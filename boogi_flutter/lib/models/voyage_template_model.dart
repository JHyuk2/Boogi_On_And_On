// ─────────────────────────────────────────────────────────────
// 항해 게시판 카드 데이터 모델
// 다른 여행자가 만든 '항로 템플릿'을 표현합니다.
// ─────────────────────────────────────────────────────────────

class VoyageTemplate {
  final String id;

  /// 항로 제목 (예: "막막한 신혼집 구하기 첫걸음")
  final String title;

  /// 작성자 이름 (예: "개발부기")
  final String authorName;

  /// 카드 대표 이모지 아이콘
  final String emoji;

  /// 좋아요 수
  final int likeCount;

  /// 저장(내 바다로 가져오기) 수
  final int saveCount;

  /// 조회 수
  final int viewCount;

  /// 생성 일시
  final DateTime createdAt;

  /// 태그 리스트 (예: ["부동산", "신혼"])
  final List<String> tags;

  /// 간략한 설명 (카드 서브타이틀)
  final String description;

  const VoyageTemplate({
    required this.id,
    required this.title,
    required this.authorName,
    required this.emoji,
    this.likeCount = 0,
    this.saveCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    this.tags = const [],
    this.description = '',
  });
}
