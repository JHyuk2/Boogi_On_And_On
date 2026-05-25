import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── 목표 아이템 데이터 모델 ──────────────────────────────────

class GoalItem {
  final String id;
  final String title;
  final String sectionKey; // 'morning' | 'anytime'
  final int energyReward;
  final bool isCompleted;

  const GoalItem({
    required this.id,
    required this.title,
    required this.sectionKey,
    this.energyReward = 10,
    this.isCompleted = false,
  });

  GoalItem copyWith({bool? isCompleted}) {
    return GoalItem(
      id: id,
      title: title,
      sectionKey: sectionKey,
      energyReward: energyReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ─── 홈 화면 통합 상태 ────────────────────────────────────────

class HomeState {
  final String? selectedMood;
  final bool isMoodSelected;
  final List<GoalItem> goals;

  const HomeState({
    this.selectedMood,
    this.isMoodSelected = false,
    this.goals = const [],
  });

  /// 완료된 목표 수
  int get completedCount => goals.where((g) => g.isCompleted).length;

  /// 현재 에너지 총합 (완료된 목표의 보상 합산)
  int get totalEnergy => goals
      .where((g) => g.isCompleted)
      .fold(0, (sum, g) => sum + g.energyReward);

  /// 최대 가능 에너지
  int get maxEnergy => goals.fold(0, (sum, g) => sum + g.energyReward);

  /// 에너지 진행률 (0.0 ~ 1.0)
  double get energyProgress => maxEnergy > 0 ? totalEnergy / maxEnergy : 0.0;

  /// 미완료 목표 (Active) 필터
  List<GoalItem> get activeGoals => goals.where((g) => !g.isCompleted).toList();

  /// 완료 목표 (Completed) 필터
  List<GoalItem> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();

  /// 섹션별 미완료 목표 필터
  List<GoalItem> activeBySection(String key) =>
      goals.where((g) => g.sectionKey == key && !g.isCompleted).toList();

  /// 섹션별 전체 목표 필터
  List<GoalItem> goalsBySection(String key) =>
      goals.where((g) => g.sectionKey == key).toList();

  HomeState copyWith({
    String? selectedMood,
    bool? isMoodSelected,
    List<GoalItem>? goals,
  }) {
    return HomeState(
      selectedMood: selectedMood ?? this.selectedMood,
      isMoodSelected: isMoodSelected ?? this.isMoodSelected,
      goals: goals ?? this.goals,
    );
  }
}

// ─── 초기 목표 목록 (Mock Data) ───────────────────────────────

const _defaultGoals = <GoalItem>[
  GoalItem(
    id: 'g1',
    title: '나는 멋진 사람이다 응원하기',
    sectionKey: 'morning',
    energyReward: 10,
  ),
  GoalItem(
    id: 'g2',
    title: '하늘 바라보기',
    sectionKey: 'morning',
    energyReward: 10,
  ),
  GoalItem(
    id: 'g3',
    title: '나를 기쁘게 하는 일 하기',
    sectionKey: 'anytime',
    energyReward: 15,
  ),
  GoalItem(
    id: 'g4',
    title: '깊게 숨 들이마시기',
    sectionKey: 'anytime',
    energyReward: 15,
  ),
];

// ─── 홈 상태 관리 Notifier ────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState(goals: _defaultGoals));

  /// 일간 기분(Mood) 선택 → 오버레이 해제
  void selectMood(String mood) {
    state = state.copyWith(selectedMood: mood, isMoodSelected: true);
  }

  /// 개별 목표 체크/해제 토글 → 에너지 자동 재계산
  void toggleGoal(String goalId) {
    final updatedGoals = state.goals.map((g) {
      if (g.id == goalId) return g.copyWith(isCompleted: !g.isCompleted);
      return g;
    }).toList();
    state = state.copyWith(goals: updatedGoals);
  }

  /// 전체 상태 초기화 (온보딩 리셋 등)
  void reset() {
    state = const HomeState(goals: _defaultGoals);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
