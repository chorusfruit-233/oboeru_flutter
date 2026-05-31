import 'package:flutter/foundation.dart';
import '../models/word.dart';

class LearningProvider extends ChangeNotifier {
  List<Word> _todaysWords = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  Set<String> _learnedWords = {};

  List<Word> get todaysWords => _todaysWords;
  int get currentIndex => _currentIndex;
  Word? get currentWord => _currentIndex < _todaysWords.length ? _todaysWords[_currentIndex] : null;
  bool get isFlipped => _isFlipped;
  int get learnedCount => _learnedWords.length;
  int get totalCount => _todaysWords.length;
  bool get hasNext => _currentIndex < _todaysWords.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  bool get isComplete => _currentIndex >= _todaysWords.length;

  void startLearning(List<Word> words) {
    _todaysWords = words;
    _currentIndex = 0;
    _isFlipped = false;
    _learnedWords = {};
    notifyListeners();
  }

  void flip() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void markLearned() {
    if (currentWord != null) {
      _learnedWords.add(currentWord!.word);
    }
  }

  void next() {
    _currentIndex++;
    _isFlipped = false;
    notifyListeners();
  }

  void previous() {
    if (hasPrevious) {
      _currentIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void goToEnd() {
    _currentIndex = _todaysWords.length;
    notifyListeners();
  }

  void reset() {
    _todaysWords = [];
    _currentIndex = 0;
    _isFlipped = false;
    _learnedWords = {};
    notifyListeners();
  }
}
