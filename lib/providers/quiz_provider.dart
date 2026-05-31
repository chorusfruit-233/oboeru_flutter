import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/vocabulary_service.dart';

class QuizQuestion {
  final Word word;
  final List<String> options;
  String? selectedAnswer;

  QuizQuestion({required this.word, required this.options, this.selectedAnswer});

  String get correctAnswer => word.meaning;
  bool get isAnswered => selectedAnswer != null;
  bool get isCorrect => selectedAnswer == correctAnswer;

  factory QuizQuestion.fromWord(Word word, List<Word> allWords) {
    final vocabService = VocabularyService();
    final options = vocabService.generateOptions(word, allWords);
    return QuizQuestion(word: word, options: options);
  }
}

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _incorrectCount = 0;
  bool _finished = false;
  List<Word> _reviewWords = [];

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizQuestion? get currentQuestion => _currentIndex < _questions.length ? _questions[_currentIndex] : null;
  int get correctCount => _correctCount;
  int get incorrectCount => _incorrectCount;
  int get totalCount => _questions.length;
  int get answeredCount => _questions.where((q) => q.isAnswered).length;
  bool get finished => _finished;
  bool get allAnswered => _questions.every((q) => q.isAnswered);
  bool get isAnswered => currentQuestion?.isAnswered ?? false;
  bool get hasNext => _currentIndex < _questions.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  List<Word> get incorrectWords => _questions
      .where((q) => q.isAnswered && !q.isCorrect)
      .map((q) => q.word)
      .toList();

  List<Word> get reviewWords => _reviewWords;

  void startQuiz(List<Word> words, List<Word> allWords) {
    _questions = words.map((w) => QuizQuestion.fromWord(w, allWords)).toList();
    _currentIndex = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _finished = false;
    _reviewWords = [];
    notifyListeners();
  }

  bool selectAnswer(String answer) {
    final question = currentQuestion;
    if (question == null || question.isAnswered) return false;

    question.selectedAnswer = answer;
    if (question.isCorrect) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }
    notifyListeners();
    return question.isCorrect;
  }

  void next() {
    if (hasNext) {
      _currentIndex++;
      notifyListeners();
    } else {
      _finished = true;
      _reviewWords = incorrectWords;
      notifyListeners();
    }
  }

  void previous() {
    if (hasPrevious) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void finish() {
    _finished = true;
    notifyListeners();
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _finished = false;
    _reviewWords = [];
    notifyListeners();
  }

  void clearReviewWords() {
    _reviewWords = [];
    notifyListeners();
  }
}
