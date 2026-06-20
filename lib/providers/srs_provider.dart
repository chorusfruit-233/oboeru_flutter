import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/srs_algorithm.dart';
import '../services/srs_service.dart';

class SrsProvider extends ChangeNotifier {
  final SrsService _service = SrsService();

  List<Word> _sessionQueue = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _sessionComplete = false;
  bool _isLoading = false;
  int _sessionReviewed = 0;
  int _sessionAgain = 0;
  SrsStats _stats = const SrsStats();

  List<Word> get sessionQueue => _sessionQueue;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  bool get sessionComplete => _sessionComplete;
  bool get isLoading => _isLoading;
  int get sessionReviewed => _sessionReviewed;
  int get sessionAgain => _sessionAgain;
  int get sessionTotal => _sessionQueue.length;
  int get sessionRemaining =>
      _sessionQueue.length - _currentIndex;

  Word? get currentWord =>
      _currentIndex < _sessionQueue.length ? _sessionQueue[_currentIndex] : null;
  bool get isComplete => _currentIndex >= _sessionQueue.length;
  bool get hasNext => _currentIndex < _sessionQueue.length - 1;

  SrsStats get stats => _stats;
  int get dueCount => _stats.due;
  int get freshCount => _stats.fresh;
  int get learnedCount => _stats.learned;

  bool _hasSession = false;
  bool get hasSession => _hasSession;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await _service.load();
    _isLoading = false;
    notifyListeners();
  }

  void refreshStats(List<Word> allWords) {
    _stats = _service.getStats(allWords);
    notifyListeners();
  }

  Future<void> startSession(
    List<Word> allWords, {
    required int dailyWords,
    required int newCardsPerDay,
    required int maxReviewsPerDay,
    bool shuffle = true,
  }) async {
    final wordMap = {for (final w in allWords) w.word: w};

    final reviewLimit = maxReviewsPerDay > 0 ? maxReviewsPerDay : 1 << 31;
    final dueCards = _service.getDueCards(limit: reviewLimit);
    final reviewWords = <Word>[];
    for (final c in dueCards) {
      final w = wordMap[c.word];
      if (w != null) reviewWords.add(w);
    }

    final remaining = dailyWords - reviewWords.length;
    final newLimit = remaining > 0 ? min(remaining, newCardsPerDay) : 0;
    final newKeys = _service.getNewWordKeys(allWords, newLimit);
    final newWords = newKeys.map((k) => wordMap[k]).whereType<Word>().toList();

    _sessionQueue = [...reviewWords, ...newWords];
    if (shuffle && _sessionQueue.isNotEmpty) {
      _sessionQueue.shuffle();
    }
    _currentIndex = 0;
    _isFlipped = false;
    _sessionComplete = false;
    _sessionReviewed = 0;
    _sessionAgain = 0;
    _hasSession = true;
    notifyListeners();
  }

  void flip() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  Future<void> rate(Quality quality) async {
    final word = currentWord;
    if (word == null) return;
    await _service.recordReview(word.word, quality);
    _sessionReviewed++;
    if (quality == Quality.again) _sessionAgain++;
    _advance();
  }

  void _advance() {
    if (hasNext) {
      _currentIndex++;
      _isFlipped = false;
      notifyListeners();
    } else {
      _sessionComplete = true;
      notifyListeners();
    }
  }

  int previewInterval(String word, Quality quality) {
    final card = _service.getCard(word) ?? SrsAlgorithm.newCard(word);
    return SrsAlgorithm.previewInterval(card, quality);
  }

  String? cardStateLabel(String word) {
    final card = _service.getCard(word);
    if (card == null || card.isNew) return '新词';
    if (card.state.name == 'relearning') return '重学';
    return '复习';
  }

  Future<void> recordQuizResult(String word, bool correct) async {
    await _service.recordReview(word, correct ? Quality.good : Quality.again);
  }

  void reset() {
    _sessionQueue = [];
    _currentIndex = 0;
    _isFlipped = false;
    _sessionComplete = false;
    _sessionReviewed = 0;
    _sessionAgain = 0;
    _hasSession = false;
    notifyListeners();
  }
}
