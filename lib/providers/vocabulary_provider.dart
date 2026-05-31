import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/vocabulary_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

class VocabularyProvider extends ChangeNotifier {
  final VocabularyService _vocabService = VocabularyService();
  final SettingsService _settingsService = SettingsService();

  List<Word> _allWords = [];
  bool _isLoading = false;
  String? _error;

  List<Word> get allWords => _allWords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWords => _allWords.isNotEmpty;

  Future<void> loadFromFile(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allWords = await _vocabService.loadFromFile(filePath);
    } catch (e) {
      _error = '加载词库失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> importAndLoad(String sourcePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final storage = StorageService.instance;
      final savedPath = await storage.copyVocabToAppDir(sourcePath);
      _allWords = await _vocabService.loadFromFile(savedPath);

      final settings = await _settingsService.load();
      final updated = settings.copyWith(vocabFilePath: savedPath);
      await _settingsService.save(updated);
    } catch (e) {
      _error = '导入词库失败: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _allWords = [];
    notifyListeners();
  }

  Future<void> autoLoad() async {
    final settings = await _settingsService.load();
    final path = settings.vocabFilePath;
    if (path != null && path.isNotEmpty) {
      await loadFromFile(path);
    }
  }
}
