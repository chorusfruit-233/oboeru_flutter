class TestRecord {
  final String word;
  final bool correct;
  final DateTime timestamp;

  const TestRecord({
    required this.word,
    required this.correct,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'correct': correct,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TestRecord.fromJson(Map<String, dynamic> json) => TestRecord(
    word: json['word'] as String,
    correct: json['correct'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class UserProgress {
  final DateTime date;
  final int wordsLearned;
  final int totalWords;
  final List<TestRecord> records;

  const UserProgress({
    required this.date,
    this.wordsLearned = 0,
    this.totalWords = 0,
    this.records = const [],
  });

  UserProgress copyWith({
    DateTime? date,
    int? wordsLearned,
    int? totalWords,
    List<TestRecord>? records,
  }) {
    return UserProgress(
      date: date ?? this.date,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      totalWords: totalWords ?? this.totalWords,
      records: records ?? this.records,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'wordsLearned': wordsLearned,
    'totalWords': totalWords,
    'records': records.map((r) => r.toJson()).toList(),
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    date: DateTime.parse(json['date'] as String),
    wordsLearned: (json['wordsLearned'] as num?)?.toInt() ?? 0,
    totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
    records: ((json['records'] as List<dynamic>?) ?? [])
        .map((r) => TestRecord.fromJson(r as Map<String, dynamic>))
        .toList(),
  );
}
