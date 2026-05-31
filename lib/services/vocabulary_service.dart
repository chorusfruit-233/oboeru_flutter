import 'dart:math';
import '../models/word.dart';
import 'storage_service.dart';

class VocabularyService {
  final StorageService _storage = StorageService.instance;

  Future<List<Word>> loadFromFile(String filePath) async {
    if (filePath.endsWith('.json')) {
      return loadFromJsonFile(filePath);
    }
    return loadFromTxtFile(filePath);
  }

  Future<List<Word>> loadFromTxtFile(String filePath) async {
    final lines = await _storage.readVocabFile(filePath);
    return lines.map((line) => Word.fromLine(line)).toList();
  }

  Future<List<Word>> loadFromJsonFile(String filePath) async {
    final data = await _storage.readJson(filePath);
    if (data == null) return [];

    final List<dynamic> wordList;
    if (data is List) {
      wordList = data;
    } else if (data is Map<String, dynamic> && data.containsKey('words')) {
      wordList = data['words'] as List<dynamic>;
    } else {
      return [];
    }

    return wordList
        .map((item) => Word.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<Word> pickDailyWords(List<Word> allWords, int count, bool shuffle) {
    final words = List<Word>.from(allWords);
    if (shuffle) {
      words.shuffle(Random());
    }
    if (words.length > count) {
      return words.sublist(0, count);
    }
    return words;
  }

  List<String> generateOptions(Word correctWord, List<Word> allWords, {int optionCount = 4}) {
    final options = <String>{correctWord.meaning};

    final pool = List<Word>.from(allWords)..shuffle();
    for (final word in pool) {
      if (options.length >= optionCount) break;
      if (word.word != correctWord.word) {
        options.add(word.meaning);
      }
    }

    final result = options.toList()..shuffle();
    return result.sublist(0, optionCount);
  }
}
