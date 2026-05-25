import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final String? selectedEmotion;
  final bool hasBreathed;

  HomeState({
    this.selectedEmotion,
    this.hasBreathed = false,
  });

  HomeState copyWith({
    String? selectedEmotion,
    bool? hasBreathed,
  }) {
    return HomeState(
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      hasBreathed: hasBreathed ?? this.hasBreathed,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  void selectEmotion(String emotion) {
    // 만약 이미 선택된 감정을 다시 누르면 선택 해제할 수 있도록 지원
    if (state.selectedEmotion == emotion) {
      state = state.copyWith(selectedEmotion: null);
    } else {
      state = state.copyWith(selectedEmotion: emotion);
    }
  }

  void toggleBreathed() {
    state = state.copyWith(hasBreathed: !state.hasBreathed);
  }

  void reset() {
    state = HomeState();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
