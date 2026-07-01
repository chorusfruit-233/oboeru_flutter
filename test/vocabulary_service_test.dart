import 'package:flutter_test/flutter_test.dart';
import 'package:oboeru_flutter/models/word.dart';
import 'package:oboeru_flutter/services/vocabulary_service.dart';

void main() {
  group('VocabularyService.generateOptions', () {
    final service = VocabularyService();

    test('returns the only available meaning for a one-word vocabulary', () {
      final word = Word(word: 'apple', pos: 'n', meaning: '苹果');

      final options = service.generateOptions(word, [word]);

      expect(options, ['苹果']);
    });

    test('handles fewer than four words without throwing', () {
      final words = [
        Word(word: 'apple', pos: 'n', meaning: '苹果'),
        Word(word: 'book', pos: 'n', meaning: '书'),
      ];

      final options = service.generateOptions(words.first, words);

      expect(options, hasLength(2));
      expect(options, contains('苹果'));
      expect(options, contains('书'));
    });

    test('deduplicates repeated meanings without throwing', () {
      final words = [
        Word(word: 'big', pos: 'adj', meaning: '大的'),
        Word(word: 'large', pos: 'adj', meaning: '大的'),
        Word(word: 'small', pos: 'adj', meaning: '小的'),
      ];

      final options = service.generateOptions(words.first, words);

      expect(options, hasLength(2));
      expect(options.toSet(), {'大的', '小的'});
    });

    test('returns at most four options and includes the correct meaning', () {
      final words = [
        Word(word: 'apple', pos: 'n', meaning: '苹果'),
        Word(word: 'book', pos: 'n', meaning: '书'),
        Word(word: 'cat', pos: 'n', meaning: '猫'),
        Word(word: 'dog', pos: 'n', meaning: '狗'),
        Word(word: 'egg', pos: 'n', meaning: '鸡蛋'),
      ];

      final options = service.generateOptions(words.first, words);

      expect(options.length, lessThanOrEqualTo(4));
      expect(options, contains('苹果'));
    });
  });
}
