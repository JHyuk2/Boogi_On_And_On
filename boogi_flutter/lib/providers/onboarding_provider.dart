import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class OnboardingState {
  final String userStatus;
  final String pledgeText;
  final bool isUploading;
  final bool uploadSuccess;
  final String? errorMessage;
  final String selectedPersona;
  final String turtleName;

  OnboardingState({
    this.userStatus = '',
    this.pledgeText = '',
    this.isUploading = false,
    this.uploadSuccess = false,
    this.errorMessage,
    this.selectedPersona = '',
    this.turtleName = '',
  });

  OnboardingState copyWith({
    String? userStatus,
    String? pledgeText,
    bool? isUploading,
    bool? uploadSuccess,
    String? errorMessage,
    String? selectedPersona,
    String? turtleName,
  }) {
    return OnboardingState(
      userStatus: userStatus ?? this.userStatus,
      pledgeText: pledgeText ?? this.pledgeText,
      isUploading: isUploading ?? this.isUploading,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      errorMessage: errorMessage,
      selectedPersona: selectedPersona ?? this.selectedPersona,
      turtleName: turtleName ?? this.turtleName,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void setUserStatus(String status) {
    state = state.copyWith(userStatus: status);
  }

  void setSelectedPersona(String persona) {
    state = state.copyWith(selectedPersona: persona);
    // userStatus와 연동하여 기존 HomeScreen 등의 레이아웃에서 표시될 수 있도록 일관성 보장
    state = state.copyWith(userStatus: persona);
  }

  void setTurtleName(String name) {
    state = state.copyWith(turtleName: name);
  }

  void setPledgeText(String text) {
    state = state.copyWith(pledgeText: text);
  }

  Future<void> startVoyage() async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      // Firebase 미설정 시: 우아한 오프라인 시뮬레이션 데모 모드 작동
      debugPrint("Running startVoyage in Offline Demo Mode.");
      await Future.delayed(const Duration(seconds: 2)); // 통신 시간 시뮬레이션

      state = state.copyWith(isUploading: false, uploadSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
