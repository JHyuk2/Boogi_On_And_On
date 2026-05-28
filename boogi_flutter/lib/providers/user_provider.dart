import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_provider.dart';

/// ⛵ 부기온앤온 여행자(유저) 정보 상태를 표현하는 모델 클래스
class UserState {
  /// 유저의 닉네임 (기본값: '코딩부기')
  final String nickname;
  /// 동반 캐릭터(거북이) 이름 (기본값: '부기')
  final String turtleName;
  /// 여행자의 현재 페르소나/상태 (예: '포근한 여행자')
  final String userStatus;
  /// 여행자의 다짐 문구
  final String pledgeText;
  /// 동반 여행 일수
  final int companionDays;
  /// 누적 여행 에너지
  final int accumulatedEnergy;

  const UserState({
    required this.nickname,
    required this.turtleName,
    required this.userStatus,
    required this.pledgeText,
    required this.companionDays,
    required this.accumulatedEnergy,
  });

  /// 상태 업데이트를 위한 copyWith 헬퍼 메서드
  UserState copyWith({
    String? nickname,
    String? turtleName,
    String? userStatus,
    String? pledgeText,
    int? companionDays,
    int? accumulatedEnergy,
  }) {
    return UserState(
      nickname: nickname ?? this.nickname,
      turtleName: turtleName ?? this.turtleName,
      userStatus: userStatus ?? this.userStatus,
      pledgeText: pledgeText ?? this.pledgeText,
      companionDays: companionDays ?? this.companionDays,
      accumulatedEnergy: accumulatedEnergy ?? this.accumulatedEnergy,
    );
  }
}

/// 🧠 여행자(유저) 전역 상태 관리를 위한 StateNotifier
class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;

  UserNotifier(this._ref)
      : super(
          const UserState(
            nickname: '코딩부기',
            turtleName: '부기',
            userStatus: '포근한 여행자',
            pledgeText: '완벽하지 않아도 괜찮아. 느려도 꾸준히 헤엄치자.',
            companionDays: 14,
            accumulatedEnergy: 340,
          ),
        ) {
    // ── onboardingProvider의 변경점을 상시 관찰하여 유저 데이터 자동 동기화 ──
    _ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
      if (next.turtleName.isNotEmpty || next.userStatus.isNotEmpty) {
        state = state.copyWith(
          nickname: next.turtleName.isNotEmpty ? '${next.turtleName}부기' : state.nickname,
          turtleName: next.turtleName.isNotEmpty ? next.turtleName : state.turtleName,
          userStatus: next.userStatus.isNotEmpty ? next.userStatus : state.userStatus,
          pledgeText: next.pledgeText.isNotEmpty ? next.pledgeText : state.pledgeText,
        );
      }
    });

    // 초기 실행 시 온보딩에 기입된 데이터 동기화
    final obState = _ref.read(onboardingProvider);
    if (obState.turtleName.isNotEmpty) {
      state = state.copyWith(
        nickname: '${obState.turtleName}부기',
        turtleName: obState.turtleName,
        userStatus: obState.userStatus.isNotEmpty ? obState.userStatus : '포근한 여행자',
        pledgeText: obState.pledgeText.isNotEmpty ? obState.pledgeText : state.pledgeText,
      );
    }
  }

  /// 닉네임 수동 변경 기능 (프로필 편집 등에서 활용)
  void updateNickname(String newNickname) {
    state = state.copyWith(nickname: newNickname);
  }

  /// 거북이 이름 수동 변경 기능
  void updateTurtleName(String newTurtleName) {
    state = state.copyWith(
      turtleName: newTurtleName,
      nickname: '$newTurtleName부기',
    );
  }

  /// 여행 에너지 추가 적립 기능
  void addEnergy(int amount) {
    state = state.copyWith(
      accumulatedEnergy: state.accumulatedEnergy + amount,
    );
  }
}

/// 🌟 UI 및 다른 프로바이더에서 구독할 유저 상태 전역 프로바이더
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});
