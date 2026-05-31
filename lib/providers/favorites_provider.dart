import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/favorites_service.dart';

enum FavoriteSortMode { timeAdded, alphabetical }

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();
  List<Word> _favorites = [];
  FavoriteSortMode _sortMode = FavoriteSortMode.timeAdded;
  bool _isLoading = false;

  List<Word> get favorites => _sortedFavorites;
  FavoriteSortMode get sortMode => _sortMode;
  bool get isLoading => _isLoading;
  bool get isEmpty => _favorites.isEmpty;

  List<Word> get _sortedFavorites {
    final sorted = List<Word>.from(_favorites);
    if (_sortMode == FavoriteSortMode.alphabetical) {
      sorted.sort((a, b) => a.word.compareTo(b.word));
    }
    return sorted;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _favorites = await _service.loadFavorites();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggle(Word word) async {
    if (_favorites.any((w) => w.word == word.word)) {
      _favorites.removeWhere((w) => w.word == word.word);
    } else {
      _favorites.add(word);
    }
    await _service.saveFavorites(_favorites);
    notifyListeners();
  }

  bool isFavorite(String word) {
    return _favorites.any((w) => w.word == word);
  }

  Future<void> remove(Word word) async {
    _favorites.removeWhere((w) => w.word == word.word);
    await _service.saveFavorites(_favorites);
    notifyListeners();
  }

  void setSortMode(FavoriteSortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }
}
