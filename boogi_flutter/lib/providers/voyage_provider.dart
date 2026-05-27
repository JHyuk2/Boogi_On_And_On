import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voyage_template_model.dart';

// ─────────────────────────────────────────────────────────────
// 항해 게시판 상태 관리 (탭 모드 + 더미 데이터)
// ─────────────────────────────────────────────────────────────

/// 항해 게시판의 카테고리 탭
enum VoyageTab { popular, latest, hallOfFame }

/// 현재 선택된 게시판 탭
final voyageTabProvider = StateProvider<VoyageTab>(
  (ref) => VoyageTab.popular,
);

/// 카테고리별 항해 템플릿 리스트 제공 (태그 및 유연한 맵핑 매칭)
final voyageByCategoryProvider = Provider.family<List<VoyageTemplate>, String>(
  (ref, category) {
    final allTemplates = [
      ..._popularTemplates,
      ..._latestTemplates,
      ..._hallOfFameTemplates,
    ];
    
    // ID 기준으로 중복 제거
    final uniqueTemplates = <String, VoyageTemplate>{};
    for (var t in allTemplates) {
      uniqueTemplates[t.id] = t;
    }
    
    // 카테고리별 태그 그룹핑
    final Map<String, List<String>> categoryMapping = {
      '멘탈케어': ['멘탈케어', '자기관리', '회복'],
      '개발': ['개발', '사이드프로젝트'],
      '취미': ['취미', '그림', '요리', '디자인'],
      '건강': ['건강', '운동', '습관'],
      '업무': ['업무', '회계', '비즈니스'],
      '시험준비': ['시험준비', '영어', '취업'],
      '부동산': ['부동산', '신혼'],
      '창업': ['창업', '비즈니스'],
    };

    final allowedTags = categoryMapping[category] ?? [category];

    return uniqueTemplates.values.where((template) {
      return template.tags.any((tag) => 
        allowedTags.contains(tag) || 
        tag.contains(category) || 
        category.contains(tag)
      );
    }).toList();
  },
);

/// 탭별 항해 템플릿 리스트 제공 (더미 데이터)
final voyageTemplatesProvider = Provider.family<List<VoyageTemplate>, VoyageTab>(
  (ref, tab) {
    switch (tab) {
      case VoyageTab.popular:
        return _popularTemplates;
      case VoyageTab.latest:
        return _latestTemplates;
      case VoyageTab.hallOfFame:
        return _hallOfFameTemplates;
    }
  },
);

// ─── 더미 데이터: 🔥 인기 항로 ────────────────────────────────

final _popularTemplates = <VoyageTemplate>[
  VoyageTemplate(
    id: 'pop1',
    title: '나만의 앱 만들어보기\n(기획부터 배포까지)',
    authorName: '개발부기',
    emoji: '💻',
    likeCount: 1200,
    saveCount: 850,
    viewCount: 5400,
    createdAt: DateTime(2026, 5, 20),
    tags: ['개발', '사이드프로젝트'],
    description: '처음이라 막막한 앱 개발, 한 걸음씩 쪼개봤어요.',
  ),
  VoyageTemplate(
    id: 'pop2',
    title: '번아웃 극복하고\n나를 사랑하는 30일',
    authorName: '힐링구마',
    emoji: '🧘',
    likeCount: 980,
    saveCount: 720,
    viewCount: 4100,
    createdAt: DateTime(2026, 5, 18),
    tags: ['멘탈케어', '자기관리'],
    description: '지친 마음을 달래는 30일 회복 루틴.',
  ),
  VoyageTemplate(
    id: 'pop3',
    title: '초보자를 위한\n토플 기초 닦기',
    authorName: '영어이사',
    emoji: '📚',
    likeCount: 750,
    saveCount: 510,
    viewCount: 3500,
    createdAt: DateTime(2026, 5, 15),
    tags: ['영어', '시험준비'],
    description: '영어 왕초보도 따라할 수 있는 토플 준비 로드맵.',
  ),
  VoyageTemplate(
    id: 'pop4',
    title: '막막한 신혼집 구하기\n첫걸음',
    authorName: '집순이거북',
    emoji: '🏠',
    likeCount: 620,
    saveCount: 440,
    viewCount: 2800,
    createdAt: DateTime(2026, 5, 14),
    tags: ['부동산', '신혼'],
    description: '예산부터 부동산 방문까지 쉽게 쪼개봤어요.',
  ),
];

// ─── 더미 데이터: ✨ 최신 항로 ────────────────────────────────

final _latestTemplates = <VoyageTemplate>[
  VoyageTemplate(
    id: 'new1',
    title: '야근 없는 결산\n스케줄 쪼개기',
    authorName: '칼퇴거북',
    emoji: '📊',
    likeCount: 180,
    saveCount: 95,
    viewCount: 620,
    createdAt: DateTime(2026, 5, 27),
    tags: ['업무', '회계'],
    description: '법인세 신고 시즌, 패닉 없이 끝내는 비법.',
  ),
  VoyageTemplate(
    id: 'new2',
    title: '매일 10분\n드로잉 습관 만들기',
    authorName: '꼬마화가',
    emoji: '🎨',
    likeCount: 95,
    saveCount: 62,
    viewCount: 380,
    createdAt: DateTime(2026, 5, 26),
    tags: ['취미', '그림'],
    description: '못 그려도 OK! 매일 조금씩 그리는 즐거움.',
  ),
  VoyageTemplate(
    id: 'new3',
    title: '건강한 식단\n1주일 밀프렙 도전기',
    authorName: '요리거북',
    emoji: '🥗',
    likeCount: 130,
    saveCount: 78,
    viewCount: 450,
    createdAt: DateTime(2026, 5, 25),
    tags: ['건강', '요리'],
    description: '배달 대신 직접 만드는 건강한 한 주.',
  ),
  VoyageTemplate(
    id: 'new4',
    title: '운동 습관 0에서\n주 3회까지',
    authorName: '근육거북',
    emoji: '💪',
    likeCount: 210,
    saveCount: 140,
    viewCount: 720,
    createdAt: DateTime(2026, 5, 24),
    tags: ['운동', '습관'],
    description: '소파에서 일어나는 게 첫 번째 징검다리.',
  ),
];

// ─── 더미 데이터: 🏅 명예 항해사 ──────────────────────────────

final _hallOfFameTemplates = <VoyageTemplate>[
  VoyageTemplate(
    id: 'fame1',
    title: '1년 만에 완성한\n포트폴리오 대장정',
    authorName: '디자인캡틴',
    emoji: '🏆',
    likeCount: 3200,
    saveCount: 2100,
    viewCount: 15000,
    createdAt: DateTime(2026, 3, 1),
    tags: ['디자인', '취업'],
    description: '디자이너 취업을 위한 1년간의 여정 기록.',
  ),
  VoyageTemplate(
    id: 'fame2',
    title: '무에서 유를 창조한\n1인 창업 가이드',
    authorName: '스타트업해마',
    emoji: '🚀',
    likeCount: 2800,
    saveCount: 1900,
    viewCount: 12000,
    createdAt: DateTime(2026, 2, 15),
    tags: ['창업', '비즈니스'],
    description: '아이디어부터 첫 고객까지, 혼자서도 할 수 있어.',
  ),
  VoyageTemplate(
    id: 'fame3',
    title: '공황장애 극복하고\n나를 되찾은 이야기',
    authorName: '용감한돌고래',
    emoji: '🐬',
    likeCount: 4100,
    saveCount: 2800,
    viewCount: 18000,
    createdAt: DateTime(2026, 1, 10),
    tags: ['멘탈케어', '회복'],
    description: '어둠 속에서도 한 걸음씩 나아간 회복 일지.',
  ),
];
