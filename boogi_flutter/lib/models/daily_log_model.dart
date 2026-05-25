class DailyLog {
  final DateTime date;
  final String mood;
  final List<String> completedTasks;
  final String grassType;
  final int level; // 0~3 (수심 깊이 = 활동량)
  final String boogiQuote;

  const DailyLog({
    required this.date,
    required this.mood,
    required this.completedTasks,
    required this.grassType,
    required this.level,
    required this.boogiQuote,
  });

  /// Supabase JSON 직렬화를 위한 factory 생성자
  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      completedTasks: List<String>.from(json['completed_tasks'] as List? ?? []),
      grassType: json['grass_type'] as String? ?? '~',
      level: json['level'] as int? ?? 0,
      boogiQuote: json['boogi_quote'] as String? ?? '오늘도 나만의 속도로.',
    );
  }

  /// Supabase 데이터베이스 저장을 위한 JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD 서식
      'mood': mood,
      'completed_tasks': completedTasks,
      'grass_type': grassType,
      'level': level,
      'boogi_quote': boogiQuote,
    };
  }

  DailyLog copyWith({
    DateTime? date,
    String? mood,
    List<String>? completedTasks,
    String? grassType,
    int? level,
    String? boogiQuote,
  }) {
    return DailyLog(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      completedTasks: completedTasks ?? this.completedTasks,
      grassType: grassType ?? this.grassType,
      level: level ?? this.level,
      boogiQuote: boogiQuote ?? this.boogiQuote,
    );
  }
}
