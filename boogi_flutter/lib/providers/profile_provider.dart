import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_provider.dart';

/// 여행자 프로필 및 시스템 설정을 관리하는 상태 모델 클래스
class ProfileState {
  final String nickname;
  final int companionDays;
  final int accumulatedEnergy;
  final bool isNotificationsEnabled;
  final String notificationTime;
  final String lastBackupTime;

  const ProfileState({
    required this.nickname,
    required this.companionDays,
    required this.accumulatedEnergy,
    required this.isNotificationsEnabled,
    required this.notificationTime,
    required this.lastBackupTime,
  });

  ProfileState copyWith({
    String? nickname,
    int? companionDays,
    int? accumulatedEnergy,
    bool? isNotificationsEnabled,
    String? notificationTime,
    String? lastBackupTime,
  }) {
    return ProfileState(
      nickname: nickname ?? this.nickname,
      companionDays: companionDays ?? this.companionDays,
      accumulatedEnergy: accumulatedEnergy ?? this.accumulatedEnergy,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }
}

/// 프로필 비즈니스 로직 및 설정을 제어하는 StateNotifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileNotifier(this._ref)
      : super(
          const ProfileState(
            nickname: '부기',
            companionDays: 14,
            accumulatedEnergy: 340,
            isNotificationsEnabled: true,
            notificationTime: '오후 21:00',
            lastBackupTime: '방금 전',
          ),
        ) {
    // onboardingProvider의 변화를 리스닝하여 부기(거북이) 이름이 설정되면 자동으로 동기화
    _ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
      if (next.turtleName.isNotEmpty && next.turtleName != state.nickname) {
        state = state.copyWith(nickname: next.turtleName);
      }
    });

    // 초기 이름 동기화 진행
    final initialName = _ref.read(onboardingProvider).turtleName;
    if (initialName.isNotEmpty) {
      state = state.copyWith(nickname: initialName);
    }
  }

  /// 닉네임 변경 기능 (추후 프로필 수정 다이얼로그용)
  void updateNickname(String newNickname) {
    state = state.copyWith(nickname: newNickname);
  }

  /// 알림 온오프 토글
  void toggleNotifications() {
    state = state.copyWith(isNotificationsEnabled: !state.isNotificationsEnabled);
  }

  /// 푸시 알림 희망 시간 수정
  void updateNotificationTime(String time) {
    state = state.copyWith(notificationTime: time);
  }

  /// 수동 백업 트리거 시뮬레이션
  Future<void> triggerBackup() async {
    // 백업 진행 중 상태를 시각적으로 보여주기 위해 잠시 대기
    state = state.copyWith(lastBackupTime: '백업 중...');
    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(lastBackupTime: '방금 전');
  }
}

/// UI에서 소비될 전역 프로필 프로바이더 (ref 주입)
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});
