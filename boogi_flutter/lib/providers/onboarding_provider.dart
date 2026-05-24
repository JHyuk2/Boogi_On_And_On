import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class OnboardingState {
  final String userStatus;
  final String pledgeText;
  final bool isUploading;
  final bool uploadSuccess;
  final String? errorMessage;

  OnboardingState({
    this.userStatus = '',
    this.pledgeText = '',
    this.isUploading = false,
    this.uploadSuccess = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? userStatus,
    String? pledgeText,
    bool? isUploading,
    bool? uploadSuccess,
    String? errorMessage,
  }) {
    return OnboardingState(
      userStatus: userStatus ?? this.userStatus,
      pledgeText: pledgeText ?? this.pledgeText,
      isUploading: isUploading ?? this.isUploading,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void setUserStatus(String status) {
    state = state.copyWith(userStatus: status);
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
