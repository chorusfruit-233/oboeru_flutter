import '../models/srs_card.dart';

enum Quality { again, hard, good, easy }

int _qualityValue(Quality q) {
  switch (q) {
    case Quality.again:
      return 0;
    case Quality.hard:
      return 3;
    case Quality.good:
      return 4;
    case Quality.easy:
      return 5;
  }
}

class SrsAlgorithm {
  static const double _minEf = 1.3;
  static const double _maxEf = 2.5;
  static const double _defaultEf = 2.5;

  static SrsCard newCard(String word, {DateTime? now}) {
    final t = now ?? DateTime.now();
    return SrsCard(
      word: word,
      repetition: 0,
      interval: 0,
      easinessFactor: _defaultEf,
      dueDate: t,
      lastReviewed: null,
      state: SrsState.newCard,
      lapses: 0,
    );
  }

  static SrsCard apply(SrsCard card, Quality quality, {DateTime? now}) {
    final q = _qualityValue(quality);
    final reviewTime = now ?? DateTime.now();

    int newRepetition;
    int newInterval;
    SrsState newState;
    int newLapses = card.lapses;

    if (q < 3) {
      newRepetition = 0;
      newInterval = 1;
      newState = SrsState.relearning;
      newLapses = card.lapses + 1;
    } else {
      if (card.repetition == 0) {
        newInterval = 1;
      } else if (card.repetition == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easinessFactor).round();
        if (newInterval < 1) newInterval = 1;
      }
      newRepetition = card.repetition + 1;
      newState = SrsState.review;
    }

    double newEf = card.easinessFactor +
        (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (newEf < _minEf) newEf = _minEf;
    if (newEf > _maxEf) newEf = _maxEf;

    final dueDate = reviewTime.add(Duration(days: newInterval));

    return card.copyWith(
      repetition: newRepetition,
      interval: newInterval,
      easinessFactor: newEf,
      dueDate: dueDate,
      lastReviewed: reviewTime,
      state: newState,
      lapses: newLapses,
    );
  }

  static int previewInterval(SrsCard card, Quality quality, {DateTime? now}) {
    return apply(card, quality, now: now).interval;
  }
}
