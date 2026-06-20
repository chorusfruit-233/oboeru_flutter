enum SrsState { newCard, review, relearning }

class SrsCard {
  final String word;
  final int repetition;
  final int interval;
  final double easinessFactor;
  final DateTime dueDate;
  final DateTime? lastReviewed;
  final SrsState state;
  final int lapses;

  const SrsCard({
    required this.word,
    required this.repetition,
    required this.interval,
    required this.easinessFactor,
    required this.dueDate,
    this.lastReviewed,
    this.state = SrsState.newCard,
    this.lapses = 0,
  });

  bool get isNew => state == SrsState.newCard;

  bool isDueAt(DateTime now) => !now.isBefore(dueDate);

  SrsCard copyWith({
    String? word,
    int? repetition,
    int? interval,
    double? easinessFactor,
    DateTime? dueDate,
    DateTime? lastReviewed,
    SrsState? state,
    int? lapses,
    bool clearLastReviewed = false,
  }) {
    return SrsCard(
      word: word ?? this.word,
      repetition: repetition ?? this.repetition,
      interval: interval ?? this.interval,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      dueDate: dueDate ?? this.dueDate,
      lastReviewed: clearLastReviewed ? null : (lastReviewed ?? this.lastReviewed),
      state: state ?? this.state,
      lapses: lapses ?? this.lapses,
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'repetition': repetition,
    'interval': interval,
    'easinessFactor': easinessFactor,
    'dueDate': dueDate.toIso8601String(),
    'lastReviewed': lastReviewed?.toIso8601String(),
    'state': state.name,
    'lapses': lapses,
  };

  factory SrsCard.fromJson(Map<String, dynamic> json) {
    SrsState parseState(String? s) {
      switch (s) {
        case 'review':
          return SrsState.review;
        case 'relearning':
          return SrsState.relearning;
        default:
          return SrsState.newCard;
      }
    }

    return SrsCard(
      word: json['word'] as String,
      repetition: (json['repetition'] as num?)?.toInt() ?? 0,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      dueDate: DateTime.parse(json['dueDate'] as String),
      lastReviewed: json['lastReviewed'] == null
          ? null
          : DateTime.parse(json['lastReviewed'] as String),
      state: parseState(json['state'] as String?),
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
    );
  }
}
