import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_log_model.dart';

/// 추후 Supabase 연동을 쉽게 갈아끼울 수 있도록 선언한 추상 리포지토리 클래스
abstract class DailyLogRepository {
  Future<List<DailyLog>> getLogs();
  Future<void> saveLog(DailyLog log);
}

/// 메모리 상에서 동작하는 임시 Mock 리포지토리 구현체
class MockDailyLogRepository implements DailyLogRepository {
  // 현재 날짜(2026년 5월) 주변의 실감 나는 항해 일지 데이터 설정
  final List<DailyLog> _mockLogs = [
    DailyLog(
      date: DateTime(2026, 5, 1),
      mood: '☀️ 맑음',
      completedTasks: ['나는 멋진 사람이다 응원하기', '하늘 바라보기', '깊게 숨 들이마시기'],
      grassType: '🪸',
      level: 3,
      boogiQuote: '남들과 비교하지 않는 나만의 항해.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 2),
      mood: '🌧️ 비 옴',
      completedTasks: [],
      grassType: '~',
      level: 0,
      boogiQuote: '오늘은 파도에 몸을 맡기고 편안하게 쉬어갔습니다.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 3),
      mood: '☁️ 잔잔',
      completedTasks: ['깊게 숨 들이마시기'],
      grassType: '~',
      level: 1,
      boogiQuote: '무리하지 않고 잔잔하게 헤엄친 하루.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 4),
      mood: '☁️ 잔잔',
      completedTasks: ['하늘 바라보기', '나는 멋진 사람이다 응원하기'],
      grassType: '⭐',
      level: 2,
      boogiQuote: '내 속도대로 무사히 마무리한 하루.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 7),
      mood: '☀️ 맑음',
      completedTasks: ['하늘 바라보기', '나를 기쁘게 하는 일 하기'],
      grassType: '⭐',
      level: 2,
      boogiQuote: '나만의 기쁨을 소중히 다루어 준 날.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 10),
      mood: '🌧️ 비 옴',
      completedTasks: [],
      grassType: '~',
      level: 0,
      boogiQuote: '비가 올 때는 젖어드는 마음도 억지로 말리지 말자.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 12),
      mood: '☁️ 잔잔',
      completedTasks: ['깊게 숨 들이마시기'],
      grassType: '~',
      level: 1,
      boogiQuote: '숨을 들이마시고 내쉬는 것만으로 충분한 하루.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 15),
      mood: '☀️ 맑음',
      completedTasks: ['나는 멋진 사람이다 응원하기', '하늘 바라보기', '나를 기쁘게 하는 일 하기'],
      grassType: '🪸',
      level: 3,
      boogiQuote: '아무것도 하지 않아도 나는 원래 눈부신 존재야.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 20),
      mood: '☁️ 잔잔',
      completedTasks: ['하늘 바라보기', '깊게 숨 들이마시기'],
      grassType: '⭐',
      level: 2,
      boogiQuote: '잔잔한 물결 위를 유유히 흘러가는 여유.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 24),
      mood: '🌧️ 비 옴',
      completedTasks: [],
      grassType: '~',
      level: 0,
      boogiQuote: '지친 날에는 가쁜 숨을 가라앉히고 완전히 이완하기.',
    ),
    DailyLog(
      date: DateTime(2026, 5, 25), // 시스템 기준 오늘 날짜에 가짜 데이터 바인딩
      mood: '☀️ 맑음',
      completedTasks: ['나는 멋진 사람이다 응원하기', '깊게 숨 들이마시기'],
      grassType: '⭐',
      level: 2,
      boogiQuote: '오늘도 나의 걸음으로 꾸준히 헤엄친 나를 칭찬해.',
    ),
  ];

  @override
  Future<List<DailyLog>> getLogs() async {
    // 300ms 딜레이를 통해 백엔드 네트워크 호출 느낌 재현
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockLogs);
  }

  @override
  Future<void> saveLog(DailyLog log) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockLogs.removeWhere((item) =>
        item.date.year == log.date.year &&
        item.date.month == log.date.month &&
        item.date.day == log.date.day);
    _mockLogs.add(log);
  }
}

/// 리포지토리 인터페이스 노출 프로바이더
final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return MockDailyLogRepository();
});

/// UI에서 데이터를 관찰하고 새로고침할 수 있는 StateNotifier
class DailyLogNotifier extends StateNotifier<AsyncValue<List<DailyLog>>> {
  final DailyLogRepository _repository;

  DailyLogNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLogs();
  }

  /// 백엔드/가짜 DB로부터 로그 리스트를 가져오는 함수
  Future<void> loadLogs() async {
    try {
      state = const AsyncValue.loading();
      final logs = await _repository.getLogs();
      state = AsyncValue.data(logs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 로그 기록 저장 및 실시간 상태 갱신 함수
  Future<void> addOrUpdateLog(DailyLog log) async {
    try {
      await _repository.saveLog(log);
      final logs = await _repository.getLogs();
      state = AsyncValue.data(logs);
    } catch (e) {
      // 로깅 및 에러 캡처 가능
    }
  }
}

/// UI에서 관찰할 주 프로바이더 (AsyncValue 래핑)
final dailyLogProvider =
    StateNotifierProvider<DailyLogNotifier, AsyncValue<List<DailyLog>>>((ref) {
  final repository = ref.watch(dailyLogRepositoryProvider);
  return DailyLogNotifier(repository);
});
