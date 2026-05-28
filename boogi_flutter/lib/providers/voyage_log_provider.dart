import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_log_model.dart';
import 'daily_log_provider.dart';

/// 🌊 여행의 항해 일지 기록을 전역에서 손쉽게 저장 및 동기화할 수 있도록 돕는 프로바이더
class VoyageLogNotifier extends StateNotifier<AsyncValue<List<DailyLog>>> {
  final Ref _ref;

  VoyageLogNotifier(this._ref) : super(const AsyncValue.loading()) {
    // ── dailyLogProvider의 상태 변화를 상시 관찰하여 동기화 ──
    _ref.listen<AsyncValue<List<DailyLog>>>(dailyLogProvider, (previous, next) {
      state = next;
    }, fireImmediately: true);
  }

  /// 📝 오늘 완료한 목표(태스크)를 전역 항해 일지에 실시간으로 추가하고 기록을 동기화합니다.
  Future<void> logCompletedTask(String taskTitle, String mood) async {
    final currentLogsAsync = _ref.read(dailyLogProvider);
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    currentLogsAsync.whenData((logs) async {
      // 1. 오늘 날짜에 기록된 기존 로그가 있는지 찾기
      DailyLog? todayLog;
      try {
        todayLog = logs.firstWhere((log) =>
            log.date.year == todayDate.year &&
            log.date.month == todayDate.month &&
            log.date.day == todayDate.day);
      } catch (_) {
        // 오늘 날짜 로그가 없는 경우 null
      }

      DailyLog updatedLog;
      if (todayLog != null) {
        // 이미 오늘 로그가 있다면 완료 태스크 추가 (중복 방지)
        final tasks = List<String>.from(todayLog.completedTasks);
        if (!tasks.contains(taskTitle)) {
          tasks.add(taskTitle);
        }
        
        // 활동량(수심 레벨) 갱신 (태스크가 많아질수록 0~3 레벨 상승)
        int newLevel = 1;
        if (tasks.length >= 3) {
          newLevel = 3;
        } else if (tasks.length >= 2) {
          newLevel = 2;
        }

        updatedLog = todayLog.copyWith(
          completedTasks: tasks,
          level: newLevel,
          mood: mood.isNotEmpty ? mood : todayLog.mood,
        );
      } else {
        // 오늘 첫 로그 생성
        updatedLog = DailyLog(
          date: todayDate,
          mood: mood.isNotEmpty ? mood : '☀️ 맑음',
          completedTasks: [taskTitle],
          grassType: '⭐',
          level: 1,
          boogiQuote: '첫걸음부터 천천히 헤엄쳐 온 오늘을 칭찬해.',
        );
      }

      // 2. 가짜 DB 리포지토리 저장 및 실시간 상태 동기화 호출
      await _ref.read(dailyLogProvider.notifier).addOrUpdateLog(updatedLog);
    });
  }

  /// 📝 오늘 완료 취소한 목표(태스크)를 항해 일지에서 제거합니다.
  Future<void> logUncompletedTask(String taskTitle) async {
    final currentLogsAsync = _ref.read(dailyLogProvider);
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    currentLogsAsync.whenData((logs) async {
      DailyLog? todayLog;
      try {
        todayLog = logs.firstWhere((log) =>
            log.date.year == todayDate.year &&
            log.date.month == todayDate.month &&
            log.date.day == todayDate.day);
      } catch (_) {}

      if (todayLog != null) {
        final tasks = List<String>.from(todayLog.completedTasks);
        tasks.remove(taskTitle);

        int newLevel = 0;
        if (tasks.length >= 3) {
          newLevel = 3;
        } else if (tasks.length >= 2) {
          newLevel = 2;
        } else if (tasks.isNotEmpty) {
          newLevel = 1;
        }

        final updatedLog = todayLog.copyWith(
          completedTasks: tasks,
          level: newLevel,
        );

        await _ref.read(dailyLogProvider.notifier).addOrUpdateLog(updatedLog);
      }
    });
  }
}

/// 🌟 UI 및 다른 영역에서 감시할 전역 항해 로그 프로바이더
final voyageLogProvider =
    StateNotifierProvider<VoyageLogNotifier, AsyncValue<List<DailyLog>>>((ref) {
  return VoyageLogNotifier(ref);
});
