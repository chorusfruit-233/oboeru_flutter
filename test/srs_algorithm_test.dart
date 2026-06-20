import 'package:flutter_test/flutter_test.dart';
import 'package:oboeru_flutter/models/srs_card.dart';
import 'package:oboeru_flutter/services/srs_algorithm.dart';

void main() {
  final fixedNow = DateTime(2026, 1, 1, 9, 0);

  SrsCard newCard() => SrsAlgorithm.newCard('apple', now: fixedNow);

  group('newCard', () {
    test('starts with SM-2 defaults', () {
      final c = newCard();
      expect(c.repetition, 0);
      expect(c.interval, 0);
      expect(c.easinessFactor, 2.5);
      expect(c.state, SrsState.newCard);
      expect(c.lapses, 0);
      expect(c.lastReviewed, isNull);
      expect(c.isNew, isTrue);
    });
  });

  group('interval progression (good)', () {
    test('rep0 -> 1d, rep1 -> 6d, rep2 -> round(prev * EF)', () {
      final t0 = fixedNow;
      var c = newCard();

      c = SrsAlgorithm.apply(c, Quality.good, now: t0);
      expect(c.repetition, 1);
      expect(c.interval, 1);
      expect(c.state, SrsState.review);
      expect(c.dueDate, t0.add(const Duration(days: 1)));

      final t1 = t0.add(const Duration(days: 1));
      c = SrsAlgorithm.apply(c, Quality.good, now: t1);
      expect(c.repetition, 2);
      expect(c.interval, 6);
      expect(c.dueDate, t1.add(const Duration(days: 6)));

      final t2 = t1.add(const Duration(days: 6));
      c = SrsAlgorithm.apply(c, Quality.good, now: t2);
      expect(c.repetition, 3);
      // interval = round(6 * 2.5) = 15
      expect(c.interval, 15);
      expect(c.dueDate, t2.add(const Duration(days: 15)));
    });
  });

  group('easiness factor', () {
    test('good (q=4) keeps EF at 2.5', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      expect(c.easinessFactor, 2.5);
    });

    test('easy (q=5) would raise EF but it is capped at 2.5', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.easy, now: fixedNow);
      expect(c.easinessFactor, 2.5);
    });

    test('again (q=0) lowers EF', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      c = SrsAlgorithm.apply(c, Quality.again, now: fixedNow);
      // EF: 2.5 + (0.1 - 5*(0.08 + 5*0.02)) = 2.5 + (0.1 - 5*0.18) = 2.5 - 0.8 = 1.7
      expect(c.easinessFactor, closeTo(1.7, 0.0001));
    });

    test('EF is clamped at minimum 1.3', () {
      var c = newCard();
      for (int i = 0; i < 10; i++) {
        c = SrsAlgorithm.apply(c, Quality.again, now: fixedNow);
      }
      expect(c.easinessFactor, greaterThanOrEqualTo(1.3));
    });

    test('hard (q=3) lowers EF slightly', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      c = SrsAlgorithm.apply(c, Quality.hard, now: fixedNow);
      // EF: 2.5 + (0.1 - 2*(0.08 + 2*0.02)) = 2.5 + (0.1 - 2*0.12) = 2.5 - 0.14 = 2.36
      expect(c.easinessFactor, closeTo(2.36, 0.0001));
    });
  });

  group('lapse handling (again)', () {
    test('resets repetition to 0, interval to 1, increments lapses', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      expect(c.repetition, 2);

      c = SrsAlgorithm.apply(c, Quality.again, now: fixedNow);
      expect(c.repetition, 0);
      expect(c.interval, 1);
      expect(c.state, SrsState.relearning);
      expect(c.lapses, 1);
    });

    test('a correct answer after lapse restarts the 1/6 ladder', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      c = SrsAlgorithm.apply(c, Quality.again, now: fixedNow);
      expect(c.repetition, 0);

      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      expect(c.repetition, 1);
      expect(c.interval, 1);

      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      expect(c.repetition, 2);
      expect(c.interval, 6);
    });
  });

  group('previewInterval', () {
    test('returns the interval that apply would produce', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      c = SrsAlgorithm.apply(c, Quality.good, now: fixedNow);
      expect(SrsAlgorithm.previewInterval(c, Quality.good, now: fixedNow), 15);
      expect(SrsAlgorithm.previewInterval(c, Quality.easy, now: fixedNow), 15);
      expect(SrsAlgorithm.previewInterval(c, Quality.again, now: fixedNow), 1);
    });

    test('for a brand-new card every rating yields 1 day', () {
      final c = newCard();
      for (final q in Quality.values) {
        expect(SrsAlgorithm.previewInterval(c, q, now: fixedNow), 1);
      }
    });
  });

  group('persistence', () {
    test('toJson / fromJson round-trips all fields', () {
      var c = newCard();
      c = SrsAlgorithm.apply(c, Quality.hard, now: fixedNow);
      final json = c.toJson();
      final restored = SrsCard.fromJson(json);
      expect(restored.word, c.word);
      expect(restored.repetition, c.repetition);
      expect(restored.interval, c.interval);
      expect(restored.easinessFactor, c.easinessFactor);
      expect(restored.dueDate, c.dueDate);
      expect(restored.lastReviewed, c.lastReviewed);
      expect(restored.state, c.state);
      expect(restored.lapses, c.lapses);
    });
  });
}
