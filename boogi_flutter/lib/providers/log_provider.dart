import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 항해 일지 화면의 두 가지 뷰 모드
enum LogViewMode { seaGrass, journeyMap }

/// 현재 선택된 뷰 모드를 관리하는 간결한 StateProvider
final logViewModeProvider = StateProvider<LogViewMode>(
  (ref) => LogViewMode.seaGrass,
);
